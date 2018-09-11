

'use strict'



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA3/exception-handler'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
warn                      = CND.get_logger 'warn',      badge
alert                     = CND.get_logger 'alert',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND

#-----------------------------------------------------------------------------------------------------------
@exit_handler = ( exception ) ->
  # debug '55567', rpr exception
  print               = alert
  message             = 'ROGUE EXCEPTION: ' + ( exception.message ? "an unrecoverable condition occurred" )
  if exception.where?
    message += '\n--------------------\n' + exception.where + '\n--------------------'
  [ head, tail..., ]  = message.split '\n'
  print CND.reverse ' ' + head + ' '
  warn line for line in tail
  ### TAINT should have a way to set exit code explicitly ###
  whisper ( ( exception.stack.split '\n' )[ .. 15 ].join '\n' ) + '\n...'
  process.exit 1

process.on 'uncaughtException', @exit_handler
process.on 'unhandledRejection', @exit_handler

