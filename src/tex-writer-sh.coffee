
'use strict'

############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/tex-writer-sh'
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
D                         = require '../../../pipedreams'
{ $ }                     = D
$async                    = D.remit_async.bind D
#...........................................................................................................
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
#...........................................................................................................
CP                        = require 'child_process'


#-----------------------------------------------------------------------------------------------------------
@$spawn = ( S ) =>
  return $async ( event, send, end ) =>
    #.......................................................................................................
    if event? and select event, '!', 'sh'
      [ type, name, parameters, meta, ] = event
      [ cmd, ]  = parameters
      cp        = CP.spawn cmd, { shell: true, }
      cp.stdout
        .pipe D.$split()
        .pipe D.$show '================>'
        #...................................................................................................
        .pipe $ ( line, _, sub_end ) =>
          send [ '.', 'text', line + '\n', ( copy meta ), ]
          if sub_end?
            send.done()
            sub_end()
    #.......................................................................................................
    else
      send event
      send.done()
    #.......................................................................................................
    end() if end?
    return null


