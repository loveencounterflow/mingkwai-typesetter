


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/MD-READER'
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
HELPERS                   = require './helpers'
#...........................................................................................................
misfit                    = Symbol 'misfit'
MKTS                      = require './main'


#-----------------------------------------------------------------------------------------------------------
@_get_badge = ( delta = 0 ) ->
  ### Experimental, to be used with remarks when things got omitted or inserted. ###
  caller_info = CND.get_caller_info delta + 2
  # filename    = njs_path.basename caller_info[ 'route' ]
  # line_nr     = caller_info[ 'line-nr' ]
  method_name = caller_info[ 'function-name' ] ? caller_info[ 'method-name' ]
  method_name = method_name.replace /^__dirname\./, ''
  # return "#{filename}/#{method_name}"
  return method_name

#-----------------------------------------------------------------------------------------------------------
@_get_remark = ( delta = 0 ) ->
  my_badge = @_get_badge delta + 1
  return ( kind, message, meta ) =>
    return @stamp [ '#', kind, message, ( @copy meta, { badge: my_badge, } ), ]
  # send stamp [ '#', 'insert', my_badge, "inserting `p` tag", ( copy meta ), ]



#===========================================================================================================
# MD / HTML PARSING
#-----------------------------------------------------------------------------------------------------------
@_new_markdown_parser = ->
  #.........................................................................................................
  ### https://markdown-it.github.io/markdown-it/#MarkdownIt.new ###
  # feature_set = 'commonmark'
  feature_set = 'zero'
  #.........................................................................................................
  settings    =
    html:           yes,            # Enable HTML tags in source
    xhtmlOut:       no,             # Use '/' to close single tags (<br />)
    breaks:         no,             # Convert '\n' in paragraphs into <br>
    langPrefix:     'language-',    # CSS language prefix for fenced blocks
    linkify:        yes,            # Autoconvert URL-like text to links
    typographer:    yes,
    quotes:         '“”‘’'
    # quotes:         '""\'\''
    # quotes:         '""`\''
    # quotes:         [ '<<', '>>', '!!!', '???', ]
    # quotes:   ['«\xa0', '\xa0»', '‹\xa0', '\xa0›'] # French
  #.........................................................................................................
  R = new Markdown_parser feature_set, settings
  # R = new Markdown_parser settings
  R
    .enable 'text'
    # .enable 'newline'
    .enable 'escape'
    .enable 'backticks'
    .enable 'strikethrough'
    .enable 'emphasis'
    .enable 'link'
    .enable 'image'
    .enable 'autolink'
    .enable 'html_inline'
    .enable 'entity'
    # .enable 'code'
    .enable 'fence'
    .enable 'blockquote'
    .enable 'hr'
    .enable 'list'
    .enable 'reference'
    .enable 'heading'
    # .enable 'lheading'
    .enable 'html_block'
    .enable 'table'
    .enable 'paragraph'
    .enable 'normalize'
    .enable 'block'
    .enable 'inline'
    # .enable 'linkify'
    .enable 'replacements'
    .enable 'smartquotes'
  #.......................................................................................................
  R.use require 'markdown-it-footnote'
  # R.use require 'markdown-it-mark'
  # R.use require 'markdown-it-sub'
  # R.use require 'markdown-it-sup'
  #.......................................................................................................
  # ### sample plugin ###
  # user_pattern  = /@(\w+)/
  # user_handler  = ( match, utils ) ->
  #   url = 'http://example.org/u/' + match[ 1 ]
  #   return '<a href="' + utils.escape(url) + '">' + utils.escape(match[1]) + '</a>'
  # user_plugin = new_md_inline_plugin user_pattern, user_handler
  # R.use user_plugin
  #.......................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
get_parse_html_methods = ->
  PARSE5      = require 'parse5'
  get_message = ( source ) -> "expected single opening node, got #{rpr source}"
  R           = {}
  #.........................................................................................................
  R[ '_parse_html_open_tag' ] = ( source ) ->
    tree    = PARSE5.parseFragment source
    throw new Error get_message source unless ( cns = tree[ 'childNodes' ] ).length is 1
    cn = cns[ 0 ]
    throw new Error get_message source unless cn[ 'childNodes' ]?.length is 0
    return [ 'begin', cn[ 'tagName' ], cn[ 'attrs' ][ 0 ] ? {}, ]
  #.........................................................................................................
  R[ '_parse_html_block' ] = ( source ) ->
    tree    = PARSE5.parseFragment source
    debug '@88817', tree
    return null
  #.........................................................................................................
  return R
