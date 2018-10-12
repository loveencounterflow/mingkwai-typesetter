


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
EXCJSCC                   = require './exceljs-spreadsheet-address-codec'



#===========================================================================================================
# INITIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_new_description = ( S ) ->
  R =
    '~isa':     'MKTS/TABLE/description'
    cellquads:          {} ### cell extents in terms of quads, by cell designations ###
    quadcells:          {} ### which quads belong to what cells, by quad designations ###
    quad_dimensions:    {}
    cellborders:        {} ### cell borders, as TikZ styles by sides ###
    cell_dimensions:    {} ### cell extents in terms of (unitwidth,unitheight), by designations ###
    border_dimensions:  {} ### border extents in terms of (unitwidth,unitheight), by designations ###
    pod_dimensions:     {} ### pod extents in terms of (unitwidth,unitheight), by designations ###
    quadwidths:         [ null, ] ### [ 0 ] is default, [ 1 .. gridwidth ] explicit or implicit widths ###
    quadheights:        [ null, ] ### [ 0 ] is default, [ 1 .. gridheight ] explicit or implicit heights ###
    joint_coordinates:  null
    debug:              false
    #.......................................................................................................
    styles:
      sThin:              'thin'
      sThick:             'thick'
      sDotted:            'dotted'
      sDashed:            'dashed'
      sRed:               'red'
      sBlack:             'black'
      sDebugQuadgrid:     'gray!30,sThin'
      sDebugCellgrid:     'gray!30,sThin'
      sDebugJoints:       'gray!30,sThick'
    #.......................................................................................................
    default:
      # gridwidth:     4
      # gridheight:    4
      unitwidth:    '1mm'
      unitheight:   '1mm'
      # quadwidth:     10
      # quadheight:    10
      marginwidth:   0
      marginheight:  0
      paddingwidth:  0
      paddingheight: 0
  return R


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@gridwidth = ( me, text ) ->
  #.........................................................................................................
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 4517) need a text for mkts-table/gridwidth, got a #{type}"
  unless ( match = text.match /^\s*(\d+)\s*$/ )?
    throw new Error "(MKTS/TABLE 4300) need a text like '3' or similar for mkts-table/gridwidth, got #{rpr text}"
  if me.gridwidth?
    throw new Error "(MKTS/TABLE 5827) unable to re-define gridwidth"
  #.........................................................................................................
  me.gridwidth      = parseInt match[ 1 ], 10
  return null

#-----------------------------------------------------------------------------------------------------------
@gridheight = ( me, text ) ->
  #.........................................................................................................
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9150) need a text for mkts-table/gridheight, got a #{type}"
  unless ( match = text.match /^\s*(\d+)\s*$/ )?
    throw new Error "(MKTS/TABLE 6572) need a text like '3' or similar for mkts-table/gridheight, got #{rpr text}"
  if me.gridheight?
    throw new Error "(MKTS/TABLE 6501) unable to re-define gridheight"
  #.........................................................................................................
  me.gridheight     = parseInt match[ 1 ], 10
  return null

#-----------------------------------------------------------------------------------------------------------
@unitwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9131) need a text for mkts-table/unitwidth, got a #{type}"
  if me.unitwidth?
    throw new Error "(MKTS/TABLE 6477) unable to re-define unitheight"
  #.........................................................................................................
  me.unitwidth = text
  return null

#-----------------------------------------------------------------------------------------------------------
@unitheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 7680) need a text for mkts-table/unitheight, got a #{type}"
  if me.unitheight?
    throw new Error "(MKTS/TABLE 2142) unable to re-define unitheight"
  #.........................................................................................................
  me.unitheight = text
  return null

#-----------------------------------------------------------------------------------------------------------
@quadwidths = ( me, text ) ->
  ### TAINT should validate ###
  @_ensure_gridwidth me
  value = parseFloat text
  me.quadwidths[  0 ] = value ### set default ###
  me.quadwidths[ nr ] = value for nr in [ 1 .. me.gridwidth ]
  return null

#-----------------------------------------------------------------------------------------------------------
@quadheights = ( me, text ) ->
  ### TAINT should validate ###
  @_ensure_gridheight me
  value = parseFloat text
  me.quadheights[  0 ] = value ### set default ###
  me.quadheights[ nr ] = value for nr in [ 1 .. me.gridheight ]
  return null

