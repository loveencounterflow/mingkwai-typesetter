


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

#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$parse_description         S
    @$grid                      S
    D.$observe ( event ) ->
      return unless select event, '.', 'mkts-table-description'
      help '99871', ( CND.blue rpr event[ 2 ] )
    ]


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'mkts-table'
      [ type, name, text, meta, ] = event
      try
        description = ECS.evaluate text, { language: 'coffee', }
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
@$grid = ( S ) -> D.$observe ( event ) =>
  return unless select event, '.', 'mkts-table-description'
  [ _, _, d, meta, ] = event
  #.........................................................................................................
  unless ( type = CND.type_of d.grid ) is 'text'
    throw new Error "need a text for mkts-table/grid, got a #{type}"
  unless ( match = d.grid.match /^(\d+)\s*x(\d+)$/ )?
    throw new Error "need a text like '3 x 4' or similar for mkts-table/grid, got #{rpr d.grid}"
  #.........................................................................................................
  [ _, col_count_txt, row_count_txt, ] = match
  d.grid = [ ( parseInt col_count_txt, 10 ), ( parseInt row_count_txt, 10 ), ]
  #.........................................................................................................
  return null



