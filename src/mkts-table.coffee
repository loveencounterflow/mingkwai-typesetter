


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
# #...........................................................................................................
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
# $async                    = D.remit_async.bind D
# #...........................................................................................................
# ECS                       = require './eval-cs'
MKTS                      = require './main'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
#...........................................................................................................
copy                      = ( x ) -> Object.assign {}, x
jr                        = JSON.stringify
IG                        = require 'intergrid'
_TMP_BORDERSEGMENTS       = require 'intergrid/lib/experiments/border-segment-finder'
UNITS                     = require './mkts-table-units'


#-----------------------------------------------------------------------------------------------------------
tex = ( source ) -> [ 'tex', source, ]

#-----------------------------------------------------------------------------------------------------------
texr = ( ref, source ) ->
  source = if ref? then "#{source}% MKTSTBL #{ref}\n" else "#{source}%\n"
  return tex source

#-----------------------------------------------------------------------------------------------------------
contains = ( text, pattern ) ->
  switch CND.type_of pattern
    when 'regex' then return ( text.match pattern )?
    else throw new Error "pattern not supported: #{rpr pattern}"
  return null


#===========================================================================================================
# INITIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_new_description = ( S, meta, id ) ->
  R =
    '~isa':               'MKTS/TABLE/description'
    ### TAINT rename field ###
    name:                 id    ? null
    meta:                 meta  ? null
    debug:                false
    ### FTTB, we make a subset of stream state available here: ###
    options:              { layout: S.options.layout, defs: S.options.defs, }
    _tmp:
      prv_fieldnr:          0
    fails:                [] ### recoverable errors / fails warnings ###
    fieldcells:           {} ### field extents in terms of cells, by fieldnrs ###
    fieldnrs_by_aliases:  {} ### lists of fieldnrs indexed by field aliases ###
    cellfields:           {} ### which cells belong to what fields, by cellkeys ###
    table_dimensions:     {} ### width and height of enclosing `\minipage`, in terms of (unitwidth,unitheight) ###
    cell_dimensions:      {}
    fieldborders:         {} ### field borders, as TikZ styles by edges ###
    gaps:
      background:           {} ### gaps between grid and background, by fieldnrs ###
      margins:              {} ### field margins, by fieldnrs ###
      paddings:             {} ### field paddings, by fieldnrs ###
    field_dimensions:     {} ### field extents in terms of (unitwidth,unitheight), by fieldnrs ###
    border_dimensions:    {} ### border extents in terms of (unitwidth,unitheight), by fieldnrs ###
    pod_dimensions:       {} ### pod extents in terms of (unitwidth,unitheight), by fieldnrs ###
    valigns:              {} ### vertical pod alignments, by fieldnrs ###
    haligns:              {} ### horizontal pod alignments, by fieldnrs ###
    colwidths:            [ null, ] ### [ 0 ] is default, [ 1 .. grid.width ] explicit or implicit widths ###
    rowheights:           [ null, ] ### [ 0 ] is default, [ 1 .. grid.height ] explicit or implicit heights ###
    joint_coordinates:    null
    #.......................................................................................................
    styles:
      sThin:              'thin'
      sThick:             'thick'
      sDotted:            'dotted'
      sDashed:            'dashed'
      sRed:               'red'
      sBlack:             'black'
      sDebugCellgrid:     'gray!30,sThin'
      sDebugFieldgrid:    'gray!30,sThin'
      sDebugJoints:       'gray!30,sThick'
    #.......................................................................................................
    default:
      unitwidth:            '1mm'
      unitheight:           '1mm'
      colwidth:             10
      rowheight:            10
      gaps:
        background:           0
        margins:              0
        paddings:             1
  return R


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@_set_unitsize = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ4613', "expected 'width' or 'height', got #{rpr direction}"
  p = "unit#{direction}"
  #.........................................................................................................
  ### Do nothing if dimension already defined: ###
  if me[ p ]?
    return _record_fail me, 'µ5661', "unable to re-define #{p}"
  #.........................................................................................................
  me[ p ] = UNITS.parse_nonnegative_quantity text
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_lanesizes = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ2352', "expected 'width' or 'height', got #{rpr direction}"
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
@grid = ( me, text ) ->
  if me.grid?
    return _record_fail me, 'µ5689', "unable to re-define grid"
  me.grid = IG.GRID.new_grid_from_cellkey text
  return null

