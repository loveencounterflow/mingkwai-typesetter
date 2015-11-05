


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/MKTS'
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
XNCHR                     = require './XNCHR'
# ASYNC                     = require 'async'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
# $async                    = D.remit_async.bind D
#...........................................................................................................
Markdown_parser           = require 'markdown-it'
# Html_parser               = ( require 'htmlparser2' ).Parser
new_md_inline_plugin      = require 'markdown-it-regexp'
#...........................................................................................................
misfit                    = Symbol 'misfit'

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

#-----------------------------------------------------------------------------------------------------------
@_tex_escape_replacements = [
  [ /// \x01        ///g,  '\x01\x02',              ]
  [ /// \x5c        ///g,  '\x01\x01',              ]
  [ ///  \{         ///g,  '\\{',                   ]
  [ ///  \}         ///g,  '\\}',                   ]
  [ ///  \$         ///g,  '\\$',                   ]
  [ ///  \#         ///g,  '\\#',                   ]
  [ ///  %          ///g,  '\\%',                   ]
  [ ///  _          ///g,  '\\_',                   ]
  [ ///  \^         ///g,  '\\textasciicircum{}',   ]
  [ ///  ~          ///g,  '\\textasciitilde{}',    ]
  [ ///  &          ///g,  '\\&',                   ]
  [ /// \x01\x01    ///g,  '\\textbackslash{}',     ]
  [ /// \x01\x02    ///g,  '\x01',                  ]
  ]

#-----------------------------------------------------------------------------------------------------------
@escape_for_tex = ( text ) ->
  R = text
  for [ pattern, replacement, ], idx in @_tex_escape_replacements
    R = R.replace pattern, replacement
  return R

#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( options ) ->
  return $ ( event, send ) =>
    if @select event, '.', 'text'
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      text          = @fix_typography_for_tex text, options
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@is_cjk_rsg = ( rsg, options ) -> rsg in options[ 'tex' ][ 'cjk-rsgs' ]

#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( text, options, send = null ) ->
  ### An improved version of `XELATEX.tag_from_chr` ###
  ### TAINT should accept settings, fall back to `require`d `options.coffee` ###
  glyph_styles          = options[ 'tex' ]?[ 'glyph-styles'             ] ? {}
  ### Legacy mode: force one command per non-latin character. This is OK for Chinese texts,
  but a bad idea for all other scripts; in the future, MKTS's TeX formatting commands like
  `\cn{}` will be rewritten to make this setting superfluous. ###
  advance_each_chr      = options[ 'tex' ]?[ 'advance-each-chr'         ] ? no
  tex_command_by_rsgs   = options[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
  cjk_interchr_glue     = options[ 'tex' ]?[ 'cjk-interchr-glue'        ] ? '\ue080'
  last_command          = null
  R                     = []
  chunk                 = []
  last_rsg              = null
  remark                = if send? then @_get_remark() else null
  last_was_cjk          = no
  is_latin_whitespace   = null
  #.........................................................................................................
  unless tex_command_by_rsgs?
    throw new Error "need setting 'tex-command-by-rsgs'"
  #.........................................................................................................
  advance = =>
    if chunk.length > 0
      # debug '©zDJqU', last_command, JSON.stringify chunk.join '.'
      R.push chunk.join ''
      R.push '}' unless last_command in [ null, 'latin', ]
    chunk.length = 0
    return null
  #.........................................................................................................
  for chr in XNCHR.chrs_from_text text
    ### Treat whitespace specially ###
    ### TAINT better to check against /^\s$/ ??? ###
    if ( is_latin_whitespace = chr in [ '\x20', '\n', '\r', '\t', ] )
      command = last_command
    else
      { chr
        uchr
        fncr
        rsg   }   = XNCHR.analyze chr
      #.......................................................................................................
      switch rsg
        when 'jzr-fig'  then chr = uchr
        when 'u-pua'    then rsg = 'jzr-fig'
        when 'u-latin'  then chr = @escape_for_tex chr
      #.......................................................................................................
      this_is_cjk = @is_cjk_rsg rsg, options
      if last_was_cjk and this_is_cjk
        # chunk.push '\\cjkInterchrSpacing{}'
        chunk.push cjk_interchr_glue
      last_was_cjk = this_is_cjk
      #.......................................................................................................
      ### TAINT if chr is a TeX active ASCII chr like `$`, `#`, then it will be escaped at this point
      and no more match entries in `glyph_styles` ###
      if ( replacement = glyph_styles[ chr ] )?
        advance()
        R.push replacement
        last_command = null
        continue
      #.......................................................................................................
      unless ( command = tex_command_by_rsgs[ rsg ] )?
        command = tex_command_by_rsgs[ 'fallback' ] ? null
        message = "unknown RSG #{rpr rsg}: #{fncr} #{chr} (using fallback #{rpr command})"
        if send? then send remark 'warn', message, {}
        else          warn message
    #.......................................................................................................
    unless command?
      advance()
      chunk.push chr
      continue
    #.......................................................................................................
    if advance_each_chr or last_command isnt command
      advance()
      last_command = command
      ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
      unless command is 'latin'
        command = 'cn'
        chunk.push "{\\#{command}{}"
      # chunk.push "{\\#{command}{}" unless command is 'latin'
      ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
    #.......................................................................................................
    chunk.push chr
  #.........................................................................................................
  advance()
  return R.join ''


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
    .enable 'lheading'
    .enable 'html_block'
    .enable 'table'
    .enable 'paragraph'
    .enable 'normalize'
    .enable 'block'
    .enable 'inline'
    .enable 'linkify'
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
  Parser      = ( require 'parse5' ).Parser
  parser      = new Parser()
  get_message = ( source ) -> "expected single opening node, got #{rpr source}"
  R           = {}
  #.........................................................................................................
  R[ '_parse_html_open_tag' ] = ( source ) ->
    tree    = parser.parseFragment source
    throw new Error get_message source unless ( cns = tree[ 'childNodes' ] ).length is 1
    cn = cns[ 0 ]
    throw new Error get_message source unless cn[ 'childNodes' ]?.length is 0
    return [ 'begin', cn[ 'tagName' ], cn[ 'attrs' ][ 0 ] ? {}, ]
  #.........................................................................................................
  R[ '_parse_html_block' ] = ( source ) ->
    tree    = parser.parseFragment source
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
@FENCES.xleft   = [ '<', '{', '[', '(', ]
@FENCES.xright  = [ '>', '}', ']', ')', ]
@FENCES.left    = [      '{', '[', '(', ]
@FENCES.right   = [      '}', ']', ')', ]
@FENCES.xpairs  =
  '<':  '>'
  '{':  '}'
  '[':  ']'
  '(':  ')'
  '>':  '<'
  '}':  '{'
  ']':  '['
  ')':  '('

#-----------------------------------------------------------------------------------------------------------
@FENCES._get_opposite = ( fence, fallback ) =>
  unless ( R = @FENCES.xpairs[ fence ] )?
    return fallback unless fallback is undefined
    throw new Error "unknown fence: #{rpr fence}"
  return R

#===========================================================================================================
# TRACKER
#-----------------------------------------------------------------------------------------------------------
@TRACKER = {}

#-----------------------------------------------------------------------------------------------------------
### TAINT shouldn't be defined at module level ###
fences_rxcc     = /// < \. \{ \[ \( \) \] \} > ///
name_rx         = /// [^ \s #{fences_rxcc.source} ]* ///
tracker_pattern = /// ^
    ( [ #{fences_rxcc.source} ]? )
    ( #{name_rx.source}          )
    ( [ #{fences_rxcc.source} ]? )
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
    unless left_fence in @FENCES.xleft
      throw new Error "illegal left_fence in pattern #{rpr pattern}"
    if right_fence?
      ### Complain about non-matching fences ###
      unless ( @FENCES._get_opposite left_fence, null ) is right_fence
        throw new Error "fences don't match in pattern #{rpr pattern}"
  if right_fence?
    ### Complain about unknown right fences ###
    unless right_fence in @FENCES.xright
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
@_PRE.$flatten_tokens = ( S ) =>
  return $ ( token, send ) ->
    switch ( type = token[ 'type' ] )
      when 'inline' then send sub_token for sub_token in token[ 'children' ]
      else send token

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
      ### TAINT what to do with useful data appearing environment? ###
      environment = {}
      tokens      = md_parser.parse XXX_source, environment
      ### remove extraneous text content: ###
      removed     = tokens[ 1 ]?[ 'children' ]?.splice 0, 1
      unless removed[ 0 ]?[ 'content' ] is "XXX"
        throw new Error "should never happen"
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
  #.........................................................................................................
  send_unknown = ( token, meta ) =>
    { type, } = token
    _send [ '?', type, token[ 'content' ], meta, ]
    unknown_tokens.push type unless type in unknown_tokens
  #.........................................................................................................
  return $ ( token, send, end ) =>
    _send = send
    if token?
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
        send [ '<', 'document', null, meta, ]
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
        # urge '@a20g', token[ 'type' ], within_footnote_block
        switch type
          # blocks
          when 'heading_open'       then send [ '[', token[ 'tag' ],  null,               meta, ]
          when 'heading_close'      then send [ ']', token[ 'tag' ],  null,               meta, ]
          when 'paragraph_open'     then null
          when 'paragraph_close'    then send [ '.', 'p',             null,               meta, ]
          when 'bullet_list_open'   then send [ '[', 'ul',            null,               meta, ]
          when 'bullet_list_close'  then send [ ']', 'ul',            null,               meta, ]
          when 'list_item_open'     then send [ '[', 'li',            null,               meta, ]
          when 'list_item_close'    then send [ ']', 'li',            null,               meta, ]
          # inlines
          when 'strong_open'        then send [ '(', 'strong',        null,               meta, ]
          when 'strong_close'       then send [ ')', 'strong',        null,               meta, ]
          when 'em_open'            then send [ '(', 'em',            null,               meta, ]
          when 'em_close'           then send [ ')', 'em',            null,               meta, ]
          # singles
          when 'text'               then send [ '.', 'text',          token[ 'content' ], meta, ]
          when 'hr'                 then send [ '.', 'hr',            token[ 'markup' ],  meta, ]
          #.................................................................................................
          # specials
          when 'code_inline'
            send [ '(', 'code', null,                        meta,    ]
            send [ '.', 'text', token[ 'content' ], ( @copy meta ),  ]
            send [ ')', 'code', null,               ( @copy meta ),  ]
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
          when 'html_block'
            throw new Error "should never happen"
          #.................................................................................................
          when 'fence'
            switch token[ 'tag' ]
              when 'code'
                language_name = token[ 'info' ]
                language_name = 'text' if language_name.length is 0
                send [ '{', 'code', language_name,               meta,    ]
                send [ '.', 'text', token[ 'content' ], ( @copy meta ),  ]
                send [ '}', 'code', language_name,      ( @copy meta ),  ]
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
            debug '@26.05', token
            send_unknown token, meta
        #...................................................................................................
        last_map = map
      #.....................................................................................................
      if type is 'footnote_block_close' then within_footnote_block = no
    #.......................................................................................................
    if end?
      if unknown_tokens.length > 0
        send remark 'warn', "unknown tokens: #{unknown_tokens.sort().join ', '}", {}
      send [ '>', 'document', null, {}, ]
      end()
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
            send.error new Error "unknown footnote ID #{rpr current_footnote_id}"
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


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$close_dangling_open_tags = ( S ) ->
  tag_stack = []
  remark    = @_get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    # debug '©nLnB5', event
    if @select event, '>', 'document'
      while tag_stack.length > 0
        sub_event                                   = tag_stack.pop()
        [ sub_type, sub_name, sub_text, sub_meta, ] = sub_event
        switch sub_type
          when '{' then sub_type = '}'
          when '[' then sub_type = ']'
          when '(' then sub_type = ')'
        send remark 'resend', "`#{sub_name}#{sub_type}`", @copy meta
        S.resend "debug '©Vc8qO'"
        # S.resend [ sub_type, sub_name, sub_text, ( @copy sub_meta ), ]
        send [ 'tex', "'©nAf98', \\end{multicols}", ]
      send event
    else if @select event, [ '{', '[', '(', ]
      tag_stack.push [ type, name, null, meta, ]
      send event
    else if @select event, [ '}', ']', ')', ]
      ### TAINT should check matching pairs ###
      tag_stack.pop()
      send event
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@select = ( event, type, name ) ->
  ### TAINT should use the same syntax as accepted by `FENCES.parse` ###
  ### check for arity as it's easy to write `select event, '(', ')', 'latex'` when what you meant
  was `select event, [ '(', ')', ], 'latex'` ###
  return false if @is_hidden event
  if ( arity = arguments.length ) > 3
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
  that have not yet found a representation in the target document. ###
  event[ 3 ][ 'stamped' ] = yes
  return event

#-----------------------------------------------------------------------------------------------------------
@is_stamped   = ( event ) -> event[ 3 ]?[ 'stamped' ] is true
@is_unstamped = ( event ) -> not @is_stamped event

#-----------------------------------------------------------------------------------------------------------
@hide = ( event ) ->
  ### 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
  ignore events that have already been marked upstream, or, inversely choose to look out for events
  that have not yet found a representation in the target document. ###
  event[ 3 ][ 'hidden' ] = yes
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
@$show_unhandled_tags = ( S ) ->
  return $ ( event, send ) =>
    ### TAINT selection could be simpler, less repetitive ###
    if event[ 0 ] in [ 'tex', 'text', ]
      send event
    else if @select event, '.', 'text'
      send event
    else unless @is_stamped event
      [ type, name, text, meta, ] = event
      if text?
        if ( CND.isa_pod text )
          if ( Object.keys text ).length is 0
            text = ''
          else
            text = rpr text
      else
        text = ''
      if type in [ '.', '!', ] or type in @FENCES.xleft
        first             = type
        last              = name
        pre               = '█'
        post              = ''
      else
        first             = name
        last              = type
        pre               = ''
        post              = '█'
      event_txt         = first + last + ' ' + text
      event_tex         = @fix_typography_for_tex event_txt, S.options
      ### TAINT use mkts command ###
      send [ 'tex', """{\\mktsStyleBold\\color{violet}{%
        \\mktsStyleSymbol#{pre}}#{event_tex}{\\mktsStyleSymbol#{post}}}""" ]
      send event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$show_illegal_chrs = ( S ) ->
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
@$show_mktsmd_events = ( S ) ->
  unknown_events    = []
  indentation       = ''
  tag_stack         = []
  return D.$observe ( event, has_ended ) =>
    if event?
      [ type, name, text, meta, ] = event
      if type is '?'
        unknown_events.push name unless name in unknown_events
        warn JSON.stringify event
      else
        color = CND.blue
        #...................................................................................................
        if @is_hidden event
          color = CND.brown
        else
          switch type
            when '<', '>'      then color = CND.yellow
            when '{','[',  '(' then color = CND.lime
            when ')', ']', '}' then color = CND.olive
            when '!'           then color = CND.indigo
            when '#'           then color = CND.plum
            when '.'
              switch name
                when 'text' then color = CND.BLUE
                # when 'code' then color = CND.orange
        #...................................................................................................
        text = if text? then ( color rpr text ) else ''
        switch type
          #.................................................................................................
          when 'text'
            log indentation + ( color type ) + ' ' + rpr name
          #.................................................................................................
          when 'tex'
            if S.show_tex_events ? no
              log indentation + ( color type ) + ( color name ) + ' ' + text
          #.................................................................................................
          when '#'
            [ _, kind, message, _, ]  = event
            my_badge                  = "(#{meta[ 'badge' ]})"
            color = switch kind
              when 'insert' then  'lime'
              when 'drop'   then  'orange'
              when 'warn'   then  'RED'
              when 'info'   then  'BLUE'
              else                'grey'
            log ( CND[ color ] '#' + kind ), ( CND.white message ), ( CND.grey my_badge )
          #.................................................................................................
          else
            log indentation + ( color type ) + ( color name ) + ' ' + text
        #...................................................................................................
        unless @is_hidden event
          switch type
            #.................................................................................................
            when '{', '[', '(', ')', ']', '}'
              switch type
                when '{', '[', '('
                  tag_stack.push [ type, name, ]
                when ')', ']', '}'
                  if tag_stack.length > 0
                    [ topmost_type, topmost_name, ] = tag_stack.pop()
                    unless topmost_name is name
                      topmost_type = { '{': '}', '[': ']', '(', ')', }[ topmost_type ]
                      warn "encountered #{type}#{name} when #{topmost_type}#{topmost_name} was expected"
                  else
                    warn "level below zero"
              indentation = ( new Array tag_stack.length ).join '  '
    #.......................................................................................................
    if has_ended
      if tag_stack.length > 0
        warn "unclosed tags: #{tag_stack.join ', '}"
      if unknown_events.length > 0
        warn "unknown events: #{unknown_events.sort().join ', '}"
    return null

#-----------------------------------------------------------------------------------------------------------
@$write_mktscript = ( S ) ->
  indentation       = ''
  tag_stack         = []
  mkscript_locator  = S.layout_info[ 'mkscript-locator' ]
  output            = njs_fs.createWriteStream mkscript_locator
  confluence        = D.create_throughstream()
  write             = confluence.write.bind confluence
  confluence.pipe output
  #.........................................................................................................
  return D.$observe ( event, has_ended ) ->
    if event?
      [ type, name, text, meta, ] = event
      unless type in [ 'tex', 'text', ]
        { line_nr, }                = meta
        anchor                      = "█ #{line_nr} █ "
        #.....................................................................................................
        switch type
          when '?'
            write "\n#{anchor}#{type}#{name}\n"
          when '<', '{', '['
            write "#{anchor}#{type}#{name}"
          when '>', '}', ']', '!'
            write "#{type}\n"
          when '('
            write "#{type}#{name}"
          when ')'
            write "#{type}"
          when '.'
            switch name
              when 'hr'
                write "\n#{anchor}#{type}#{name}\n"
              when 'p'
                write "¶\n"
              when 'text'
                ### TAINT doesn't recognize escaped backslash ###
                text_rpr = ( rpr text ).replace /\\n/g, '\n'
                write text_rpr
              else
                write "\n#{anchor}IGNORED: #{rpr event}"
          else
            write "\n#{anchor}IGNORED: #{rpr event}"
    if has_ended
      output.end()
    return null


#===========================================================================================================
# _ESC (RAW / ACTION / COMMAND ESCAPING)
#-----------------------------------------------------------------------------------------------------------
@_ESC = {}

#-----------------------------------------------------------------------------------------------------------
@_ESC.initialize = ( state ) =>
  state[ '_ESC' ] =
    registry:   []
    index:      new Map()

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.html_comment_pattern = ///
  (?: ( ^ | [^\\] ) <!--                      --> ) |
  (?: ( ^ | [^\\] ) <!-- ( [ \s\S ]*? [^\\] ) --> )
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.do_bracketed_pattern = ///
  (?: ( ^ | [^\\] ) <<\{ do >>                      << do \}>> ) |
  (?: ( ^ | [^\\] ) <<\{ do >> ( [ \s\S ]*? [^\\] ) << do \}>> )
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.raw_bracketed_pattern = ///
  (?: ( ^ | [^\\] ) <<\( raw >>                      << raw \)>> ) |
  (?: ( ^ | [^\\] ) <<\( raw >> ( [ \s\S ]*? [^\\] ) << raw \)>> )
  ///g

#-----------------------------------------------------------------------------------------------------------
@_ESC.raw_heredoc_pattern  = ///
  ( ^ | [^\\] ) <<! raw: ( [^\s>]* )>> ( .*? ) \2
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.raw_id_pattern       = ///
  \x15 raw ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.html_comment_id_pattern = ///
  \x15 comment ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.do_id_pattern   = ///
  \x15 do ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
### Code duplication ###
@_ESC.action_id_pattern   = ///
  \x15 action ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@_ESC.command_pattern = ///
  ( ^ | [^\\] )
  (
    <<
    ( [     ! { [ (           ]?  )
    ( [^ \s ! { [ ( ) \] > }  ]+? )
    ( [              ) \]   } ]?  )
    >>
    )
  ///g

#-----------------------------------------------------------------------------------------------------------
@_ESC.escape_html_comments_raw_spans_and_commands = ( S, text ) =>
  debug '©II6XI', rpr text
  R = text
  R = @_ESC.escape_escape_chrs R
  #.........................................................................................................
  R = R.replace @_ESC.html_comment_pattern, ( _, $1, $2, $3 ) =>
    $1           ?= ''
    $2           ?= ''
    $1           += $2
    raw_content   = $3 ? ''
    key           = @_ESC.register_content S, 'comment', raw_content.trim()
    return "#{$1}\x15#{key}\x13"
  #.........................................................................................................
  R = R.replace @_ESC.do_bracketed_pattern, ( _, $1, $2, $3 ) =>
    $1           ?= ''
    $2           ?= ''
    $1           += $2
    raw_content   = $3 ? ''
    debug '©0qY0t', raw_content
    id            = @_ESC.register_content S, 'do', raw_content
    return "#{$1}\x15#{id}\x13"
  #.........................................................................................................
  R = R.replace @_ESC.raw_bracketed_pattern, ( _, $1, $2, $3 ) =>
    $1           ?= ''
    $2           ?= ''
    $1           += $2
    raw_content   = $3 ? ''
    id            = @_ESC.register_content S, 'raw', raw_content
    return "#{$1}\x15#{id}\x13"
  #.........................................................................................................
  R = R.replace @_ESC.raw_heredoc_pattern, ( _, $1, $2, $3 ) =>
    raw_content   = $3 ? ''
    id            = @_ESC.register_content S, 'raw', raw_content
    return "#{$1}\x15#{id}\x13"
  #.........................................................................................................
  R = R.replace @_ESC.command_pattern, ( _, $1, $2, $3, $4, $5 ) =>
    raw_content     = $2
    parsed_content  = [ $3, $4, $5, ]
    ### replace fences by `null` in case of empty string: ###
    parsed_content[ 0 ] = null if parsed_content[ 0 ].length is 0
    parsed_content[ 2 ] = null if parsed_content[ 2 ].length is 0
    key                 = @_ESC.register_content S, 'action', raw_content, parsed_content
    return "#{$1}\x15#{key}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_ESC.register_content = ( S, kind, raw, parsed = null ) =>
  registry  = S[ '_ESC' ][ 'registry' ]
  index     = S[ '_ESC' ][ 'index' ]
  id        = index.get raw
  if id?
    entry   = registry[ id ]
    { key } = entry
  else
    id      = registry.length
    key     = "#{kind}#{id}"
    registry.push { key, raw, parsed, }
    index.set raw, id
  return key

#-----------------------------------------------------------------------------------------------------------
@_ESC.retrieve_entry = ( S, id ) =>
  throw new Error "unknown ID #{rpr id}" unless ( R = S[ '_ESC' ][ 'registry' ][ id ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@_ESC.$expand_html_comments = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if @select event, '.', [ 'text', 'code', ]
      is_comment                  = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @_ESC.html_comment_id_pattern
        is_comment = not is_comment
        if is_comment
          id      = parseInt stretch, 10
          entry   = @_ESC.retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '.', 'comment', content, ( @copy meta ), ]
        else
          send [ type, name, stretch, ( @copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_ESC.$expand_actions = ( S ) =>
  ### TAINT code duplication ###
  track = @TRACKER.new_tracker '(code)', '{code}'
  return $ ( event, send ) =>
    within_code = track.within '(code)', '{code}'
    track event
    #.......................................................................................................
    ### TAINT wrong selector ###
    if @select event, '.', [ 'text', 'code', 'comment', ]
      is_command                  = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @_ESC.action_id_pattern
        is_command = not is_command
        if is_command
          id      = parseInt stretch, 10
          entry   = @_ESC.retrieve_entry S, id
          if within_code
            content = entry[ 'raw' ]
            send [ '.', 'text', content, ( @copy meta ), ]
          else
            content = entry[ 'parsed' ]
            ### should never happen: ###
            throw new Error "not registered correctly: #{rpr stretch}"  unless CND.isa_list content
            [ left_fence, action_name, right_fence, ] = content
            fence = left_fence ? right_fence
            send [ fence, action_name, null, ( @copy meta ), ]
        else
          send [ type, name, stretch, ( @copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_ESC.$expand_raw_spans  = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if @select event, '.', [ 'text', 'code', 'comment', ]
      is_raw                      = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @_ESC.raw_id_pattern
        is_raw = not is_raw
        if is_raw
          id      = parseInt stretch, 10
          entry   = @_ESC.retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '.', 'raw', content, ( @copy meta ), ]
        else
          send [ type, name, stretch, ( @copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_ESC.$expand_do_spans  = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if @select event, '.', [ 'text', 'code', 'comment', ]
      is_do                       = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @_ESC.do_id_pattern
        is_do = not is_do
        if is_do
          id      = parseInt stretch, 10
          entry   = @_ESC.retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '!', 'do', content, ( @copy meta ), ]
        else
          send [ type, name, stretch, ( @copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_ESC.escape_escape_chrs = ( text ) =>
  R = text
  R = R.replace /\x10/g, '\x10A'
  R = R.replace /\x15/g, '\x10X'
  return R

#-----------------------------------------------------------------------------------------------------------
@_ESC.unescape_escape_chrs = ( text ) =>
  R = text
  R = R.replace /\x10X/g, '\x15'
  R = R.replace /\x10A/g, '\x10'
  return R


#-----------------------------------------------------------------------------------------------------------
@new_resender = ( S, stream ) ->
  ### TAINT new parser not needed, can reuse 'main' parser ###
  md_parser = @_new_markdown_parser()
  return ( md_source ) =>
    ### TAINT must handle data in environment ###
    if CND.isa_text md_source
      md_source   = @_ESC.escape_html_comments_raw_spans_and_commands S, md_source
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
        ( debug '©9fdeD', "resending", tokens[ idx ] ) for idx in [ first_idx .. last_idx ]
        stream.write tokens[ idx ] for idx in [ first_idx .. last_idx ]
    else
      debug '©vKQlM', "resending", md_source
      stream.write md_source

#===========================================================================================================
# STREAM CREATION
#-----------------------------------------------------------------------------------------------------------
@create_mdreadstream = ( md_source, settings ) ->
  throw new Error "settings currently unsupported" if settings?
  #.........................................................................................................
  confluence  = D.create_throughstream()
  R           = D.create_throughstream()
  R.pause()
  #.........................................................................................................
  S =
    confluence:           confluence
    environment:          {}
  #.........................................................................................................
  ### TAINT shouldn't attach method here ###
  R.XXX_resend = @new_resender S, confluence
  #.........................................................................................................
  confluence
    .pipe @_PRE.$flatten_tokens                 S
    .pipe @_PRE.$reinject_html_blocks           S
    .pipe @_PRE.$rewrite_markdownit_tokens      S
    .pipe @_ESC.$expand_html_comments           S
    .pipe @_ESC.$expand_actions                 S
    .pipe @_ESC.$expand_raw_spans               S
    .pipe @_ESC.$expand_do_spans                S
    .pipe @_PRE.$process_end_command            S
    .pipe @_PRE.$consolidate_footnotes          S
    .pipe R
  #.........................................................................................................
  R.on 'resume', =>
    md_parser   = @_new_markdown_parser()
    ### for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse ###
    @_ESC.initialize S
    ### TAINT consider to make `<<!end>>` special and detect it before parsing ###
    md_source   = @_ESC.escape_html_comments_raw_spans_and_commands S, md_source
    urge 'registry    ', S[ '_ESC' ][ 'registry' ]
    urge 'index       ', S[ '_ESC' ][ 'index' ]
    tokens      = md_parser.parse md_source, S.environment
    debug '©iOCip', S.environment
    # process.exit()
    # @set_meta R, 'environment', environment
    confluence.write token for token in tokens
    confluence.end()
  #.........................................................................................................
  return R


