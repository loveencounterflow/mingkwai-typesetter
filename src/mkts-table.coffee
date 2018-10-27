


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
      marginwidth:          0
      marginheight:         0
      paddingwidth:         0
      paddingheight:        0
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
  me[ p ] = text
  return null

#-----------------------------------------------------------------------------------------------------------
@_set_lanesizes = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ2352', "expected 'width' or 'height', got #{rpr direction}"
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
      ### TAINT ad-hoc fail message production, use method ###
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
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldborder = ( me, text ) ->
  d = @_parse_fieldborder me, text
  for fieldname in d.fieldnames
    for edge in d.edges
      ( me.fieldborders[ fieldname ]?= {} )[ edge ] = d.style
  #.........................................................................................................
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
@marginwidth = ( me, text ) ->
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@marginheight = ( me, text ) ->
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginheight = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingwidth = ( me, text ) ->
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.paddingwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingheight = ( me, text ) ->
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.paddingheight = parseFloat text
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


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me, fieldhints_and_content_events ) ->
  @_compute_cell_dimensions     me
  @_compute_field_dimensions    me
  @_compute_border_dimensions   me
  @_compute_pod_dimensions      me
  @_compute_table_height        me
  #.........................................................................................................
  ### Preparatory ###
  yield from @_walk_opening_events                      me
  yield from @_walk_style_events                        me ### TAINT should write to document preamble ###
  #.........................................................................................................
  ### Borders, content ###
  yield from @_walk_field_borders_events                me
  yield from @_walk_pod_events                          me, fieldhints_and_content_events
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
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_opening_events = ( me ) ->
  @_ensure_unitvector me
  layout_name = me.name
  yield tex "\n\n"
  yield tex "% ============================================================================================================\n"
  yield tex "\\par% Beginning of MKTS Table (layout: #{rpr layout_name})\n"
  yield texr 'µ1', "{\\setlength{\\fboxsep}{0mm}"
  # yield texr 'µ2', "\\mktsColorframebox{red}{% debugging framebox" if me.debug
  ### NOTE only height of minipage is important; TikZ will happily draw outside of minipage when told ###
  ### TAINT calculate proper height so text will keep register ###
  yield texr 'µ3', "\\newdimen\\mktsTableUnitwidth\\setlength{\\mktsTableUnitwidth}{#{me.unitwidth}}"
  yield texr 'µ4', "\\newdimen\\mktsTableUnitheight\\setlength{\\mktsTableUnitheight}{#{me.unitheight}}"
  yield texr 'µ2', "\\begin{minipage}[t][#{me.table_dimensions.height}\\mktsTableUnitheight][t]{\\linewidth}"
  yield texr 'µ5', "\\begin{tikzpicture}[ overlay, yshift = 0mm, yscale = -1, line cap = rect ]"
  yield texr 'µ6', "\\tikzset{x=#{me.unitwidth}};\\tikzset{y=#{me.unitheight}};"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  yield texr 'µ7', "\\end{tikzpicture}"
  yield texr 'µ8', "\\end{minipage}}"
  # yield texr 'µ8', "}% debugging framebox" if me.debug
  yield texr 'µ81', "\\mktsVspace{1}"
  yield tex "\\par% End of MKTS Table ====================================================================================\n\n"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_style_events = ( me ) ->
  for key, value of me.styles
    yield texr 'µ9', "\\tikzset{#{key}/.style={#{value}}}"
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_field_borders_events = ( me ) ->
  #.........................................................................................................
  for designation, d of me.border_dimensions
    continue unless ( fieldborders = me.fieldborders[ designation ] )?
    if ( borderstyle = fieldborders[ 'left' ] )?
      yield texr 'µ10', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.left},#{d.bottom});"
    if ( borderstyle = fieldborders[ 'right' ] )?
      yield texr 'µ11', "\\draw[#{borderstyle}] (#{d.right},#{d.top}) -- (#{d.right},#{d.bottom});"
    if ( borderstyle = fieldborders[ 'top' ] )?
      yield texr 'µ12', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.right},#{d.top});"
    if ( borderstyle = fieldborders[ 'bottom' ] )?
      yield texr 'µ13', "\\draw[#{borderstyle}] (#{d.left},#{d.bottom}) -- (#{d.right},#{d.bottom});"
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
@_walk_pod_events = ( me, fieldhints_and_content_events ) ->
  for [ field_designation, content..., ] from @_walk_most_recent_field_designations me, fieldhints_and_content_events
    d           = me.pod_dimensions[ field_designation ]
    valign_tex  = @_get_valign_tex me, me.valigns[ field_designation ] ? me.valigns[ '*' ] ? 'center'
    halign_tex  = @_get_halign_tex me, me.haligns[ field_designation ] ? me.haligns[ '*' ] ? 'left'
    yield texr 'µ14', "\\node[anchor=north west,inner sep=0mm] at (#{d.left},#{d.top})"
    yield texr 'µ15', "{\\begin{minipage}[t][#{d.height}\\mktsTableUnitheight][#{valign_tex}]{#{d.width}\\mktsTableUnitwidth}#{halign_tex}"
    yield [ '.', 'noindent', null, {}, ]
    yield sub_event for sub_event in content
    yield texr 'µ16', "\\end{minipage}};"
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
  yield texr 'µ17', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  top       = ( @_top_from_rownr     me, 1             ) - 3
  bottom    = ( @_bottom_from_rownr  me, me.grid.height ) + 3
  for colnr in [ 1 .. me.grid.width + 1 ]
    x = @_left_from_colnr me, colnr
    yield texr 'µ18', "\\draw[sDebugCellgrid] (#{x},#{top}) -- (#{x},#{bottom});"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  left      = ( @_left_from_colnr    me, 1             ) - 3
  right     = ( @_right_from_colnr   me, me.grid.width  ) + 3
  for rownr in [ 1 .. me.grid.height + 1 ]
    y = @_top_from_rownr me, rownr
    yield texr 'µ19', "\\draw[sDebugCellgrid] (#{left},#{y}) -- (#{right},#{y});"
  #.........................................................................................................
  yield texr 'µ20', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_fieldgrid_events = ( me ) ->
  unless @_should_debug me
    yield return
  #.........................................................................................................
  yield texr 'µ21', "\\begin{scope}[on background layer]"
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
  yield texr 'µ22', "\\end{scope}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
  unless @_should_debug me
    yield return
  @_ensure_grid me
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  yield texr 'µ23', "\\begin{scope}[on background layer]"
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  for [ colletters, colnr, ] from IG.GRID.walk_colletters_and_colnrs me.grid
    for rownr from IG.GRID.walk_rownrs me.grid
      x = ( @_left_from_colnr  me, colnr ) + 2
      y = ( @_top_from_rownr   me, rownr ) + 2
      cellkey = "#{colletters}#{rownr}"
      yield tex "\\node[sDebugJoints] at (#{x},#{y}) {{\\mktsStyleCode{}#{cellkey}}}; "
  #.........................................................................................................
  yield texr 'µ24', "\\end{scope}"
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
@_ensure_margin = ( me ) ->
  @marginwidth   me, me.default.marginwidth   unless me.marginwidth?
  @marginheight  me, me.default.marginheight  unless me.marginheight?
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_padding = ( me ) ->
  @paddingwidth   me, me.default.paddingwidth   unless me.paddingwidth?
  @paddingheight  me, me.default.paddingheight  unless me.paddingheight?
  return null

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
      # ### TAINT must not become negative ###
      # cellwidth_u   = right  - left # - 2 * me.marginwidth
      # cellheight_u  = bottom - top  # - 2 * me.marginheight
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
  @_ensure_margin me
  for designation, d of me.field_dimensions
    left   = d.left   + me.marginwidth
    right  = d.right  - me.marginwidth
    top    = d.top    + me.marginheight
    bottom = d.bottom - me.marginheight
    ### TAINT must not become negative ###
    width       = right  - left
    height      = bottom - top
    me.border_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_pod_dimensions = ( me ) ->
  @_ensure_padding me
  for designation, d of me.field_dimensions
    left   = d.left   + me.paddingwidth
    right  = d.right  - me.paddingwidth
    top    = d.top    + me.paddingheight
    bottom = d.bottom - me.paddingheight
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


