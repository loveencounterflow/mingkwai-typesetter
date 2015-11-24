



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/MACROS'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#-----------------------------------------------------------------------------------------------------------
D                         = require 'pipedreams'
$                         = D.remit.bind D
# $async                    = D.remit_async.bind D
#...........................................................................................................
# Markdown_parser           = require 'markdown-it'
# # Html_parser               = ( require 'htmlparser2' ).Parser
# new_md_inline_plugin      = require 'markdown-it-regexp'
#...........................................................................................................
# HELPERS                   = require './HELPERS'
#...........................................................................................................
# misfit                    = Symbol 'misfit'
MKTS                      = require './main'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$process_actions = ( S ) =>
  copy  = MKTS.MD_READER.copy.bind  MKTS.MD_READER
  stamp = MKTS.MD_READER.stamp.bind MKTS.MD_READER
  hide  = MKTS.MD_READER.hide.bind  MKTS.MD_READER
  #.........................................................................................................
  CS                        = require 'coffee-script'
  VM                        = require 'vm'
  local_filename            = 'XXXXXXXXXXXXX'
  S.local                   = { definitions: new Map(), }
  sandbox =
    urge:         CND.get_logger 'urge', local_filename
    help:         CND.get_logger 'help', local_filename
    __filename:   local_filename
    define:       ( pod ) ->
      for key, value of pod
        S.local.definitions.set key, value
  # sandbox[ '__sandbox' ] = sandbox
  VM.createContext sandbox
  #.........................................................................................................
  return $ ( event, send ) =>
    # warn "re-defining command #{rpr identifier}" if S.definitions[ identifier ]?
    # S.definitions[ identifier ] = []
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'action'
      send stamp hide event
      [ type, action, source, meta, ] = event
      { mode, language, line_nr, }    = meta
      #.....................................................................................................
      switch language
        when 'js'
          js_source = source
        when 'coffee'
          js_source = CS.compile source, { bare: true, filename: local_filename, }
        else
          return send.error new Error "unknown language #{rpr language} in action on line ##{line_nr}"
      #.....................................................................................................
      value = VM.runInContext js_source, sandbox, { filename: local_filename, }
      urge '4742', js_source
      urge '4742', rpr value
      debug '©YMF7F', sandbox
      debug '©YMF7F', S.local.definitions
      #.....................................................................................................
      switch mode
        when 'silent'
          null
        when 'vocal'
          ### TAINT must resend to allow for TeX-escaping (or MD-escaping?) ###
          ### TAINT send `tex` or `text`??? ###
          value_rpr = if ( CND.isa_text value ) then value else rpr value
          send [ '.', 'text', value_rpr, ( copy meta ), ]
    #.......................................................................................................
    else
      send event

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.COMMAND.$expansion = ( S ) =>
#   remark = MD_READER._get_remark()
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     if MKTS.MD_READER.select event, '!'
#       [ type, identifier, _, meta, ] = event
#       if ( definition = S.local.definitions.get identifier )?
#         # send stamp hide event
#         send stamp hide [ '(', '!', identifier, ( copy meta ), ]
#         # send copy sub_event for sub_event in definition
#         # debug '@16', rpr definition
#         send remark 'resend', "expanding `#{identifier}`", ( copy meta )
#         S.resend definition # [ '.', 'text', definition, ( copy meta ), ]
#         send stamp hide [ ')', '!', identifier, ( copy meta ), ]
#       else
#         send event
#     #.......................................................................................................
#     else
#       send event