#-----------------------------------------------------------------------------------------------------------
@unitwidth    = ( me, text ) -> @_set_unitsize  me, 'width',    text
@unitheight   = ( me, text ) -> @_set_unitsize  me, 'height',   text
@columnwidth  = ( me, text ) -> @_set_lanesizes me, 'width',    text
@rowheight    = ( me, text ) -> @_set_lanesizes me, 'height',   text

#-----------------------------------------------------------------------------------------------------------
@fieldcells = ( me, source ) ->
  @_ensure_grid       me
  #.........................................................................................................
  unless ( match = source.match @fieldcells.source_pattern )?
    _record_fail me, 'µ6379', """need a text like 'A1:B2:"alias"' or similar for mkts-table/#{fieldcell}, got #{rpr source}"""
    return null
  #.........................................................................................................
  { selector, aliases, }  = match.groups
  selector    = selector + '..' + selector unless contains selector, /\.\./
  aliases     = @_parse_aliases me, aliases
  fieldnr     = ( me._tmp.prv_fieldnr += +1 )
  d           = IG.GRID.parse_rangekey me.grid, selector
  if me.fieldcells[ fieldnr ]? ### should never happen ###
    throw new Error "(MKTS/TABLE µ5375) unable to redefine field #{fieldnr}: #{rpr source}"
  #.........................................................................................................
  me.fieldcells[ fieldnr ] = d
  for fieldcell from IG.GRID.walk_cells_from_rangeref me.grid, d
    ( me.cellfields[ fieldcell.cellkey ]?= [] ).push fieldnr
  #.........................................................................................................
  for alias in aliases
    ( me.fieldnrs_by_aliases[ alias ]?= [] ).push fieldnr
  #.........................................................................................................
  @_set_default_gaps me, fieldnr
  return null
@fieldcells.source_pattern = /^\s*(?<selector>[^:\s]+)\s*(?::\s*(?<aliases>\S.+))?\s*$/

#-----------------------------------------------------------------------------------------------------------
@_parse_aliases = ( me, source ) ->
  return [] if ( not source? ) or ( source.length is 0 )
  R = ( part.trim() for part in source.split ',' )
  R.pop() if R[ R.length - 1 ] is ''
  for alias in R
    unless alias[ 0 ] in [ '@', '#', ]
      throw new Error "(MKTS/TABLE µ5376) aliases must be prefixed with '@' or '#', got #{rpr alias}"
  return [ ( new Set R )... ]

#-----------------------------------------------------------------------------------------------------------
@_resolve_aliases = ( me, selector ) ->
  ### TAINT now done in API walk_fieldnrs_from_selectors ###
  ### Given a comma-separated string or a list of cellkeys, cellrange literals, and / or aliases, return a
  list of cellkeys and / or cellrange literals. ###
  return @_resolve_aliases me, selector.split /\s*,\s*/ if CND.isa_text selector
  R = new Set()
  for term in selector
    if ( CND.isa_text term ) and ( ( term.startsWith '@' ) or ( term.startsWith '#' ) )
      unless ( fieldnrs = me.fieldnrs_by_aliases[ term ] )?
        ### TAINT error or failure? ###
        throw new Error "(MKTS/TABLE µ5446) unknown alias #{rpr term}"
      R.add fieldnr for fieldnr in fieldnrs
    else
      R.add term
  return [ R... ]

#-----------------------------------------------------------------------------------------------------------
@_set_default_gaps = ( me, fieldnr ) ->
  for gap in [ 'background', 'margins', 'paddings', ]
    for edge in [ 'left', 'right', 'top', 'bottom', ]
      ( me.gaps[ gap ][ fieldnr ]?= {} )[ edge ] = me.default.gaps[ gap ]
  return null

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

