
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
throw_all_errors          = yes


# [ ')',
#   'code',
#   [ 'keep-lines' ],
#   { line_nr: 92, col_nr: 129, markup: '```' } ]
# 00:03 mkts/tex-writer-call  ⚙  33733 [ '.',
#   'hr2',
#   { slash: true,
#     above: 0,
#     one: '-',
#     two: '',
#     three: '',
#     below: 1,
#     stop: '/' },
#   { line_nr: 130,
#     col_nr: 131,
#     markup: '/--------------------------------------------/' } ]

f = ->
  return await g()

#-----------------------------------------------------------------------------------------------------------
@$call = ( S ) =>
  reference_path = S.layout_info[ 'source-home' ]
  # self = @
  return $async ( event, send, end ) =>
    #.......................................................................................................
    if event? and select event, '!', 'call'
      [ type, name, parameters, meta, ]   = event
      [ module_path, method_path, P..., ] = parameters
      lines                               = null
      locator                             = PATH.join reference_path, module_path
      [ crumbs..., method_name, ]         = method_path.split '.'
      send [ '.', 'text', "76765 module:#{rpr module_path}\n",        ( copy meta ), ]
      send [ '.', 'text', "76765 method: #{rpr method_path}\n",       ( copy meta ), ]
      send [ '.', 'text', "76765 P: #{rpr P}\n",                      ( copy meta ), ]
      ### TAINT could result be streamed? ###
      #.....................................................................................................
      try
        module  = require locator
        module  = module[ crumb ] for crumb in crumbs
      catch error
        alert '98987', "when trying to resolve #{crumbs.join '.'}"
        alert '98987', "starting with module #{rpr locator}"
        alert '98987', "an error occurred at path component #{rpr crumb}"
        throw error if throw_all_errors
        send [ '.', 'warning', error.message, ( copy meta ), ]
        return send.done()
      #.....................................................................................................
      try
        # process.chdir '/home/flow/io/mingkwai-rack/texts/800-demo-actions/mojikura3-model'
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
        line = line + '\n' unless line.endsWith '\n'
        send [ '.', 'text', line, ( copy meta ), ]
      send.done()
    #.......................................................................................................
    else
      send event
      send.done()
    #.......................................................................................................
    end() if end?
    return null


