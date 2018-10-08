


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/MKTSTABLES'
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
MKTS.MACRO_ESCAPER.register_raw_tag 'mkts-table'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$parse_description               S
    @$show_metrics                    S
    ]


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$show_metrics = ( S ) -> D.$observe ( event ) ->
  return unless select event, '.', 'mkts-table-description'
  help '99871', ( CND.blue rpr event[ 2 ] )

#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'mkts-table'
      [ type, name, text, meta, ] = event
      description                 = {}
      sandbox                     = @get_mkts_table_definition_language_sandbox S, event, description
      debug '37733', sandbox
      try
        ECS.evaluate text, { language: 'coffee', sandbox, }
      catch error
        warn "when trying to evaluate CS source text for <mkts-table> (source line ##{meta.line_nr}),"
        warn "an error occurred"
        throw error
      send stamp event
      send [ '.', 'mkts-table-description', description, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@get_mkts_table_definition_language_sandbox = ( S, event, description ) ->
  ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
  curried so that the current context (`me`) that contains the processed details as defined so far as well
  as data on the general typesetting context. All names are templating functions, such that each may be
  called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
  table is being defined. ###
  me      = description
  me.meta = event[ 3 ]
  ### ... more typesetting detail attached here ... ###
  #.........................................................................................................
  f = ->
    @grid   = ( template ) -> MKTSTF.grid  me, template
    @merge  = ( template ) -> MKTSTF.merge me, template
    return @
  #.........................................................................................................
  return f.apply {}


#===========================================================================================================
# MKTS TABLE FORMATTER
#-----------------------------------------------------------------------------------------------------------
require_mkts_table_formatter = ->

  #-----------------------------------------------------------------------------------------------------------
  @grid = ( me, t ) ->
    #.........................................................................................................
    if me.grid?
      throw new Error "(MKTSTABLES 3124) illegal to redefine grid"
    unless ( type = CND.type_of t ) is 'text'
      throw new Error "(MKTSTABLES 5183) need a text for mkts-table/grid, got a #{type}"
    unless ( match = t.match /^(\d+)\s*x(\d+)$/ )?
      throw new Error "(MKTSTABLES 7414) need a text like '3 x 4' or similar for mkts-table/grid, got #{rpr t}"
    #.........................................................................................................
    [ _, col_count_txt, row_count_txt, ] = match
    me.grid = { width: ( parseInt col_count_txt, 10 ), height: ( parseInt row_count_txt, 10 ), }
    #.........................................................................................................
    return null

  #-----------------------------------------------------------------------------------------------------------
  @merge = ( me, text ) ->
    me.cells ?= []
    #.........................................................................................................
    unless ( type = CND.type_of text ) is 'text'
      throw new Error "(MKTSTABLES 3075) need a text for mkts-table/merge, got a #{type}"
    #.........................................................................................................
    for merge_quadref, idx in d.merge
      me.cells.push @parse_merge_quadref merge_quadref
    #.........................................................................................................
    return null

  #-----------------------------------------------------------------------------------------------------------
  @_idx_from_col_and_row = ( col, row ) ->
    unless ( type = CND.type_of col ) is 'text'
      throw new Error "(MKTSTABLES 4726) expected a text for col, got a #{rpr type}"
    unless ( type = CND.type_of row ) is 'text'
      throw new Error "(MKTSTABLES 8186) expected a text for row, got a #{rpr type}"
    col_idx = ( col.codePointAt 0 ) - ( 'a'.codePointAt 0 )
    row_idx = ( parseInt row, 10 ) - 1
    return { col: col_idx, row: row_idx, }

  #-----------------------------------------------------------------------------------------------------------
  ### TAINT use proper parsing tool ###
  @parse_merge_quadref = ( merge_quadref ) ->
    unless ( type = CND.type_of merge_quadref ) is 'text'
      throw new Error "(MKTSTABLES 2120) expected a text for merge_quadref, got a #{rpr type}"
    ### TAINT only supports quadrefs `[a1]` thru `[z99]` ###
    unless ( match = merge_quadref.match /^\[([a-z])([0-9]{1,2})\]\.\.\[([a-z])([0-9]{1,2})\]$/ )?
      throw new Error "(MKTSTABLES 6098) expected a merge-quadref like '[a1]..[d4]', got #{rpr merge_quadref}"
    debug '37373', match
    [ _, q1col, q1row, q2col, q2row, ] = match
    q1idx = @_idx_from_col_and_row q1col, q1row
    q2idx = @_idx_from_col_and_row q2col, q2row
    ### TAINT validate that q2 is not to the left / top of q1 ###
    return { q1idx, q2idx, }

  #-----------------------------------------------------------------------------------------------------------
  return null


############################################################################################################
MKTSTF = {}
require_mkts_table_formatter.apply MKTSTF


