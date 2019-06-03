


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
    throw new Error "µ1234 unable to re-define grid"
  switch size.type
    when 'cellkey'
      me.grid = IG.GRID.new_grid_from_cellkey size.value
    else
      throw new Error "µ1235 unknown type for grid size #{rpr size}"
  return null

#-----------------------------------------------------------------------------------------------------------
@set_debug = ( me, toggle ) ->
  switch toggle
    when true   then me.debug = true
    when false  then me.debug = false
    else throw new Error "µ1236 expected `true` or `false` for mkts-table/debug, got #{rpr toggle}"
  return null

#-----------------------------------------------------------------------------------------------------------
@create_field = ( me, id, selector ) ->
  switch selector.type
    when 'cellkey'
      rangekey    = "#{selector.value}..#{selector.value}"
    when 'rangekey'
      first       = selector.first
      second      = selector.second
      throw new Error "(MKTS/TABLE µ1237) expected a cellkey, got a #{rpr first.type}"  unless first.type  is 'cellkey'
      throw new Error "(MKTS/TABLE µ1238) expected a cellkey, got a #{rpr second.type}" unless second.type is 'cellkey'
      rangekey    = "#{first.value}..#{second.value}"
  #.........................................................................................................
  ### TAINT should support using variables etc. ###
  ### aliases     = @_parse_aliases me, aliases ###
  rangeref    = IG.GRID.parse_rangekey me.grid, rangekey
  fieldnr     = ( me._tmp.prv_fieldnr += +1 )
  if me.fieldcells[ fieldnr ]? ### should never happen ###
    throw new Error "(MKTS/TABLE µ1239) unable to redefine field #{fieldnr}: #{rpr source}"
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
@set_borders = ( me, selectors, edges, style ) ->
  for fieldnr from @walk_fieldnrs_from_selectors me, selectors
    target = me.fieldborders[ fieldnr ]?= {}
    for edge in @_expand_edges me, edges
      if style is 'none' then delete  target[ edge ]
      else                            target[ edge ] = style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_expand_edges = ( me, edges ) ->
  for edge in edges
    unless edge in [ 'left', 'right', 'top', 'bottom', 'all', ]
      throw new Error "µ1240 unknown edge #{rpr edge}"
  return [ edges..., ] unless 'all' in edges
  return [ 'left', 'right', 'top', 'bottom', ]

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
@set_background = ( me, selectors, style ) ->
  for fieldnr from @walk_fieldnrs_from_selectors me, selectors
    me.fieldbackgrounds[ fieldnr ] = style
    # target = me.fieldbackgrounds[ fieldnr ]?= {}
    # target.background = style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@set_alignment = ( me, selectors, direction, alignment ) ->
  switch direction
    #.......................................................................................................
    when 'horizontal'
      unless alignment in [ 'left', 'right', 'center', 'justified', ]
        throw new Error "(MKTS/TABLE µ1241) unknown horizontal alignment #{rpr alignment}"
      target = me.haligns
    #.......................................................................................................
    when 'vertical'
      unless alignment in [ 'top', 'bottom', 'center', 'spread', ]
        throw new Error "(MKTS/TABLE µ1242) unknown vertical alignment #{rpr alignment}"
      target = me.valigns
    else
      throw new Error "µ1243 unknown direction #{rpr direction}"
  #.........................................................................................................
  for fieldnr from @walk_fieldnrs_from_selectors me, selectors
    target[ fieldnr ] = alignment
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@set_lane_sizes = ( me, direction, value ) ->
  unless direction in [ 'width', 'height', ]
    throw new Error "µ1249 expected 'width' or 'height', got #{rpr direction}"
  #.........................................................................................................
  p   = if direction is 'width' then 'colwidth'   else 'rowheight'
  ps  = if direction is 'width' then 'colwidths'  else 'rowheights'
  #.........................................................................................................
  @_ensure_grid me
  lane_count = me.grid[ direction ]
  # #.........................................................................................................
  # if selector?
  #   me[ ps ][  0 ]  ?= me.default[ p ] ### set default ###
  #   me[ ps ][ nr ]  ?= me.default[ p ] for nr in [ 1 .. lane_count ] ### set defaults where missing ###
  #   for [ fail, lanenr, ] from @_walk_fails_and_lanenrs_from_direction_and_selector me, direction, selector
  #     if fail? then _record me, fail
  #     else          me[ ps ][ lanenr ] = length
  # else
  me[ ps ][  0 ]  = value ### set default ###
  me[ ps ][ nr ]  = value for nr in [ 1 .. lane_count ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_default_gaps = ( me, fieldnr ) ->
  for gap in [ 'background', 'margins', 'paddings', ]
    for edge in [ 'left', 'right', 'top', 'bottom', ]
      ( me.gaps[ gap ][ fieldnr ]?= {} )[ edge ] = me.default.gaps[ gap ]
  return null

#-----------------------------------------------------------------------------------------------------------
@set_default_gaps = ( me, feature, value ) ->
  unless feature in [ 'border', 'text', 'background', ]
    throw new Error "µ1290 expected one of 'border', 'text', 'background', got #{rpr feature}"
  switch feature
    when 'border'     then me.default.gaps.margins    = value
    when 'text'       then me.default.gaps.paddings   = value
    when 'background' then me.default.gaps.background = value
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@set_field_gaps = ( me, selectors, edges, feature, value ) ->
  switch feature
    when 'border'     then target = me.gaps.margins
    when 'text'       then target = me.gaps.paddings
    when 'background' then target = me.gaps.background
    else throw new Error "µ1290 expected one of 'border', 'text', 'background', got #{rpr feature}"
  for fieldnr from @walk_fieldnrs_from_selectors me, selectors
    sub_target = target[ fieldnr ]?= {}
    for edge in @_expand_edges me, edges
      sub_target[ edge ] = value
  #.........................................................................................................
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@walk_fieldnrs_from_selectors = ( me, selectors ) ->
  seen_fieldnrs = new Set()
  #.........................................................................................................
  for selector in selectors
    switch selector.type
      when 'rangekey'
        rangekey = selector.first.value + '..' + selector.second.value
        for cellref from IG.GRID.walk_cells_from_rangekey me.grid, rangekey
          for fieldnr in me.cellfields[ cellref.cellkey ] ? []
            continue if seen_fieldnrs.has fieldnr
            seen_fieldnrs.add fieldnr
            yield fieldnr
      when 'cellkey'
        for cellref from IG.GRID.walk_cells_from_key me.grid, selector.value
          for fieldnr in me.cellfields[ cellref.cellkey ] ? []
            continue if seen_fieldnrs.has fieldnr
            seen_fieldnrs.add fieldnr
            yield fieldnr
      when 'id'
        for fieldnr in me.fieldnrs_by_aliases[ selector.id ] ? []
          continue if seen_fieldnrs.has fieldnr
          seen_fieldnrs.add fieldnr
          yield fieldnr
      else
        throw new Error "µ1245 ignoring selector type #{selector.type}"
  #.........................................................................................................
  if seen_fieldnrs.size is 0
    throw new Error "µ1244 selectors #{rpr selectors} do not match any field"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@walk_cellrefs_from_selectors = ( me, selectors ) ->
  count         = 0
  seen_cellkeys = new Set()
  #.........................................................................................................
  for selector in selectors
    switch selector.type
      when 'cellkey'
        for cellref from IG.GRID.walk_cells_from_key me.grid, selector.value
          continue if seen_cellkeys.has cellref.cellkey
          seen_cellkeys.add cellref.cellkey
          count += +1
          yield cellref
      when 'id'
        for fieldnr in me.fieldnrs_by_aliases[ selector.id ] ? []
          for cellref from @walk_cellrefs_from_fieldnr me, fieldnr
            continue if seen_cellkeys.has cellref.cellkey
            seen_cellkeys.add cellref.cellkey
            count += +1
            yield cellref
      else
        warn 'µ1245', "ignoring selector type #{selector.type}"
  #.........................................................................................................
  if count is 0
    throw new Error "µ1246 selectors #{rpr selectors} do not match any cell"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@walk_cellrefs_from_fieldnr = ( me, fieldnr ) ->
  unless ( rangeref = me.fieldcells[ fieldnr ] )?
    throw new Error "µ1246 unknown fieldnr #{rpr fieldnr}"
  for cellref from IG.GRID.walk_cells_from_rangeref me.grid, rangeref
    yield cellref
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_ensure_grid = ( me ) ->
  return null if me.grid?
  throw new Error "(MKTS/TABLE µ5307) grid must be set"







