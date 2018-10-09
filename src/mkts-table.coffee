


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
    # grid:       { width: 4, height: 4, }
    # ### default unit for width, height: ###
    # u:
    #   width:    '10mm'
    #   height:   '10mm'
    cells:              []
    quadwidths:         null
    quadheights:        null
    joint_coordinates:  null
    cellgrid:           false
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
@cell = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9791) need a text for mkts-table/cell, got a #{type}"
  #.........................................................................................................
  @_ensure_gridwidth  me
  @_ensure_gridheight me
  @_ensure_unitvector me
  cell = @_parse_range_quadref me, text
  if cell.right > me.gridwidth
    throw new Error "(MKTS/TABLE 1274) cell exceeds grid width: #{rpr text}"
  if cell.bottom > me.gridheight
    throw new Error "(MKTS/TABLE 6069) cell exceeds grid height: #{rpr text}"
  me.cells.push cell
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@cellgrid = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 9791) need a text for mkts-table/cell, got a #{type}"
  #.........................................................................................................
  switch text
    when 'true'   then me.cellgrid = true
    when 'false'  then me.cellgrid = false
    else throw new Error "(MKTS/TABLE 9791) expected 'true' or 'false' for mkts-table/cellgrid, got a #{rpr text}"
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


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me ) ->
  #.........................................................................................................
  yield from @_walk_opening_events                      me
  yield from @_walk_cellspacing_events                  me
  yield from @_walk_column_and_row_coordinates_events   me
  yield from @_walk_joint_coordinates_events            me
  yield from @_walk_quad_sides_events                   me
  yield from @_walk_quad_coordinates_events             me
  yield from @_walk_debugging_events                    me
  yield from @_walk_cellgrid_events                     me
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
  return null

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
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_closing_events = ( me ) ->
  yield [ 'tex', "\\end{tikzpicture}%\n", ]
  yield [ 'tex', "\\end{minipage}}}%\n", ]
  yield [ 'tex', "\\par% End of MKTS Table ====================================================================================\n\n", ]
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_cellspacing_events = ( me ) ->
  ### TAINT should rather use default cellspacing ###
  return null unless me.cellspacing?
  yield [ 'tex', "\\coordinate (horizontal spacing)  at ( #{me.cellspacing.x}, 0 );%\n", ]
  yield [ 'tex', "\\coordinate (vertical spacing)    at ( 0, #{me.cellspacing.y} );%\n", ]
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_column_and_row_coordinates_events = ( me ) ->
  @_ensure_joint_coordinates  me
  x_position  = 0
  y_position  = 0
  #.........................................................................................................
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    yield [ 'tex', "\\coordinate (c#{col_letter}) at ( #{x_position}, 0 );%\n", ]
    x_position += me.quadwidths[ col_nr ]
  #.........................................................................................................
  for row_nr from @_walk_row_numbers me, 'long'
    yield [ 'tex', "\\coordinate (r#{row_nr}) at ( 0, #{y_position} );%\n", ]
    y_position += me.quadheights[ row_nr ]
  #.........................................................................................................
  return null

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
      yield [ 'tex', "\\coordinate (joint #{joint}) at ($ (c#{col_letter}) + (r#{row_nr}) $);%\n", ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_quad_sides_events = ( me ) ->
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    yield [ 'tex', "\\coordinate (c#{col_letter} W) at ($ (c#{col_letter}) - (horizontal spacing) $);%\n", ]
    yield [ 'tex', "\\coordinate (c#{col_letter} E) at ($ (c#{col_letter}) + (horizontal spacing) $);%\n", ]
  #.........................................................................................................
  for row_nr from @_walk_row_numbers me, 'long'
    yield [ 'tex', "\\coordinate (r#{row_nr} N) at ($ (r#{row_nr}) - (vertical spacing) $);%\n", ]
    yield [ 'tex', "\\coordinate (r#{row_nr} S) at ($ (r#{row_nr}) + (vertical spacing) $);%\n", ]
  #.........................................................................................................
  return null

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
      yield [ 'tex', "\\coordinate (quad #{quad} top left)      at ($ (r#{row_nr_1} S) + (c#{col_letter_1} E) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad #{quad} top right)     at ($ (r#{row_nr_1} S) + (c#{col_letter_2} W) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad #{quad} bottom left)   at ($ (r#{row_nr_2} N) + (c#{col_letter_1} E) $);%\n", ]
      yield [ 'tex', "\\coordinate (quad #{quad} bottom right)  at ($ (r#{row_nr_2} N) + (c#{col_letter_2} W) $);%\n", ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_cellgrid_events = ( me ) ->
  return null unless me.cellgrid
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter_1, col_nr_1, ] from @_walk_column_letters_and_numbers me, 'short'
    col_nr_2      = col_nr_1 + 1
    ### TAINT don't use EXCJSCC directly ###
    col_letter_2  = ( EXCJSCC.n2l col_nr_2 ).toLowerCase()
    for row_nr_1 from @_walk_row_numbers me, 'short'
      row_nr_2  = row_nr_1 + 1
      quad = "#{col_letter_1}#{row_nr_1}"
      yield [ 'tex', "\\draw[ red, line width = 0.2mm ] (quad #{quad} top    left)  -- (quad #{quad} top    right); % Quad a1 top\n",    ]
      yield [ 'tex', "\\draw[ red, line width = 0.2mm ] (quad #{quad} top    left)  -- (quad #{quad} bottom left);  % Quad a1 left\n",   ]
      yield [ 'tex', "\\draw[ red, line width = 0.2mm ] (quad #{quad} bottom left)  -- (quad #{quad} bottom right); % Quad a1 bottom\n", ]
      yield [ 'tex', "\\draw[ red, line width = 0.2mm ] (quad #{quad} top    right) -- (quad #{quad} bottom right); % Quad a1 right\n",  ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_walk_debugging_events = ( me ) ->
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  ### TAINT code duplication; use iterator ###
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'long'
    for row_nr from @_walk_row_numbers me, 'long'
      joint = "#{col_letter}#{row_nr}"
      yield [ 'tex', "\\node[ color = gray ] at ($(joint #{joint})+(2mm,2mm)$) {{\\mktsStyleCode{}#{joint}}}; ", ]
      yield [ 'tex', "\\node[ color = gray, shape = circle, draw ] at (joint #{joint}) {};%\n", ]
  #.........................................................................................................
  return null


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

#-----------------------------------------------------------------------------------------------------------
@_walk_row_numbers = ( me, mode ) ->
  @_ensure_gridheight me
  delta = if mode is 'short' then 0 else 1
  yield row_nr for row_nr in [ 1 .. me.gridheight + delta ]


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
