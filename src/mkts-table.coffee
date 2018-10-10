


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
    cellquads:          {}
    cellborders:        {}
    quadwidths:         null
    quadheights:        null
    joint_coordinates:  null
    quadgrid:           false
    #.......................................................................................................
    styles:
      sThin:              'thin'
      sThick:             'thick'
      sDotted:            'dotted'
      sDashed:            'dashed'
      sRed:               'red'
      sBlack:             'black'
      sDebugQuadgrid:     'sRed,sDotted,sThin'
      sDebugJoints:       'gray!30,sThick'
    #.......................................................................................................
    default:
      gridwidth:  4
      gridheight: 4
      unitwidth:  '1mm'
      unitheight: '1mm'
      quadwidth:  10
      quadheight: 10
  return R


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@gridwidth = ( me, text ) ->
  #.........................................................................................................
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 8082) need a text for mkts-table/gridwidth, got a #{type}"
  unless ( match = text.match /^\s*(\d+)\s*$/ )?
    throw new Error "(MKTS/TABLE 9000) need a text like '3' or similar for mkts-table/gridwidth, got #{rpr text}"
  if me.gridwidth?
    throw new Error "(MKTS/TABLE 1282) unable to re-define gridwidth"
  #.........................................................................................................
  me.gridwidth      = parseInt match[ 1 ], 10
  return null

#-----------------------------------------------------------------------------------------------------------
@gridheight = ( me, text ) ->
  #.........................................................................................................
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 4532) need a text for mkts-table/gridheight, got a #{type}"
  unless ( match = text.match /^\s*(\d+)\s*$/ )?
    throw new Error "(MKTS/TABLE 3691) need a text like '3' or similar for mkts-table/gridheight, got #{rpr text}"
  if me.gridheight?
    throw new Error "(MKTS/TABLE 5164) unable to re-define gridheight"
  #.........................................................................................................
  me.gridheight     = parseInt match[ 1 ], 10
  return null

#-----------------------------------------------------------------------------------------------------------
@unitwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 4959) need a text for mkts-table/unitwidth, got a #{type}"
  if me.unitwidth?
    throw new Error "(MKTS/TABLE 7732) unable to re-define unitheight"
  #.........................................................................................................
  me.unitwidth = text
  return null

#-----------------------------------------------------------------------------------------------------------
@unitheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 3643) need a text for mkts-table/unitheight, got a #{type}"
  if me.unitheight?
    throw new Error "(MKTS/TABLE 3537) unable to re-define unitheight"
  #.........................................................................................................
  me.unitheight = text
  return null

#-----------------------------------------------------------------------------------------------------------
@cellquads = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9791) need a text for mkts-table/cellquads, got a #{type}"
  #.........................................................................................................
  @_ensure_gridwidth  me
  @_ensure_gridheight me
  @_ensure_unitvector me
  d           = @_parse_range_quadref me, text
  designation = d.tl.toUpperCase()
  if d.right > me.gridwidth
    throw new Error "(MKTS/TABLE 1274) cell exceeds grid width: #{rpr text}"
  if d.bottom > me.gridheight
    throw new Error "(MKTS/TABLE 6069) cell exceeds grid height: #{rpr text}"
  if me.cellquads[ designation ]?
    throw new Error "(MKTS/TABLE 6069) unable to redefine cell #{designation}: #{rpr text}"
  #.........................................................................................................
  me.cellquads[ designation ] = d
  return null

#-----------------------------------------------------------------------------------------------------------
@cellborder = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9791) need a text for mkts-table/cellborder, got a #{type}"
  #.........................................................................................................
  d                 = @_parse_cellborder me, text
  if d.side is '*'
    for side in [ 'left', 'right', 'top', 'bottom', ]
      target            = me.cellborders[ d.cellref ]?= {}
      target[ side ]    = d.style
  else
    target            = me.cellborders[ d.cellref ]?= {}
    target[ d.side ]  = d.style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@quadgrid = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9791) need a text for mkts-table/cell, got a #{type}"
  #.........................................................................................................
  switch text
    when 'true'   then me.quadgrid = true
    when 'false'  then me.quadgrid = false
    else throw new Error "(MKTS/TABLE 9791) expected 'true' or 'false' for mkts-table/quadgrid, got a #{rpr text}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@cellspacing = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 1539) need a text for mkts-table/cellspacing, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  me.cellspacing = @_parse_coordinate_without_units me, text
  #.........................................................................................................
  return null


