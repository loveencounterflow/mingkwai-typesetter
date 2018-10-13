


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
jr                        = JSON.stringify
#...........................................................................................................
MKTS_TABLE                = require './mkts-table'
MKTS.MACRO_ESCAPER.register_raw_tag 'mkts-table-description'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$parse_description               S
    @$render_description              S
    # @$dump_table_description          S
    ]

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$dump_table_description = ( S ) -> D.$observe ( event ) ->
  return unless select event, '.', 'MKTS/TABLE/description', true
  help '99871', ( CND.blue rpr event[ 2 ] )

#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S ) ->
  within_mkts_table = false
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'mkts-table-description'
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
  ### TAINT should allow to name tables in description and content tags ###
  prv_description       = null
  within_table_content  = false
  within_field           = false
  fields                 = {}
  current_field          = null
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'MKTS/TABLE/description'
      [ type, name, description, meta, ]  = event
      prv_description                     = description
      return send stamp event
    #.......................................................................................................
    if select event, '(', 'mkts-table-content'
      within_table_content = true
      return send stamp event
    #.......................................................................................................
    if select event, ')', 'mkts-table-content'
      within_table_content = false
      # send sub_event for sub_event from MKTS_TABLE._walk_events description
      ### TAINT render table now ###
      debug '66522', fields
      return send stamp event
    #.......................................................................................................
    if within_table_content
      #.....................................................................................................
      if select event, '(', 'field'
        within_field = true
        [ type, name, Q, meta, ]  = event
        if not Q? and Q.key?
          throw new Error "need key for field"
        ### TAINT must validate key at some point; like this, content with an unknown key will just vanish ###
        current_field = fields[ Q.key ] = []
        return send stamp event
      #.....................................................................................................
      if select event, ')', 'field'
        within_field   = false
        current_field  = null
        return send stamp event
      #.....................................................................................................
      if within_field
        current_field.push event
        urge '27762', jr event
        return send stamp event
      #.....................................................................................................
      if ( select event, '.', 'text' ) and ( event[ 2 ].match /^\s*$/ )?
        whisper '27762', jr event
        return send stamp event
      #.....................................................................................................
      # throw new Error "detected illegal content: #{rpr event}"
      warn '27762', jr event
      return
    #.......................................................................................................
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
    @cellwidths       = ( raw_parts ) -> MKTS_TABLE.cellwidths      me, raw_parts.join ''
    @cellheights      = ( raw_parts ) -> MKTS_TABLE.cellheights     me, raw_parts.join ''
    @fieldcells       = ( raw_parts ) -> MKTS_TABLE.fieldcells      me, raw_parts.join ''
    @fieldborder      = ( raw_parts ) -> MKTS_TABLE.fieldborder     me, raw_parts.join ''
    return @
  #.........................................................................................................
  return [ me, ( f.apply {} ), ]



