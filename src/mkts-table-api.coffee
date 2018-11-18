


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE/API'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
MKTS                      = require './main'
MKTS_TABLE                = require './mkts-table'
#...........................................................................................................
jr                        = JSON.stringify
IG                        = require 'intergrid'
UNITS                     = require './mkts-table-units'



#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@create_layout = ( S, meta, id ) ->
  R       = MKTS_TABLE._new_description S
  R.meta  = meta
  R.name  = id
  return R

#-----------------------------------------------------------------------------------------------------------
@set_grid = ( me, size ) ->
  if me.grid?
    return _record_fail me, 'µ5689', "unable to re-define grid"
  switch size.type
    when 'cellkey'
      me.grid = IG.GRID.new_grid_from_cellkey size.value
    else
      throw _stackerr me, 'µ4613', "unknown type for grid size #{rpr size}"
  return null

#-----------------------------------------------------------------------------------------------------------
@set_debug = ( me, toggle ) ->
  switch toggle
    when true   then me.debug = true
    when false  then me.debug = false
    else throw new Error "(MKTS/TABLE µ1343) expected `true` or `false` for mkts-table/debug, got #{rpr toggle}"
  return null

#-----------------------------------------------------------------------------------------------------------
@create_field = ( me, id, selector ) ->
  switch selector.type
    when 'cellkey'
      rangekey    = "#{selector.value}..#{selector.value}"
    when 'rangekey'
      first       = selector.first
      second      = selector.second
      throw new Error "(MKTS/TABLE µ1344) expected a cellkey, got a #{rpr first.type}"  unless first.type is 'cellkey'
      throw new Error "(MKTS/TABLE µ1345) expected a cellkey, got a #{rpr second.type}" unless second.type is 'cellkey'
      rangekey    = "#{first.value}..#{second.value}"
  #.........................................................................................................
  ### TAINT should support using variables etc. ###
  ### aliases     = @_parse_aliases me, aliases ###
  rangeref    = IG.GRID.parse_rangekey me.grid, rangekey
  fieldnr     = ( me._tmp.prv_fieldnr += +1 )
  if me.fieldcells[ fieldnr ]? ### should never happen ###
    throw new Error "(MKTS/TABLE µ5375) unable to redefine field #{fieldnr}: #{rpr source}"
  #.........................................................................................................
  me.fieldcells[ fieldnr ] = rangeref
  for fieldcell from IG.GRID.walk_cells_from_rangeref me.grid, rangeref
    ( me.cellfields[ fieldcell.cellkey ]?= [] ).push fieldnr
  #.........................................................................................................
  ### TAINT should support using variables etc.
  for alias in aliases
    ( me.fieldnrs_by_aliases[ alias ]?= [] ).push fieldnr ###
  if id?
    ( me.fieldnrs_by_aliases[ id ]?= [] ).push fieldnr
  #.........................................................................................................
  @_set_default_gaps me, fieldnr
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_default_gaps = ( me, fieldnr ) ->
  for gap in [ 'fill', 'margins', 'paddings', ]
    for edge in [ 'left', 'right', 'top', 'bottom', ]
      ( me.gaps[ gap ][ fieldnr ]?= {} )[ edge ] = me.default.gaps[ gap ]
  return null

#-----------------------------------------------------------------------------------------------------------
@set_borders = ( me, selectors, edges, style ) ->
  for fieldnr from @walk_fieldnrs_from_selectors me, selectors
    ### TAINT must resolve symbolic edges like `all` ###
    for edge in edges
      throw new Error "µ1240 must resolve symbolic edges like `all`, got #{rpr edge}" unless edge in [ 'left', 'right', 'top', 'bottom', ]
      ( me.fieldborders[ fieldnr ]?= {} )[ edge ] = style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@set_unit_lengths = ( me, value, unit ) ->
  @_set_unit_length me, 'width',   value, unit
  @_set_unit_length me, 'height',  value, unit
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_unit_length = ( me, direction, value, unit ) ->
  unless direction in [ 'width', 'height', ]
    throw new Error "µ1247 expected 'width' or 'height', got #{rpr direction}"
  p = "unit#{direction}"
  #.........................................................................................................
  ### Do nothing if dimension already defined: ###
  if me[ p ]?
    throw new Error "µ1247 unable to re-define unit for #{rpr direction}"
  #.........................................................................................................
  me[ p ] = UNITS.new_quantity value, unit
  return null

