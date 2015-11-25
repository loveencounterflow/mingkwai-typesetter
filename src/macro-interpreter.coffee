



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
  do =>
    sandbox                   =
      'rpr':            CND.rpr
      urge:             CND.get_logger 'urge', local_filename
      help:             CND.get_logger 'help', local_filename
      mkts:
        reserved_names:   []
        __filename:       local_filename
    for name of sandbox
      sandbox.mkts.reserved_names.push name
    VM.createContext sandbox
    S.sandbox = sandbox
  #.........................................................................................................
  return $ ( event, send ) =>
    # warn "re-defining command #{rpr identifier}" if S.definitions[ identifier ]?
    # S.definitions[ identifier ] = []
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'action'
      [ type, action, source, meta, ] = event
      send stamp hide event
      { mode, language, line_nr, }    = meta
      error_message                   = null
      #.....................................................................................................
      switch language
        when 'js'
          js_source = source
        when 'coffee'
          try
            js_source = CS.compile source, { bare: true, filename: local_filename, }
          catch error
            error_message = error[ 'message' ]
        else
          error_message = "unknown language #{rpr language}"
      #.....................................................................................................
      try
        value = VM.runInContext js_source, S.sandbox, { filename: local_filename, }
      #.....................................................................................................
      catch error
        error_message = error[ 'message' ]
      #.....................................................................................................
      if error_message?
        warn error_message
        # debug '@294308', event
        ### TAINT should resend because error message might need escaping ###
        ### TAINT should preserve stack trace of error ###
        ### TAINT use method to assemble warning event ###
        ### TAINT insert reference to error log ###
        warning_message = "action on line #{line_nr}: #{error_message}"
        send [ '.', 'warning', warning_message, ( copy meta ), ]
      #.....................................................................................................
      else
        # for sub_name, sub_value of S.sandbox
        #   continue if sub_name in S.sandbox.mkts.reserved_names
        #   S.sandbox.mkts.definitions[ sub_name ] = sub_value
        #.....................................................................................................
        debug '©Y action: source:    ', rpr source
        debug '©Y action: js_source: ', rpr js_source
        debug '©Y action: language:  ', rpr language
        debug '©Y action: mode:      ', rpr mode
        debug '©Y action: S.sandbox: ', rpr S.sandbox
        debug '©Y action: value:     ', rpr value
        #.....................................................................................................
        switch mode
          when 'silent'
            null
          when 'vocal'
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
