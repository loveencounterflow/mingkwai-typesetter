





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
ECS                       = require './eval-cs'
### TAINT cyclic dependency ###
MKTS_TABLE                = require './mkts-table'
TW_MKTS_TABLE             = require './tex-writer-mkts-table'


#-----------------------------------------------------------------------------------------------------------
@read_layout = ( S, L, event, source ) ->
  [ R, sandbox, ] = @get_mkts_table_description_and_sandbox S, L, event
  try
    ECS.evaluate source, { language: 'coffee', sandbox, }
  catch error
    warn "when trying to evaluate CS source text for <mkts-table> an error occurred"
    throw error
  return R

#-----------------------------------------------------------------------------------------------------------
@get_mkts_table_description_and_sandbox = ( S, L, event ) ->
  ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
  curried so that the current context (`me`) that contains the processed details as defined so far as well
  as data on the general typesetting context. All names are templating functions, such that each may be
  called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
  table is being defined. ###
  me      = MKTS_TABLE._new_description S
  ### ... more typesetting detail attached here ... ###
  #.........................................................................................................
  f = =>
    @copy                 = ( raw_parts ) => TW_MKTS_TABLE._API_copy S, L, me, raw_parts.join ''
    #.........................................................................................................
    @name                 = ( raw_parts ) -> MKTS_TABLE.name                  me, raw_parts.join ''
    @debug                = ( raw_parts ) -> MKTS_TABLE.debug                 me, raw_parts.join ''
    @grid                 = ( raw_parts ) -> MKTS_TABLE.grid                  me, raw_parts.join ''
    @fill_gap             = ( raw_parts ) -> MKTS_TABLE.fill_gap              me, raw_parts.join ''
    @padding              = ( raw_parts ) -> MKTS_TABLE.padding               me, raw_parts.join ''
    @margin               = ( raw_parts ) -> MKTS_TABLE.margin                me, raw_parts.join ''
    @unitwidth            = ( raw_parts ) -> MKTS_TABLE.unitwidth             me, raw_parts.join ''
    @unitheight           = ( raw_parts ) -> MKTS_TABLE.unitheight            me, raw_parts.join ''
    @columnwidth          = ( raw_parts ) -> MKTS_TABLE.columnwidth           me, raw_parts.join ''
    @rowheight            = ( raw_parts ) -> MKTS_TABLE.rowheight             me, raw_parts.join ''
    @fieldcells           = ( raw_parts ) -> MKTS_TABLE.fieldcells            me, raw_parts.join ''
    @fieldborder          = ( raw_parts ) -> MKTS_TABLE.fieldborder           me, raw_parts.join ''
    @fieldalignvertical   = ( raw_parts ) -> MKTS_TABLE.fieldalignvertical    me, raw_parts.join ''
    @fieldalignhorizontal = ( raw_parts ) -> MKTS_TABLE.fieldalignhorizontal  me, raw_parts.join ''
    return @
  #.........................................................................................................
  return [ me, ( f.apply {} ), ]