#-----------------------------------------------------------------------------------------------------------
@walk_fieldnrs_from_selectors = ( me, selectors ) ->
  seen_fieldnrs = new Set()
  for selector in selectors
    for cellref from @walk_cellrefs_from_selectors me, selectors
      for fieldnr in me.cellfields[ cellref.cellkey ] ? []
        continue if seen_fieldnrs.has fieldnr
        seen_fieldnrs.add fieldnr
        yield fieldnr
  #.........................................................................................................
  yield return
      # unless ( fieldnrs = me.fieldnrs_by_aliases[ term ] )?
      #   throw new Error "(MKTS/TABLE µ5446) unknown alias #{rpr term}"
      # R.add fieldnr for fieldnr in fieldnrs

#-----------------------------------------------------------------------------------------------------------
@walk_cellrefs_from_selectors = ( me, selectors ) ->
  seen_cellkeys = new Set()
  for selector in selectors
    # debug '38393', rpr selector
    switch selector.type
      when 'cellkey'
        for cellref from IG.GRID.walk_cells_from_key me.grid, selector.value
          continue if seen_cellkeys.has cellref.cellkey
          seen_cellkeys.add cellref.cellkey
          yield cellref
      else
        warn '90901', "ignoring selector type #{selector.type}"
  #.........................................................................................................
  yield return


### ***************************************************** ###
### ***************************************************** ###
### ***************************************************** ###
### ***************************************************** ###
### ***************************************************** ###



#-----------------------------------------------------------------------------------------------------------
@_set_lanesizes = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ1249', "expected 'width' or 'height', got #{rpr direction}"
  #.........................................................................................................
  p   = if direction is 'width' then 'colwidth'   else 'rowheight'
  ps  = if direction is 'width' then 'colwidths'  else 'rowheights'
  #.........................................................................................................
  @_ensure_grid me
  lane_count = me.grid[ direction ]
  #.........................................................................................................
  unless ( match = text.match /^(?:(?<selector>[^:]+):)?(?<length>[+\d.]+)$/ )?
    _record_fail me, 'µ6377', "need a text like '2.7', 'A*,C3:20' or similar for mkts-table/#{p}, got #{rpr text}"
    return null
  #.........................................................................................................
  { selector, length, } = match.groups
  length                = parseFloat length
  #.........................................................................................................
  if selector?
    me[ ps ][  0 ]  ?= me.default[ p ] ### set default ###
    me[ ps ][ nr ]  ?= me.default[ p ] for nr in [ 1 .. lane_count ] ### set defaults where missing ###
    for [ fail, lanenr, ] from @_walk_fails_and_lanenrs_from_direction_and_selector me, direction, selector
      if fail? then _record me, fail
      else          me[ ps ][ lanenr ] = length
  else
    me[ ps ][  0 ]  = length ### set default ###
    me[ ps ][ nr ]  = length for nr in [ 1 .. lane_count ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@unitwidth    = ( me, text ) -> @_set_unitsize  me, 'width',    text
@unitheight   = ( me, text ) -> @_set_unitsize  me, 'height',   text
@columnwidth  = ( me, text ) -> @_set_lanesizes me, 'width',    text
@rowheight    = ( me, text ) -> @_set_lanesizes me, 'height',   text


# #-----------------------------------------------------------------------------------------------------------
# @_resolve_aliases = ( me, selector ) ->
#   ### Given a comma-separated string or a list of cellkeys, cellrange literals, and / or aliases, return a
#   list of cellkeys and / or cellrange literals. ###
#   return @_resolve_aliases me, selector.split /\s*,\s*/ if CND.isa_text selector
#   R = new Set()
#   for term in selector
#     if ( CND.isa_text term ) and ( term.startsWith '@' )
#       unless ( fieldnrs = me.fieldnrs_by_aliases[ term ] )?
#         ### TAINT error or failure? ###
#         throw new Error "(MKTS/TABLE µ5446) unknown alias #{rpr term}"
#       R.add fieldnr for fieldnr in fieldnrs
#     else
#       R.add term
#   return [ R... ]

#-----------------------------------------------------------------------------------------------------------
@fieldalignvertical = ( me, text ) ->
  unless ( match = text.match /^(.+?):([^:]+)$/ )?
    throw new Error "(MKTS/TABLE µ5229) expected something like 'C3:top' for mkts-table/fieldalignvertical, got #{rpr text}"
  [ _, selector, value, ] = match
  #.........................................................................................................
  unless value in [ 'top', 'bottom', 'center', 'spread', ]
    throw new Error "(MKTS/TABLE µ1876) expected one of 'top', 'bottom', 'center', 'spread' for mkts-table/fieldalignvertical, got #{rpr value}"
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_fieldnrs_from_selector me, selector
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {field_designation}})"
    else          me.valigns[ field_designation ] = value
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldalignhorizontal = ( me, text ) ->
  unless ( match = text.match /^(.+?):([^:]+)$/ )?
    throw new Error "(MKTS/TABLE µ5229) expected something like 'C3:left' for mkts-table/fieldalignhorizontal, got #{rpr text}"
  [ _, selector, value, ] = match
  #.........................................................................................................
  unless value in [ 'left', 'right', 'center', 'justified', ]
    throw new Error "(MKTS/TABLE µ1876) expected one of 'left', 'right', 'center', 'justified' for mkts-table/fieldalignhorizontal, got #{rpr value}"
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_fieldnrs_from_selector me, selector
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {field_designation}})"
    else          me.haligns[ field_designation ] = value
  #.........................................................................................................
  return null

