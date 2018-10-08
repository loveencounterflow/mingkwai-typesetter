


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TEX-WRITER/MKTSTABLE'
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
MKTS_TABLE                = require './mkts-table'
MKTS.MACRO_ESCAPER.register_raw_tag 'mkts-table'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$parse_description               S
    @$render_description              S
    @$show_metrics                    S
    ]

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$show_metrics = ( S ) -> D.$observe ( event ) ->
  return unless select event, '.', 'MKTS/TABLE/description'
  help '99871', ( CND.blue rpr event[ 2 ] )

#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'mkts-table'
      [ type, name, text, meta, ] = event
      [ description, sandbox, ]   = @get_mkts_table_description_and_sandbox S, event
      try
        ECS.evaluate text, { language: 'coffee', sandbox, }
      catch error
        warn "when trying to evaluate CS source text for <mkts-table> (source line ##{meta.line_nr}),"
        warn "an error occurred"
        throw error
      send stamp event
      send [ '.', 'MKTS/TABLE/description', description, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$render_description = ( S ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'MKTS/TABLE/description'
      [ type, name, description, meta, ] = event
      for sub_event in MKTS_TABLE.mkts_events_from_table_description description
        ### TAINT supply meta? ###
        send sub_event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@get_mkts_table_description_and_sandbox = ( S, event ) ->
  ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
  curried so that the current context (`me`) that contains the processed details as defined so far as well
  as data on the general typesetting context. All names are templating functions, such that each may be
  called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
  table is being defined. ###
  me      = MKTS_TABLE.new_description S
  me.meta = event[ 3 ]
  ### ... more typesetting detail attached here ... ###
  #.........................................................................................................
  f = ->
    @grid   = ( raws ) ->
      MKTS_TABLE.grid  me, raws.join ''
      # debug '44343', 'grid ->', me
    @merge  = ( raws ) ->
      MKTS_TABLE.merge me, raws.join ''
      # debug '44343', 'merge ->', me
    return @
  #.........................................................................................................
  return [ me, ( f.apply {} ), ]