#-----------------------------------------------------------------------------------------------------------
@name = ( me, text ) ->
  if me.name?
    throw new Error "(MKTS/TABLE µ1344) refused to rename table layout #{rpr me.name} to #{rpr text}"
  #.........................................................................................................
  ### TAINT should check syntax (no whitespace etc) ###
  me.name = text
  return null

#-----------------------------------------------------------------------------------------------------------
@debug = ( me, text ) ->
  switch text
    when 'true'   then me.debug = true
    when 'false'  then me.debug = false
    else throw new Error "(MKTS/TABLE µ1343) expected 'true' or 'false' for mkts-table/debug, got #{rpr text}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldborder = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldborder me, text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.fieldborders[ fieldname ]?= {} )[ edge ] = d.style
  #.........................................................................................................
  return null

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
@background_gap = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldgap me, 'background', text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.gaps.background[ fieldname ]?= {} )[ edge ] = d.length
  #.........................................................................................................
  return null


#===========================================================================================================
# PARSERS ETC
#-----------------------------------------------------------------------------------------------------------
@_idx_from_col_and_row = ( col, row ) ->
  unless ( type = CND.type_of col ) is 'text'
    throw new Error "(MKTS/TABLE µ6848) expected a text for col, got a #{rpr type}"
  unless ( type = CND.type_of row ) is 'text'
    throw new Error "(MKTS/TABLE µ1080) expected a text for row, got a #{rpr type}"
  #.........................................................................................................
  col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
  row_idx = ( parseInt row, 10 ) - 1
  return { col: col_idx, row: row_idx, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_fieldborder = ( me, fieldborder ) ->
  unless ( type = CND.type_of fieldborder ) is 'text'
    throw new Error "(MKTS/TABLE µ1225) expected a text for fieldborder, got a #{rpr type}"
  unless ( groups = fieldborder.match /^(.+):(.+):(.*)$/ )?
    throw new Error "(MKTS/TABLE µ2582) expected a fieldborder like 'a1:left:sDashed,sThick', got #{rpr fieldborder}"
  [ _, selector, edges, style, ] = groups
  #.........................................................................................................
  edges       = ( _.trim() for _ in edges.split ',' )
  edges       = [ 'top', 'left', 'bottom', 'right', ] if '*' in edges
  fieldnames  = []
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_fieldnrs_from_selector me, selector
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {field_designation}})"
    else          fieldnames.push field_designation
  #.........................................................................................................
  style = style.trim()
  style = null if style in [ 'none', '', ]
  #.........................................................................................................
  return { fieldnames, edges, style, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
### TAINT unify parsing routines ###
@_parse_fieldgap = ( me, gaptype, source ) ->
  unless ( type = CND.type_of source ) is 'text'
    throw new Error "(MKTS/TABLE µ1225) expected a text for source, got a #{rpr type}"
  #.........................................................................................................
  unless ( match = source.match /^(?<selector>[^:]+):(?<edges>[^:]+):(?<length>-?[+\d.]+)$/ )?
    _record_fail me, 'µ6377', "need a text like 'A*,C3:top:2' or similar for mkts-table/#{gaptype}, got #{rpr source}"
    return null
  #.........................................................................................................
  { selector, edges, length, }  = match.groups
  length                        = parseFloat length
  #.........................................................................................................
  edges       = ( _.trim() for _ in edges.split ',' )
  edges       = [ 'top', 'left', 'bottom', 'right', ] if '*' in edges
  fieldnames  = []
  #.........................................................................................................
  for [ fail, fieldname, ] from @_walk_fails_and_fieldnrs_from_selector me, selector
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {fieldname}})"
    else          fieldnames.push fieldname
  #.........................................................................................................
  return { fieldnames, edges, length, }


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me, selectors_and_content_events, layout_name_stack, field_selector_stack ) ->
  @_compute_cell_dimensions     me
  @_compute_field_dimensions    me
  @_compute_border_dimensions   me
  @_compute_pod_dimensions      me
  @_compute_table_height        me
  #.........................................................................................................
  me._tmp_is_outermost  = layout_name_stack.length < 2
  me._tmp_name          = layout_name_stack.join '/'
  ### Preparatory ###
  yield from @_walk_opening_events                      me, layout_name_stack, field_selector_stack
  yield from @_walk_style_events                        me ### TAINT should write to document preamble ###
  #.........................................................................................................
  ### Borders, content ###
  yield from @_walk_field_borders_events                me
  yield from @_walk_pod_events                          me, selectors_and_content_events
  #.........................................................................................................
  ### Debugging ### ### TAINT should make ordering configurable so we can under- or overprint debugging ###
  yield from @_walk_debug_joints_events                 me
  yield from @_walk_debug_cellgrid_events               me
  yield from @_walk_debug_fieldgrid_events              me
  #.........................................................................................................
  ### Finishing ###
  yield from @_walk_closing_events                      me
  yield from @_convert_fails_to_warnings                me
  #.........................................................................................................
  # ### dump description for debugging ###
  # ### TAINT make dump configurable ###
  # ### TAINT print in smaller type ###
  # yield [ 'tex', '\\par{}', ]
  # yield [ 'text', "MKTS Table Description:\n\n", ( copy me.meta ), ]
  # yield [ '(', 'code', [],                       ( copy me.meta ), ]
  # yield [ '.', 'text', ( rpr me ),               ( copy me.meta ), ]
  # yield [ ')', 'code', [],                       ( copy me.meta ), ]
  # yield [ 'tex', '\\par{}', ]
  #.........................................................................................................
  delete me._tmp_name
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_opening_events = ( me, layout_name_stack, field_selector_stack ) ->
  @_ensure_unitvector me
  layout_name                 = me.name
  me._tmp.unitwidth_txt       = UNITS.as_text me.unitwidth
  me._tmp.unitheight_txt      = UNITS.as_text me.unitheight
  me._tmp.table_height_txt    = UNITS.as_text me.unitheight, '*', me.table_dimensions.height
  me._tmp.table_width_txt     = UNITS.as_text me.unitwidth,  '*', me.table_dimensions.width
  ### TAINT in order to be used in \vspace, must subtract equivalent of one \mktsLineheight; in order te
  used in \mktsVspace, must subtract one. ###
  me._tmp.table_height_lh     = UNITS.integer_multiple me._tmp.table_height_txt, me.options.layout.lineheight
  me._tmp.table_height_lh_txt = UNITS.as_text me._tmp.table_height_lh
  ### TAINT valign center, top, bottom do not work well for nested tables; need dimensions of enclosing
  field to introduce explicit vertical spaces ###
  yield tex "\n\n"
  yield tex "% ==========================================================================================================\n"
  yield tex "% Beginning of MKTS Table (layout: #{rpr layout_name})\n"
  # yield tex "\\par% Beginning of MKTS Table (layout: #{rpr layout_name})\n"
  yield texr 'ð1000', "{\\setlength{\\fboxsep}{0mm}"
  yield texr 'ð1001', "\\mktsColorframebox{green}{% debugging framebox" if me.debug
  yield texr 'ð1002', "\\begin{minipage}[t][#{me._tmp.table_height_txt}][t]{#{me._tmp.table_width_txt}}"
  yield texr 'ð1003', "\\begin{tikzpicture}[ overlay, yshift = 0mm, yscale = -1, line cap = rect ]"
  yield texr 'ð1004', "\\tikzset{x=#{me._tmp.unitwidth_txt}};\\tikzset{y=#{me._tmp.unitheight_txt}};"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  layout_name = me.name
  yield texr 'ð1005', "\\end{tikzpicture}"
  yield texr 'ð1006', "\\end{minipage}}"
  yield texr 'ð1007', "}% debugging framebox" if me.debug
  # yield texr 'ð1008', "\\mktsVspace{1}"
  yield texr 'ð1000', "\\vspace{#{me._tmp.table_height_lh_txt}}" ### TAINT should use `\mktsVspace` ###
  yield tex "\\par% End of MKTS Table (layout: #{rpr layout_name})\n"
  yield tex "% ==========================================================================================================\n"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_style_events = ( me ) ->
  for key, value of me.styles
    yield texr 'ð1009', "\\tikzset{#{key}/.style={#{value}}}"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_field_borders_events = ( me ) ->
  #.........................................................................................................
  for fieldnr, d of me.border_dimensions
    continue unless ( borders = me.fieldborders[ fieldnr ] )?
    for i from _TMP_BORDERSEGMENTS.walk_segments fieldnr, borders
      # urge '33455', "#{me.name}/#{fieldnr}", jr i
      yield texr 'ð1010', "%>>> #{me.name}/#{fieldnr} #{jr i}% #{fieldnr} border "
      switch i.mode
        when 'rectangle'
          yield texr 'ð1011', "\\draw[#{i.style}] (#{d.left},#{d.top}) rectangle (#{d.right},#{d.bottom});% #{fieldnr} border "
        when 'single'
          ### TAINT refactor to method ###
          edge  = i.edges[ 0 ]
          v     = @_line_xy_from_edge_and_dimensions edge, d
          yield texr 'ð1012', "\\draw[#{i.style}] (#{v.from.x},#{v.from.y}) -- (#{v.to.x},#{v.to.y});% #{fieldnr} #{edge} "
        when 'connect'
          v     = @_line_xy_from_edge_and_dimensions i.edges[ 0 ], d
          parts = [ "\\draw[#{i.style}] (#{v.from.x},#{v.from.y})", ]
          for edge in i.edges
            v = @_line_xy_from_edge_and_dimensions edge, d
            parts.push "(#{v.to.x},#{v.to.y})"
          yield texr 'ð1013', ( parts.join ' -- ' ) + ';'
        else
          throw new Error "(MKTS/TABLE µ4801) unknown border instruction mode #{rpr i.mode} in table #{me.name}/#{fieldnr} #{jr i}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_line_xy_from_edge_and_dimensions = ( edge, d ) ->
  return switch edge
    when 'left'   then { from: { x: d.left,  y: d.bottom, },  to: { x: d.left,  y: d.top,     }, }
    when 'top'    then { from: { x: d.left,  y: d.top,    },  to: { x: d.right, y: d.top,     }, }
    when 'right'  then { from: { x: d.right, y: d.top,    },  to: { x: d.right, y: d.bottom,  }, }
    when 'bottom' then { from: { x: d.right, y: d.bottom, },  to: { x: d.left,  y: d.bottom,  }, }
    else throw new Error "(MKTS/TABLE µ4800) illegal value for edge #{rpr edge}"