# #-----------------------------------------------------------------------------------------------------------
# @name = ( me, text ) ->
#   if me.name?
#     throw new Error "(MKTS/TABLE µ1344) refused to rename table layout #{rpr me.name} to #{rpr text}"
#   #.........................................................................................................
#   ### TAINT should check syntax (no whitespace etc) ###
#   me.name = text
#   return null


#-----------------------------------------------------------------------------------------------------------
@margin = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldgap me, 'margin', text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.gaps.margins[ fieldname ]?= {} )[ edge ] = d.length
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@padding = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldgap me, 'padding', text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.gaps.paddings[ fieldname ]?= {} )[ edge ] = d.length
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fill_gap = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldgap me, 'fill', text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.gaps.fill[ fieldname ]?= {} )[ edge ] = d.length
  #.........................................................................................................
  return null



#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
_stackerr = ( me, ref, message, error = null ) ->
  ###
  Prepends local error message to the original one so we get more informative traces. Usage:

  ```
  try
    ...
  catch error
    throw _stackerr error, "(MKTS/TABLE µ4781) ... new message ..."
  ```
  ###
  filename  = me.meta.filename ? '<NOFILENAME>'
  line_nr   = me.meta.line_nr ? '(NOLINENR)'
  message   = "[#{badge}##{ref}: #{filename}##{line_nr}]: #{message}"
  if error?
    error.message = "#{message}\n#{error.message}"
  else
    ### TAINT elide current line from stack trace ###
    error = new Error message
  return error

#-----------------------------------------------------------------------------------------------------------
_fail = ( me, ref, message ) ->
  ### TAINT using strings as error values is generally being frowned upon ###
  filename    = me.meta.filename  ? '<NOFILENAME>'
  line_nr     = me.meta.line_nr   ? '(NOLINENR)'
  return "[#{badge}##{ref}: #{filename}##{line_nr}]: #{message}"

#-----------------------------------------------------------------------------------------------------------
_record = ( me, message ) ->
  me.fails.push message
  return null

#-----------------------------------------------------------------------------------------------------------
_record_fail = ( me, ref, message ) -> _record me, _fail me, ref, message