#...........................................................................................................
parse_methods = get_parse_html_methods()
@_parse_html_open_tag = parse_methods[ '_parse_html_open_tag' ]
@_parse_html_block    = parse_methods[ '_parse_html_block'    ]

#-----------------------------------------------------------------------------------------------------------
@_parse_html_tag = ( source ) ->
  if ( match = source.match @_parse_html_tag.close_tag_pattern )?
    return [ 'end', match[ 1 ], ]
  if ( match = source.match @_parse_html_tag.comment_pattern )?
    return [ 'comment', 'comment', match[ 1 ], ]
  return @_parse_html_open_tag source
@_parse_html_tag.close_tag_pattern   = /^<\/([^>]+)>$/
@_parse_html_tag.comment_pattern     = /^<!--([\s\S]*)-->$/


#===========================================================================================================
# FENCES
#-----------------------------------------------------------------------------------------------------------
@FENCES = {}

#-----------------------------------------------------------------------------------------------------------
### TAINT moving to parentheses-only syntax; note that most of the `FENCES` submodule can then go ###
@FENCES.left    = [ '(', ]
@FENCES.right   = [ ')', ]
@FENCES.pairs   =
  '(':  ')'
  ')':  '('

#-----------------------------------------------------------------------------------------------------------
@FENCES._get_opposite = ( fence, fallback ) =>
  unless ( R = @FENCES.pairs[ fence ] )?
    return fallback unless fallback is undefined
    throw new Error "unknown fence: #{rpr fence}"
  return R

#===========================================================================================================
# TRACKER
#-----------------------------------------------------------------------------------------------------------
@TRACKER = {}

#-----------------------------------------------------------------------------------------------------------
tracker_pattern = /// ^
    ( [     .!$(  ]? )
    ( [^ \s .!$() ]* )
    ( [         ) ]? )
    $ ///

#-----------------------------------------------------------------------------------------------------------
@FENCES.parse = ( pattern, settings ) =>
  left_fence  = null
  name        = null
  right_fence = null
  symmetric   = settings?[ 'symmetric' ] ? yes
  #.........................................................................................................
  if ( not pattern? ) or pattern.length is 0
    throw new Error "pattern must be non-empty, got #{rpr pattern}"
  #.........................................................................................................
  match = pattern.match @TRACKER._tracker_pattern
  throw new Error "not a valid pattern: #{rpr pattern}" unless match?
  #.........................................................................................................
  [ _, left_fence, name, right_fence, ] = match
  left_fence  = null if  left_fence.length is 0
  name        = null if        name.length is 0
  right_fence = null if right_fence.length is 0
  #.........................................................................................................
  if left_fence is '.'
    ### Can not have a right fence if left fence is a dot ###
    if right_fence?
      throw new Error "fence '.' can not have right fence, got #{rpr pattern}"
  #.........................................................................................................
  else
    ### Except for dot fence, must always have no fence or both fences in case `symmetric` is set ###
    if symmetric
      if ( left_fence? and not right_fence? ) or ( right_fence? and not left_fence? )
        throw new Error "unmatched fence in #{rpr pattern}"
  #.........................................................................................................
  if left_fence? and left_fence isnt '.'
    ### Complain about unknown left fences ###
    unless left_fence in @FENCES.left
      throw new Error "illegal left_fence in pattern #{rpr pattern}"
    if right_fence?
      ### Complain about non-matching fences ###
      unless ( @FENCES._get_opposite left_fence, null ) is right_fence
        throw new Error "fences don't match in pattern #{rpr pattern}"
  if right_fence?
    ### Complain about unknown right fences ###
    unless right_fence in @FENCES.right
      throw new Error "illegal right_fence in pattern #{rpr pattern}"
  #.........................................................................................................
  return [ left_fence, name, right_fence, ]

#-----------------------------------------------------------------------------------------------------------
@TRACKER._tracker_pattern = tracker_pattern

