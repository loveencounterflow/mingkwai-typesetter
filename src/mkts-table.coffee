


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
jr                        = JSON.stringify


#===========================================================================================================
# INITIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_new_description = ( S ) ->
  R =
    '~isa':               'MKTS/TABLE/description'
    fails:                [] ### recoverable errors / fails warnings ###
    fieldcells:           {} ### field extents in terms of cells, by field designations ###
    cellfields:           {} ### which cells belong to what fields, by cellkeys ###
    cell_dimensions:      {}
    fieldborders:         {} ### field borders, as TikZ styles by sides ###
    field_dimensions:     {} ### field extents in terms of (unitwidth,unitheight), by field designations ###
    border_dimensions:    {} ### border extents in terms of (unitwidth,unitheight), by field designations ###
    pod_dimensions:       {} ### pod extents in terms of (unitwidth,unitheight), by field designations ###
    valigns:              {} ### vertical pod alignments, by field designations ###
    cellwidths:           [ null, ] ### [ 0 ] is default, [ 1 .. gridwidth ] explicit or implicit widths ###
    cellheights:          [ null, ] ### [ 0 ] is default, [ 1 .. gridheight ] explicit or implicit heights ###
    joint_coordinates:    null
    debug:                false
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
      gridwidth:     4
      gridheight:    4
      unitwidth:    '1mm'
      unitheight:   '1mm'
      cellwidths:    10
      cellheights:   10
      marginwidth:   0
      marginheight:  0
      paddingwidth:  0
      paddingheight: 0
  return R


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@_set_gridsize = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ9061', "expected 'width' or 'height', got #{rpr direction}"
  p = "grid#{direction}"
  #.........................................................................................................
  ### Apply default unless text matches integer pattern: ###
  unless ( match = text.match /^\s*(\d+)\s*$/ )?
    me[ p ] = me.default[ p ]
    return _record_fail  me, 'µ4833', "need a text like '3' or similar for mkts-table/#{p}, got #{rpr text}"
  #.......................................................................................................
  ### Do nothing if dimension already defined: ###
  if me[ p ]?
    return _record_fail me, 'µ5689', "unable to re-define #{p}"
  #.........................................................................................................
  me[ p ] = parseInt match[ 1 ], 10
  return null

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
@_set_cellsizes = ( me, direction, text ) ->
  unless direction in [ 'width', 'height', ]
    throw _stackerr me, 'µ2352', "expected 'width' or 'height', got #{rpr direction}"
  p = "cell#{direction}s"
  #.........................................................................................................
  ### Do nothing if dimension already defined: ###
  if me[ p ].length > 1
    return _record_fail me, 'µ8613', "unable to re-define #{p}"
  #.........................................................................................................
  if direction is 'width'
    @_ensure_gridwidth me
    lane_count = me.gridwidth
  else
    @_ensure_gridheight me
    lane_count = me.gridheight
  #.........................................................................................................
  ### Apply default unless text matches (simplified) float pattern: ###
  unless ( match = text.match /^([+\d.]+)$/ )?
    _record_fail me, 'µ6377', "need a text like '2.7' or similar for mkts-table/#{p}, got #{rpr text}"
    value = me.default[ p ]
  else
    value = parseFloat text
  me[ p ][  0 ] = value ### set default ###
  me[ p ][ nr ] = value for nr in [ 1 .. lane_count ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@gridwidth    = ( me, text ) -> @_set_gridsize  me, 'width',    text
@gridheight   = ( me, text ) -> @_set_gridsize  me, 'height',   text
@unitwidth    = ( me, text ) -> @_set_unitsize  me, 'width',    text
@unitheight   = ( me, text ) -> @_set_unitsize  me, 'height',   text
@cellwidths   = ( me, text ) -> @_set_cellsizes me, 'width',    text
@cellheights  = ( me, text ) -> @_set_cellsizes me, 'height',   text

#-----------------------------------------------------------------------------------------------------------
@fieldcells = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ1064) need a text for mkts-table/fieldcells, got a #{type}"
  #.........................................................................................................
  @_ensure_gridwidth  me
  @_ensure_gridheight me
  @_ensure_unitvector me
  d           = @_parse_range_cellref me, text
  designation = d.tl
  if d.right > me.gridwidth
    throw new Error "(MKTS/TABLE µ6376) field exceeds grid width: #{rpr text}"
  if d.bottom > me.gridheight
    throw new Error "(MKTS/TABLE µ1709) field exceeds grid height: #{rpr text}"
  if me.fieldcells[ designation ]?
    throw new Error "(MKTS/TABLE µ5375) unable to redefine field #{designation}: #{rpr text}"
  #.........................................................................................................
  me.fieldcells[ designation ] = d
  for fieldcell from @_walk_fieldcells me, d
    ( me.cellfields[ fieldcell.designation ]?= [] ).push designation
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldborder = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ9222) need a text for mkts-table/fieldborder, got a #{type}"
  #.........................................................................................................
  d = @_parse_fieldborder me, text
  for field in d.fields
    for side in d.sides
      ( me.fieldborders[ field ]?= {} )[ side ] = d.style
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@fieldalignvertical = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ9289) need a text for mkts-table/fieldalignvertical, got a #{type}"
  #.........................................................................................................
  unless ( match = text.match /^(.+?):([^:]+)$/ )?
    throw new Error "(MKTS/TABLE µ5229) expected something like 'c3:top' for mkts-table/fieldalignvertical, got #{rpr text}"
  [ _, fieldhints, value, ] = match
  #.........................................................................................................
  unless value in [ 'top', 'bottom', 'center', 'spread', ]
    throw new Error "(MKTS/TABLE µ1876) expected one of 'top', 'bottom', 'center', 'spread' for mkts-table/fieldalignvertical, got #{rpr value}"
  #.........................................................................................................
  for [ fail, field_designation, ] from @_walk_f_field_designations_from_hints me, fieldhints
    ### TAINT ad-hoc fail message production, use method ###
    if fail? then _record me, "#{fail} (#{jr {field_designation}})"
    else          me.valigns[ field_designation ] = value
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@debug = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ9299) need a text for mkts-table/field, got a #{type}"
  #.........................................................................................................
  switch text
    when 'true'   then me.debug = true
    when 'false'  then me.debug = false
    else throw new Error "(MKTS/TABLE µ1343) expected 'true' or 'false' for mkts-table/debug, got #{rpr text}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@marginwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ7503) need a text for mkts-table/marginwidth, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@marginheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ2371) need a text for mkts-table/marginheight, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.marginheight = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingwidth = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ3859) need a text for mkts-table/paddingwidth, got a #{type}"
  #.........................................................................................................
  @_ensure_unitvector me
  ### TAINT use parser, validate syntax ###
  me.paddingwidth = parseFloat text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@paddingheight = ( me, text ) ->
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE µ4525) need a text for mkts-table/paddingheight, got a #{type}"
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
    throw new Error "(MKTS/TABLE µ6848) expected a text for col, got a #{rpr type}"
  unless ( type = CND.type_of row ) is 'text'
    throw new Error "(MKTS/TABLE µ1080) expected a text for row, got a #{rpr type}"
  #.........................................................................................................
  col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
  row_idx = ( parseInt row, 10 ) - 1
  return { col: col_idx, row: row_idx, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_range_cellref = ( me, cell_range ) ->
  unless ( type = CND.type_of cell_range ) is 'text'
    throw new Error "(MKTS/TABLE µ2870) expected a text for cell_range, got a #{rpr type}"
  unless ( match = cell_range.match /^([a-z]{1,3})([0-9]{1,4}):([a-z]{1,3})([0-9]{1,4})$/ )?
    throw new Error "(MKTS/TABLE µ6344) expected a cell range like 'a1:d4', got #{rpr cell_range}"
  ### TAINT don't use EXCJSCC directly ###
  R = EXCJSCC.decode cell_range.toUpperCase()
  delete R.dimensions
  R.tl = R.tl.toLowerCase()
  R.br = R.br.toLowerCase()
  R.tr = "#{( EXCJSCC.n2l R.right ).toLowerCase()}#{R.top}"
  R.bl = "#{( EXCJSCC.n2l R.left ).toLowerCase()}#{R.bottom}"
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@_parse_fieldborder = ( me, fieldborder ) ->
  unless ( type = CND.type_of fieldborder ) is 'text'
    throw new Error "(MKTS/TABLE µ1225) expected a text for fieldborder, got a #{rpr type}"
  unless ( groups = fieldborder.match /^(.+):(.+):(.*)$/ )?
    throw new Error "(MKTS/TABLE µ2582) expected a fieldborder like 'a1:left:sDashed,sThick', got #{rpr fieldborder}"
  [ _, fieldhints, sides, style, ] = groups
  #.........................................................................................................
  sides = ( _.trim() for _ in sides.split ',' )
  sides = [ 'top', 'left', 'bottom', 'right', ] if '*' in sides
  #.........................................................................................................
  ### TAINT code duplication ###
  ### TAINT this will have to be changed to allow for named fields ###
  fieldhints = new Set ( _.trim() for _ in fieldhints.split ',' )
  if fieldhints.has '*'
    fields = Object.keys me.fieldcells
  else
    ### TAINT as it stands, `fieldborder'table:bottom,right:red'` will style all bottom and right borders
    of all fields that have real estate along the bottom and right borders of the table. An improved version
    should probably only affect the bottom borders of table-bottom fields and the right borders of
    table-right fields. Use two statements `fieldborder'table:bottom:red'`, `fieldborder'table:right:red'` to
    express that meaning FTTB. ###
    if fieldhints.has 'table'
      fieldhints.delete 'table'
      for side in sides
        fieldhints.add d.cellkey for d from @_walk_table_edge_cells me, side
    cellkeys    = ( fieldhint for fieldhint from fieldhints )
    fields      = @_fieldnames_from_cellkeys me, cellkeys
  #.........................................................................................................
  style = style.trim()
  style = null if style in [ 'none', '', ]
  #.........................................................................................................
  return { fields, sides, style, }


#===========================================================================================================
# EVENT GENERATORS
#-----------------------------------------------------------------------------------------------------------
@_walk_events = ( me, fieldhints_and_content_events ) ->
  @_compute_cell_dimensions     me
  @_compute_field_dimensions    me
  @_compute_border_dimensions   me
  @_compute_pod_dimensions      me
  #.........................................................................................................
  ### Preparatory ###
  yield from @_walk_opening_events                      me
  yield from @_walk_style_events                        me ### TAINT should write to document preamble ###
  #.........................................................................................................
  ### Debugging ### ### TAINT should make ordering configurable so we can under- or overprint debugging ###
  yield from @_walk_debug_joints_events                 me
  yield from @_walk_debug_cellgrid_events               me
  yield from @_walk_debug_fieldgrid_events              me
  #.........................................................................................................
  ### Borders, content ###
  yield from @_walk_field_borders_events                me
  yield from @_walk_pod_events                          me, fieldhints_and_content_events
  #.........................................................................................................
  ### Finishing ###
  yield from @_walk_closing_events                      me
  yield from @_walk_fail_events                         me
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
@_walk_field_borders_events = ( me ) ->
  #.........................................................................................................
  for designation, d of me.border_dimensions
    continue unless ( fieldborders = me.fieldborders[ designation ] )?
    if ( borderstyle = fieldborders[ 'left' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.left},#{d.bottom});\n", ]
    if ( borderstyle = fieldborders[ 'right' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.right},#{d.top}) -- (#{d.right},#{d.bottom});\n", ]
    if ( borderstyle = fieldborders[ 'top' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.top}) -- (#{d.right},#{d.top});\n", ]
    if ( borderstyle = fieldborders[ 'bottom' ] )?
      yield [ 'tex', "\\draw[#{borderstyle}] (#{d.left},#{d.bottom}) -- (#{d.right},#{d.bottom});\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_get_valign_tex = ( me, valign ) ->
  return switch valign
    when 'top'    then 't'
    when 'bottom' then 'b'
    when 'center' then 'c'
    when 'spread' then 's'
    else throw new Error "(MKTS/TABLE µ4799) illegal value for valign #{rpr valign}"

#-----------------------------------------------------------------------------------------------------------
@_walk_most_recent_field_designations = ( me, fieldhints_and_stuff ) ->
  ### Given a list of `[ fieldhints, x... ]` lists, return a list of `[ designation, x... ]` lists such
  that each `designation` that resulted from each of the `fieldhints` is only kept from the instance
  that appeared last in the list. Each `fieldhints` can produce an arbitrary number of matching field
  designations, and later occurrences of a given field will replace earlier appearances. ###
  R = {}
  for [ fieldhints, stuff..., ] in fieldhints_and_stuff
    for [ fail, field_designation, ] from @_walk_f_field_designations_from_hints me, fieldhints
      if fail? then _record me, fail
      else          R[ field_designation ]  = stuff
  yield [ field_designation, stuff..., ] for field_designation, stuff of R
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_pod_events = ( me, fieldhints_and_content_events ) ->
  for [ field_designation, content, ] from @_walk_most_recent_field_designations me, fieldhints_and_content_events
    d           = me.pod_dimensions[ field_designation ]
    valign_tex  = @_get_valign_tex me, me.valigns[ field_designation ] ? me.valigns[ '*' ] ? 'center'
    yield [ 'tex', "\\node[anchor=north west,inner sep=0mm] at (#{d.left},#{d.top})%\n", ]
    yield [ 'tex', "{\\begin{minipage}[t][#{d.height}\\mktsTableUnitheight][#{valign_tex}]{#{d.width}\\mktsTableUnitwidth}%\n", ]
    # yield [ 'tex', "\\vfill{}", ]
    yield [ '.', 'noindent', null, {}, ]
    # yield [ 'tex', "\\begin{flushright}", ]
    yield sub_event for sub_event in content
    # yield [ 'tex', "\\par\\end{flushright}", ]
    # yield [ 'tex', "\\par", ]
    # yield [ 'tex', "\\vfill{}", ]
    yield [ 'tex', "\\end{minipage}};%\n", ]
    # yield [ 'tex', "{\\framebox{\\begin{minipage}[t][#{d.height}\\mktsTableUnitheight][t]{#{d.width}\\mktsTableUnitwidth}%\n", ]
    # yield [ 'tex', "A\\hfill{}B\\hfill{}C\\end{minipage}}};%\n", ]
  #.........................................................................................................
  yield return


#===========================================================================================================
# EVENT GENERATORS: DEBUGGING EVENTS
#-----------------------------------------------------------------------------------------------------------
@_walk_debug_cellgrid_events = ( me ) ->
  unless me.debug
    yield return
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  top       = ( @_top_from_row_nr     me, 1             ) - 3
  bottom    = ( @_bottom_from_row_nr  me, me.gridheight ) + 3
  for col_nr in [ 1 .. me.gridwidth + 1 ]
    x = @_left_from_col_nr me, col_nr
    yield [ 'tex', "\\draw[sDebugCellgrid] (#{x},#{top}) -- (#{x},#{bottom});\n", ]
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  left      = ( @_left_from_col_nr    me, 1             ) - 3
  right     = ( @_right_from_col_nr   me, me.gridwidth  ) + 3
  for row_nr in [ 1 .. me.gridheight + 1 ]
    y = @_top_from_row_nr me, row_nr
    yield [ 'tex', "\\draw[sDebugCellgrid] (#{left},#{y}) -- (#{right},#{y});\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_fieldgrid_events = ( me ) ->
  unless me.debug
    yield return
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
    yield [ 'tex', "\n", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_debug_joints_events = ( me ) ->
  unless me.debug
    yield return
  @_ensure_joint_coordinates  me
  #.........................................................................................................
  ### TAINT use fixed size like 1mm ###
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'short'
    for row_nr from @_walk_row_numbers me, 'short'
      x = ( @_left_from_col_nr  me, col_nr ) + 2
      y = ( @_top_from_row_nr   me, row_nr ) + 2
      cellkey = "#{col_letter}#{row_nr}"
      yield [ 'tex', "\\node[sDebugJoints] at (#{x},#{y}) {{\\mktsStyleCode{}#{cellkey}}}; ", ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_fail_events = ( me ) ->
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
@_ensure_gridwidth = ( me ) ->
  return null if me.gridwidth?
  throw new Error "(MKTS/TABLE µ5307) gridwidth must be set"

#-----------------------------------------------------------------------------------------------------------
@_ensure_gridheight = ( me ) ->
  return null if me.gridheight?
  throw new Error "(MKTS/TABLE µ6708) gridheight must be set"

#-----------------------------------------------------------------------------------------------------------
@_ensure_cellwidths = ( me ) ->
  return null if ( me.cellwidths.length is me.gridwidth + 1 ) and ( null not in me.cellwidths[ 1 .. ] )
  throw new Error "(MKTS/TABLE µ4039) cellwidths must be all set; got #{rpr me.cellwidths}"

#-----------------------------------------------------------------------------------------------------------
@_ensure_cellheights = ( me ) ->
  return null if ( me.cellheights.length is me.gridheight + 1 ) and ( null not in me.cellheights[ 1 .. ] )
  throw new Error "(MKTS/TABLE µ8054) cellheights must be all set; got #{rpr me.cellheights}"

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
  for [ col_letter, col_nr, ] from @_walk_column_letters_and_numbers me, 'short'
    for row_nr from @_walk_row_numbers me, 'short'
      designation   = "#{col_letter}#{row_nr}"
      left   = @_left_from_col_nr   me, col_nr
      right  = @_right_from_col_nr  me, col_nr
      top    = @_top_from_row_nr    me, row_nr
      bottom = @_bottom_from_row_nr me, row_nr
      # ### TAINT must not become negative ###
      # cellwidth_u   = right  - left # - 2 * me.marginwidth
      # cellheight_u  = bottom - top  # - 2 * me.marginheight
      me.cell_dimensions[ designation ] = {
        col_nr,         row_nr,
        left,    right,
        top,     bottom, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_field_dimensions = ( me ) ->
  ### TAINT use me.field_dimensions ###
  for designation, fieldcells of me.fieldcells
    left   = ( @_left_from_col_nr   me, fieldcells.left    )
    right  = ( @_right_from_col_nr  me, fieldcells.right   )
    top    = ( @_top_from_row_nr    me, fieldcells.top     )
    bottom = ( @_bottom_from_row_nr me, fieldcells.bottom  )
    width       = right  - left
    height      = bottom - top
    me.field_dimensions[ designation ] = {
      left,  right,   width,
      top,   bottom,  height, }
  return null

#-----------------------------------------------------------------------------------------------------------
@_compute_border_dimensions = ( me ) ->
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
@_left_from_col_nr = ( me, col_nr ) ->
  ### TAINT should precompute ###
  @_ensure_cellwidths me
  R = 0
  R += me.cellwidths[ nr ] for nr in [ 1 ... col_nr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_right_from_col_nr = ( me, col_nr ) ->
  return ( @_left_from_col_nr me, col_nr ) + me.cellwidths[ col_nr ]

#-----------------------------------------------------------------------------------------------------------
@_top_from_row_nr = ( me, row_nr ) ->
  ### TAINT should precompute ###
  @_ensure_cellheights me
  R = 0
  R += me.cellheights[ nr ] for nr in [ 1 ... row_nr ]
  return R

#-----------------------------------------------------------------------------------------------------------
@_bottom_from_row_nr = ( me, row_nr ) ->
  return ( @_top_from_row_nr me, row_nr ) + me.cellheights[ row_nr ]

#-----------------------------------------------------------------------------------------------------------
@_fieldnames_from_cellkeys = ( me, cellkeys ) ->
  R = new Set()
  for cellkey in cellkeys
    continue unless ( cellfields = me.cellfields[ cellkey ] )?
    R.add fieldname for fieldname in cellfields
  return ( fieldname for fieldname from R )


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
@_walk_fieldcells = ( me, fieldcells ) ->
  for row_nr in [ fieldcells.top .. fieldcells.bottom ]
    for col_nr in [ fieldcells.left .. fieldcells.right ]
      ### TAINT don't use EXCJSCC directly ###
      col_letter  = ( EXCJSCC.n2l col_nr ).toLowerCase()
      designation = "#{col_letter}#{row_nr}"
      yield { col_nr, row_nr, col_letter, designation, }
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_f_field_designations_from_hints = ( me, fieldhints ) ->
  ### TAINT this will have to be changed to allow for named fields ###
  count           = 0
  fieldhints_set  = new Set ( _.trim() for _ in fieldhints.split ',' )
  #.........................................................................................................
  if fieldhints_set.has '*'
    keys    = Object.keys me.fieldcells
    count  += keys.length
    yield [ null, key, ] for key in keys
  #.........................................................................................................
  else
    seen_field_designations = new Set()
    for fieldhint from fieldhints_set
      continue unless ( field_designations = me.cellfields[ fieldhint ] )?
      for field_designation in field_designations
        continue if seen_field_designations.has field_designation
        seen_field_designations.add field_designation
        count += +1
        yield [ null, field_designation, ]
  #.........................................................................................................
  if count is 0
    yield [ ( _fail me, 'µ5131', "field hints #{rpr fieldhints} do not match any field" ), null ]
  #.........................................................................................................
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_table_edge_field_designations = ( me, edge ) ->
  seen_field_designations = new Set()
  for d from @_walk_table_edge_cells me, edge
    continue unless ( field_designations = me.cellfields[ d.cellkey ] )?
    for field_designation in field_designations
      continue if seen_field_designations.has field_designation
      seen_field_designations.add field_designation
      yield field_designation
  yield return

#-----------------------------------------------------------------------------------------------------------
@_walk_table_edge_cells = ( me, edge ) ->
  switch edge
    when 'left'
      col_nr_1    = 1
      col_nr_2    = 1
      row_nr_1    = 1
      row_nr_2    = me.gridheight
    when 'right'
      col_nr_1    = me.gridwidth
      col_nr_2    = me.gridwidth
      row_nr_1    = 1
      row_nr_2    = me.gridheight
    when 'top'
      col_nr_1    = 1
      col_nr_2    = me.gridwidth
      row_nr_1    = 1
      row_nr_2    = 1
    when 'bottom'
      col_nr_1    = 1
      col_nr_2    = me.gridwidth
      row_nr_1    = me.gridheight
      row_nr_2    = me.gridheight
    when '*'
      yield from @_walk_table_edge_cells me, 'left'
      yield from @_walk_table_edge_cells me, 'right'
      yield from @_walk_table_edge_cells me, 'top'
      yield from @_walk_table_edge_cells me, 'bottom'
      yield return
    else
      throw new Error "(MKTS/TABLE µ9803) illegal argument for edge #{rpr edge}"
  for row_nr in [ row_nr_1 .. row_nr_2 ]
    for col_nr in [ col_nr_1 .. col_nr_2 ]
      ### TAINT don't use EXCJSCC directly ###
      col_letter  = ( EXCJSCC.n2l col_nr ).toLowerCase()
      cellkey     = "#{col_letter}#{row_nr}"
      yield { col_nr, row_nr, col_letter, cellkey, edge, }
  yield return


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
  filename  = me.meta.filename ? '<NOFILENAME>'
  line_nr   = me.meta.line_nr ? '(NOLINENR)'
  return "[#{badge}##{ref}: #{filename}##{line_nr}]: #{message}"

#-----------------------------------------------------------------------------------------------------------
_record = ( me, message ) ->
  me.fails.push message
  return null

#-----------------------------------------------------------------------------------------------------------
_record_fail = ( me, ref, message ) -> _record me, _fail me, ref, message


