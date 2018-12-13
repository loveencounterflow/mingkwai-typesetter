
'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/EMBEDDED-FILE'
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
XREGEXP                   = require 'xregexp'
PS                        = require 'pipestreams'
{ $, $async, }            = PS
# new_pushable              = require 'pull-pushable'
assign                    = Object.assign
jr                        = JSON.stringify

#-----------------------------------------------------------------------------------------------------------
@get_path_and_fragment = ( xpath ) ->
  return { path: xpath, fragment: null, } unless ( match = xpath.match /^(?<path>.*?)(?<fragment>[^#]+)$/ )?
  return { path: match.groups.path, fragment: match.groups.fragment, }

#-----------------------------------------------------------------------------------------------------------
@read_embedded_file = ( xpath ) ->
  d         = @get_path_and_fragment xpath
  source    = PS.new_file_source xpath
  #.........................................................................................................
  on_stop   = PS.new_event_collector 'stop', -> help 'ok'
  pipeline  = []
  pipeline.push source
  pipeline.push PS.$split()
  pipeline.push PS.$show()
  pipeline.push on_stop.add PS.$drain()
  PS.pull pipeline...