#-----------------------------------------------------------------------------------------------------------
@TRACKER.new_tracker = ( patterns... ) =>
  _MKTS = @
  #.........................................................................................................
  self = ( event ) ->
    # CND.dir self
    # debug '@763', "tracking event #{rpr event}"
    for pattern, state of self._states
      { parts } = state
      continue unless _MKTS.select event, parts...
      [ [ left_fence, right_fence, ], pattern_name, ] = parts
      [ type, event_name, ]                           = event
      if type is left_fence
        # debug '@1', pattern, yes
        self._enter state
      else
        # debug '@2', pattern, no
        self._leave state
        ### TAINT shouldn't throw error but issue warning remark ###
        throw new Error "too many right fences: #{rpr event}" if state[ 'count' ] < 0
    return event
  #.........................................................................................................
  self._states = {}
  #.........................................................................................................
  self._get_state = ( pattern ) ->
    throw new Error "untracked pattern #{rpr pattern}" unless ( R = self._states[ pattern ] )?
    return R
  #.........................................................................................................
  self.within = ( patterns... ) ->
    for pattern in patterns
      return true if self._within pattern
    return false
  self._within  = ( pattern ) -> ( self._get_state pattern )[ 'count' ] > 0
  #.........................................................................................................
  self.enter    = ( pattern ) -> self._enter self._get_state pattern
  self.leave    = ( pattern ) -> self._leave self._get_state pattern
  self._enter   = ( state   ) -> state[ 'count' ] += +1
  ### TAINT should validate count when leaving ###
  self._leave   = ( state   ) -> state[ 'count' ] += -1
  #.........................................................................................................
  do ->
    for pattern in patterns
      [ left_fence, pattern_name, right_fence, ]  = _MKTS.FENCES.parse pattern
      state =
        parts:    [ [ left_fence, right_fence, ], pattern_name, ]
        count:    0
      self._states[ pattern ] = state
  #.........................................................................................................
  return self


#===========================================================================================================
# _PRE (PREPROCESSING)
#-----------------------------------------------------------------------------------------------------------
@_PRE = {}

#-----------------------------------------------------------------------------------------------------------
@_PRE.$flatten_inline_tokens = ( S ) =>
  return $ ( token, send ) ->
    if ( type = token[ 'type' ] ) is 'inline'
      send sub_token for sub_token in token[ 'children' ]
    else
      send token

#-----------------------------------------------------------------------------------------------------------
@_PRE.$flatten_image_tokens = ( S ) =>
  return $ ( token, send ) ->
    if ( type = token[ 'type' ] ) is 'image'
      src = null
      for [ attribute_name, attribute_value, ] in token[ 'attrs' ]
        if attribute_name is 'src'
          src = attribute_value
          break
      send { type: 'image_open',  src, map: token[ 'map' ], }
      send sub_token for sub_token in token[ 'children' ]
      send { type: 'image_close', src, map: token[ 'map' ], }
    else
      send token

#-----------------------------------------------------------------------------------------------------------
@_PRE.$reinject_html_blocks = ( S ) =>
  ### re-inject HTML blocks ###
  md_parser   = @_new_markdown_parser()
  return $ ( token, send ) =>
    { type, map, } = token
    if type is 'html_block'
      ### TAINT `map` location data is borked with this method ###
      ### add extraneous text content; this causes the parser to parse the HTML block as a paragraph
      with some inline HTML: ###
      XXX_source  = "XXX" + token[ 'content' ]
      ### for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse ###
      ### TAINT what to do with useful data appearing in `environment`? ###
      environment = {}
      tokens      = md_parser.parse XXX_source, environment
      ### remove extraneous text content: ###
      removed     = tokens[ 1 ]?[ 'children' ]?.splice 0, 1
      unless removed[ 0 ]?[ 'content' ] is "XXX"
        throw new Error "should never happen (1)"
      S.confluence.write token for token in tokens
    else
      send token