#-----------------------------------------------------------------------------------------------------------
@cellquads = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 8532) need a text for mkts-table/cellquads, got a #{type}"
  #.........................................................................................................
  @_ensure_gridwidth  me
  @_ensure_gridheight me
  @_ensure_unitvector me
  d           = @_parse_range_quadref me, text
  designation = d.tl
  if d.right > me.gridwidth
    throw new Error "(MKTS/TABLE 2282) cell exceeds grid width: #{rpr text}"
  if d.bottom > me.gridheight
    throw new Error "(MKTS/TABLE 2523) cell exceeds grid height: #{rpr text}"
  if me.cellquads[ designation ]?
    throw new Error "(MKTS/TABLE 1246) unable to redefine cell #{designation}: #{rpr text}"
  #.........................................................................................................
  me.cellquads[ designation ] = d
  for cellquad from @_walk_cellquads me, d
    ( me.quadcells[ cellquad.designation ]?= [] ).push designation
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@cellborder = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 2034) need a text for mkts-table/cellborder, got a #{type}"
  #.........................................................................................................
  d = @_parse_cellborder me, text
  for cell in d.cells
    for side in d.sides
      ( me.cellborders[ cell ]?= {} )[ side ] = d.style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@debug = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 8055) need a text for mkts-table/cell, got a #{type}"
  #.........................................................................................................
  switch text
    when 'true'   then me.debug = true
    when 'false'  then me.debug = false
    else throw new Error "(MKTS/TABLE 9035) expected 'true' or 'false' for mkts-table/debug, got #{rpr text}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@marginwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 1811) need a text for mkts-table/marginwidth, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@marginheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9480) need a text for mkts-table/marginheight, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginheight = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 8254) need a text for mkts-table/paddingwidth, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.paddingwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 7209) need a text for mkts-table/paddingheight, got a #{type}"
  #.........................................................................................................
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
    throw new Error "(MKTS/TABLE 4182) expected a text for col, got a #{rpr type}"
  unless ( type = CND.type_of row ) is 'text'
    throw new Error "(MKTS/TABLE 5931) expected a text for row, got a #{rpr type}"
  #.........................................................................................................
  col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
  row_idx = ( parseInt row, 10 ) - 1
  return { col: col_idx, row: row_idx, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_range_quadref = ( me, quad_range ) ->
  unless ( type = CND.type_of quad_range ) is 'text'
    throw new Error "(MKTS/TABLE 6402) expected a text for quad_range, got a #{rpr type}"
  unless ( match = quad_range.match /^([a-z]{1,3})([0-9]{1,4}):([a-z]{1,3})([0-9]{1,4})$/ )?
    throw new Error "(MKTS/TABLE 2499) expected a quad range like 'a1:d4', got #{rpr quad_range}"
  ### TAINT don't use EXCJSCC directly ###
  R = EXCJSCC.decode quad_range.toUpperCase()
  delete R.dimensions
  R.tl = R.tl.toLowerCase()
  R.br = R.br.toLowerCase()
  R.tr = "#{( EXCJSCC.n2l R.right ).toLowerCase()}#{R.top}"
  R.bl = "#{( EXCJSCC.n2l R.left ).toLowerCase()}#{R.bottom}"
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_coordinate_with_units = ( me, coordinate ) ->
  unless ( type = CND.type_of coordinate ) is 'text'
    throw new Error "(MKTS/TABLE 1045) expected a text for coordinate, got a #{rpr type}"
  unless ( match = coordinate.match /^\s*\(\s*([-0-9.]{1,8}[a-z]{0,3})\s*,\s*([-0-9.]{1,8}[a-z]{0,3})\s*\)\s*$/ )?
    throw new Error "(MKTS/TABLE 2032) expected a coordinate with units like '( 1mm, 2.4cm )', got #{rpr coordinate}"
  [ _, x, y, ] = match
  return { x, y, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_coordinate_without_units = ( me, coordinate ) ->
  unless ( type = CND.type_of coordinate ) is 'text'
    throw new Error "(MKTS/TABLE 2262) expected a text for coordinate, got a #{rpr type}"
  unless ( match = coordinate.match /^\s*\(\s*([-0-9.]{1,8})\s*,\s*([-0-9.]{1,8})\s*\)\s*$/ )?
    throw new Error "(MKTS/TABLE 6904) expected a unitless coordinate like '( 1, 2.4 )', got #{rpr coordinate}"
  [ _, x, y, ] = match
  return { x, y, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_cellborder = ( me, cellborder ) ->
  unless ( type = CND.type_of cellborder ) is 'text'
    throw new Error "(MKTS/TABLE 6043) expected a text for cellborder, got a #{rpr type}"
  unless ( groups = cellborder.match /^(.+):(.+):(.*)$/ )?
    throw new Error "(MKTS/TABLE 5822) expected a cellborder like 'a1:left:sDashed,sThick', got #{rpr cellborder}"
  [ _, quads, sides, style, ] = groups
  #.........................................................................................................
  ### TAINT this will have to be changed to allow for named cells ###
  cells = if '*' in quads
    Object.keys me.cellquads
  else
    @_cellnames_from_quadkeys me, ( _.trim() for _ in quads.split ',' )
  #.........................................................................................................
  sides = if '*' in sides
    [ 'top', 'left', 'bottom', 'right', ]
  else
    ( _.trim() for _ in sides.split ',' )
  #.........................................................................................................
  style = style.trim()
  style = null if style in [ 'none', '', ]
  #.........................................................................................................
  return { cells, sides, style, }


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me ) ->
  @_compute_quad_dimensions     me
  @_compute_cell_dimensions     me
  @_compute_border_dimensions   me
  @_compute_pod_dimensions      me
  #.........................................................................................................
  ### Preparatory ###
  yield from @_walk_opening_events                      me
  yield from @_walk_style_events                        me ### TAINT should write to document preamble ###
  #.........................................................................................................
  ### Debugging ### ### TAINT should make ordering configurable so we can under- or overprint debugging ###
  # yield from @_walk_debug_joints_events                 me
  yield from @_walk_debug_quadgrid_events               me
  yield from @_walk_debug_cellgrid_events               me
  #.........................................................................................................
  ### Borders, content ###
  yield from @_walk_cell_borders_events                 me
  yield from @_walk_pod_events                          me
  #.........................................................................................................
  ### Finishing ###
  yield from @_walk_closing_events                      me
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
  yield [ 'tex', "\n\n", ]
  yield [ 'tex', "\\par% Beginning of MKTS Table ==============================================================================\n", ]
  yield [ 'tex', "{\\setlength{\\fboxsep}{0mm}%\n", ]
  ### TAINT insert proper dimensions ###
  # yield [ 'tex', "\\framebox{%\n", ] ### framebox ###
  yield [ 'tex', "\\begin{minipage}[t][45mm][t]{100mm}%\n", ]
  yield [ 'tex', "\\newdimen\\mktsTableUnitwidth\\setlength{\\mktsTableUnitwidth}{#{me.unitwidth}}%\n", ]
  yield [ 'tex', "\\newdimen\\mktsTableUnitheight\\setlength{\\mktsTableUnitheight}{#{me.unitheight}}%\n", ]
  yield [ 'tex', "\\begin{tikzpicture}[ overlay, yshift = 0mm, yscale = -1, line cap = rect ]%\n", ]
  yield [ 'tex', "\\tikzset{x=#{me.unitwidth}};\\tikzset{y=#{me.unitheight}};%\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  yield [ 'tex', "\\end{tikzpicture}%\n", ]
  yield [ 'tex', "\\end{minipage}}%\n", ]
  # yield [ 'tex', "}%\n", ] ### framebox ###
  yield [ 'tex', "\\par% End of MKTS Table ====================================================================================\n\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_style_events = ( me ) ->
  for key, value of me.styles
    yield [ 'tex', "\\tikzset{#{key}/.style={#{value}}}%\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_cell_borders_events = ( me ) ->
  #.........................................................................................................
  for designation, d of me.border_dimensions
    continue unless ( cellborders = me.cellborders[ designation ] )?
    if ( borderstyle = cellborders[ 'left' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.left},#{d.bottom});\n", ]
    if ( borderstyle = cellborders[ 'right' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.right},#{d.top}) -- (#{d.right},#{d.bottom});\n", ]
    if ( borderstyle = cellborders[ 'top' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.right},#{d.top});\n", ]
    if ( borderstyle = cellborders[ 'bottom' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.bottom}) -- (#{d.right},#{d.bottom});\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_pod_events = ( me ) ->
  for designation, cellquads of me.cellquads
    d = me.pod_dimensions[ designation ]
    yield [ 'tex', "\\node[anchor=north west,inner sep=0mm] at (#{d.left},#{d.top})%\n", ]
    yield [ 'tex', "{\\begin{minipage}[t][#{d.height}\\mktsTableUnitheight][t]{#{d.width}\\mktsTableUnitwidth}%\n", ]
    yield [ 'tex', "A\\hfill{}B\\hfill{}C\\end{minipage}};%\n", ]
    # yield [ 'tex', "{\\framebox{\\begin{minipage}[t][#{d.height}\\mktsTableUnitheight][t]{#{d.width}\\mktsTableUnitwidth}%\n", ]
    # yield [ 'tex', "A\\hfill{}B\\hfill{}C\\end{minipage}}};%\n", ]
  #.........................................................................................................
  yield return


#===========================================================================================================
# EVENT GENERATORS: DEBUGGING EVENTS
#-----------------------------------------------------------------------------------------------------------
@_walk_debug_quadgrid_events = ( me ) ->
  unless me.debug
    yield return
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  top       = ( @_top_from_row_nr     me, 1             ) - 3
  bottom    = ( @_bottom_from_row_nr  me, me.gridheight ) + 3
  for col_nr in [ 1 .. me.gridwidth + 1 ]
    x = @_left_from_col_nr me, col_nr
    yield [ 'tex', "\\draw[sDebugQuadgrid] (#{x},#{top}) -- (#{x},#{bottom});\n", ]
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  left      = ( @_left_from_col_nr    me, 1             ) - 3
  right     = ( @_right_from_col_nr   me, me.gridwidth  ) + 3
  for row_nr in [ 1 .. me.gridheight + 1 ]
    y = @_top_from_row_nr me, row_nr
    yield [ 'tex', "\\draw[sDebugQuadgrid] (#{left},#{y}) -- (#{right},#{y});\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_cellgrid_events = ( me ) ->
  unless me.debug
    yield return
  #.........................................................................................................
  for designation, d of me.cell_dimensions
    ### TAINT use fixed size like 1mm ###
    left   = d.left   + 0.5
    right  = d.right  - 0.5
    top    = d.top    + 0.5
    bottom = d.bottom - 0.5
    yield [ 'tex', "\\draw[sDebugCellgrid] (#{left},#{bottom})" \
                 + " -- (#{left},#{top})"                       \
                 + " -- (#{right},#{top});", ]
    yield [ 'tex', " \\draw[sDebugCellgrid] (#{right},#{top}) " \
                 + " -- (#{right},#{bottom});", ]
    yield [ 'tex', " \\draw[sDebugCellgrid] (#{left},#{bottom}) " \
                 + " -- (#{right},#{bottom});", ]
    yield [ 'tex', "\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
  unless me.debug
    yield return
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    for row_nr from @_walk_row_numbers me, 'long'
      joint = "#{col_letter}#{row_nr}"
      yield [ 'tex', "\\node[sDebugJoints] at ($(joint_#{joint})+(2mm,2mm)$) {{\\mktsStyleCode{}#{joint}}}; ", ]
      yield [ 'tex', "\\node[sDebugJoints, shape = circle, draw ] at (joint_#{joint}) {};%\n", ]
  #.........................................................................................................
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
  @_ensure_quadwidths   me
  @_ensure_quadheights  me
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_gridwidth = ( me ) ->
  return null if me.gridwidth?
  throw new Error "(MKTS/TABLE 5822) gridwidth must be set"

#-----------------------------------------------------------------------------------------------------------
@_ensure_gridheight = ( me ) ->
  return null if me.gridheight?
  throw new Error "(MKTS/TABLE 5822) gridheight must be set"

#-----------------------------------------------------------------------------------------------------------
@_ensure_quadwidths = ( me ) ->
  return null if ( me.quadwidths.length is me.gridwidth + 1 ) and ( null not in me.quadwidths[ 1 .. ] )
  throw new Error "(MKTS/TABLE 5822) quadwidths must be all set; got #{rpr me.quadwidths}"

#-----------------------------------------------------------------------------------------------------------
@_ensure_quadheights = ( me ) ->
  return null if ( me.quadheights.length is me.gridheight + 1 ) and ( null not in me.quadheights[ 1 .. ] )
  throw new Error "(MKTS/TABLE 5822) quadheights must be all set; got #{rpr me.quadheights}"

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
@_compute_quad_dimensions = ( me ) ->
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'short'
    for row_nr from @_walk_row_numbers me, 'short'
      designation   = "#{col_letter}#{row_nr}"
      left   = @_left_from_col_nr   me, col_nr
      right  = @_right_from_col_nr  me, col_nr
      top    = @_top_from_row_nr    me, row_nr
      bottom = @_bottom_from_row_nr me, row_nr
      # ### TAINT must not become negative ###
      # quadwidth_u   = right  - left # - 2 * me.marginwidth
      # quadheight_u  = bottom - top  # - 2 * me.marginheight
      me.quad_dimensions[ designation ] = {
        col_nr,         row_nr,
        left,    right,
        top,     bottom, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_cell_dimensions = ( me ) ->
  ### TAINT use me.cell_dimensions ###
  for designation, cellquads of me.cellquads
    left   = ( @_left_from_col_nr   me, cellquads.left    )
    right  = ( @_right_from_col_nr  me, cellquads.right   )
    top    = ( @_top_from_row_nr    me, cellquads.top     )
    bottom = ( @_bottom_from_row_nr me, cellquads.bottom  )
    width       = right  - left
    height      = bottom - top
    me.cell_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_border_dimensions = ( me ) ->
  for designation, d of me.cell_dimensions
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
  for designation, d of me.cell_dimensions
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
@_left_from_col_nr = ( me, col_nr ) ->
  ### TAINT should precompute ###
  @_ensure_quadwidths me
  R = 0
  R += me.quadwidths[ nr ] for nr in [ 1 ... col_nr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_right_from_col_nr = ( me, col_nr ) ->
  return ( @_left_from_col_nr me, col_nr ) + me.quadwidths[ col_nr ]

#-----------------------------------------------------------------------------------------------------------
@_top_from_row_nr = ( me, row_nr ) ->
  ### TAINT should precompute ###
  @_ensure_quadheights me
  R = 0
  R += me.quadheights[ nr ] for nr in [ 1 ... row_nr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_bottom_from_row_nr = ( me, row_nr ) ->
  return ( @_top_from_row_nr me, row_nr ) + me.quadheights[ row_nr ]

#-----------------------------------------------------------------------------------------------------------
@_cellnames_from_quadkeys = ( me, quadkeys ) ->
  R = new Set()
  for quadkey in quadkeys
    R.add cellname for cellname in me.quadcells
  return ( cellname for cellname from R )


#===========================================================================================================
# ITERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_column_letters_and_numbers = ( me, mode ) ->
  @_ensure_gridwidth me
  delta = if mode is 'short' then 0 else 1
  for col_nr in [ 1 .. me.gridwidth + delta ]
    ### TAINT don't use EXCJSCC directly ###
    col_letter  = ( EXCJSCC.n2l col_nr ).toLowerCase()
    yield [ col_letter, col_nr, ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_row_numbers = ( me, mode ) ->
  @_ensure_gridheight me
  delta = if mode is 'short' then 0 else 1
  yield row_nr for row_nr in [ 1 .. me.gridheight + delta ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_cellquads = ( me, cellquads ) ->
  for row_nr in [ cellquads.top .. cellquads.bottom ]
    for col_nr in [ cellquads.left .. cellquads.right ]
      ### TAINT don't use EXCJSCC directly ###
      col_letter  = ( EXCJSCC.n2l col_nr ).toLowerCase()
      designation = "#{col_letter}#{row_nr}"
      yield { col_nr, row_nr, col_letter, designation, }
  yield return


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
_stackerr = ( ref, message, error = null ) ->
  ###
  Prepends local error message to the original one so we get more informative traces. Usage:

  ```
  try
    ...
  catch error
    throw _stackerr error, "(MKTS/TABLE 2406) ... new message ..."
  ```
  ###
  message = "(MKTS/TABLE##{ref}) #{message}"
  if error?
    error.message = "#{message}\n#{error.message}"
  else
    ### TAINT elide current line from stack trace ###
    error = new Error message
  return error
