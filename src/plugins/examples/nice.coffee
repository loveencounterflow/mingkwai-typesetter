

'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/PLUGINS/MY-PLUGIN'
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
MD_READER                 = require '../../md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
#...........................................................................................................
### plugins must use pipestreams ###
PS                        = require 'pipestreams'
{ $, $async, }            = PS

#-----------------------------------------------------------------------------------------------------------
@$nice = ( S, settings ) ->
  ### kludge to generate prefixed name; this will be changed in next version ###
  nice = "#{settings.prefix}-nice"
  return $ ( event, send ) =>
    [ ..., meta, ] = event
    if select event, '(', nice
      send [ '.', 'text', "(NICE:", ( copy meta ), ]
      send stamp event
    else if select event, ')', nice
      send [ '.', 'text', ":NICE)", ( copy meta ), ]
      send stamp event
    else
      send event
    return null

#-----------------------------------------------------------------------------------------------------------
@$spec = ( S, settings ) ->
  ### kludge to generate prefixed name; this will be changed in next version ###
  spec = "#{settings.prefix}-spec"
  return $ ( event, send ) =>
    [ ..., meta, ] = event
    if select event, '(', spec
      # send [ '.', 'mktscript', "<em>", ( copy meta ), ]
      send [ '.', 'mktscript', "(<em>!!!MKTScript</em>", ( copy meta ), ]
      send stamp event
    else if select event, ')', spec
      # send [ '.', 'mktscript', "</em>", ( copy meta ), ]
      send [ '.', 'mktscript', "<em>!!!MKTScript</em>)", ( copy meta ), ]
      send stamp event
    else
      send event
    return null

#-----------------------------------------------------------------------------------------------------------
@main = ( S, settings ) ->
  pipieline = []
  pipieline.push @$nice  S, settings
  pipieline.push @$spec  S, settings
  return PS.pull pipieline...






