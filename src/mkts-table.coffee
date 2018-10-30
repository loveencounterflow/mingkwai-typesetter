


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
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
ECS                       = require './eval-cs'
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
@_new_description = ( S ) ->
  R =
    '~isa':               'MKTS/TABLE/description'
    name:                 null
    debug:                false
    fails:                [] ### recoverable errors / fails warnings ###
    fieldcells:           {} ### field extents in terms of cells, by field designations ###
    cellfields:           {} ### which cells belong to what fields, by cellkeys ###
    table_dimensions:     {} ### width and height of enclosing `\minipage`, in terms of (unitwidth,unitheight) ###
    cell_dimensions:      {}
    fieldborders:         {} ### field borders, as TikZ styles by edges ###
    margins:              {} ### field margins, by field designations ###
    paddings:             {} ### field paddings, by field designations ###
    field_dimensions:     {} ### field extents in terms of (unitwidth,unitheight), by field designations ###
    border_dimensions:    {} ### border extents in terms of (unitwidth,unitheight), by field designations ###
    pod_dimensions:       {} ### pod extents in terms of (unitwidth,unitheight), by field designations ###
    valigns:              {} ### vertical pod alignments, by field designations ###
    haligns:              {} ### horizontal pod alignments, by field designations ###
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
      margin:               0
      padding:              1
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
@fieldcells = ( me, text ) ->
  @_ensure_grid       me
  @_ensure_unitvector me
  text        = text + '..' + text unless contains text, /\.\./
  d           = IG.GRID.parse_rangekey me.grid, text
  designation = IG.CELLS.get_cellkey { colnr: d.left_colnr, rownr: d.top_rownr, }
  ### TAINT we should allow multiple fields with same designation ###
  if me.fieldcells[ designation ]?
    throw new Error "(MKTS/TABLE µ5375) unable to redefine field #{designation}: #{rpr text}"
  #.........................................................................................................
  me.fieldcells[ designation ] = d
  for fieldcell from IG.GRID.walk_cells_from_rangeref me.grid, d
    ( me.cellfields[ fieldcell.cellkey ]?= [] ).push designation
  #.........................................................................................................
  @_set_default_gaps me, designation
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_default_gaps = ( me, designation ) ->
  for gap in [ 'margin', 'padding', ]
    p = gap + 's'
    for edge in [ 'left', 'right', 'top', 'bottom', ]
      ( me[ p ][ designation ]?= {} )[ edge ] = me.default[ gap ]
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldalignvertical = ( me, text ) ->
  unless ( match = text.match /^(.+?):([^:]+)$/ )?
    throw new Error "(MKTS/TABLE µ5229) expected something like 'C3:top' for mkts-table/fieldalignvertical, got #{rpr text}"
  [ _, fieldhints, value, ] = match
  #.........................................................................................................
  unless value in [ 'top', 'bottom', 'center', 'spread', ]
    throw new Error "(MKTS/TABLE µ1876) expected one of 'top', 'bottom', 'center', 'spread' for mkts-table/fieldalignvertical, got #{rpr value}"
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_field_designations_from_hints me, fieldhints
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {field_designation}})"
    else          me.valigns[ field_designation ] = value
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldalignhorizontal = ( me, text ) ->
  unless ( match = text.match /^(.+?):([^:]+)$/ )?
    throw new Error "(MKTS/TABLE µ5229) expected something like 'C3:left' for mkts-table/fieldalignhorizontal, got #{rpr text}"
  [ _, fieldhints, value, ] = match
  #.........................................................................................................
  unless value in [ 'left', 'right', 'center', 'justified', ]
    throw new Error "(MKTS/TABLE µ1876) expected one of 'left', 'right', 'center', 'justified' for mkts-table/fieldalignhorizontal, got #{rpr value}"
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_field_designations_from_hints me, fieldhints
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
      ( me.margins[ fieldname ]?= {} )[ edge ] = d.length
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@padding = ( me, text ) ->
  ### TAINT code duplication ###
  d = @_parse_fieldgap me, 'padding', text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.paddings[ fieldname ]?= {} )[ edge ] = d.length
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
  [ _, fieldhints, edges, style, ] = groups
  #.........................................................................................................
  edges       = ( _.trim() for _ in edges.split ',' )
  edges       = [ 'top', 'left', 'bottom', 'right', ] if '*' in edges
  fieldnames  = []
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_fails_and_field_designations_from_hints me, fieldhints
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
  for [ fail, fieldname, ] from @_walk_fails_and_field_designations_from_hints me, selector
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {fieldname}})"
    else          fieldnames.push fieldname
  #.........................................................................................................
  return { fieldnames, edges, length, }


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me, selectors_and_content_events, layout_name_stack ) ->
  @_compute_cell_dimensions     me
  @_compute_field_dimensions    me
  @_compute_border_dimensions   me
  @_compute_pod_dimensions      me
  @_compute_table_height        me
  #.........................................................................................................
  me._tmp_is_outermost  = layout_name_stack.length < 2
  me._tmp_name          = layout_name_stack.join '/'
  ### Preparatory ###
  yield from @_walk_opening_events                      me
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
@_walk_opening_events = ( me ) ->
  @_ensure_unitvector me
  layout_name       = me.name
  unitwidth_txt     = UNITS.as_text me.unitwidth
  unitheight_txt    = UNITS.as_text me.unitheight
  table_height_txt  = UNITS.as_text me.unitheight, '*', me.table_dimensions.height
  yield tex "\n\n"
  yield tex "% ==========================================================================================================\n"
  yield tex "\\par% Beginning of MKTS Table (layout: #{rpr layout_name})\n"
  yield texr 'ð1', "{\\setlength{\\fboxsep}{0mm}"
  yield texr 'ð2', "\\mktsColorframebox{green}{% debugging framebox" if me.debug
  ### NOTE only height of minipage is important; TikZ will happily draw outside of minipage when told ###
  ### TAINT calculate proper height so text will keep register ###
  yield texr 'ð5', "\\begin{minipage}[t][#{table_height_txt}][t]{\\linewidth}"
  yield texr 'ð6', "\\begin{tikzpicture}[ overlay, yshift = 0mm, yscale = -1, line cap = rect ]"
  yield texr 'ð7', "\\tikzset{x=#{unitwidth_txt}};\\tikzset{y=#{unitheight_txt}};"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  layout_name = me.name
  yield texr 'ð8', "\\end{tikzpicture}"
  yield texr 'ð9', "\\end{minipage}}"
  yield texr 'ð10', "}% debugging framebox" if me.debug
  yield texr 'ð11', "\\mktsVspace{1}"
  yield tex "\\par% End of MKTS Table (layout: #{rpr layout_name})\n"
  yield tex "% ==========================================================================================================\n"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_style_events = ( me ) ->
  for key, value of me.styles
    yield texr 'ð12', "\\tikzset{#{key}/.style={#{value}}}"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_field_borders_events = ( me ) ->
  #.........................................................................................................
  for designation, d of me.border_dimensions
    continue unless ( fieldborders = me.fieldborders[ designation ] )?
    if ( borderstyle = fieldborders[ 'left' ] )?
      yield texr 'ð13', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.left},#{d.bottom});% #{designation} left "
    if ( borderstyle = fieldborders[ 'right' ] )?
      yield texr 'ð14', "\\draw[#{borderstyle}] (#{d.right},#{d.top}) -- (#{d.right},#{d.bottom});% #{designation} right "
    if ( borderstyle = fieldborders[ 'top' ] )?
      yield texr 'ð15', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.right},#{d.top});% #{designation} top "
    if ( borderstyle = fieldborders[ 'bottom' ] )?
      yield texr 'ð16', "\\draw[#{borderstyle}] (#{d.left},#{d.bottom}) -- (#{d.right},#{d.bottom});% #{designation} bottom "
  #.........................................................................................................
  yield return

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
    yield texr 'ð17', "\\node[anchor=north west,inner sep=0mm] at (#{d.left},#{d.top}) {%#{_ref}"
    yield texr 'ð18', "\\mktsColorframebox{orange}{%#{_ref} debugging sub-framebox " if me.debug
    yield texr 'ð19', "\\begin{minipage}[t][#{pod_height_txt}][#{valign_tex}]{#{pod_width_txt}}#{halign_tex}%#{_ref}"
    yield [ '.', 'noindent', null, {}, ]
    yield sub_event for sub_event in content
    if me.debug
      yield texr 'ð20', "\\end{minipage}}};%#{_ref} debugging sub-framebox"
    else
      yield texr 'ð21', "\\end{minipage}};%#{_ref}"
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
  yield texr 'ð22', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  top       = ( @_top_from_rownr     me, 1             ) - 3
  bottom    = ( @_bottom_from_rownr  me, me.grid.height ) + 3
  for colnr in [ 1 .. me.grid.width + 1 ]
    x = @_left_from_colnr me, colnr
    yield texr 'ð23', "\\draw[sDebugCellgrid] (#{x},#{top}) -- (#{x},#{bottom});"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  left      = ( @_left_from_colnr    me, 1             ) - 3
  right     = ( @_right_from_colnr   me, me.grid.width  ) + 3
  for rownr in [ 1 .. me.grid.height + 1 ]
    y = @_top_from_rownr me, rownr
    yield texr 'ð24', "\\draw[sDebugCellgrid] (#{left},#{y}) -- (#{right},#{y});"
  #.........................................................................................................
  yield texr 'ð25', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_fieldgrid_events = ( me ) ->
  unless @_should_debug me
    yield return
  #.........................................................................................................
  yield texr 'ð26', "\\begin{scope}[on background layer]"
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
  yield texr 'ð27', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
  unless @_should_debug me
    yield return
  @_ensure_grid me
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  yield texr 'ð28', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  for [ colletters, colnr, ] from IG.GRID.walk_colletters_and_colnrs me.grid
    for rownr from IG.GRID.walk_rownrs me.grid
      x = ( @_left_from_colnr  me, colnr ) + 2
      y = ( @_top_from_rownr   me, rownr ) + 2
      cellkey = "#{colletters}#{rownr}"
      yield tex "\\node[sDebugJoints] at (#{x},#{y}) {{\\mktsStyleCode{}#{cellkey}}}; "
  #.........................................................................................................
  yield texr 'ð29', "\\end{scope}"
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
    unless ( target = me.margins[ designation ] )?
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
    unless ( target = me.paddings[ designation ] )?
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
  me.table_dimensions.width   = null ### not used ATM, all tables are nominally as wide as column ###
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
@_walk_fails_and_field_designations_from_hints = ( me, fieldhints ) ->
  ### TAINT this will have to be changed to allow for named fields ###
  count                   = 0
  seen_field_designations = new Set()
  #.........................................................................................................
  for cell from IG.GRID.walk_cells_from_selector me.grid, fieldhints
    continue unless ( field_designations = me.cellfields[ cell.cellkey ] )?
    for field_designation in field_designations
      continue if seen_field_designations.has field_designation
      seen_field_designations.add field_designation
      count += +1
      yield [ null, field_designation, ]
  #.........................................................................................................
  if count is 0
    yield [ ( _fail me, 'µ5131', "field hint #{rpr fieldhints} do not match any field" ), null ]
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
    for [ fail, field_designation, ] from @_walk_fails_and_field_designations_from_hints me, fieldhints
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


