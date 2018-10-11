


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
MKTS_TABLE                = require './mkts-table-1'
MKTS.MACRO_ESCAPER.register_raw_tag 'mkts-table-description-1'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$parse_description               S
    @$render_description              S
    @$dump_table_description          S
    ]

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$dump_table_description = ( S ) -> D.$observe ( event ) ->
  return unless select event, '.', 'MKTS/TABLE/description-1', true
  help '99871', ( CND.blue rpr event[ 2 ] )

#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S ) ->
  within_mkts_table = false
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'mkts-table-description-1'
      [ type, name, text, meta, ] = event
      [ description, sandbox, ]   = @get_mkts_table_description_and_sandbox S, event
      try
        ECS.evaluate text, { language: 'coffee', sandbox, }
      catch error
        warn "when trying to evaluate CS source text for <mkts-table> (source line ##{meta.line_nr}),"
        warn "an error occurred"
        throw error
      send stamp event
      send [ '.', 'MKTS/TABLE/description-1', description, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$render_description = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', 'MKTS/TABLE/description-1'
    [ type, name, description, meta, ] = event
    send sub_event for sub_event from MKTS_TABLE._walk_events description
    send stamp event
    return null

#-----------------------------------------------------------------------------------------------------------
@get_mkts_table_description_and_sandbox = ( S, event ) ->
  ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
  curried so that the current context (`me`) that contains the processed details as defined so far as well
  as data on the general typesetting context. All names are templating functions, such that each may be
  called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
  table is being defined. ###
  me      = MKTS_TABLE._new_description S
  me.meta = event[ 3 ]
  ### ... more typesetting detail attached here ... ###
  #.........................................................................................................
  f = ->
    @debug            = ( raw_parts ) -> MKTS_TABLE.debug           me, raw_parts.join ''
    @gridwidth        = ( raw_parts ) -> MKTS_TABLE.gridwidth       me, raw_parts.join ''
    @gridheight       = ( raw_parts ) -> MKTS_TABLE.gridheight      me, raw_parts.join ''
    @paddingwidth     = ( raw_parts ) -> MKTS_TABLE.paddingwidth    me, raw_parts.join ''
    @paddingheight    = ( raw_parts ) -> MKTS_TABLE.paddingheight   me, raw_parts.join ''
    @marginwidth      = ( raw_parts ) -> MKTS_TABLE.marginwidth     me, raw_parts.join ''
    @marginheight     = ( raw_parts ) -> MKTS_TABLE.marginheight    me, raw_parts.join ''
    @unitwidth        = ( raw_parts ) -> MKTS_TABLE.unitwidth       me, raw_parts.join ''
    @unitheight       = ( raw_parts ) -> MKTS_TABLE.unitheight      me, raw_parts.join ''
    @quadwidths       = ( raw_parts ) -> MKTS_TABLE.quadwidths      me, raw_parts.join ''
    @quadheights      = ( raw_parts ) -> MKTS_TABLE.quadheights     me, raw_parts.join ''
    @cellquads        = ( raw_parts ) -> MKTS_TABLE.cellquads       me, raw_parts.join ''
    @cellborder       = ( raw_parts ) -> MKTS_TABLE.cellborder      me, raw_parts.join ''
    return @
  #.........................................................................................................
  return [ me, ( f.apply {} ), ]