#-----------------------------------------------------------------------------------------------------------
@_get_halign_tex = ( me, halign ) ->
  return switch halign
    when 'left'       then '\\mktsLeft{}'
    when 'right'      then '\\mktsRight{}'
    when 'center'     then '\\mktsCenter{}'
    when 'justified'  then ''
    else throw new Error "(MKTS/TABLE µ4799) illegal value for halign #{rpr halign}"

#-----------------------------------------------------------------------------------------------------------
@_get_valign_tex = ( me, valign ) ->
  return switch valign
    when 'top'    then 't'
    when 'bottom' then 'b'
    when 'center' then 'c'
    when 'spread' then 's'
    else throw new Error "(MKTS/TABLE µ4799) illegal value for valign #{rpr valign}"

#-----------------------------------------------------------------------------------------------------------
@_walk_pod_events = ( me, selectors_and_content_events ) ->
  for [ selector, content..., ] from @_walk_most_recent_field_designations me, selectors_and_content_events
    # debug '88733', selector, content if me.name is 'small-table'
    continue if content.length is 0
    d                 = me.pod_dimensions[ selector ]
    pod_height_txt    = UNITS.as_text me.unitheight,  '*', d.height
    pod_width_txt     = UNITS.as_text me.unitwidth,   '*', d.width
    # ### TAINT faulty, should look at whether sub-table is only content, then set valign to top ###
    # if me._tmp_is_outermost then  valign_tex  = @_get_valign_tex me, me.valigns[ selector ] ? me.valigns[ '*' ] ? 'center'
    # else                          valign_tex  = @_get_valign_tex me, 'top'
    valign_tex  = @_get_valign_tex me, me.valigns[ selector ] ? me.valigns[ '*' ] ? 'center'
    halign_tex  = @_get_halign_tex me, me.haligns[ selector ] ? me.haligns[ '*' ] ? 'left'
    _ref = " field #{me._tmp_name}:#{selector} "
    yield texr 'ð1014', "\\node[anchor=north west,inner sep=0mm] at (#{d.left},#{d.top}) {%#{_ref}"
    yield texr 'ð1015', "\\mktsColorframebox{orange}{%#{_ref} debugging sub-framebox " if me.debug
    yield texr 'ð1016', "\\begin{minipage}[t][#{pod_height_txt}][#{valign_tex}]{#{pod_width_txt}}#{halign_tex}%#{_ref}"
    yield [ '.', 'noindent', null, {}, ]
    yield sub_event for sub_event in content
    if me.debug
      yield texr 'ð1017', "\\end{minipage}}};%#{_ref} debugging sub-framebox"
    else
      yield texr 'ð1018', "\\end{minipage}};%#{_ref}"
  #.........................................................................................................
  yield return