#-----------------------------------------------------------------------------------------------------------
@_PRE.$rewrite_markdownit_tokens = ( S ) =>
  unknown_tokens        = []
  is_first              = yes
  last_map              = [ 0, 0, ]
  _send                 = null
  remark                = @_get_remark()
  within_footnote_block = false
  end_token             = Symbol.for 'end'
  last_link_href        = null
  #.........................................................................................................
  send_unknown = ( token, meta ) =>
    { type, } = token
    _send [ '?', type, token[ 'content' ], meta, ]
    unknown_tokens.push type unless type in unknown_tokens
  #.........................................................................................................
  # return $ ( token, send, end ) =>
  return $ ( token, send ) =>
    _send = send
    #.......................................................................................................
    if token is end_token
      if unknown_tokens.length > 0
        send remark 'warn', "unknown tokens: #{unknown_tokens.sort().join ', '}", {}
      if is_first
        is_first = no
        send [ '(', 'document', null, {}, ]
      send [ ')', 'document', null, {}, ]
      setImmediate => send.end()
    else if CND.isa_list token
      ### TAINT this clause shouldn't be here; we should target resends (which could be source texts
      or MKTS events) to appropriate insertion points in the stream ###
      ### pass through re-injected MKTS events ###
      send token
    else
      { type
        map
        markup }      = token
      map            ?= last_map
      line_nr         = ( map[ 0 ] ? 0 ) + 1
      col_nr          = ( map[ 1 ] ? 0 ) + 1
      #.....................................................................................................
      meta = {
        line_nr
        col_nr
        markup
        }
      if is_first
        is_first = no
        send [ '(', 'document', null, meta, ]
      # #.....................................................................................................
      # if type in [
      #   'footnote_ref',
      #   'footnote_open', 'footnote_close',
      #   'footnote_anchor',
      #   'footnote_block_open', 'footnote_block_close', ]
      #   whisper '@a20g', token[ 'type' ]
      #.....................................................................................................
      if type is 'footnote_block_open'  then within_footnote_block = yes
      #.....................................................................................................
      if within_footnote_block or not S.has_ended
        # urge '@a20g', token[ 'type' ]#, within_footnote_block
        switch type
          # blocks
          when 'paragraph_open'     then null
          when 'paragraph_close'    then send [ '.', 'p',             null,                         meta, ]
          when 'bullet_list_open'   then send [ '(', 'ul',            null,                         meta, ]
          when 'bullet_list_close'  then send [ ')', 'ul',            null,                         meta, ]
          when 'list_item_open'     then send [ '(', 'li',            null,                         meta, ]
          when 'list_item_close'    then send [ ')', 'li',            null,                         meta, ]
          # inlines
          when 'strong_open'        then send [ '(', 'strong',        null,                         meta, ]
          when 'strong_close'       then send [ ')', 'strong',        null,                         meta, ]
          when 'em_open'            then send [ '(', 'em',            null,                         meta, ]
          when 'em_close'           then send [ ')', 'em',            null,                         meta, ]
          # singles
          when 'text'               then send [ '.', 'text',          token[ 'content' ],           meta, ]
          when 'hr'                 then send [ '.', 'hr',            token[ 'markup' ],            meta, ]
          #.................................................................................................
          # specials
          #.................................................................................................
          when 'heading_open'
            h_level = parseInt token[ 'tag' ][ 1 ], 10
            send [ '(', 'h', h_level, meta, ]
          #.................................................................................................
          when 'heading_close'
            h_level = parseInt token[ 'tag' ][ 1 ], 10
            send [ ')', 'h', h_level, meta, ]
          #.................................................................................................
          when 'link_open'
            ### NB markdown-it does not support nested link markup a la `xxx [333 [444](555) 666](777)`;
            as such, we have only to recall the most recent link target when the linking span is closed. ###
            for [ attribute_name, attribute_value, ] in token[ 'attrs' ]
              if attribute_name is 'href'
                last_link_href = attribute_value
                break
            send [ '(', 'link', last_link_href, meta, ]
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'link_close'
            send [ ')', 'link', last_link_href, meta, ]
            last_link_href = null
          #.................................................................................................
          when 'image_open'
            meta[ 'src' ] = token[ 'src' ]
            send [ '(', 'image', null, meta, ]
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'image_close'
            meta[ 'src' ] = token[ 'src' ]
            send [ ')', 'image', null, meta, ]
          #.................................................................................................
          when 'code_inline'
            text_meta             = ( @copy meta )
            text_meta[ 'markup' ] = ''
            send [ '(', 'code-span',  null,                       meta,   ]
            send [ '.', 'text',       token[ 'content' ],    text_meta,   ]
            send [ ')', 'code-span',  null,               ( @copy meta ),  ]
          #.................................................................................................
          when 'footnote_ref'
            id = token[ 'meta' ][ 'id' ]
            send [ '.', 'footnote-ref', id, meta, ]
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'footnote_open'
            id = token[ 'meta' ][ 'id' ]
            send [ '(', 'footnote-def', id, meta, ]
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'footnote_close'
            send [ ')', 'footnote-def', null, meta, ]
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'footnote_anchor'
            null
            # send remark 'drop', "footnote anchor is dispensable", ( @copy meta )
          #  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
          when 'footnote_block_open', 'footnote_block_close'
            null
            # send remark 'drop', "footnote block processed", ( @copy meta )
          #.................................................................................................
          when 'table_open', 'table_close', 'tbody_open', 'tbody_close', 'td_open', 'td_close', 'th_open', \
            'th_close', 'thead_open', 'thead_close', 'tr_open', 'tr_close'
              # debug '982342', token
              if type is 'th_open' and token[ 'attrs' ]?
                for [ attribute_name, attribute_value, ] in token[ 'attrs' ]
                  if attribute_name is 'style'
                    ( meta[ 'table' ]?= {} )[ 'style' ] = attribute_value
                    break
              [ tag, position, ] = type.split '_'
              send [ ( if position is 'open' then '(' else ')' ), tag, null, meta, ]
          #.................................................................................................
          when 'html_block'
            throw new Error "should never happen (2)"
          #.................................................................................................
          when 'fence'
            switch token[ 'tag' ]
              when 'code'
                language_name = token[ 'info' ]
                language_name = 'text' if language_name.length is 0
                send [ '(', 'code', language_name,              meta,    ]
                send [ '.', 'text', token[ 'content' ], ( @copy meta ),  ]
                send [ ')', 'code', language_name,      ( @copy meta ),  ]
              else send_unknown token, meta
          #.................................................................................................
          when 'html_inline'
            [ position, name, extra, ] = @_parse_html_tag token[ 'content' ]
            switch position
              when 'comment'
                send [ '.', 'comment', extra.trim(), meta, ]
              when 'begin'
                unless name is 'p'
                  send [ '(', name, extra, meta, ]
              when 'end'
                if name is 'p' then send [ '.', name, null, meta, ]
                else                send [ ')', name, null, meta, ]
              else throw new Error "unknown HTML tag position #{rpr position}"
          #.................................................................................................
          else
            # debug '@26.05', token
            send_unknown token, meta
        #...................................................................................................
        last_map = map
      #.....................................................................................................
      if type is 'footnote_block_close' then within_footnote_block = no
    # #.......................................................................................................
    # if end?
    #   if unknown_tokens.length > 0
    #     send remark 'warn', "unknown tokens: #{unknown_tokens.sort().join ', '}", {}
    #   send [ ')', 'document', null, {}, ]
    #   # setImmediate => end()
    #   setTimeout ( => end() ), 1000
    return null

