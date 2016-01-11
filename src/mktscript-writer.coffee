



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/mktscript-writer'
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
Markdown_parser           = require 'markdown-it'
# Html_parser               = ( require 'htmlparser2' ).Parser
new_md_inline_plugin      = require 'markdown-it-regexp'
#...........................................................................................................
# HELPERS                   = require './helpers'
# @MACROS                   = require './macros'
#...........................................................................................................
misfit                    = Symbol 'misfit'
MKTS                      = require './main'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER


# #-----------------------------------------------------------------------------------------------------------
# @$show_mktsmd_events = ( S ) ->
#   unknown_events    = []
#   indentation       = ''
#   tag_stack         = []
#   return D.$observe ( event, has_ended ) =>
#     if event?
#       [ type, name, text, meta, ] = event
#       if type is '?'
#         unknown_events.push name unless name in unknown_events
#         warn JSON.stringify event
#       else
#         color = CND.blue
#         #...................................................................................................
#         if is_hidden event
#           color = CND.brown
#         else
#           switch type
#             # when '('  then color = CND.yellow
#             when '('  then color = CND.lime
#             when ')'  then color = CND.olive
#             when '!'  then color = CND.indigo
#             when '#'  then color = CND.plum
#             when '.'
#               switch name
#                 when 'text' then color = CND.BLUE
#                 # when 'code' then color = CND.orange
#         #...................................................................................................
#         text = if text? then ( color rpr text ) else ''
#         switch type
#           #.................................................................................................
#           when 'text'
#             log indentation + ( color type ) + ' ' + rpr name
#           #.................................................................................................
#           when 'tex'
#             if S.show_tex_events ? no
#               log indentation + ( color type ) + ( color name ) + ' ' + text
#           #.................................................................................................
#           when '#'
#             [ _, kind, message, _, ]  = event
#             my_badge                  = "(#{meta[ 'badge' ]})"
#             color = switch kind
#               when 'insert' then  'lime'
#               when 'drop'   then  'orange'
#               when 'warn'   then  'RED'
#               when 'info'   then  'BLUE'
#               else                'grey'
#             log ( CND[ color ] '#' + kind ), ( CND.white message ), ( CND.grey my_badge )
#           #.................................................................................................
#           else
#             log indentation + ( color type ) + ( color name ) + ' ' + text
#         #...................................................................................................
#         unless is_hidden event
#           switch type
#             #.................................................................................................
#             when '(', ')'
#               switch type
#                 when '('
#                   tag_stack.push [ type, name, ]
#                 when ')'
#                   if tag_stack.length > 0
#                     [ topmost_type, topmost_name, ] = tag_stack.pop()
#                     unless topmost_name is name
#                       warn "encountered <<#{name}#{type}>> when <<#{topmost_name})>> was expected"
#                   else
#                     warn "level below zero"
#               indentation = ( new Array tag_stack.length ).join '  '
#     #.......................................................................................................
#     if has_ended
#       if tag_stack.length > 0
#         warn "unclosed tags: #{tag_stack.join ', '}"
#       if unknown_events.length > 0
#         warn "unknown events: #{unknown_events.sort().join ', '}"
#     return null

#-----------------------------------------------------------------------------------------------------------
@$show_mktsmd_events = ( S ) ->
  return D.$observe ( event, has_ended ) =>
    if event?
      [ type, name, text, meta, ] = event
      if select event, 'tex', null, yes
        null
      else if select event, '#'
        switch name
          when 'warn'
            line_color = CND.red
          else
            line_color = CND.brown
        log line_color type, name, text
      else
        if is_hidden event
          line_color = CND.grey
        else if select event, '.', 'warning'
          line_color = CND.red
        else if select event, '.', 'text'
          line_color = CND.blue
        else
          line_color = CND.white
        log line_color type, name, ( if text? then rpr text else '' )
    #.......................................................................................................
    if has_ended
      null
    return null

#-----------------------------------------------------------------------------------------------------------
@$produce_mktscript = ( S ) ->
  indentation       = ''
  tag_stack         = []
  #.........................................................................................................
  return $ ( event, send, end ) ->
    if event?
      debug '©Yo4cR', rpr event
      [ type, name, text, meta, ] = event
      unless type in [ 'tex', 'text', ]
        { line_nr, } = meta
        if line_nr?
          anchor = "#{line_nr} █ "
        else
          anchor = ""
        #.....................................................................................................
        # send JSON.stringify event
        text_rpr = ''
        if text?
          ### TAINT we have to adopt a new event format; for now, the `text` attribute is misnamed,
          as it is really a `data` attribute ###
          if CND.isa_text text
            ### TAINT doesn't recognize escaped backslash ###
            text_rpr = ' ' + ( rpr text ).replace /\\n/g, '\n'
          else if ( Object.keys text ).length > 0
            text_rpr = ' ' + JSON.stringify text
        send "#{anchor}#{type}#{name}#{text_rpr}"
        send '\n'
        # switch type
        #   when '?'
        #     send "\n#{anchor}#{type}#{name}\n"
        #   when '('
        #     send "#{anchor}#{type}#{name}"
        #   when ')', '!'
        #     send "#{type}\n"
        #   when '('
        #     send "#{type}#{name}"
        #   when ')'
        #     send "#{type}"
        #   when '.'
        #     switch name
        #       when 'hr'
        #         send "\n#{anchor}#{type}#{name}\n"
        #       when 'p'
        #         send "¶\n"
        #       when 'text'
        #         ### TAINT doesn't recognize escaped backslash ###
        #         text_rpr = ( rpr text ).replace /\\n/g, '\n'
        #         send text_rpr
        #       else
        #         send "\n#{anchor}IGNORED: #{rpr event}"
        #   else
        #     send "\n#{anchor}IGNORED: #{rpr event}"
    if end?
      send "# EOF"
      end()
    return null

#-----------------------------------------------------------------------------------------------------------
@mkts_events_from_md = ( source, settings, handler ) ->
  switch arity = arguments.length
    when 2
      handler   = settings
      settings  = {}
    when 3 then null
    else throw new Error "expected 2 or 3 arguments, got #{arity}"
  bare          = settings[ 'bare' ] ? no
  md_readstream = MKTS.MD_READER.create_md_read_tee source
  { input
    output }    = md_readstream.tee
  Z             = []
  output.pipe $ ( event, send ) =>
    # debug '©G3QXt', event
    Z.push event unless bare and select event, [ '(', ')', ], 'document'
  output.on 'end', -> handler null, Z
  input.resume()
  return null

#-----------------------------------------------------------------------------------------------------------
@mktscript_from_md = ( md_source, settings, handler ) ->
  ### TAINT code duplication ###
  switch arity = arguments.length
    when 2
      handler   = settings
      settings  = {}
    when 3 then null
    else throw new Error "expected 2 or 3 arguments, got #{arity}"
  #.........................................................................................................
  source_route        = settings[ 'source-route' ] ? '<STRING>'
  md_readstream       = MKTS.MD_READER.create_md_read_tee md_source
  { input
    output }          = md_readstream.tee
  f                   = => input.resume()
  #.........................................................................................................
  output
    .pipe @$produce_mktscript md_readstream.tee[ 'S' ]
    # .pipe D.$show '>>>>>>>>>>>>>>'
    .pipe do =>
      Z = []
      return $ ( event, send, end ) =>
        Z.push event if event?
        if end?
          handler null, Z.join ''
          end()
  #.........................................................................................................
  D.run f, @_handle_error
  return null
