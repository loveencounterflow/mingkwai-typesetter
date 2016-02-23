



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/MACRO-INTERPRETER'
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
  sandbox_backup  = null
  sandbox         =
    'rpr':            CND.rpr
    urge:             CND.get_logger 'urge', local_filename
    help:             CND.get_logger 'help', local_filename
    setImmediate:     setImmediate
    echo:             ( P... ) -> macro_output.push CND.pen P...
    mkts:
      signature_reader: ( P... ) -> P
      output:           macro_output
      # reserved_names:   []
      __filename:       local_filename
  #.........................................................................................................
  S.sandbox =
    #.......................................................................................................
    get: ( name ) ->
      return sandbox[ name ]
    #.......................................................................................................
    set: ( name, value ) ->
      sandbox[ name ] = value
      return null
    #.......................................................................................................
    snapshot: ->
      debug '131-1 sandbox       ',        sandbox?[ 'COLUMNS' ]
      debug '131-2 sandbox_backup', sandbox_backup?[ 'COLUMNS' ]
      sandbox_backup = MKTS.DIFFPATCH.snapshot sandbox
      debug '131-3 sandbox       ',        sandbox?[ 'COLUMNS' ]
      debug '131-4 sandbox_backup', sandbox_backup?[ 'COLUMNS' ]
      return null
    #.......................................................................................................
    get_context: ->
      return sandbox
    #.......................................................................................................
    new_change_event: ->
      debug '131-5 sandbox       ',        sandbox?[ 'COLUMNS' ]
      debug '131-6 sandbox_backup', sandbox_backup?[ 'COLUMNS' ]
      changeset = MKTS.DIFFPATCH.diff sandbox_backup, sandbox
      @snapshot()
      return null if changeset.length > 0
      return [ '~', 'change', changeset, {}, ]
  #.........................................................................................................
  VM.createContext sandbox
  #.........................................................................................................
  return $ ( event, send ) =>
    if MKTS.MD_READER.select '(', 'document'
      [ ..., meta, ] = event
      send event
      changeset = MKTS.DIFFPATCH.diff {}, sandbox
      debug '©47846', 'initial changeset', changeset
      send stamp [ '~', 'change', changeset, ( copy meta ), ]
    #.......................................................................................................
    else if MKTS.MD_READER.select event, '.', 'action'
      [ _, _, raw_source, meta, ]     = event
      send stamp hide event
      { mode, language, line_nr, }    = meta
      error_message                   = null
      S.sandbox.snapshot()
      #.....................................................................................................
      switch language
        when 'js'
          js_source = raw_source
        when 'coffee'
          wrapped_source  = "do =>\n  " + raw_source.replace /\n/g, "\n  "
          try
            js_source     = CS.compile wrapped_source, { bare: true, filename: local_filename, }
          catch error
            error_message = error[ 'message' ] ? rpr error
        else
          error_message = "unknown language #{rpr language}"
      #.....................................................................................................
      try
        action_value = VM.runInContext js_source, sandbox, { filename: local_filename, }
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
        #...................................................................................................
        switch mode
          when 'silent'
            null
          when 'vocal'
          else
            ### TAINT send `tex` or `text`??? ###
            action_value_rpr = if CND.isa_text action_value then action_value else rpr action_value
            send [ '.', 'text', action_value_rpr, ( copy meta ), ]
        # action_value_rpr = if CND.isa_text action_value then action_value else rpr action_value
        # send [ '~', 'update', action_value_rpr, ( copy meta ), ]
        ### TAINT use more specific change event ('change sandbox')? ###
        # debug '34821', sandbox.COLUMNS
        change_event = S.sandbox.new_change_event()
        debug '34821', change_event
        send change_event if change_event
        # send change_event if ( change_event = S.sandbox.new_change_event() )?
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$process_values = ( S ) =>
  copy  = MKTS.MD_READER.copy.bind  MKTS.MD_READER
  stamp = MKTS.MD_READER.stamp.bind MKTS.MD_READER
  hide  = MKTS.MD_READER.hide.bind  MKTS.MD_READER
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    if MKTS.MD_READER.select event, '$'
      [ _, identifier, _, meta, ]     = event
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