#===========================================================================================================
# EVENT GENERATORS: DEBUGGING EVENTS
#-----------------------------------------------------------------------------------------------------------
@_should_debug = ( me ) -> me.debug or ( me.fails.length != 0 )

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_cellgrid_events = ( me ) ->
  unless @_should_debug me
    yield return
  #.........................................................................................................
  yield texr 'ð1019', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  top       = ( @_top_from_rownr     me, 1              )
  bottom    = ( @_bottom_from_rownr  me, me.grid.height )
  for colnr in [ 1 .. me.grid.width + 1 ]
    x = @_left_from_colnr me, colnr
    yield texr 'ð1020', "\\draw[sDebugCellgrid] (#{x},#{top}) -- (#{x},#{bottom});"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  left      = ( @_left_from_colnr    me, 1              )
  right     = ( @_right_from_colnr   me, me.grid.width  )
  for rownr in [ 1 .. me.grid.height + 1 ]
    y = @_top_from_rownr me, rownr
    yield texr 'ð1021', "\\draw[sDebugCellgrid] (#{left},#{y}) -- (#{right},#{y});"
  #.........................................................................................................
  yield texr 'ð1022', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_fieldgrid_events = ( me ) ->
  unless @_should_debug me
    yield return
  #.........................................................................................................
  yield texr 'ð1023', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  for designation, d of me.field_dimensions
    ### TAINT use fixed size like 1mm ###
    left   = d.left   + 0.5
    right  = d.right  - 0.5
    top    = d.top    + 0.5
    bottom = d.bottom - 0.5
    yield [ 'tex', "\\draw[sDebugFieldgrid] (#{left},#{bottom})" \
                 + " -- (#{left},#{top})"                       \
                 + " -- (#{right},#{top});", ]
    yield [ 'tex', " \\draw[sDebugFieldgrid] (#{right},#{top}) " \
                 + " -- (#{right},#{bottom});", ]
    yield [ 'tex', " \\draw[sDebugFieldgrid] (#{left},#{bottom}) " \
                 + " -- (#{right},#{bottom});", ]
    yield [ 'tex', "% MKTSTBL@26\n", ]
  #.........................................................................................................
  yield texr 'ð1024', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
  unless @_should_debug me
    yield return
  @_ensure_grid me
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  yield texr 'ð1025', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  for [ colletters, colnr, ] from IG.GRID.walk_colletters_and_colnrs me.grid
    for rownr from IG.GRID.walk_rownrs me.grid
      x = ( @_left_from_colnr  me, colnr ) + 2
      y = ( @_top_from_rownr   me, rownr ) + 2
      cellkey = "#{colletters}#{rownr}"
      yield tex "\\node[sDebugJoints] at (#{x},#{y}) {{\\mktsStyleCode{}#{cellkey}}}; "
  #.........................................................................................................
  yield texr 'ð1026', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_convert_fails_to_warnings = ( me ) ->
  for fail in me.fails
    yield [ '.', 'warning', fail, ( copy me.meta ), ]
    yield [ 'tex', '\\par\n', ]
  yield return


