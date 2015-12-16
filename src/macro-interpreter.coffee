



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
  ### TAINT this is an essentially synchronous solution that will not work for async code ###
  copy  = MKTS.MD_READER.copy.bind  MKTS.MD_READER
  stamp = MKTS.MD_READER.stamp.bind MKTS.MD_READER
  hide  = MKTS.MD_READER.hide.bind  MKTS.MD_READER
  #.........................................................................................................
  CS                        = require 'coffee-script'
  VM                        = require 'vm'
  local_filename            = 'XXXXXXXXXXXXX'
  macro_output              = []
  #.........................................................................................................
  do =>
    S.compiled          = {}
    S.compiled.coffee   = {}
    S.sandbox           =
      'rpr':            CND.rpr
      urge:             CND.get_logger 'urge', local_filename
      help:             CND.get_logger 'help', local_filename
      setImmediate:     setImmediate
      echo:             ( P... ) -> macro_output.push CND.pen P...
      mkts:
        output:           macro_output
        reserved_names:   []
        __filename:       local_filename
    S.sandbox[ 'here' ] = S.sandbox
    for name of S.sandbox
      S.sandbox.mkts.reserved_names.push name
    VM.createContext S.sandbox
  #.........................................................................................................
  return $ ( event, send ) =>
    if MKTS.MD_READER.select event, '.', 'action'
      [ _, _, raw_source, meta, ]     = event
      send stamp hide event
      { mode, language, line_nr, }    = meta
      error_message                   = null
      #.....................................................................................................
      switch language
        when 'js'
          js_source = raw_source
        when 'coffee'
          unless ( js_source = S.compiled.coffee[ raw_source ] )?
            wrapped_source  = "do =>\n  " + raw_source.replace /\n/g, "\n  "
            try
              js_source     = CS.compile wrapped_source, { bare: true, filename: local_filename, }
            catch error
              error_message = error[ 'message' ] ? rpr error
            unless error_message?
              S.compiled.coffee[ raw_source ] = js_source
        else
          error_message = "unknown language #{rpr language}"
      #.....................................................................................................
      try
        action_value = VM.runInContext js_source, S.sandbox, { filename: local_filename, }
      #.....................................................................................................
      catch error
        error_message = error[ 'message' ] ? rpr error
      #.....................................................................................................
      if error_message?
        warn error_message
        ### TAINT should preserve stack trace of error ###
        ### TAINT use method to assemble warning event ###
        ### TAINT write error log with full trace, insert reference (error nr) ###
        error_message = "action on line #{line_nr}: #{error_message}"
        send [ '.', 'warning', error_message, ( copy meta ), ]
      #.....................................................................................................
      else
        ### TAINT join using empty string? spaces? newlines? ###
        if macro_output.length > 0
          macro_output_rpr    = macro_output.join ''
          macro_output.length = 0
          send [ '.', 'text', macro_output_rpr, ( copy meta ), ]
        #.....................................................................................................
        switch mode
          when 'silent'
            null
          when 'vocal'
            ### TAINT send `tex` or `text`??? ###
            action_value_rpr = if CND.isa_text action_value then action_value else rpr action_value
            send [ '.', 'text', action_value_rpr, ( copy meta ), ]
    #.......................................................................................................
    else
      send event

        # # for sub_name, sub_value of S.sandbox
        # #   continue if sub_name in S.sandbox.mkts.reserved_names
        # #   S.sandbox.mkts.definitions[ sub_name ] = sub_value
        # #.....................................................................................................
        # do =>
        #   # debug '©Y action: source:    ', rpr source
        #   # debug '©Y action: js_source: ', rpr js_source
        #   # debug '©Y action: language:  ', rpr language
        #   # debug '©Y action: mode:      ', rpr mode
        #   # debug '©Y action: S.sandbox: ', rpr S.sandbox
        #   debug '©Y action: value:     ', rpr action_value
        #   for name, value of S.sandbox
        #     whisper "#{name}: #{rpr value}"

#-----------------------------------------------------------------------------------------------------------
@$process_values = ( S ) =>
  copy  = MKTS.MD_READER.copy.bind  MKTS.MD_READER
  stamp = MKTS.MD_READER.stamp.bind MKTS.MD_READER
  hide  = MKTS.MD_READER.hide.bind  MKTS.MD_READER
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    if MKTS.MD_READER.select event, '.', 'value'
      [ _, _, identifier, meta, ]     = event
      action_value                    = S.sandbox[ identifier ]
      unless action_value is undefined
        action_value_rpr = rpr action_value unless CND.isa_text action_value
        send [ '.', 'text', action_value_rpr, ( copy meta ), ]
      else
        ### TAINT should preserve stack trace of error ###
        ### TAINT use method to assemble warning event ###
        ### TAINT write error log with full trace, insert reference (error nr) ###
        { line_nr, }  = meta
        error_message = "value on line #{line_nr}: unknown identifier #{rpr identifier}"
        send [ '.', 'warning', error_message, ( copy meta ), ]
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