#===========================================================================================================
# PARSERS ETC
#-----------------------------------------------------------------------------------------------------------
@_idx_from_col_and_row = ( col, row ) ->
  unless ( type = CND.type_of col ) is 'text'
    throw new Error "(MKTS/TABLE 1763) expected a text for col, got a #{rpr type}"
  unless ( type = CND.type_of row ) is 'text'
    throw new Error "(MKTS/TABLE 4752) expected a text for row, got a #{rpr type}"
  #.........................................................................................................
  col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
  row_idx = ( parseInt row, 10 ) - 1
  return { col: col_idx, row: row_idx, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_range_quadref = ( me, quad_range ) ->
  unless ( type = CND.type_of quad_range ) is 'text'
    throw new Error "(MKTS/TABLE 9879) expected a text for quad_range, got a #{rpr type}"
  unless ( match = quad_range.match /^([a-z]{1,3})([0-9]{1,4}):([a-z]{1,3})([0-9]{1,4})$/ )?
    throw new Error "(MKTS/TABLE 3807) expected a quad range like 'a1:d4', got #{rpr quad_range}"
  ### TAINT don't use EXCJSCC directly ###
  R = EXCJSCC.decode quad_range.toUpperCase()
  delete R.dimensions
  R.tl = R.tl.toLowerCase()
  R.br = R.br.toLowerCase()
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_coordinate_with_units = ( me, coordinate ) ->
  unless ( type = CND.type_of coordinate ) is 'text'
    throw new Error "(MKTS/TABLE 8077) expected a text for coordinate, got a #{rpr type}"
  unless ( match = coordinate.match /^\s*\(\s*([-0-9.]{1,8}[a-z]{0,3})\s*,\s*([-0-9.]{1,8}[a-z]{0,3})\s*\)\s*$/ )?
    throw new Error "(MKTS/TABLE 3191) expected a coordinate with units like '( 1mm, 2.4cm )', got #{rpr coordinate}"
  [ _, x, y, ] = match
  return { x, y, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_coordinate_without_units = ( me, coordinate ) ->
  unless ( type = CND.type_of coordinate ) is 'text'
    throw new Error "(MKTS/TABLE 3975) expected a text for coordinate, got a #{rpr type}"
  unless ( match = coordinate.match /^\s*\(\s*([-0-9.]{1,8})\s*,\s*([-0-9.]{1,8})\s*\)\s*$/ )?
    throw new Error "(MKTS/TABLE 2658) expected a unitless coordinate like '( 1, 2.4 )', got #{rpr coordinate}"
  [ _, x, y, ] = match
  return { x, y, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_cellborder = ( me, cellborder ) ->
  unless ( type = CND.type_of cellborder ) is 'text'
    throw new Error "(MKTS/TABLE 3975) expected a text for cellborder, got a #{rpr type}"
  unless ( match = cellborder.match /^\s*([A-Z]{1,3}[-0-9.]{1,4})-(left|right|top|bottom|\*)\s*:\s*(.+)$/ )?
    throw new Error "(MKTS/TABLE 2658) expected a cellborder like 'a1-left:sDashed,sThick', got #{rpr cellborder}"
  [ _, cellref, side, style, ] = match
  return { cellref, side, style, }


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me ) ->
  #.........................................................................................................
  yield from @_walk_opening_events                      me
  yield from @_walk_style_events                        me
  yield from @_walk_cellspacing_events                  me
  yield from @_walk_column_and_row_coordinates_events   me
  yield from @_walk_joint_coordinates_events            me
  yield from @_walk_quad_sides_events                   me
  yield from @_walk_quad_coordinates_events             me
  yield from @_walk_debug_joints_events                 me
  yield from @_walk_debug_quadgrid_events               me
  yield from @_walk_quad_borders_events                 me
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
  yield [ 'tex', "\\framebox{\\begin{minipage}[t][45mm][t]{100mm}%\n", ]
  ### !!!!!!!!!!!!!!!!!!!!! ###
  yield [ '.', 'text', "table goes here", ( copy me.meta ), ]
  ### !!!!!!!!!!!!!!!!!!!!! ###
  yield [ 'tex', "\\begin{tikzpicture}[ overlay, yshift = 0mm, yscale = -1, line cap = round ]%\n", ]
  yield [ 'tex', "\\tikzset{ x = #{me.unitheight} };%\n", ]
  yield [ 'tex', "\\tikzset{ y = #{me.unitheight} };%\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  yield [ 'tex', "\\end{tikzpicture}%\n", ]
  yield [ 'tex', "\\end{minipage}}}%\n", ]
  yield [ 'tex', "\\par% End of MKTS Table ====================================================================================\n\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_style_events = ( me ) ->
  for key, value of me.styles
    yield [ 'tex', "\\tikzset{#{key}/.style={#{value}}}%\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_cellspacing_events = ( me ) ->
  ### TAINT should rather use default cellspacing ###
  return null unless me.cellspacing?
  yield [ 'tex', "\\coordinate (horizontal spacing)  at ( #{me.cellspacing.x}, 0 );%\n", ]
  yield [ 'tex', "\\coordinate (vertical spacing)    at ( 0, #{me.cellspacing.y} );%\n", ]
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_column_and_row_coordinates_events = ( me ) ->
  @_ensure_joint_coordinates  me
  x_position  = 0
  y_position  = 0
  #.........................................................................................................
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    yield [ 'tex', "\\coordinate (col_#{col_letter}) at ( #{x_position}, 0 );%\n", ]
    x_position += me.quadwidths[ col_nr ]
  #.........................................................................................................
  for row_nr from @_walk_row_numbers me, 'long'
    yield [ 'tex', "\\coordinate (row_#{row_nr}) at ( 0, #{y_position} );%\n", ]
    y_position += me.quadheights[ row_nr ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_joint_coordinates_events = ( me ) ->
  @_ensure_joint_coordinates  me
  x_position  = 0
  y_position  = 0
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    for row_nr from @_walk_row_numbers me, 'long'
      joint = "#{col_letter}#{row_nr}"
      yield [ 'tex', "\\coordinate (joint_#{joint}) at ($ (col_#{col_letter}) + (row_#{row_nr}) $);%\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_quad_sides_events = ( me ) ->
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    yield [ 'tex', "\\coordinate (col_#{col_letter} W) at ($ (col_#{col_letter}) - (horizontal spacing) $);%\n", ]
    yield [ 'tex', "\\coordinate (col_#{col_letter} E) at ($ (col_#{col_letter}) + (horizontal spacing) $);%\n", ]
  #.........................................................................................................
  for row_nr from @_walk_row_numbers me, 'long'
    yield [ 'tex', "\\coordinate (row_#{row_nr} N) at ($ (row_#{row_nr}) - (vertical spacing) $);%\n", ]
    yield [ 'tex', "\\coordinate (row_#{row_nr} S) at ($ (row_#{row_nr}) + (vertical spacing) $);%\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_quad_coordinates_events = ( me ) ->
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter_1, col_nr_1, ] from @_walk_column_letters_and_numbers me, 'short'
    col_nr_2      = col_nr_1 + 1
    ### TAINT don't use EXCJSCC directly ###
    col_letter_2  = ( EXCJSCC.n2l col_nr_2 ).toLowerCase()
    for row_nr_1 from @_walk_row_numbers me, 'short'
      row_nr_2  = row_nr_1 + 1
      quad = "#{col_letter_1}#{row_nr_1}"
      yield [ 'tex', "\\coordinate (quad_#{quad} top left)      at ($ (row_#{row_nr_1} S) + (col_#{col_letter_1} E) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad_#{quad} top right)     at ($ (row_#{row_nr_1} S) + (col_#{col_letter_2} W) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad_#{quad} bottom left)   at ($ (row_#{row_nr_2} N) + (col_#{col_letter_1} E) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad_#{quad} bottom right)  at ($ (row_#{row_nr_2} N) + (col_#{col_letter_2} W) $);%\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_quadgrid_events = ( me ) ->
  return null unless me.quadgrid
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter_1, col_nr_1, ] from @_walk_column_letters_and_numbers me, 'short'
    col_nr_2      = col_nr_1 + 1
    ### TAINT don't use EXCJSCC directly ###
    col_letter_2  = ( EXCJSCC.n2l col_nr_2 ).toLowerCase()
    for row_nr_1 from @_walk_row_numbers me, 'short'
      row_nr_2  = row_nr_1 + 1
      quad = "#{col_letter_1}#{row_nr_1}"
      yield [ 'tex', "\\draw[sDebugQuadgrid] (quad_#{quad} top    left)  -- (quad_#{quad} top    right);%\n",  ]
      yield [ 'tex', "\\draw[sDebugQuadgrid] (quad_#{quad} top    left)  -- (quad_#{quad} bottom left);%\n",   ]
      yield [ 'tex', "\\draw[sDebugQuadgrid] (quad_#{quad} bottom left)  -- (quad_#{quad} bottom right);%\n",  ]
      yield [ 'tex', "\\draw[sDebugQuadgrid] (quad_#{quad} top    right) -- (quad_#{quad} bottom right);%\n",  ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_quad_borders_events = ( me ) ->
  #.........................................................................................................
  for designation, cellquads of me.cellquads
    continue unless ( cellborders = me.cellborders[ designation ] )?
    for d from @_walk_cellquads_sides me, cellquads, '*'
      continue unless ( borderstyle = cellborders[ d.side ] )?
      switch d.side
        when 'top', 'bottom'
          yield [ 'tex', "\\draw[#{borderstyle}] (quad_#{d.quad} #{d.side} left) -- (quad_#{d.quad} #{d.side} right);\n", ]
        when 'left', 'right'
          yield [ 'tex', "\\draw[#{borderstyle}] (quad_#{d.quad} top #{d.side}) -- (quad_#{d.quad} bottom #{d.side});\n", ]
        else
          throw new Error "(MKTS/TABLE 2658) illegal value for side #{rpr d.side}"
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
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
  me.gridwidths = me.default.gridwidth
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_gridheight = ( me ) ->
  return null if me.gridheight?
  me.gridheights = me.default.gridheight
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_quadwidths = ( me ) ->
  return null if me.quadwidths?
  @_ensure_gridwidth  me
  me.quadwidths = ( me.default.quadwidth for col_nr in [ 1 .. me.gridwidth + 1 ] )
  return null

#-----------------------------------------------------------------------------------------------------------
@_ensure_quadheights = ( me ) ->
  return null if me.quadheights?
  @_ensure_gridheight me
  me.quadheights = ( me.default.quadheight for col_nr in [ 1 .. me.gridheight + 1 ] )
  return null


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
@_walk_cellquads_sides = ( me, cellquads, side ) ->
  switch side
    when 'left'
      row_nr_1    = cellquads.top
      row_nr_2    = cellquads.bottom
      col_nr_1    = cellquads.left
      col_nr_2    = cellquads.left
    when 'right'
      row_nr_1    = cellquads.top
      row_nr_2    = cellquads.bottom
      col_nr_1    = cellquads.right
      col_nr_2    = cellquads.right
    when 'top'
      row_nr_1    = cellquads.top
      row_nr_2    = cellquads.top
      col_nr_1    = cellquads.left
      col_nr_2    = cellquads.right
    when 'bottom'
      row_nr_1    = cellquads.bottom
      row_nr_2    = cellquads.bottom
      col_nr_1    = cellquads.left
      col_nr_2    = cellquads.right
    when '*'
      yield from @_walk_cellquads_sides me, cellquads, 'left'
      yield from @_walk_cellquads_sides me, cellquads, 'right'
      yield from @_walk_cellquads_sides me, cellquads, 'top'
      yield from @_walk_cellquads_sides me, cellquads, 'bottom'
      yield return
    else
      throw new Error "(MKTS/TABLE 2658) illegal argument for side #{rpr side}"
  for row_nr in [ row_nr_1 .. row_nr_2 ]
    for col_nr in [ col_nr_1 .. col_nr_2 ]
      ### TAINT don't use EXCJSCC directly ###
      col_letter  = ( EXCJSCC.n2l col_nr ).toLowerCase()
      quad        = "#{col_letter}#{row_nr}"
      yield { col_nr, row_nr, col_letter, quad, side, }
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
    throw _stackerr error, "(MKTS/TABLE 6358) ... new message ..."
  ```
  ###
  message = "(MKTS/TABLE##{ref}) #{message}"
  if error?
    error.message = "#{message}\n#{error.message}"
  else
    ### TAINT elide current line from stack trace ###
    error = new Error message
  return error