#===========================================================================================================
# ENSURERS
#-----------------------------------------------------------------------------------------------------------
@_ensure_unitvector = ( me ) ->
  @unitwidth  me, me.default.unitwidth   unless me.unitwidth?
  @unitheight me, me.default.unitheight  unless me.unitheight?
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_joint_coordinates = ( me ) ->
  return null if me.joint_coordinates?
  @_ensure_cellwidths   me
  @_ensure_cellheights  me
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_grid = ( me ) ->
  return null if me.grid?
  throw new Error "(MKTS/TABLE µ5307) grid must be set"

#-----------------------------------------------------------------------------------------------------------
@_ensure_cellwidths = ( me ) ->
  return null if ( me.colwidths.length is me.grid.width + 1 ) and ( null not in me.colwidths[ 1 .. ] )
  throw new Error "(MKTS/TABLE µ4039) colwidths must be all set; got #{rpr me.colwidths}"

#-----------------------------------------------------------------------------------------------------------
@_ensure_cellheights = ( me ) ->
  return null if ( me.rowheights.length is me.grid.height + 1 ) and ( null not in me.rowheights[ 1 .. ] )
  throw new Error "(MKTS/TABLE µ8054) rowheights must be all set; got #{rpr me.rowheights}"

#-----------------------------------------------------------------------------------------------------------
@_compute_cell_dimensions = ( me ) ->
  @_ensure_grid me
  for [ colletters, colnr, ] from IG.GRID.walk_colletters_and_colnrs me.grid
    for rownr from IG.GRID.walk_rownrs me.grid
      designation   = "#{colletters}#{rownr}"
      left   = @_left_from_colnr   me, colnr
      right  = @_right_from_colnr  me, colnr
      top    = @_top_from_rownr    me, rownr
      bottom = @_bottom_from_rownr me, rownr
      me.cell_dimensions[ designation ] = {
        colnr,         rownr,
        left,    right,
        top,     bottom, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_field_dimensions = ( me ) ->
  ### TAINT use me.field_dimensions ###
  for designation, fieldcells of me.fieldcells
    left   = ( @_left_from_colnr   me, fieldcells.left_colnr    )
    right  = ( @_right_from_colnr  me, fieldcells.right_colnr   )
    top    = ( @_top_from_rownr    me, fieldcells.top_rownr     )
    bottom = ( @_bottom_from_rownr me, fieldcells.bottom_rownr  )
    width       = right  - left
    height      = bottom - top
    me.field_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_border_dimensions = ( me ) ->
  ### TAINT code duplication ###
  for designation, d of me.field_dimensions
    unless ( target = me.gaps.margins[ designation ] )?
      throw new Error "(MKTS/TABLE µ8054) unknown field designation #{rpr designation}"
    left   = d.left   + target.left
    right  = d.right  - target.right
    top    = d.top    + target.top
    bottom = d.bottom - target.bottom
    ### TAINT must not become negative ###
    width       = right  - left
    height      = bottom - top
    me.border_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_pod_dimensions = ( me ) ->
  ### TAINT code duplication ###
  for designation, d of me.field_dimensions
    unless ( target = me.gaps.paddings[ designation ] )?
      throw new Error "(MKTS/TABLE µ8054) unknown field designation #{rpr designation}"
    left   = d.left   + target.left
    right  = d.right  - target.right
    top    = d.top    + target.top
    bottom = d.bottom - target.bottom
    ### TAINT must not become negative ###
    width       = right  - left
    height      = bottom - top
    me.pod_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_table_height = ( me ) ->
  me.table_dimensions.height  = @_bottom_from_rownr me, me.grid.height
  me.table_dimensions.width   = @_right_from_colnr  me, me.grid.width
  return null

#-----------------------------------------------------------------------------------------------------------
@_left_from_colnr = ( me, colnr ) ->
  ### TAINT should precompute ###
  @_ensure_cellwidths me
  R = 0
  R += me.colwidths[ nr ] for nr in [ 1 ... colnr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_right_from_colnr = ( me, colnr ) ->
  return ( @_left_from_colnr me, colnr ) + me.colwidths[ colnr ]

#-----------------------------------------------------------------------------------------------------------
@_top_from_rownr = ( me, rownr ) ->
  ### TAINT should precompute ###
  @_ensure_cellheights me
  R = 0
  R += me.rowheights[ nr ] for nr in [ 1 ... rownr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_bottom_from_rownr = ( me, rownr ) ->
  return ( @_top_from_rownr me, rownr ) + me.rowheights[ rownr ]


#===========================================================================================================
# ITERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_fails_and_fieldnrs_from_selector = ( me, selector ) ->
  ### TAINT this will have to be changed to allow for named fields ###
  count                   = 0
  seen_fieldnrs           = new Set()
  selector                = @_resolve_aliases me, selector
  #.........................................................................................................
  ### TAINT must resolve aliases ###
  for term in selector
    if CND.isa_text term
      for cell from IG.GRID.walk_cells_from_selector me.grid, selector
        continue unless ( fieldnrs = me.cellfields[ cell.cellkey ] )?
        for fieldnr in fieldnrs
          ### TAINT code duplication ###
          continue if seen_fieldnrs.has fieldnr
          seen_fieldnrs.add fieldnr
          count += +1
          yield [ null, fieldnr, ]
    else
      fieldnr = term
      ### TAINT code duplication ###
      continue if seen_fieldnrs.has fieldnr
      seen_fieldnrs.add fieldnr
      count += +1
      yield [ null, fieldnr, ]
  #.........................................................................................................
  if count is 0
    yield [ ( _fail me, 'µ5131', "selector #{rpr selector} does not match any field" ), null ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_fails_and_lanenrs_from_direction_and_selector = ( me, direction, selector ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ4656', "expected 'width' or 'height', got #{rpr direction}"
  #.........................................................................................................
  count         = 0
  seen_lanenrs  = new Set()
  p             = if direction is 'width' then 'colnr' else 'rownr'
  #.........................................................................................................
  ### TAINT should implement this in intergrid ###
  for cell from IG.GRID.walk_cells_from_selector me.grid, selector
    lanenr = cell[ p ]
    continue if seen_lanenrs.has lanenr
    seen_lanenrs.add lanenr
    count += +1
    yield [ null, lanenr, ]
  #.........................................................................................................
  if count is 0
    ### should never happen ###
    yield [ ( _fail me, 'µ5131', "selector #{rpr selector} doesn't match any lane" ), null ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_most_recent_field_designations = ( me, fieldhints_and_stuff ) ->
  ### Given a list of `[ fieldhints, x... ]` lists, return a list of `[ designation, x... ]` lists such
  that each `designation` that resulted from each of the `fieldhints` is only kept from the instance
  that appeared last in the list. Each `fieldhints` can produce an arbitrary number of matching field
  designations, and later occurrences of a given field will replace earlier appearances. ###
  R = {}
  for [ fieldhints, stuff..., ] in fieldhints_and_stuff
    for [ fail, field_designation, ] from @_walk_fails_and_fieldnrs_from_selector me, fieldhints
      if fail? then _record me, fail
      else          R[ field_designation ]  = stuff
  yield [ field_designation, stuff..., ] for field_designation, stuff of R
  yield return

# #-----------------------------------------------------------------------------------------------------------
# @_walk_table_edge_field_designations = ( me, edge ) ->
#   seen_field_designations = new Set()
#   for d from IG.GRID.walk_edge_cellrefs me.grid, edge
#     continue unless ( field_designations = me.cellfields[ d.cellkey ] )?
#     for field_designation in field_designations
#       continue if seen_field_designations.has field_designation
#       seen_field_designations.add field_designation
#       yield field_designation
#   yield return


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
  filename  = me.meta?.filename ? '<NOFILENAME>'
  line_nr   = me.meta?.line_nr ? '(NOLINENR)'
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
  filename    = me.meta?.filename  ? '<NOFILENAME>'
  line_nr     = me.meta?.line_nr   ? '(NOLINENR)'
  return "[#{badge}##{ref}: #{filename}##{line_nr}]: #{message}"

#-----------------------------------------------------------------------------------------------------------
_record = ( me, message ) ->
  me.fails.push message
  return null

#-----------------------------------------------------------------------------------------------------------
_record_fail = ( me, ref, message ) -> _record me, _fail me, ref, message


