


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER'
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
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
ASYNC                     = require 'async'
#...........................................................................................................
ƒ                         = CND.format_number.bind CND
HELPERS                   = require './helpers'
TEXLIVEPACKAGEINFO        = require './texlivepackageinfo'
options_route             = '../options.coffee'
{ CACHE, OPTIONS, }       = require './options-and-cache'
SEMVER                    = require 'semver'
#...........................................................................................................
TEXT                      = require 'coffeenode-text'
XNCHR                     = require './xnchr'
MKTS                      = require './main'
MKTSCRIPT_WRITER          = require './mktscript-writer'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
MACRO_ESCAPER             = require './macro-escaper'
MACRO_INTERPRETER         = require './macro-interpreter'
LINEBREAKER               = require './linebreaker'
@COLUMNS                  = require './tex-writer-columns'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
### TAINT experimental, should become part of `PIPEDREAMS` to facilitate automated assembly of pipelines
based on registered precedences using `CND.TSORT` ###
before = ( names..., method ) ->
  return method

#-----------------------------------------------------------------------------------------------------------
after = ( names..., method ) ->
  return method


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@compile_options = ->
  ### TAINT this method should go to OPTIONS ###
  options_locator                   = require.resolve njs_path.resolve __dirname, options_route
  # debug '©zNzKn', options_locator
  options_home                      = njs_path.dirname options_locator
  @options                          = OPTIONS.from_locator options_locator
  @options[ 'home' ]                = options_home
  @options[ 'locator' ]             = options_locator
  cache_route                       = @options[ 'cache' ][ 'route' ]
  @options[ 'cache' ][ 'locator' ]  = cache_locator = njs_path.resolve options_home, cache_route
  @options[ 'xelatex-command' ]     = njs_path.resolve options_home, @options[ 'xelatex-command' ]
  #.........................................................................................................
  unless njs_fs.existsSync cache_locator
    @options[ 'cache' ][ '%self' ] = {}
    CACHE.save @options
  #.........................................................................................................
  @options[ 'cache' ][ '%self' ]    = require cache_locator
  #.........................................................................................................
  if ( texinputs_routes = @options[ 'texinputs' ]?[ 'routes' ] )?
    locators = []
    for route in texinputs_routes
      has_single_slash  = ( /\/$/   ).test route
      has_double_slash  = ( /\/\/$/ ).test route
      locator           = njs_path.resolve options_home, route
      if      has_double_slash then locator += '//'
      else if has_single_slash then locator += '/'
      locators.push locator
    ### TAINT duplication: tex_inputs_home, texinputs_value ###
    ### TAINT path separator depends on OS ###
    @options[ 'texinputs' ][ 'value' ] = locators.join ':'
  # @options[ 'locators' ] = {}
  # for key, route of @options[ 'routes' ]
  #   @options[ 'locators' ][ key ] = njs_path.resolve options_home, route
  #.........................................................................................................
  # debug '©ed8gv', JSON.stringify @options, null, '  '
  CACHE.update @options
#...........................................................................................................
@compile_options()

