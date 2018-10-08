


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

#-----------------------------------------------------------------------------------------------------------
@new_description = ( S ) ->
  R =
    '~isa':     'MKTS/TABLE/description'
    grid:       { width: 4, height: 4, }
    ### default unit for width, height: ###
    u:
      width:    '10mm'
      height:   '10mm'
    cells:      []
  return R

#-----------------------------------------------------------------------------------------------------------
@grid = ( me, t ) ->
  #.........................................................................................................
  unless ( type = CND.type_of t ) is 'text'
    throw new Error "(MKTS/TABLE 5183) need a text for mkts-table/grid, got a #{type}"
  unless ( match = t.match /^(\d+)\s*x(\d+)$/ )?
    throw new Error "(MKTS/TABLE 7414) need a text like '3 x 4' or similar for mkts-table/grid, got #{rpr t}"
  #.........................................................................................................
  [ _, col_count_txt, row_count_txt, ] = match
  me.grid.width   = parseInt col_count_txt, 10
  me.grid.height  = parseInt row_count_txt, 10
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@merge = ( me, text ) ->
  #.........................................................................................................
  unless ( type = CND.type_of text ) is 'text'
    throw new Error "(MKTS/TABLE 3075) need a text for mkts-table/merge, got a #{type}"
  #.........................................................................................................
  me.cells.push @parse_merge_quadref text
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_idx_from_col_and_row = ( col, row ) ->
  unless ( type = CND.type_of col ) is 'text'
    throw new Error "(MKTS/TABLE 4726) expected a text for col, got a #{rpr type}"
  unless ( type = CND.type_of row ) is 'text'
    throw new Error "(MKTS/TABLE 8186) expected a text for row, got a #{rpr type}"
  col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
  row_idx = ( parseInt row, 10 ) - 1
  return { col: col_idx, row: row_idx, }

#-----------------------------------------------------------------------------------------------------------
### TAINT use proper parsing tool ###
@parse_merge_quadref = ( merge_quadref ) ->
  unless ( type = CND.type_of merge_quadref ) is 'text'
    throw new Error "(MKTS/TABLE 2120) expected a text for merge_quadref, got a #{rpr type}"
  ### TAINT only supports quadrefs `[a1]` thru `[z99]` ###
  unless ( match = merge_quadref.match /^\[([a-z])([0-9]{1,2})\]\.\.\[([a-z])([0-9]{1,2})\]$/ )?
    throw new Error "(MKTS/TABLE 6098) expected a merge-quadref like '[a1]..[d4]', got #{rpr merge_quadref}"
  [ _, q1col, q1row, q2col, q2row, ] = match
  q1idx = @_idx_from_col_and_row q1col, q1row
  q2idx = @_idx_from_col_and_row q2col, q2row
  ### TAINT validate that q2 is not to the left / top of q1 ###
  return [ q1idx, q2idx, ]

#-----------------------------------------------------------------------------------------------------------
@mkts_events_from_table_description = ( me ) ->
  R = []
  R.push [ 'tex', '\n\n', ]
  R.push [ '(', 'code', [], ( copy me ), ]
  R.push [ '.', 'text', ( rpr me ), ( copy me ), ]
  R.push [ ')', 'code', [], ( copy me ), ]
  R.push [ 'tex', '\n\n', ]
  return R