#-----------------------------------------------------------------------------------------------------------
@_PRE.$issue_administrative_events = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if @select event, '(', 'document'
      send [ '~', 'start', null, ( @copy meta ), ]
      send [ '~', 'flush', null, ( @copy meta ), ]
      send event
    #.......................................................................................................
    else if @select event, ')', 'document'
      send event
      send [ '~', 'stop', null, ( @copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@_PRE.$process_end_command = ( S ) =>
  S.has_ended   = no
  remark        = @_get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    # [ type, name, text, meta, ] = event
    if @select event, '!', 'end'
      if not S.has_ended
        [ _, _, _, meta, ]    = event
        { line_nr, }          = meta
        ### TAINT consider to re-send `document>` ###
        send @stamp event
        send remark 'info', "encountered `<<!end>>` on line ##{line_nr}", @copy meta
        S.has_ended = yes
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@_PRE.$consolidate_tables  = ( S ) =>
  ### TAINT assumes unnested tables without merged cells ###
  track         = @TRACKER.new_tracker '(table)'
  collector     = []
  collecting    = no
  col_count     = 0
  alignments    = null
  description   = null
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    within_table                = track.within '(table)'
    track event
    #.......................................................................................................
    if @select event, '(', 'table'
      return send [ '.', 'warning', "detected nested tables", ( @copy meta ), ] if collecting
      collecting        = yes
      alignments        = []
      description       = {}
      meta[ 'table' ]  ?= description
      collector.push event
    #.......................................................................................................
    else if collecting
      #.....................................................................................................
      if @select event, '(', [ 'td', 'th', ]
        collector.push event
        col_count += +1
        ### TAINT relying on very specific format detail here; need `{ style: 'text-align:xxx' }` ###
        style = meta[ 'table' ]?[ 'style' ] ? 'text-align:left'
        [ style_name, style_value, ] = style.split ':'
        if style_name is 'text-align' then  alignments.push style_value
        else                                alignments.push 'left'
      #.....................................................................................................
      else if @select event, ')', 'tr'
        description[ 'col_count'  ] = col_count
        description[ 'alignments' ] = alignments
        send past_event for past_event in collector
        send event
        collector.length  = 0
        col_count         = 0
        collecting        = no
        alignments        = null
        table_meta        = null
      #.....................................................................................................
      else
        collector.push event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_PRE.$consolidate_footnotes  = ( S ) =>
  track                   = @TRACKER.new_tracker '(footnote-def)'
  collector               = []
  idx_by_ids              = new Map()
  current_footnote_events = []
  current_footnote_id     = null
  within_footnote_def     = no
  #.........................................................................................................
  return $ ( event, send, end ) =>
    if event?
      within_footnote_def = track.within '(footnote-def)'
      track event
      #.....................................................................................................
      if @select event, '.', 'footnote-ref'
        [ type, name, id, meta, ] = event
        collector.push [ [ '(', 'footnote', id, ( @copy meta ), ], ]
        idx_by_ids.set id, collector.length
        collector.push []
        collector.push [ [ ')', 'footnote', id, ( @copy meta ), ], ]
      #.....................................................................................................
      else if @select event, '(', 'footnote-def'
        [ type, name, id, meta, ] = event
        current_footnote_id       = id
      #.....................................................................................................
      else if @select event, ')', 'footnote-def'
        current_footnote_id       = null
      #.....................................................................................................
      else
        if within_footnote_def
          target_idx = idx_by_ids.get current_footnote_id
          unless target_idx
            message = "unknown footnote ID #{rpr current_footnote_id}"
            # send.error new Error message
            send [ '.', 'warning', message, ( @copy meta ? {} ), ]
          else
            collector[ target_idx ].push event
        else
          collector.push [ event, ]
    #.......................................................................................................
    if end?
      for events in collector
        for event in events
          send event
      end()

#-----------------------------------------------------------------------------------------------------------
@_PRE.$close_dangling_open_tags = ( S ) =>
  tag_stack = []
  remark    = @_get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if @select event, '(', 'document'
      null
    #.......................................................................................................
    else if @select event, ')', 'document'
      while tag_stack.length > 0
        sub_event                                   = tag_stack.pop()
        [ sub_type, sub_name, sub_text, sub_meta, ] = sub_event
        sub_type = ')'
        send remark 'resend', "`#{sub_name}#{sub_type}`", @copy meta
        S.resend [ sub_type, sub_name, sub_text, ( @copy sub_meta ), ]
    #.......................................................................................................
    else if @select event, '('
      tag_stack.push [ type, name, null, meta, ]
      # debug '©18623', tag_stack
    #.......................................................................................................
    else if @select event, ')'
      ### TAINT should check matching pairs ###
      tag_stack.pop()
    #.......................................................................................................
    send event
    return null

#-----------------------------------------------------------------------------------------------------------
@_PRE.$extra_hr = ( S ) =>
  pattern = /// ^ ( \#{3,} | ={3,} ) $ ///gm
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if @select event, '.', 'text'
      [ type, name, text, meta, ] = event
      is_plain = no
      for stretch in text.split pattern
        if is_plain = not is_plain
          send [ '.', 'text', stretch, ( @copy meta ), ]
        else
          send [ '.', 'hr', stretch, ( @copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@select = ( event, type, name, hidden = no ) ->
  ### TAINT should use the same syntax as accepted by `FENCES.parse` ###
  ### check for arity as it's easy to write `select event, '(', ')', 'latex'` when what you meant
  was `select event, [ '(', ')', ], 'latex'` ###
  return false if ( not hidden ) and @is_hidden event
  if ( arity = arguments.length ) > 4
    throw new Error "expected at most 3 arguments, got #{arity}"
  if type?
    switch type_of_type = CND.type_of type
      when 'text' then return false unless event[ 0 ] is type
      when 'list' then return false unless event[ 0 ] in type
      else throw new Error "expected text or list, got a #{type_of_type}"
  if name?
    switch type_of_name = CND.type_of name
      when 'text' then return false unless event[ 1 ] is name
      when 'list' then return false unless event[ 1 ] in name
      else throw new Error "expected text or list, got a #{type_of_name}"
  return true


#===========================================================================================================
# STAMPING & HIDING
#-----------------------------------------------------------------------------------------------------------
@stamp = ( event ) ->
  ### 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
  ignore events that have already been marked upstream, or, inversely choose to look out for events
  that have not yet found a representation in the target document. **NB** that stamping and hiding an
  event will place a copy of the `meta` event element into the event. ###
  event[ 3 ] = @copy event[ 3 ], { stamped: yes, }
  return event

#-----------------------------------------------------------------------------------------------------------
@unstamp = ( event ) ->
  event[ 3 ] = @copy event[ 3 ], { stamped: no, }
  return event

#-----------------------------------------------------------------------------------------------------------
@is_stamped   = ( event ) -> event[ 3 ]?[ 'stamped' ] is true
@is_unstamped = ( event ) -> not @is_stamped event

#-----------------------------------------------------------------------------------------------------------
@hide = ( event ) ->
  ### 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
  ignore events that have already been marked upstream, or, inversely choose to look out for events
  that have not yet found a representation in the target document. **NB** that stamping and hiding an
  event will place a copy of the `meta` event element into the event. ###
  event[ 3 ] = @copy event[ 3 ], { hidden: yes, }
  return event

#-----------------------------------------------------------------------------------------------------------
@is_hidden = ( event ) -> event[ 3 ]?[ 'hidden' ] is true

#-----------------------------------------------------------------------------------------------------------
@copy = ( x, updates... ) ->
  ### (Hopefully) fast semi-deep copying for events (i.e. lists with a possible `meta` object on
  index 3) and plain objects. The value returned will be a shallow copy in the case of objects and
  lists, but if a list has a value at index 3, that object will also be copied. Not guaranteed to
  work for general values. ###
  if ( isa_list = CND.isa_list x ) then R = []
  else if         CND.isa_pod  x   then R = {}
  else throw new Error "unable to copy a #{CND.type_of x}"
  R       = Object.assign R, x, updates...
  R[ 3 ]  = Object.assign {}, meta if isa_list and ( meta = R[ 3 ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@_split_lines_with_nl = ( text ) -> ( line for line in text.split /(.*\n)/ when line.length > 0 )

#-----------------------------------------------------------------------------------------------------------
@_flush_text_collector = ( send, collector, meta ) ->
  if collector.length > 0
    send [ '.', 'text', ( collector.join '' ), meta, ]
    collector.length = 0
  return null

#-----------------------------------------------------------------------------------------------------------
@$show_illegal_chrs = ( S ) ->
  ### TAINT if these characters are illegal, we don't have to escape them when tunneling macros ###
  ### TAINT must send MKTS events, not TeX to keep method general ###
  return $ ( old_text, send ) ->
    new_text = old_text.replace /[\x00-\x08\x0b\x0c\x0e-\x1f\x7f\ufffd-\uffff]/g, ( $0 ) ->
      cid_hex = ( $0.codePointAt 0 ).toString 16
      pre     = '█'
      post    = '█'
      ### TAINT use mkts command ###
      warn "detected illegal character U+#{cid_hex}" # if old_text isnt new_text
      return """{\\mktsStyleBold\\color{red}{%
        \\mktsStyleSymbol#{pre}}U+#{cid_hex}{\\mktsStyleSymbol#{post}}}"""
    send new_text

#-----------------------------------------------------------------------------------------------------------
@new_resender = ( S, stream ) ->
  ### TAINT re-parsing new source text should be handled by regular stream transform at an appropriate
  stream entry point ###
  ### TAINT new parser not needed, can reuse 'main' parser ###
  md_parser = @_new_markdown_parser()
  return ( md_source ) =>
    ### TAINT must handle data in environment ###
    if CND.isa_text md_source
      md_source   = MKTS.MACRO_ESCAPER.escape S, md_source
      environment = {}
      tokens      = md_parser.parse md_source, environment
      # tokens      = md_parser.parse md_source, S.environment
      #.......................................................................................................
      ### TAINT intermediate solution ###
      if ( keys = Object.keys environment ).length > 0
        warn "ignoring keys from sub-parsing environment: #{rpr keys}"
      #.......................................................................................................
      if tokens.length > 0
        ### Omit `paragraph_open` as first and `paragraph_close` as last token: ###
        first_idx   = 0
        last_idx    = tokens.length - 1
        first_idx   = if tokens[ first_idx ][ 'type' ] is 'paragraph_open'  then first_idx + 1 else first_idx
        last_idx    = if tokens[  last_idx ][ 'type' ] is 'paragraph_close' then  last_idx - 1 else  last_idx
        # ( debug '©9fdeD', "resending", tokens[ idx ] ) for idx in [ first_idx .. last_idx ]
        stream.write tokens[ idx ] for idx in [ first_idx .. last_idx ]
    else
      stream.write md_source


#===========================================================================================================
# STREAM CREATION
#-----------------------------------------------------------------------------------------------------------
@create_md_read_tee = ( S, md_source ) ->
  switch arity = arguments.length
    when 1
      md_source = S
      #.....................................................................................................
      ### for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse ###
      S =
        # confluence:           confluence
        environment:  {}
    when 2
      S.environment = {}
    else
      throw new Error "expected 1 or 2 arguments, got #{arity}"
  #.........................................................................................................
  ### TAINT `settings`, `S` and fitting should be the same object ###
  settings =
    S:                S
  #.........................................................................................................
  ### TAINT rewrite to use D.TEE.from_pipeline, don't use readstream, writestream ###
  readstream    = D.create_throughstream()
  writestream   = D.create_throughstream()
  # confluence  = D.create_throughstream()
  R             = D.TEE.from_readwritestreams readstream, writestream, settings
  { input }     = R.tee
  input.pause()
  #.........................................................................................................
  S.resend      = @new_resender S, readstream
  S.confluence  = readstream
  # S.confluence = input
  #.........................................................................................................
  readstream
    # .pipe D.$observe ( event ) -> alert event
    .pipe @_PRE.$flatten_inline_tokens                S
    .pipe @_PRE.$flatten_image_tokens                 S
    .pipe @_PRE.$reinject_html_blocks                 S
    # .pipe D.$observe ( event ) => debug '©1', rpr event
    .pipe @_PRE.$rewrite_markdownit_tokens            S
    .pipe @_PRE.$issue_administrative_events          S
    .pipe MKTS.MACRO_ESCAPER.$expand                  S
    .pipe @_PRE.$process_end_command                  S
    .pipe @_PRE.$consolidate_tables                   S
    .pipe @_PRE.$consolidate_footnotes                S
    .pipe @_PRE.$extra_hr                             S
    .pipe MKTS.MACRO_INTERPRETER.$prepare_sandbox     S
    .pipe MKTS.MACRO_INTERPRETER.$process_actions     S
    .pipe MKTS.MACRO_INTERPRETER.$process_values      S
    .pipe MKTS.MACRO_INTERPRETER.$process_commands    S
    .pipe MKTS.MACRO_INTERPRETER.$process_regions     S
    # .pipe MKTS.MACRO_INTERPRETER.$consolidate_regions S
    .pipe MKTS.MACRO_INTERPRETER.$process_code_blocks S
    .pipe @_PRE.$close_dangling_open_tags             S
    # .pipe D.$show '47594-B'
    .pipe writestream
  #.........................................................................................................
  # readstream.on     'end', -> debug '©tdfA4', "readstream ended"
  # writestream.on    'end', -> debug '©sId1V', "writestream ended"
  # input.on          'end', -> debug '©1sbYv', "input ended"
  # R[ 'output' ].on  'end', -> debug '©zSMOc', "output ended"
  #.........................................................................................................
  input.on 'resume', =>
    md_parser   = @_new_markdown_parser()
    MKTS.MACRO_ESCAPER.initialize_state S
    md_source   = MKTS.MACRO_ESCAPER.escape S, md_source
    tokens      = md_parser.parse md_source, S.environment
    # debug '©78531', rpr tokens
    for token in tokens
      input.write token
    input.write Symbol.for 'end'
  #.........................................................................................................
  return R