#-----------------------------------------------------------------------------------------------------------
@write_mkts_master = ( layout_info, handler ) ->
  step ( resume ) =>
    lines             = []
    write             = lines.push.bind lines
    master_locator    = layout_info[ 'master-locator'  ]
    content_locator   = layout_info[ 'content-locator' ]
    help "writing #{master_locator}"
    #-------------------------------------------------------------------------------------------------------
    write ""
    write "% #{master_locator}"
    write "% do not edit this file"
    write "% generated from #{@options[ 'locator' ]}"
    write "% on #{new Date()}"
    write ""
    write "\\documentclass[a4paper,twoside]{book}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    # DEFS
    #.......................................................................................................
    defs = @options[ 'defs' ]
    write ""
    write "% DEFS"
    if defs?
      write "\\def\\#{name}{#{value}}" for name, value of defs
    #-------------------------------------------------------------------------------------------------------
    # NEWCOMMANDS
    #.......................................................................................................
    newcommands = @options[ 'newcommands' ]
    write ""
    write "% NEWCOMMANDS"
    if newcommands?
      for name, value of newcommands
        warn "implicitly converting newcommand value for #{name}"
        value = njs_path.resolve __dirname, '..', value
        write "\\newcommand{\\#{name}}{%\n#{value}%\n}"
    #-------------------------------------------------------------------------------------------------------
    # PACKAGES
    #.......................................................................................................
    write ""
    write "% PACKAGES"
    # write "\\usepackage{mkts2015-main}"
    # write "\\usepackage{mkts2015-fonts}"
    # write "\\usepackage{mkts2015-article}"
    write "\\usepackage{mkts2015-consolidated}"


    #-------------------------------------------------------------------------------------------------------
    # FONTS
    #......................................................................................................
    fontspec_version  = yield TEXLIVEPACKAGEINFO.read_texlive_package_version @options, 'fontspec', resume
    use_new_syntax    = SEMVER.satisfies fontspec_version, '>=2.4.0'
    fonts_home        = @options[ 'fonts' ][ 'home' ]
    #.......................................................................................................
    write ""
    write "% FONTS"
    write "% assuming fontspec@#{fontspec_version}"
    write "\\usepackage{fontspec}"
    #.......................................................................................................
    for { texname, otf, home, subfolder, filename, } in @options[ 'fonts' ][ 'files' ]
      home              ?= fonts_home
      home              = njs_path.join home, subfolder if subfolder?
      home              = "#{home}/" unless home.endsWith '/'
      font_settings     = [ "Path=#{home}", ]
      font_settings.push otf if otf?
      font_settings_txt = font_settings.join ','
      if use_new_syntax
        ### TAINT should properly escape values ###
        write "\\newfontface{\\#{texname}}{#{filename}}[#{font_settings_txt}]"
        # write "\\newcommand{\\#{texname}}{"
        # write "\\typeout{\\trmWhite{redefining #{texname}}}"
        # write "\\newfontface{\\#{texname}XXX}{#{filename}}[#{font_settings_txt}/]"
        # write "\\renewcommand{\\#{texname}}{\\#{texname}XXX}"
        # write "}"
      else
        write "\\newfontface\\#{texname}[#{font_settings_txt}]{#{filename}}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    # STYLES
    #......................................................................................................
    write ""
    write "% STYLES"
    if ( styles = @options[ 'styles' ] )?
      write "\\newcommand{\\#{name}}{%\n#{value}%\n}" for name, value of styles
    #-------------------------------------------------------------------------------------------------------
    main_font_name = @options[ 'fonts' ][ 'main' ]
    throw new Error "need entry options/fonts/name" unless main_font_name?
    write ""
    write "% CONTENT"
    # write "\\begin{document}\\mktsStyleNormal"
    #-------------------------------------------------------------------------------------------------------
    # INCLUDES
    #.......................................................................................................
    write ""
    write "\\input{#{content_locator}}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    write "\\end{document}"
    #-------------------------------------------------------------------------------------------------------
    text = lines.join '\n'
    # whisper text
    njs_fs.writeFile master_locator, text, handler


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@MKTX =
  TYPOFIX:      require './tex-writer-typofix'
  DOCUMENT:     {}
  COMMAND:      {}
  REGION:       {}
  BLOCK:        {}
  INLINE:       {}
  MIXED:        {}
  CLEANUP:      {}

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, '!', 'new-page'
    send stamp event
    [ type, name, text, meta, ] = event
    send [ 'tex', "\\null\\newpage{}", ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$comment = ( S ) =>
  remark = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, '.', 'comment'
    [ type, name, text, meta, ] = event
    send remark 'drop', "`.comment`: #{rpr text}", copy meta

#-----------------------------------------------------------------------------------------------------------
@$document = ( S ) =>
  buffer                  = []
  start_document_event    = null
  before_document_command = yes
  send_                   = null
  before_flush            = yes
  bare                    = S.bare ? no
  #.........................................................................................................
  flush_as = ( what ) =>
    send_ [ 'tex', "\n% begin of MD document\n", ]
    if what is 'preamble' and buffer.length > 0
      send_ [ 'tex', "% (extra preamble inserted from MD document)\n", ]
      send_ event for event in buffer
    send_ stamp start_document_event
    send_ [ 'tex', "\\begin{document}\\mktsStyleNormal{}", ] unless bare
    if what is 'document'
      send_ event for event in buffer
    buffer.length           = 0
    before_document_command = no
  #.........................................................................................................
  return $ ( event, send ) =>
    send_ = send
    #.......................................................................................................
    if before_flush
      send event
      before_flush = no if select event, '~', 'flush'
    #.......................................................................................................
    else if select event, ')', 'document'
      flush_as 'document' if before_document_command
      send [ 'tex', "\n% end of MD document\n", ]
      send stamp event
    #.......................................................................................................
    else if select event, '!', 'document'
      send stamp event
      flush_as 'preamble'
    #.......................................................................................................
    else if before_document_command
      if select event, '(', 'document'
        start_document_event = event
      else
        buffer.push event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$code = ( S ) =>
  ### TAINT code duplication with `REGION.$keep_lines` possible ###
  track = MD_READER.TRACKER.new_tracker '(code)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code = track.within '(code)'
    track event
    #.......................................................................................................
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      if within_code
        text = text.replace /\u0020/g, '\u00a0'
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'code'
      [ type, name, parameters, meta, ] = event
      [ language, settings, ]           = parameters
      keeplines_parameters              = if settings? then [ settings, ] else []
      #.....................................................................................................
      if type is '('
        send stamp event
        send [ '(', 'keep-lines', keeplines_parameters, ( copy meta ), ]
        send [ 'tex', "\n\n{\\mktsStyleCode{}", ] unless language is 'keep-lines'
      else
        send [ 'tex', "}\n\n", ] unless language is 'keep-lines'
        send [ ')', 'keep-lines', keeplines_parameters, ( copy meta ), ]
        send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$keep_lines = ( S ) =>
  track           = MD_READER.TRACKER.new_tracker '(keep-lines)'
  last_was_empty  = no
  squish          = no
  #.........................................................................................................
  return $ ( event, send ) =>
    within_keep_lines = track.within '(keep-lines)'
    track event
    #.......................................................................................................
    if within_keep_lines and select event, '.', 'text'
      # send stamp event
      [ type, name, text, meta, ] = event
      ### TAINT other replacements possible; use API ###
      ### TAINT U+00A0 (nbsp) might be too wide ###
      # text = text.replace /\n\n/g, "{\\mktsTightParagraphs\\null\\par\n"
      text    = text.replace /\u0020/g, '\u00a0'
      # text    = text.replace /^\n/,     ''
      chunks  = text.split /(\n)/g
      for chunk in chunks
        if chunk is '\n'
          if last_was_empty then send [ 'tex', "\\null\\par\n", ]
          else                   send [ 'tex',       "\\par\n", ]
        else
          unless last_was_empty = chunk.length is 0
            # debug `0903`, rpr chunk
            # chunk = @MKTX.TYPOFIX.fix_typography_for_tex chunk, S.options
            send [ '.', 'text', chunk, ( copy meta ), ]
            # send [ 'tex', chunk, ]
    #.......................................................................................................
    else if select event, '(', 'keep-lines'
      send stamp event
      [ type, name, parameters, meta, ] = event
      unless squish = parameters?[ 0 ]?[ 'squish' ] ? no
        send [ 'tex', "\\null\\par", ]
      send [ 'tex', "{\\mktsTightParagraphs{}", ]
    #.......................................................................................................
    else if select event, ')', 'keep-lines'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
before '@MKTX.BLOCK.$heading', '@MKTX.COMMAND.$toc', \
@MKTX.REGION.$toc = ( S ) =>
  track   = MD_READER.TRACKER.new_tracker '(toc)'
  buffer  = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_toc = track.within '(toc)'
    track event
    #.......................................................................................................
    if select event, '(', 'toc'
      send stamp event
      [ type, name, text, meta, ] = event
      buffer = [ '!', name, text, meta, ]
    #.......................................................................................................
    else if select event, ')', 'toc'
      send stamp event
      if buffer?
        send buffer
        buffer = null
    #.......................................................................................................
    else if within_toc and select event, '.', 'comma'
      if buffer?
        send buffer
        buffer = null
    #.......................................................................................................
    else if within_toc and select event, [ '(', ')', ], 'h'
      [ type, name, text, meta, ] = event
      meta[ 'toc' ] = 'omit'
      send event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  ### TAINT make numbering style configurable ###
  ### TAINT generalize for more than 3 levels ###
  h_nrs             = [ 1, 1, 1, ]
  h_idx             = -1
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'h'
      [ type, name, level, meta, ] = event
      h_idx                += +1
      h_key                 = "h-#{h_idx}"
      meta[ 'h' ]          ?= {}
      meta[ 'h' ][ 'idx' ]  = h_idx
      meta[ 'h' ][ 'key' ]  = h_key
      #.....................................................................................................
      send [ 'tex', "\n", ]
      send stamp event
      #.....................................................................................................
      switch level
        when 1
          send [ '!', 'columns', [ 1, ], ( copy meta, { toc: 'omit' }, ), ]
          send [ 'tex', "{\\mktsHOne{}", ]
          send [ 'tex', "\\zlabel{#{h_key}}", { toc: 'omit' }, ]
        when 2
          send [ '!', 'columns', [ 1, ], ( copy meta, { toc: 'omit' }, ), ]
          send [ 'tex', "{\\mktsHTwo{}", ]
          send [ 'tex', "\\zlabel{#{h_key}}", { toc: 'omit' }, ]
        when 3
          send [ '!', 'columns', [ 1, ], ( copy meta, { toc: 'omit' }, ), ]
          send [ 'tex', "{\\mktsHThree{}", ]
          send [ 'tex', "\\zlabel{#{h_key}}", { toc: 'omit' }, ]
        else return send [ '.', 'warning', "heading level #{level} not implemented", ( copy meta ), ]
    #.......................................................................................................
    else if select event, ')', 'h'
      [ type, name, level, meta, ] = event
      #.....................................................................................................
      switch level
        when 1
          send [ 'tex', "\\mktsHOneBeg}%\n",          ]
          send [ '!', 'columns', [ 'pop', ], ( copy meta, { toc: 'omit' }, ), ]
        when 2
          send [ 'tex', "\\mktsHTwoBeg}%\n",          ]
          send [ '!', 'columns', [ 'pop', ], ( copy meta, { toc: 'omit' } ), ]
        when 3
          send [ 'tex', "\\mktsHThreeBeg}%\n\n",        ]
          send [ '!', 'columns', [ 'pop', ], ( copy meta, { toc: 'omit' } ), ]
        else return send [ '.', 'warning', "heading level #{level} not implemented", ( copy meta ), ]
      #.....................................................................................................
      send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
before '@MKTX.COMMAND.$toc', after '@MKTX.BLOCK.$heading', \
@MKTX.MIXED.$collect_headings_for_toc = ( S ) =>
  within_heading  = no
  this_heading    = null
  headings        = []
  buffer          = []
  remark          = MD_READER._get_remark()
  #.........................................................................................................
  new_heading = ( level, meta ) ->
    R =
      level:    level
      idx:      meta[ 'h' ][ 'idx' ]
      key:      meta[ 'h' ][ 'key' ]
      events:   []
    return R
  #.........................................................................................................
  return $ ( event, send ) =>
    # debug '8624', event
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '~', [ 'flush', 'stop', ]
      send remark name, "releasing #{buffer.length} events", ( copy meta, )
      send sub_event for sub_event in buffer
      buffer.length = 0
      send event
    #.......................................................................................................
    else if select event, '(', 'document'
      send event
    #.......................................................................................................
    else if select event, ')', 'document'
      # debug '2139', unstamp [ '.', 'toc-headings', headings, meta, ]
      send unstamp [ '.', 'toc-headings', headings, meta, ]
      send sub_event for sub_event in buffer
      buffer.length = 0
      send event
    #.......................................................................................................
    else if meta? and ( meta[ 'toc' ] isnt 'omit' ) and select event, '(', 'h'
      ### TAINT use library method to test event category ###
      level                           = text
      within_heading                  = yes
      this_heading                    = new_heading level, meta
      headings.push this_heading
      buffer.push event
    #.......................................................................................................
    else if select event, ')', 'h'
      within_heading                  = no
      this_heading                    = null
      buffer.push event
    #.......................................................................................................
    else if within_heading
      ### TAINT use library method to determine event category ###
      unless event[ event.length - 1 ][ 'toc' ] is 'omit'
        if event.length is 4
          this_heading[ 'events' ].push [ type, name, text, ( copy meta ), ]
        else
          this_heading[ 'events' ].push event
      unless event[ event.length - 1 ][ 'toc' ] is 'only'
        buffer.push event
    #.......................................................................................................
    else
      buffer.push event

#-----------------------------------------------------------------------------------------------------------
after '@MKTX.REGION.$toc', '@MKTX.MIXED.$collect_headings_for_toc', \
@MKTX.COMMAND.$toc = ( S ) =>
  headings = null
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT use library method to test event category ###
    if select event, '.', 'toc-headings'
      [ _, _, headings, _, ] = event
      send stamp event
    #.......................................................................................................
    else if select event, '!', 'toc'
      send stamp event
      #.....................................................................................................
      unless headings?
        return send [ '.', 'warning', "expecting toc-headings event before this", ( copy meta ), ]
      #.....................................................................................................
      [ type, name, text, meta, ] = event
      send [ 'tex', '{\\mktsToc%\n', ]
      # send [ '!', 'mark', 'toc', ( copy meta ), ]
      for heading in headings
        { level, events, key, } = heading
        last_idx                = events.length - 1
        for h_event, idx in events
          # debug '23432', h_event
          ### TAINT use library method to determine event category ###
          h_event = unstamp h_event if h_event.length is 4
          send [ 'tex', "{\\mktsStyleNormal \\dotfill \\zpageref{#{key}}}", ] if idx is last_idx
          # send [ 'tex', " \\dotfill \\zpageref{#{key}}", ] if idx is last_idx
          send h_event
      send [ 'tex', '\\mktsTocBeg}%\n', ]
      # headings.length = 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$yadda = ( S ) =>
  generate_yadda  = require 'lorem-ipsum'
  cache           = []
  settings        =
    count:                1                       # Number of words, sentences, or paragraphs to generate.
    # units:                'sentences'             # Generate words, sentences, or paragraphs.
    units:                'paragraphs'            # Generate words, sentences, or paragraphs.
    sentenceLowerBound:   5                       # Minimum words per sentence.
    sentenceUpperBound:   15                      # Maximum words per sentence.
    paragraphLowerBound:  3                       # Minimum sentences per paragraph.
    paragraphUpperBound:  7                       # Maximum sentences per paragraph.
    format:               'plain'                 # Plain text or html
    # words:                ['ad', 'dolor', ... ]   # Custom word dictionary. Uses dictionary.words (in lib/dictionary.js) by default.
    random:               CND.get_rnd 42, 3       # A PRNG function. Uses Math.random by default
    suffix:               '\n'                    # The character to insert between paragraphs. Defaults to default EOL for your OS.
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '!', 'yadda'
      [ type, name, parameters, meta, ] = event
      [ yadda_idx, ]                    = parameters
      yadda_idx                        ?= cache.length
      cache.push generate_yadda settings while cache.length - 1 < yadda_idx
      yadda = cache[ yadda_idx ]
      # yadda = @MKTX.TYPOFIX.fix_typography_for_tex yadda, S.options
      send stamp event
      # send [ 'tex', yadda, ]
      send [ '.', 'text', yadda, ( copy meta ), ]
      # send [ '.', 'p', null, ( copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$blockquote = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', 'blockquote'
      # [ type, name, parameters, meta, ] = event
      send stamp event
      # send [ 'tex', "{\\setlength{\\leftskip}{5mm}\\setlength{\\rightskip}{5mm}", ]
      send [ 'tex', "\\begin{mktsEnvBlockquote}", ]
    #.......................................................................................................
    else if select event, ')', 'blockquote'
      # [ type, name, parameters, meta, ] = event
      send stamp event
      # send [ 'tex', "}\n\n", ]
      send [ 'tex', "\\end{mktsEnvBlockquote}\n\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph_1 = ( S ) =>
  ### TAINT should unify the two observers ###
  track = MD_READER.TRACKER.new_tracker '(code)', '(keep-lines)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code       = track.within '(code)'
    within_keep_lines = track.within '(keep-lines)'
    track event
    #.......................................................................................................
    if select event, '.', 'p'
      [ type, name, text, meta, ] = event
      if within_code or within_keep_lines
        send stamp event
        send [ 'tex', '\n\n' ]
      else
        send stamp event
        send @MKTX.BLOCK._end_paragraph()
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph_2 = ( S ) =>
  within_paragraph  = no
  seen_text_event   = no
  collector         = []
  close_paragraph   = no
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if event[ 0 ] is '~' and event[ 1 ] is 'start-paragraph'
      within_paragraph  = yes
      seen_text_event   = no
    #.......................................................................................................
    else if select event, '.', 'p'
      within_paragraph  = no
      seen_text_event   = no
      # send [ 'tex', "\n}\n" ]
      send cached_event for cached_event in collector
      collector.length = 0
      if close_paragraph
        close_paragraph = no
        send [ 'tex', "\n}% )p\n" ]
    #.......................................................................................................
    else if within_paragraph
      if seen_text_event
        send event
      else
        if select event, '.', 'text'
          ### TAINT can omit either of these two ###
          seen_text_event = yes
          close_paragraph = yes
          send [ 'tex', "\n{% (p\n" ]
          # send [ 'tex', "\n{\n" ]
          send cached_event for cached_event in collector
          collector.length = 0
          send event
        else
          collector.push event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK._end_paragraph = =>
  ### TAINT use command from sty ###
  ### TAINT make configurable ###
  # return [ 'tex', '\\mktsShowpar\\par\n' ]
  return [ 'tex', '\n\n' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$unordered_list = ( S ) =>
  tex_by_md_markup =
    '*':          '$\\star$'
    'fallback':   '—'
  item_markup_tex = null
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'ul'
      [ type, name, text, meta, ] = event
      { markup } = meta
      ### TAINT won't work in nested lists ###
      ### TAINT make configurable ###
      item_markup_tex = tex_by_md_markup[ markup ] ? tex_by_md_markup[ 'fallback' ]
      send stamp event
      # send [ 'tex', '\\begin{itemize}' ]
    #.......................................................................................................
    else if select event, '(', 'li'
      send stamp event
      # send [ 'tex', "\\item[#{item_markup_tex}] " ]
      # send [ 'tex', "{\\mktsFontfileHanamina{}.⚫.▪.⏹.◼.⬛.}\\hspace{3mm}y" ]
      ### TAINT Horizontal space should depend on other metrics ###
      send [ 'tex', "{\\mktsFontfileHanamina{}\\prPushRaise{-0.4}{-0.1}{⚫}\\hspace{-0.75mm}}" ]
    #.......................................................................................................
    else if select event, ')', 'li'
      send stamp event
      send [ 'tex', '\n' ]
    #.......................................................................................................
    else if select event, ')', 'ul'
      send stamp event
      # send [ 'tex', '\\end{itemize}' ]
    #.......................................................................................................
    else
      send event

# #-----------------------------------------------------------------------------------------------------------
# # before '@MKTX.REGION.$single_column', '@MKTX.REGION.$multi_column', \
# @MKTX.BLOCK.$hr = ( S ) =>
#   plain_rule  = [ 'tex', "\\mktsRulePlain{}", ]
#   swell_rule  = [ 'tex', "\\mktsRuleSwell{}", ]
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     #.......................................................................................................
#     if select event, '.', 'hr'
#       [ type, name, text, meta, ] = event
#       switch chr = text[ 0 ]
#         when '.'
#           send stamp copy event
#           send plain_rule
#         when '-'
#           send stamp copy event
#           send swell_rule
#         when '°'
#           send stamp hide copy event
#           send [ '!', 'slash', [], ( copy meta ), ]
#         when ':'
#           send stamp hide copy event
#           send [ '!', 'slash', [ plain_rule, ], ( copy meta ), ]
#         when '='
#           send stamp hide copy event
#           send [ '!', 'slash', [ swell_rule, ], ( copy meta ), ]
#         when '^'
#           send stamp hide copy event
#           send [ '(', 'slash', [], ( copy meta ), ]
#         when 'v'
#           send stamp hide copy event
#           send [ ')', 'slash', [], ( copy meta ), ]
#         else
#           send stamp hide copy event
#           send [ '.', 'warning', "horizontal rule with unknown markup #{rpr text}", ( copy meta ), ]
#     #.......................................................................................................
#     else
#       send event

#-----------------------------------------------------------------------------------------------------------
# before '@MKTX.REGION.$single_column', '@MKTX.REGION.$multi_column', \
@MKTX.BLOCK.$hr2 = ( S ) =>
  # plain_rule  = [ 'tex', "\\mktsRulePlain{}", ]
  # swell_rule  = [ 'tex', "\\mktsRuleSwell{}", ]
  # tight_rule  = [ 'tex', "\\mktsRulePlainTight{}", ]
  ###

  / slash
  - plain (line)
  = bold (line)
  -= plain with bold (2 stacked lines)
  =- bold with plain (2 stacked lines)
  -=- plain, bold, plain (3 stacked lines)
  . dotted (line)
  * asterisks (line)
  + swole (line)
  0 compress (above & below)
  1 normal (spacing, one line above & below; default)
  2,1 custom (2 above, 1 below)
  2 splendid (2 above & below)

  // <!-- just a slash -->
  /0-------/
  0-------
  /2+++++2/
  /0--------============1/
  ###
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'hr2'
      send stamp event
      [ type, name, parameters, meta, ]         = event
      { slash, above, one, two, three, below, } = parameters
      switch one
        when '-' then rule_command = 'mktsRulePlainTight'
        when '=' then rule_command = 'mktsRuleBoldTight'
        when '#' then rule_command = 'mktsRuleBlackTight'
        when '+' then rule_command = 'mktsRuleEnglish'
        when '°' then rule_command = 'mktsRuleZero'
        else return send [ '.', 'warning', "unknown hrule markup #{rpr one}", ( copy meta ), ]
      below      += -1
      sub_events  = []
      sub_events.push [ 'tex', "\\mktsVspace{#{above}}", ] unless above is 0
      sub_events.push [ 'tex', "\\#{rule_command}{}", ]
      sub_events.push [ 'tex', "\\mktsVspace{#{below}}", ] unless below is 0
      sub_events.push [ 'tex', "\n\n", ]
      if slash
        # send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{above}}%TEX-WRITER/$hr2\n", ]
        # send [ '!', 'slash', null, ( copy meta ), ]
        mid = sub_events
        send [ '!', 'slash', { above, mid, below, }, ( copy meta ), ]
      else
        # send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{above}}\\mktsVspace{}" ] if above > 0
        # send [ 'tex', "\\mktsRulePlainTight{}", ]
        # send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{below}}\\mktsVspace{}" ] if below > 0
        # send [ 'tex', "\n\n" ]
        send sub_event for sub_event in sub_events
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$echo = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '!', 'echo'
      [ _, _, parameters, meta, ] = event
      send stamp event
      send [ '.', 'text', ( rpr parameters ), ( copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$nl = ( S ) =>
  ### TAINT consider to zero-width non-breaking space ###
  nl = [ 'tex', "~\\\\\n", ]
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '!', 'nl'
      [ type, name, [ count, ], meta, ] = event
      send nl for _ in [ 0 ... ( count ? 1 ) ] by +1
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$code_span = ( S ) =>
  track = MD_READER.TRACKER.new_tracker '(code-span)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code_span = track.within '(code-span)'
    track event
    #.......................................................................................................
    if select event, '(', 'code-span'
      send stamp event
      send [ 'tex', '{\\mktsStyleCode{}', ]
    #.......................................................................................................
    else if select event, ')', 'code-span'
      send [ 'tex', "}", ]
      send stamp event
    #.......................................................................................................
    else if within_code_span and select event, '.', 'text'
      # send event
      [ _, _, text, meta, ] = event
      #.....................................................................................................
      ### TAINT sort-of code duplication with command url ###
      fragments     = LINEBREAKER.fragmentize text
      last_idx      = fragments.length - 1
      #.....................................................................................................
      for fragment, idx in fragments
        send [ '.', 'text', fragment, ( copy meta ), ]
        send [ 'tex', "\\allowbreak{}", ] unless idx is last_idx
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$image = ( S ) =>
  track       = MD_READER.TRACKER.new_tracker '(image)'
  event_cache = []
  alt_cache   = []
  src         = null
  alt         = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_image = track.within '(image)'
    track event
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '(', 'image'
      send stamp event
      src = njs_path.resolve S.layout_info[ 'source-home' ], meta[ 'src' ]
      # src = njs_path.resolve S.layout_info[ 'source-home' ], meta[ 'src' ]
    #.......................................................................................................
    else if select event, ')', 'image'
      alt = alt_cache.join ''
      send [ 'tex', '\\begin{figure}%\n', ]
      ### TAINT escape `src`? ###
      send [ 'tex', "\\includegraphics[width=\\textwidth]{#{src}}%\n", ]
      # send [ 'tex', "\\includegraphics[width=0.5\\textwidth]{#{src}}%\n", ]
      send [ 'tex', "\\caption[#{alt}]{%\n", ]
      send cached_event for cached_event in event_cache
      send [ 'tex', '}%\n', ]
      send [ 'tex', '\\end{figure}%\n', ]
      src               = null
      alt_cache.length  = 0
      send stamp event
    #.......................................................................................................
    else if within_image
      event_cache.push event
      alt_cache.push text if select event, '.', 'text'
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$raw = ( S ) =>
  remark = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'raw'
      [ type, name, text, meta, ] = event
      send stamp hide copy event
      send remark 'convert', "raw to TeX", copy meta
      text = MACRO_ESCAPER.escape.unescape_escape_chrs S, text
      # debug '9382', [ 'tex', text, ]
      send [ 'tex', text, ]
      # send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$table = ( S ) =>
  track   = MD_READER.TRACKER.new_tracker '(table)', '(th)'
  remark  = MD_READER._get_remark()
  buffer  = null
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    within_table                = track.within '(table)'
    within_th                   = track.within '(th)'
    track event
    #.......................................................................................................
    if within_th and select event, '.', 'text'
      send [ '(', 'strong', null, ( copy meta ), ]
      send stamp event
      send [ ')', 'strong', null, ( copy meta ), ]
    #.......................................................................................................
    else if select event, ')', 'tr'
      buffer = null
      send stamp hide copy event
      send [ 'tex', "\\\\\n", ]
      send [ 'tex', "\\mktsZerohline\n", ]
    #.......................................................................................................
    else
      send buffer if buffer
      buffer = null
      #.....................................................................................................
      if select event, '(', 'table'
        # debug '©36643', event
        send stamp hide copy event
        col_styles  = []
        for alignment in meta[ 'table' ][ 'alignments' ]
          switch alignment
            when 'left'   then col_styles.push 'l'
            when 'center' then col_styles.push 'c'
            when 'right'  then col_styles.push 'r'
            else               col_styles.push 'l'
        col_styles  = '| ' + ( col_styles.join ' | ' ) + ' |'
        ### thx to http://tex.stackexchange.com/a/86893 for `\\setlength\\lineskiplimit{0mm}` ###
        # send [ 'tex', "\n\n{", ]
        ###
        {%
        \setlength\lineskiplimit{1mm}%
        \setlength\lineskip{5mm}%
        \begin{minipage}[b][7\mktsLineheight]{1\linewidth}%
        \color{red}%
        % \mktsVspace{3}%
        Anim et laborum nisi voluptate occaecat irure duis enim labore tempor magna. Sunt magna irure nisi elit aliquip tempor veniam nulla ea eiusmod sit. Nostrud nisi non dolor est sunt enim aute. Sint cillum quis et do veniam. Ipsum sint deserunt aute ipsum nostrud excepteur anim non occaecat anim proident nulla excepteur. Elit commodo velit aliqua consectetur.
        % \mktsVspace{3}%
        \end{minipage}
        }
        ###
        send [ 'tex', "{", ]
        send [ 'tex', "\\mktsVspace{7}\\tfRaise{5}%\n", ]
        send [ 'tex', "\\begin{tabular}[pos]{ #{col_styles} }\n", ]
      #.....................................................................................................
      else if select event, ')', 'table'
        send stamp hide copy event
        send [ 'tex', "\\end{tabular}\n", ]
        # send [ 'tex', "XXXXXXXXXXXXXXXXX\n", ]
        # send [ 'tex', "\\end{minipage}\n", ]
        # send [ 'tex', "\\mktsVspace{3}%\n", ]
        # send [ 'tex', "\\vskip 1.01\\mktsLineheight\n\n", ]
        send [ 'tex', "}", ]
        send [ 'tex', "\n\n", ]
      #.....................................................................................................
      else if select event, '(', 'tbody'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'tbody'
        send [ 'tex', "\\hline\n", ]
        send stamp hide copy event
      #.....................................................................................................
      else if select event, '(', 'td'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'td'
        send stamp hide copy event
        buffer = [ 'tex', " & ", ]
      #.....................................................................................................
      else if select event, '(', 'th'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'th'
        send stamp hide copy event
        buffer = [ 'tex', " & ", ]
      #.....................................................................................................
      else if select event, '(', 'thead'
        send [ 'tex', "\\hline\n", ]
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'thead'
        send stamp hide copy event
        send [ 'tex', "\n\\hline\n", ]
      #.....................................................................................................
      else if select event, '(', 'tr'
        send stamp hide copy event
      #.....................................................................................................
      else
        send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$footnote = ( S ) =>
  ### TAINT should move this to initialization ###
  throw new Error "`S.footnotes` already defined" if S.footnotes?
  S.footnotes =
    # 'style':      'classic'
    'style':      'on-demand'
    'by-idx':     []
  #.........................................................................................................
  return switch style = S.footnotes[ 'style' ]
    when 'classic'    then @MKTX.MIXED._$footnote_classic    S
    when 'on-demand'  then @MKTX.MIXED._$footnote_on_demand  S
    else throw new Error "unknown footnote style #{rpr style}"

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED._$footnote_classic = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'footnote'
      send stamp event
      send [ 'tex', "\\footnote{", ]
    #.......................................................................................................
    else if select event, ')', 'footnote'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED._$footnote_on_demand = ( S ) =>
  ### TAINT TeX codes used here should be made configurable ###
  cache             = S.footnotes[ 'by-idx' ]
  current_fn_idx    = -1
  current_fn_cache  = -1
  first_fn_idx      = 0
  last_fn_idx       = -1
  track             = MD_READER.TRACKER.new_tracker '(footnote)'
  remark            = MD_READER._get_remark()
  last_was_footnote = no
  #.........................................................................................................
  insert_footnotes = ( send, meta ) =>
    if last_fn_idx >= first_fn_idx
      # send [ '!', 'mark', '42', ( copy meta ), ]
      # send [ '.', 'p', null, ( copy meta ), ]
      send [ 'tex', "\n\n", ]
      send [ 'tex', "\\begin{mktsEnNotes}", ]
      for fn_idx in [ first_fn_idx .. last_fn_idx ]
        fn_nr           = fn_idx + 1
        fn_cache        = cache[ fn_idx ]
        cache[ fn_idx ] = null
        # send [ 'tex', "(#{fn_nr})\\,", ]
        send [ 'tex', "{\\mktsEnStyleMarkNotes\\mktsEnMarkBefore#{fn_nr}\\mktsEnMarkAfter{}}", ]
        send fn_event for fn_event in fn_cache
      send [ 'tex', "\\end{mktsEnNotes}\n\n", ]
      first_fn_idx  = last_fn_idx  + 1
      last_fn_idx   = first_fn_idx - 1
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    within_footnote             = track.within '(footnote)'
    track event
    #.......................................................................................................
    if select event, '(', 'footnote'
      send stamp event
      current_fn_cache        = []
      current_fn_idx         += +1
      last_fn_idx             = current_fn_idx
      fn_nr                   = current_fn_idx + 1
      cache[ current_fn_idx ] = current_fn_cache
      fn_separator            = if last_was_footnote then ',' else ''
      # send [ 'tex', "\\mktsEnStyleMark{#{fn_separator}#{fn_nr}}" ]
      send [ 'tex', "{\\mktsEnStyleMarkMain{}#{fn_separator}#{fn_nr}}" ]
    #.......................................................................................................
    else if select event, ')', 'footnote'
      send stamp event
      current_fn_cache  = null
      last_was_footnote = yes
    #.......................................................................................................
    else if within_footnote
      current_fn_cache.push event
      send remark 'caching', "event within footnote", event
    #.......................................................................................................
    else if select event, '!', 'footnotes'
      send stamp event
      insert_footnotes send, meta
    #.......................................................................................................
    else if select event, ')', 'document'
      insert_footnotes send, meta
      send event
    #.......................................................................................................
    else
      last_was_footnote = no
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$footnote.$remove_extra_paragraphs = ( S ) =>
  last_event  = null
  #.........................................................................................................
  return $ ( event, send, end ) =>
    if event?
      #.....................................................................................................
      if select event, ')', 'footnote'
        send last_event if last_event? and not select last_event, '.', 'p'
        last_event = event
      #.....................................................................................................
      else
        send last_event if last_event?
        last_event = event
    #.......................................................................................................
    if end?
      send last_event if last_event?
      end()

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$translate_i_and_b = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ '(', ')', ], [ 'i', 'b', ]
      [ type, name, text, meta, ] = event
      new_name = if name is 'i' then 'em' else 'strong'
      send [ type, new_name, text, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$super_and_subscript = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', [ 'sup', 'sub', ]
      [ type, name, text, meta, ] = event
      send stamp event
      tex_style_name = if name is 'sup' then  'mktsStyleFontSuperscript'
      else                                    'mktsStyleFontSubscript'
      send [ 'tex', "{\\#{tex_style_name}{}", ]
    #.......................................................................................................
    else if select event, ')', [ 'sup', 'sub', ]
      [ type, name, text, meta, ] = event
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$mark = ( S ) =>
  mark_idx = 0
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '!', 'mark'
      [ type, name, text, meta, ] = event
      send stamp event
      unless text?
        mark_idx += +1
        text      = "a-#{mark_idx}"
      # text = @MKTX.TYPOFIX.fix_typography_for_tex text, S.options
      send [ 'tex', "\\mktsMark{#{text}}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$em_strong_and_smallcaps = ( S ) =>
  em_count        = 0
  strong_count    = 0
  sc_upper_count  = 0
  sc_lower_count  = 0
  code_count      = 0
  #.........................................................................................................
  tex_events_by_keys =
    # ____: { start: [], stop: [], }
    ___l: { start: [ "{\\mktsStyleSmallcapslower{}", ],           stop: [        "}", ], }
    __u_: { start: [ "{\\mktsStyleSmallcapsupper{}", ],           stop: [        "}", ], }
    __ul: { start: [ "{\\mktsStyleSmallcapsall{}", ],             stop: [        "}", ], }
    _s__: { start: [ "{\\mktsStyleBold{}", ],                     stop: [        "}", ], }
    _s_l: { start: [ "{\\mktsStyleBold{}", ],                     stop: [        "}", ], }
    _su_: { start: [ "{\\mktsStyleBold{}", ],                     stop: [        "}", ], }
    _sul: { start: [ "{\\mktsStyleBold{}", ],                     stop: [        "}", ], }
    e___: { start: [ "{\\mktsStyleItalic{}", ],                   stop: [ "\\/", "}", ], }
    e__l: { start: [ "{\\mktsStyleItalicsmallcapslower{}", ],     stop: [ "\\/", "}", ], }
    e_u_: { start: [ "{\\mktsStyleItalicsmallcapsupper{}", ],     stop: [ "\\/", "}", ], }
    e_ul: { start: [ "{\\mktsStyleItalicsmallcapsall{}", ],       stop: [ "\\/", "}", ], }
    es__: { start: [ "{\\mktsStyleBolditalic{}", ],               stop: [ "\\/", "}", ], }
    es_l: { start: [ "{\\mktsStyleBolditalic{}", ],               stop: [ "\\/", "}", ], }
    esu_: { start: [ "{\\mktsStyleBolditalic{}", ],               stop: [ "\\/", "}", ], }
    esul: { start: [ "{\\mktsStyleBolditalic{}", ],               stop: [ "\\/", "}", ], }
# "{\\mktsStyleBold{}"
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    delta = if ( type is '(' ) then +1 else - 1
    #.......................................................................................................
    if select event, [ '(', ')', ], [ 'code', 'code-span', ]
      code_count += delta
      send event
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'smallcaps-upper'
      sc_upper_count += delta
      send stamp event
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'smallcaps-lower'
      sc_lower_count += delta
      send stamp event
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'em'
      em_count += delta
      send stamp event
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'strong'
      strong_count += delta
      send stamp event
    #.......................................................................................................
    else if code_count < 1 and select event, '.', 'text'
      ### skip markup when text is blank: ###
      return send event if /^\s*$/.test event[ 2 ]
      key = [
        if (       em_count > 0 ) then 'e' else '_'
        if (   strong_count > 0 ) then 's' else '_'
        if ( sc_upper_count > 0 ) then 'u' else '_'
        if ( sc_lower_count > 0 ) then 'l' else '_'
        ].join ''
      return send event if key is '____'
      { start, stop, } = tex_events_by_keys[ key ]
      send [ 'tex', sub_event, ] for sub_event in start
      send event
      send [ 'tex', sub_event, ] for sub_event in stop
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$link = ( S ) =>
  cache     = []
  last_href = null
  track     = MD_READER.TRACKER.new_tracker '(link)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_link = track.within '(link)'
    track event
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '(', 'link'
      send stamp event
      last_href = text
    #.......................................................................................................
    else if select event, ')', 'link'
      # debug '©97721', event
      # debug '©97721', cache
      send [ 'tex', '{\\mktsStyleLinklabel{}', ]
      for cached_event in cache
        send cached_event
      send [ 'tex', '}', ]
      # send [ '(', 'footnote', null,       ( copy meta ), ]
      # send [ '(', 'url',      null,       ( copy meta ), ]
      # send [ '.', 'text',     last_href,  ( copy meta ), ]
      # send [ '.', 'p',        null,       ( copy meta ), ]
      # send [ ')', 'url',      null,       ( copy meta ), ]
      # send [ ')', 'footnote', null,       ( copy meta ), ]
      send [ '(', 'footnote', null,           ( copy meta ), ]
      send [ '!', 'url',      [ last_href, ], ( copy meta ), ]
      send [ '.', 'p',        null,           ( copy meta ), ]
      send [ ')', 'footnote', null,           ( copy meta ), ]
      cache.length  = 0
      last_href     = null
      send stamp event
    #.......................................................................................................
    else if cache.length > 0 and select event, ')', 'document'
      send [ '.', 'warning', "missing closing region 'link'", ( copy meta ), ]
      send cached_event for cached_event in cache
      send event
    #.......................................................................................................
    else if within_link
      cache.push event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$url = ( S ) =>
  track   = MD_READER.TRACKER.new_tracker '(url)'
  buffer  = []
  #.........................................................................................................
  return $ ( event, send ) =>
    within_url = track.within '(url)'
    track event
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '(', 'url'
      send stamp hide copy event
    #.......................................................................................................
    else if select event, ')', 'url'
      send [ '!', 'url', [ buffer.join '' ], ( copy meta ), ]
      buffer.length = 0
      send stamp hide copy event
    #.......................................................................................................
    else if within_url and select event, '.', 'text'
      buffer.push text
    #.......................................................................................................
    else if within_url
      send [ '.', 'warning', "ignoring non-text event inside `(url)`: #{rpr event}"]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$url = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '!', 'url'
      [ type, name, parameters, meta, ] = event
      send stamp event
      [ url, ] = parameters
      unless url?
        return send [ '.', 'warning', "missing required argument for `<<!url>>`", ( copy meta ), ]
      #.....................................................................................................
      ### TAINT sort-of code duplication with inline code ###
      fragments     = LINEBREAKER.fragmentize url
      last_idx      = fragments.length - 1
      #.....................................................................................................
      send [ 'tex', "{\\mktsStyleUrl{}", ]
      #.....................................................................................................
      for fragment, idx in fragments
        [ segment, slashes, ] = fragment.split /(\/+)$/
        send [ '.', 'text', segment, ( copy meta ), ]
        if slashes?
          slashes = '\\g' + ( Array.from slashes ).join '\\g'
          send [ 'tex', slashes, ]
        send [ 'tex', "\\allowbreak{}", ]
      #.....................................................................................................
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.COMMAND.$url = ( S ) =>
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     #.......................................................................................................
#     if select event, '!', 'url'
#       [ type, name, parameters, meta, ] = event
#       send stamp event
#       [ url, ] = parameters
#       unless url?
#         return send [ '.', 'warning', "missing required argument for `<<!url>>`", ( copy meta ), ]
#       #.....................................................................................................
#       fragments = LINEBREAKER.fragmentize url
#       last_idx  = fragments.length - 1
#       for fragment, idx in fragments
#         unless idx is last_idx
#           if      fragment.endsWith '//' then fragment = fragment[ .. fragment.length - 3 ] + "\\g/\\g/"
#           else if fragment.endsWith '/'  then fragment = fragment[ .. fragment.length - 2 ] + "\\g/"
#         fragments[ idx ] = fragment
#       url_tex = fragments.join "\\g\\allowbreak{}"
#       send [ 'tex', "{\\mktsStyleUrl{}", ]
#       send [ 'tex', url_tex, ]
#       send [ 'tex', "}", ]
#     #.......................................................................................................
#     else
#       send event


#===========================================================================================================
# CLEANUP
#-----------------------------------------------------------------------------------------------------------
@MKTX.CLEANUP.$remove_empty_texts = ( S ) ->
  remark = MD_READER._get_remark()
  return $ ( event, send ) =>
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      if text is ''
        ### remain silent to make output an easier read ###
        null
        send remark 'drop', "empty text", copy meta
      else
        send event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.CLEANUP.$consolidate_texts = ( S ) ->
  # remark      = MD_READER._get_remark()
  collector   = []
  first_meta  = null
  return $ ( event, send ) =>
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      first_meta                 ?= meta
      collector.push text
    else
      # debug '83726', collector
      if collector.length > 0
        send [ '.', 'text', ( collector.join '' ), ( copy first_meta ), ]
        first_meta        = null
        collector.length  = 0
      send event

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.CLEANUP.$drop_empty_p_tags = ( S ) =>
#   ### TAINT emptyness of  `p` tags ist tested for by counting intermittend `text` events; however, a
#   paragraph could conceivably also consist of e.g. a single image. ###
#   text_count  = 0
#   remark      = MD_READER._get_remark()
#   #.........................................................................................................
#   warn "not using `$drop_empty_p_tags` at the moment"
#   return $ ( event, send ) =>
#     send event
  # #.........................................................................................................
  # return $ ( event, send ) =>
  #   #.......................................................................................................
  #   ### TAINT bogus selector ###
  #   if select event, [ ')', ]
  #     text_count = 0
  #     send event
  #   #.......................................................................................................
  #   else if select event, '.', 'text'
  #     text_count += +1
  #     send event
  #   #.......................................................................................................
  #   else if select event, '.', 'p'
  #     if text_count > 0
  #       send event
  #     else
  #       [ _, _, _, meta, ] = event
  #       send remark 'drop', "empty `.p`", copy meta
  #     text_count = 0
  #   #.......................................................................................................
  #   else
  #     send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$correct_p_tags_before_regions = ( S ) =>
  last_was_p              = no
  last_was_begin_document = no
  remark                  = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    # debug '©MwBAv', event
    #.......................................................................................................
    if select event, 'tex'
      send event
    #.......................................................................................................
    else if select event, '(', 'document'
      # debug '©---1', last_was_begin_document
      # debug '©---2', last_was_p
      last_was_p              = no
      last_was_begin_document = yes
      send event
    #.......................................................................................................
    else if select event, '.', 'p'
      # debug '©---3', last_was_begin_document
      # debug '©---4', last_was_p
      last_was_p              = yes
      last_was_begin_document = no
      send event
    #.......................................................................................................
    else if select event, [ '(', ]
      # debug '©---5', last_was_begin_document
      # debug '©---6', last_was_p
      if ( not last_was_begin_document ) and ( not last_was_p )
        [ ..., meta, ] = event
        # send stamp [ '#', 'insert', my_badge, "inserting `.p` tag", ( copy meta ), ]
        send remark 'insert', "`.p` because region or block opens", copy meta
        send [ '.', 'p', null, ( copy meta ), ]
      send event
      last_was_p              = no
      last_was_begin_document = no
    #.......................................................................................................
    else
      last_was_p              = no
      last_was_begin_document = no
      send event


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@MKTX.$show_unhandled_tags = ( S ) =>
  return $ ( event, send ) =>
    ### TAINT selection could be simpler, less repetitive ###
    [ type, name, text, meta, ] = event
    if ( type is 'tex' ) or select event, '.', [ 'text', 'raw', ]
      send event
    else if ( not is_stamped event ) and ( type isnt '~' ) and ( not select event, '.', 'warning' )
      # debug '©04210', JSON.stringify event
      # if text?
      #   if ( CND.isa_pod text )
      #     if ( Object.keys text ).length is 0
      #       text = ''
      #     else
      #       text = rpr text
      # else
      #   text = ''
      # if type in [ '.', '!', ] or type in MKTS.MD_READER.FENCES.left
      #   first             = type
      #   last              = name
      # else
      #   first             = name
      #   last              = type
      # event_txt         = first + last + ' ' + text
      event_txt = "unhandled event: #{JSON.stringify event, null, ' '}"
      warn event_txt
      send [ '.', 'warning', event_txt, ( copy meta ), ]
      # send stamp hide copy event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.$show_warnings = ( S ) =>
  return $async ( event, done ) =>
    ### TAINT this makes clear why we should not use '.' as type here; `warning` is a meta-event, not
    primarily a formatting instruction ###
    #.......................................................................................................
    if select event, '.', 'warning'
      [ type, name, text, meta, ] = event
      step ( resume ) =>
        message = yield @MKTX.TYPOFIX.fix_typography_for_tex S, text, resume
        done [ 'tex', "\\begin{mktsEnvWarning}#{message}\\end{mktsEnvWarning}" ]
    #.......................................................................................................
    else
      done event
    #.......................................................................................................
    return null

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$filter_tex = ( S ) ->
  ### TAINT reduce number of event types, shapes to simplify this ###
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    if type is 'tex'
      send event[ 1 ]
    else if select event, '.', [ 'text', 'raw', ]
      send event[ 2 ]
    else if meta?[ 'tex' ] is 'pass-through'
      # debug '82341', event
      send event
    else unless ( type is '~' ) or ( is_stamped event )
      warn "unhandled event: #{JSON.stringify event}"
      send.error new Error "unhandled events not allowed at this point; got #{JSON.stringify event}"


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@create_tex_write_tee = ( S ) ->
  ### TAINT get state via return value of MKTS.create_mdreadstream ###
  ### TAINT make execution of `$produce_mktscript` a matter of settings ###
  #.......................................................................................................
  readstream    = D.create_throughstream()
  writestream   = D.create_throughstream()
  mktscript_in  = D.create_throughstream()
  mktscript_out = D.create_throughstream()
  #.......................................................................................................
  ### TAINT need a file to write MKTScript text events to; must still send on incoming events ###
  # mktscript_in
  #   .pipe MKTSCRIPT_WRITER.$produce_mktscript             S
  #   .pipe mktscript_out
  # mktscript_tee = D.TEE.from_readwritestreams mktscript_in, mktscript_out
  #.......................................................................................................
  pipeline    = ( ( plugin.$main S ) for plugin in MK.TS.plugins )
  # plugins_tee = D.TEE.from_pipeline pipeline
  plugins_tee = D.combine pipeline
  #.......................................................................................................
  readstream
    .pipe plugins_tee
    .pipe MACRO_ESCAPER.$expand.$remove_backslashes         S
    .pipe @$document                                        S
    #.......................................................................................................
    # .pipe D.$show()
    .pipe @MKTX.BLOCK.$blockquote                           S
    .pipe @MKTX.INLINE.$link                                S
    .pipe @MKTX.MIXED.$footnote                             S
    .pipe @MKTX.MIXED.$footnote.$remove_extra_paragraphs    S
    .pipe @MKTX.COMMAND.$new_page                           S
    .pipe @MKTX.COMMAND.$comment                            S
    .pipe @MKTX.MIXED.$table                                S
    .pipe @MKTX.COMMAND.$echo                               S
    # .pipe @MKTX.BLOCK.$hr                                   S
    .pipe @MKTX.BLOCK.$hr2                                  S
    .pipe @MKTX.BLOCK.$nl                                   S
    .pipe @MKTX.REGION.$code                                S
    .pipe @MKTX.REGION.$keep_lines                          S
    .pipe @MKTX.REGION.$toc                                 S
    .pipe @MKTX.BLOCK.$heading                              S
    .pipe @MKTX.MIXED.$collect_headings_for_toc             S
    .pipe @MKTX.COMMAND.$toc                                S
    .pipe @MKTX.BLOCK.$unordered_list                       S
    .pipe @MKTX.INLINE.$code_span                           S
    .pipe @MKTX.INLINE.$url                                 S
    .pipe @MKTX.COMMAND.$url                                S
    .pipe @MKTX.INLINE.$super_and_subscript                 S
    .pipe @MKTX.INLINE.$translate_i_and_b                   S
    # .pipe @MKTX.INLINE.$smallcaps                           S
    # .pipe @MKTX.INLINE.$em_and_strong                       S
    .pipe @MKTX.INLINE.$em_strong_and_smallcaps             S
    .pipe @MKTX.INLINE.$image                               S
    .pipe @MKTX.BLOCK.$yadda                                S
    .pipe @MKTX.BLOCK.$paragraph_1                          S
    .pipe @MKTX.MIXED.$raw                                  S
    .pipe @COLUMNS.$main                                    S
    #.......................................................................................................
    .pipe MACRO_INTERPRETER.$capture_change_events          S
    .pipe @MKTX.CLEANUP.$remove_empty_texts                 S
    .pipe @MKTX.CLEANUP.$consolidate_texts                  S
    .pipe @MKTX.BLOCK.$paragraph_2                          S
    .pipe @MKTX.TYPOFIX.$fix_typography_for_tex             S
    #.......................................................................................................
    .pipe MKTSCRIPT_WRITER.$show_mktsmd_events              S
    .pipe do =>
      S.event_count = 0
      return D.$observe ( event ) =>
        S.event_count += +1
    .pipe @MKTX.INLINE.$mark                                S
    .pipe @MKTX.$show_unhandled_tags                        S
    .pipe @MKTX.$show_warnings                              S
    .pipe @$filter_tex                                      S
    # ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
    .pipe @COLUMNS.$XXX_transform_pretex_to_tex             S
    # ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
    .pipe MD_READER.$show_illegal_chrs                      S
    .pipe writestream
  #.......................................................................................................
  settings =
    # inputs:
    #   mktscript:        mktscript_in
    # outputs:
    #   mktscript:        mktscript_out
    S:                S
  #.......................................................................................................
  R                           = D.TEE.from_readwritestreams readstream, writestream, settings
  S[ 'tees' ]                ?= {}
  S[ 'tees' ][ 'tex-writer' ] = R
  return R

#-----------------------------------------------------------------------------------------------------------
@_handle_error = ( error ) =>
  alert error[ 'message' ]
  stack = error[ 'stack' ] ? "(no stacktrace available)"
  whisper '\n' + ( stack.split '\n' )[ .. 10 ].join '\n'
  whisper '...'
  process.exit 1


#===========================================================================================================
# PDF FROM MD
#-----------------------------------------------------------------------------------------------------------
@pdf_from_md = ( source_route, handler ) ->
  ### TAINT code duplication ###
  ### TAIN only works with docs in the filesystem, not with literal texts ###
  #---------------------------------------------------------------------------------------------------------
  f = => step ( resume ) =>
    # handler                ?= ->
    layout_info             = HELPERS.new_layout_info @options, source_route
    yield @write_mkts_master layout_info, resume
    source_locator          = layout_info[ 'source-locator'  ]
    content_locator         = layout_info[ 'content-locator' ]
    file_output             = njs_fs.createWriteStream content_locator
    #.......................................................................................................
    mkscript_locator        = layout_info[ 'mkscript-locator' ]
    mkscript_output         = njs_fs.createWriteStream mkscript_locator
    #.......................................................................................................
    file_output.on 'close', =>
      HELPERS.write_pdf layout_info, ( error ) =>
        throw error if error?
        S.t1              = +new Date()
        dt_s              = ( S.t1 - S.t0 ) / 1000
        dt_s_txt          = dt_s.toFixed 3
        chrs_per_s_txt    = (   S.chr_count / dt_s ).toFixed 3
        events_per_s_txt  = ( S.event_count / dt_s ).toFixed 3
        chr_count_txt     = ƒ S.chr_count
        event_count_txt   = ƒ S.event_count
        help "#{TEXT.flush_right    chr_count_txt, 10}       chrs (approx.)"
        help "#{TEXT.flush_right  event_count_txt, 10}     events (approx.)"
        help "#{TEXT.flush_right         dt_s_txt, 14}          s"
        help "#{TEXT.flush_right   chrs_per_s_txt, 14}   chrs / s"
        help "#{TEXT.flush_right events_per_s_txt, 14} events / s"
        handler null if handler?
    #.......................................................................................................
    S =
      options:              @options
      layout_info:          layout_info
    #.......................................................................................................
    ### TAINT should read MD source stream ###
    md_source               = njs_fs.readFileSync source_locator, encoding: 'utf-8'
    md_readstream           = MD_READER.create_md_read_tee S, md_source
    tex_writestream         = @create_tex_write_tee S
    md_input                =  md_readstream.tee[ 'input'  ]
    md_output               =  md_readstream.tee[ 'output' ]
    tex_input               = tex_writestream.tee[ 'input'  ]
    tex_output              = tex_writestream.tee[ 'output' ]
    #.......................................................................................................
    S.resend                = md_readstream.tee[ 'S' ].resend
    #.......................................................................................................
    md_output
      .pipe tex_input
    tex_output
      # .pipe $ ( event, send, end ) =>
      #   if event?
      #     send event
      #   if end?
      #     end() # setTimeout end, 1000
      .pipe file_output
    #.......................................................................................................
    md_input.resume()
  #---------------------------------------------------------------------------------------------------------
  D.run f, @_handle_error


#===========================================================================================================
# TEX FROM MD
#-----------------------------------------------------------------------------------------------------------
@tex_from_md = ( md_source, settings, handler ) ->
  ### TAINT code duplication ###
  switch arity = arguments.length
    when 2
      handler   = settings
      settings  = {}
    when 3 then null
    else throw new Error "expected 2 or 3 arguments, got #{arity}"
  #.........................................................................................................
  $collect_and_call = ( handler ) =>
    Z = []
    return $ ( event, send, end ) =>
      Z.push event if event?
      if end?
        handler null, Z.join ''
        end()
  #.........................................................................................................
  source_route        = settings[ 'source-route' ] ? '<STRING>'
  layout_info         = HELPERS.new_layout_info @options, source_route, false
  #.........................................................................................................
  S =
    options:              @options
    layout_info:          layout_info
    bare:                 settings[ 'bare' ] ? no
  #.........................................................................................................
  md_readstream       = MD_READER.create_md_read_tee md_source
  tex_writestream     = @create_tex_write_tee S
  md_input            =   md_readstream.tee[ 'input'  ]
  md_output           =   md_readstream.tee[ 'output' ]
  tex_input           = tex_writestream.tee[ 'input'  ]
  tex_output          = tex_writestream.tee[ 'output' ]
  #.........................................................................................................
  S.resend            = md_readstream.tee[ 'S' ].resend
  #.........................................................................................................
  md_output
    .pipe tex_input
  tex_output
    .pipe D.$show '>>>>>>>>>>>>>>>>>>'
    .pipe $collect_and_call handler
  #.........................................................................................................
  D.run ( => md_input.resume() ), @_handle_error
  return null



############################################################################################################
unless module.parent?
  # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
  @pdf_from_md 'texts/demo'

  # debug '©nL12s', MKTS.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
  # debug '©nL12s', MKTS.as_tex_text 'helo さし'
  # event = [ '(', 'single-column', ]
  # event = [ ')', 'single-column', ]
  # event = [ '(', 'new-page', ]
  # debug '©Gpn1J', select event, [ '(', ')'], [ 'single-column', 'new-page', ]