#-----------------------------------------------------------------------------------------------------------
@$process_commands = ( S ) =>
  copy  = MKTS.MD_READER.copy.bind  MKTS.MD_READER
  stamp = MKTS.MD_READER.stamp.bind MKTS.MD_READER
  hide  = MKTS.MD_READER.hide.bind  MKTS.MD_READER
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    if MKTS.MD_READER.select event, '!'
      [ _, call_signature, _, meta,     ] = event
      [ _, identifier, parameters_txt,  ] = call_signature.match /^\s*([^\s]*)\s*(.*)$/
      { mode, language, line_nr, }        = meta
      [ error_message, parameters, ]      = @_parameters_from_text S, line_nr, parameters_txt
      return send [ '.', 'warning', error_message, meta, ] if error_message?
      send [ '!', identifier, parameters, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$process_regions = ( S ) =>
  copy      = MKTS.MD_READER.copy.bind    MKTS.MD_READER
  stamp     = MKTS.MD_READER.stamp.bind   MKTS.MD_READER
  hide      = MKTS.MD_READER.hide.bind    MKTS.MD_READER
  select    = MKTS.MD_READER.select.bind  MKTS.MD_READER
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    ### TAINT code duplication ###
    if select event, '('
      [ _, call_signature, extra, meta, ] = event
      [ _, identifier, parameters_txt,  ] = call_signature.match /^\s*([^\s]*)\s*(.*)$/
      #.....................................................................................................
      ### Refuse to overwrite 3rd event parameter when already set. This is a makeshift solution that will
      be removed when we implement a simplified and more unified event syntax. ###
      if extra?
        warn "encountered start region event with parameters and extra" if parameters_txt.length > 0
        return send event
      #.....................................................................................................
      { mode, language, line_nr, }        = meta
      [ error_message, parameters, ]      = @_parameters_from_text S, line_nr, parameters_txt
      #.....................................................................................................
      send [ '.', 'warning', error_message, meta, ] if error_message?
      send [ '(', identifier, parameters, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$consolidate_regions = ( S ) =>
  copy      = MKTS.MD_READER.copy.bind    MKTS.MD_READER
  stamp     = MKTS.MD_READER.stamp.bind   MKTS.MD_READER
  hide      = MKTS.MD_READER.hide.bind    MKTS.MD_READER
  select    = MKTS.MD_READER.select.bind  MKTS.MD_READER
  tag_stack = []
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    ### TAINT code duplication ###
    debug '©18567', event
    if select event, '('
      [ _, call_signature, extra, meta, ] = event
      [ _, identifier, parameters_txt,  ] = call_signature.match /^\s*([^\s]*)\s*(.*)$/
      #.....................................................................................................
      ### Refuse to overwrite 3rd event parameter when already set. This is a makeshift solution that will
      be removed when we implement a simplified and more unified event syntax. ###
      if extra?
        warn "encountered start region event with parameters and extra" if parameters_txt.length > 0
        return send event
      #.....................................................................................................
      { mode, language, line_nr, }        = meta
      [ error_message, parameters, ]      = @_parameters_from_text S, line_nr, parameters_txt
      #.....................................................................................................
      send [ '.', 'warning', error_message, meta, ] if error_message?
      send [ '(', identifier, parameters, meta, ]
      tag_stack.push identifier
    #.......................................................................................................
    else if select event, ')'
      # debug '©01840', JSON.stringify event
      # debug '©01840', select event, ')'
      [ _, identifier, extra, meta, ] = event
      #.....................................................................................................
      if tag_stack.length < 1
        warn '34-1', [ '.', 'warning', "too many closing regions", ( copy meta ), ]
        return send [ '.', 'warning', "too many closing regions", ( copy meta ), ]
      #.....................................................................................................
      expected = tag_stack.pop()
      #.....................................................................................................
      if ( identifier.length > 0 ) and ( expected isnt identifier )
        message = "expected closing region #{rpr expected}, got #{rpr identifier}"
        warn '34-2', [ '.', 'warning', message, ( copy meta ), ]
        send [ '.', 'warning', message, ( copy meta ), ]
        send event if identifier is 'document'
      #.....................................................................................................
      identifier = expected
      send [ ')', identifier, extra, ( copy meta ), ]
      # send [ ')', 'document', extra, ( copy meta ), ]
      urge '443', [ ')', identifier, extra, ( copy meta ), ]
    #.......................................................................................................
    else
      # debug '©88225', JSON.stringify event
      send event

#-----------------------------------------------------------------------------------------------------------
@$process_code_blocks = ( S ) =>
  copy      = MKTS.MD_READER.copy.bind    MKTS.MD_READER
  stamp     = MKTS.MD_READER.stamp.bind   MKTS.MD_READER
  hide      = MKTS.MD_READER.hide.bind    MKTS.MD_READER
  select    = MKTS.MD_READER.select.bind  MKTS.MD_READER
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.........................................................................................................
  return $ ( event, send ) =>
    ### TAINT code duplication ###
    if select event, [ '(', ')', ], 'code'
      [ type, _, call_signature, meta, ]     = event
      { line_nr, }                        = meta
      [ _, identifier, parameters_txt,  ] = call_signature.match /^\s*([^\s]*)\s*(.*)$/
      #.....................................................................................................
      [ error_message, parameters, ]      = @_parameters_from_text S, line_nr, parameters_txt
      parameters.unshift identifier
      #.....................................................................................................
      send [ '.', 'warning', error_message, meta, ] if error_message?
      send [ type, 'code', parameters, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_parameters_from_text = ( S, line_nr, text ) =>
  return [ null, [], ] if ( /^\s*$/ ).test text
  #.........................................................................................................
  ### TAINT replicates some code from MACRO_INTERPRETER.process_actions ###
  ### TAINT move to CND? COFFEESCRIPT? ###
  CS              = require 'coffee-script'
  VM              = require 'vm'
  source          = "@mkts.signature_reader #{text}"
  error_message   = null
  #.........................................................................................................
  throw new Error "internal error: need S.sandbox, must use `$process_actions`" unless S.sandbox?
  #.....................................................................................................
  try
    js_source = CS.compile source, { bare: true, filename: 'parameter resolution', }
  catch error
    error_message = error[ 'message' ] ? rpr error
  #.....................................................................................................
  unless error_message?
    try
      R = VM.runInContext js_source, S.sandbox.get_context(), { filename: 'parameter resolution', }
    catch error
      error_message = error[ 'message' ] ? rpr error
  #.....................................................................................................
  if error_message?
    warn error_message
    ### TAINT should preserve stack trace of error ###
    ### TAINT use method to assemble warning event ###
    ### TAINT write error log with full trace, insert reference (error nr) ###
    return [ "action on line #{line_nr}: #{error_message}", null, ]
    # return done [ '.', 'warning', error_message, ( copy meta ), ]
  return [ null, R, ]

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
