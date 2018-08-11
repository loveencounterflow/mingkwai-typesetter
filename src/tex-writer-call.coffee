
'use strict'

############################################################################################################
PATH                      = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/tex-writer-call'
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
PIPEDREAMS                = require '../../../pipedreams'
PS                        = require 'pipestreams'
{ $, $async, }            = PS
#...........................................................................................................
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER

#-----------------------------------------------------------------------------------------------------------
@_resolve_arguments = ( S, event ) =>
  reference_path                      = S.layout_info[ 'source-home' ]
  [ type, name, parameters, meta, ]   = event
  [ module_path, method_path, P..., ] = parameters
  locator                             = PATH.join reference_path, module_path
  [ crumbs..., method_name, ]         = method_path.split '.'
  #.....................................................................................................
  try
    module  = require locator
    module  = module[ crumb ] for crumb in crumbs
  catch error
    alert '98987', "when trying to resolve #{crumbs.join '.'}"
    alert '98987', "starting with module #{rpr locator}"
    alert '98987', "an error occurred at path component #{rpr crumb}"
    throw error
  #.....................................................................................................
  return {
    type,
    name,
    parameters,
    meta,
    module_path,
    method_path,
    P,
    method_name,
    locator,
    module,
    crumbs, }

#-----------------------------------------------------------------------------------------------------------
@$call_await = ( S ) =>
  ### TAINT implicitly assumes return value will be lines of text ###
  ### parses MKTS commands of the form `<<!call_await module_path, method_name, parameters... >>` ###
  # self = @
  return PIPEDREAMS.$async ( event, send, end ) =>
    #.......................................................................................................
    if event? and select event, '!', 'call_await'
      { module, method_name, P, meta, locator, crumbs, } = @_resolve_arguments S, event
      #.....................................................................................................
      try
        lines   = await module[ method_name ] P...
      #.....................................................................................................
      catch error
        alert '98987', "when trying to call method #{rpr method_name}"
        alert '98987', "from module #{rpr locator}##{crumbs.join '.'}"
        alert '98987', "with arguments #{rpr P}"
        alert '98987', "an error occurred:"
        alert '98987', error.message
        throw error if throw_all_errors
        send [ '.', 'warning', error.message, ( copy meta ), ]
        return send.done()
      #.....................................................................................................
      for line in lines
        if CND.isa_text line
          line = line + '\n' unless line.endsWith '\n'
          send [ '.', 'text', line, ( copy meta ), ]
        else
          send line
      send.done()
    #.......................................................................................................
    else
      send event
      send.done()
    #.......................................................................................................
    end() if end?
    return null

#-----------------------------------------------------------------------------------------------------------
@$call_stream = ( S ) =>
  ### TAINT implicitly assumes return value will be lines of text ###
  # self = @
  return PIPEDREAMS.$async ( event, send, end ) =>
    #.......................................................................................................
    if event? and select event, '!', 'call_stream'
      { module, method_name, P, meta, locator, crumbs, } = @_resolve_arguments S, event
      #.....................................................................................................
      try
        on_stop   = PS.new_event_collector 'stop', ->
          send.done()
          help "(finished $call_stream #{method_name})"
        pipeline  = []
        pipeline.push await module[ method_name ] P...
        pipeline.push PS.$watch ( line ) ->
          if CND.isa_text line
            line = line + '\n' unless line.endsWith '\n'
            send [ '.', 'text', line, ( copy meta ), ]
          else
            send line
          return null
        pipeline.push on_stop.add PS.$drain()
        PS.pull pipeline...
      #.....................................................................................................
      catch error
        alert '98987', "when trying to call method #{rpr method_name}"
        alert '98987', "from module #{rpr locator}##{crumbs.join '.'}"
        alert '98987', "with arguments #{rpr P}"
        alert '98987', "an error occurred:"
        alert '98987', error.message
        throw error
    #.......................................................................................................
    else
      send event
      send.done()
    #.......................................................................................................
    end() if end?
    return null


