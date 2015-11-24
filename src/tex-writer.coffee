



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/tex-adapter'
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
{ CACHE, OPTIONS, }       = require './options'
SEMVER                    = require 'semver'
#...........................................................................................................
XNCHR                     = require './xnchr'
MKTS                      = require './main'
MKTSCRIPT_WRITER          = require './mktscript-writer'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER


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
    for { texname, home, filename, } in @options[ 'fonts' ][ 'files' ]
      home ?= fonts_home
      if use_new_syntax
        ### TAINT should properly escape values ###
        write "\\newfontface{\\#{texname}}{#{filename}}[Path=#{home}/]"
        # write "\\newcommand{\\#{texname}}{"
        # write "\\typeout{\\trmWhite{redefining #{texname}}}"
        # write "\\newfontface{\\#{texname}XXX}{#{filename}}[Path=#{home}/]"
        # write "\\renewcommand{\\#{texname}}{\\#{texname}XXX}"
        # write "}"
      else
        write "\\newfontface\\#{texname}[Path=#{home}/]{#{filename}}"
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
    write "\\begin{document}#{main_font_name}"
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
  TEX:        {}
  DOCUMENT:   {}
  COMMAND:    {}
  REGION:     {}
  BLOCK:      {}
  INLINE:     {}
  MIXED:      {}
  CLEANUP:    {}

#-----------------------------------------------------------------------------------------------------------
@MKTX.TEX._tex_escape_replacements = [
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
@MKTX.TEX.escape_for_tex = ( text ) =>
  R = text
  for [ pattern, replacement, ], idx in @MKTX.TEX._tex_escape_replacements
    R = R.replace pattern, replacement
  return R

#-----------------------------------------------------------------------------------------------------------
@MKTX.TEX.$fix_typography_for_tex = ( S ) =>
  return $ ( event, send ) =>
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      text          = @MKTX.TEX.fix_typography_for_tex text, S.options
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.TEX.is_cjk_rsg = ( rsg, options ) => rsg in options[ 'tex' ][ 'cjk-rsgs' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.TEX._get_cjk_interchr_glue = ( options ) => options[ 'tex' ]?[ 'cjk-interchr-glue' ] ? '\ue080'

#-----------------------------------------------------------------------------------------------------------
@MKTX.TEX.fix_typography_for_tex = ( text, options, send = null ) =>
  ### An improved version of `XELATEX.tag_from_chr` ###
  ### TAINT should accept settings, fall back to `require`d `options.coffee` ###
  glyph_styles          = options[ 'tex' ]?[ 'glyph-styles'             ] ? {}
  ### Legacy mode: force one command per non-latin character. This is OK for Chinese texts,
  but a bad idea for all other scripts; in the future, MKTS's TeX formatting commands like
  `\cn{}` will be rewritten to make this setting superfluous. ###
  advance_each_chr      = options[ 'tex' ]?[ 'advance-each-chr'         ] ? no
  tex_command_by_rsgs   = options[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
  cjk_interchr_glue     = @MKTX.TEX._get_cjk_interchr_glue options
  last_command          = null
  R                     = []
  chunk                 = []
  last_rsg              = null
  remark                = if send? then @_get_remark() else null
  this_is_cjk           = no
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
      R.push "}" unless last_command in [ null, 'latin', ]
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
        when 'u-latn'   then chr = @MKTX.TEX.escape_for_tex chr
      #.......................................................................................................
      this_is_cjk = @MKTX.TEX.is_cjk_rsg rsg, options
      if last_was_cjk and this_is_cjk
        ### Avoid to put second glue between glue and CJK character: ###
        chunk.push cjk_interchr_glue unless chr is cjk_interchr_glue
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


#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, '!', 'new-page'
    send stamp event
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
@MKTX.DOCUMENT.$begin = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'document'
      send stamp event
      send [ 'tex', "\n% begin of MD document\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$end = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, ')', 'document'
      send stamp event
      send [ 'tex', "\n% end of MD document\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION._begin_multi_column = =>
  ### TAINT Column count must come from layout / options / MKTS-MD command ###
  return [ 'tex', '\\begin{multicols}{2}' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION._end_multi_column = =>
  return [ 'tex', '\\end{multicols}' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$multi_column = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '!', 'multi-column'
      [ type, name, text, meta, ] = event
      send stamp hide [ '(', '!', name, ( copy meta ), ]
      send [ '(', 'multi-column', text, ( copy meta ), ]
      send stamp hide [ ')', '!', name, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$multi_column = ( S ) =>
  track   = MD_READER.TRACKER.new_tracker '{multi-column}'
  remark  = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    if select event, [ '(', ')', ], 'multi-column'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '('
        if within_multi_column
          send remark 'drop', "`(multi-column` because already within `(multi-column)`", ( copy meta )
        else
          send track @MKTX.REGION._begin_multi_column()
      #.....................................................................................................
      else
        if within_multi_column
          send track @MKTX.REGION._end_multi_column()
        else
          send remark 'drop', "`multi-column)` because not within `(multi-column)`", ( copy meta )
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$single_column = ( S ) =>
  ### TAINT consider to implement command `change_column_count = ( send, n )` ###
  track   = MD_READER.TRACKER.new_tracker '{multi-column}'
  remark  = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if select event, [ '(', ')', ], 'single-column'
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '('
        if within_multi_column
          send remark 'insert', "`multi-column}`", copy meta
          send track @MKTX.REGION._end_multi_column()
          send stamp event
        else
          # send stamp event
          send remark 'drop', "`single-column` because not within `{multi-column}`", copy meta
      #.....................................................................................................
      else
        if within_multi_column
          send stamp event
          send remark 'insert', "`{multi-column`", copy meta
          send track @MKTX.REGION._begin_multi_column()
        else
          send remark 'drop', "`single-column` because not within `{multi-column}`", copy meta
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$keep_lines = ( S ) =>
  track = MD_READER.TRACKER.new_tracker '{keep-lines}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_keep_lines = track.within '{keep-lines}'
    track event
    #.......................................................................................................
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      ### TAINT other replacements possible; use API ###
      ### TAINT U+00A0 (nbsp) might be too wide ###
      text = text.replace /\u0020/g, '\u00a0' if within_keep_lines
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'keep-lines'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '('
        track.enter '{keep-lines}'
        send [ 'tex', "\\begingroup\\mktsObeyAllLines{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
        track.leave '{keep-lines}'
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$code = ( S ) =>
  ### TAINT code duplication with `REGION.$keep_lines` possible ###
  track = MD_READER.TRACKER.new_tracker '{code}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code = track.within '{code}'
    track event
    #.......................................................................................................
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      if within_code
        text = text.replace /\u0020/g, '\u00a0'
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'code'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '('
        send [ 'tex', "\\begingroup\\mktsObeyAllLines\\mktsStyleCode{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  restart_multicols = no
  track             = MD_READER.TRACKER.new_tracker '{multi-column}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if select event, [ '(', ')', ], [ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', ]
      # debug '@rg19TQ', event
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      # OPEN
      #.....................................................................................................
      if type is '('
        #...................................................................................................
        if within_multi_column and ( name in [ 'h1', 'h2', ] )
          send track @MKTX.REGION._end_multi_column meta
          restart_multicols = yes
        #...................................................................................................
        send [ 'tex', "\n", ]
        #...................................................................................................
        switch name
          when 'h1' then  send [ 'tex', "\\chapter{", ]
          when 'h2' then  send [ 'tex', "\\section{", ]
          else            send [ 'tex', "\\subsection{", ]
      #.....................................................................................................
      # CLOSE
      #.....................................................................................................
      else
        ### Placing the closing brace on a new line seems to improve line breaking ###
        send [ 'tex', "\n", ]
        send [ 'tex', "}", ]
        send [ 'tex', "\n", ]
        if restart_multicols
          send track @MKTX.REGION._begin_multi_column meta
          restart_multicols = no
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph = ( S ) =>
  ### TAINT should unify the two observers ###
  track = MD_READER.TRACKER.new_tracker '{code}', '{keep-lines}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code       = track.within '{code}'
    within_keep_lines = track.within '{keep-lines}'
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
@MKTX.BLOCK._end_paragraph = =>
  ### TAINT use command from sty ###
  ### TAINT make configurable ###
  return [ 'tex', '\\mktsShowpar\\par\n' ]

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
      send [ 'tex', '\\begin{itemize}' ]
    #.......................................................................................................
    else if select event, '(', 'li'
      send stamp event
      send [ 'tex', "\\item[#{item_markup_tex}] " ]
    #.......................................................................................................
    else if select event, ')', 'li'
      send stamp event
      send [ 'tex', '\n' ]
    #.......................................................................................................
    else if select event, ')', 'ul'
      send stamp event
      send [ 'tex', '\\end{itemize}' ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$hr = ( S ) =>
  remark = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'hr'
      send stamp event
      [ type, name, text, meta, ] = event
      switch chr = text[ 0 ]
        when '-' then send [ 'tex', '\n--------------\n' ]
        when '*' then send [ 'tex', '\n**************\n' ]
        else send remark 'drop', "`[hr] because markup unknown #{rpr text}", copy meta
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$code_span = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ '(', ')', ], 'code-span'
      send stamp event
      [ type, name, text, meta, ] = event
      if type is '('
        send [ 'tex', '{\\mktsStyleCode{}', ]
      else
        send [ 'tex', "}", ]
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
      send stamp hide event
      send remark 'convert', "raw to TeX", copy meta
      send [ 'tex', text, ]
      # send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$footnote = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'footnote'
      send stamp event
      [ type, name, id, meta, ] = event
      send [ 'tex', "\\footnote{", ]
    #.......................................................................................................
    else if select event, ')', 'footnote'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$remove_footnote_extra_paragraphs = ( S ) =>
  last_event  = null
  #.........................................................................................................
  return $ ( event, send, end ) =>
    if event?
      #.......................................................................................................
      if select event, ')', 'footnote'
        send last_event if last_event? and not select last_event, '.', 'p'
        last_event = event
      #.......................................................................................................
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
@MKTX.INLINE.$em_and_strong = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ '(', ')', ], [ 'em', 'strong', ]
      send stamp event
      [ type, name, text, meta, ] = event
      if type is '('
        if name is 'em'
          send [ 'tex', '{\\mktsStyleItalic{}', ]
          ### TAINT must not be sent when in vertical mode ###
          # send [ 'tex', '\\/', ]
        else
          send [ 'tex', '{\\mktsStyleBold{}', ]
      else
        send [ 'tex', '\\/', ] if name is 'em'
        send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event


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
        # send remark 'drop', "empty text", copy meta
      else
        send event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.CLEANUP.$remove_empty_p_tags = ( S ) =>
  text_count  = 0
  remark      = MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ ')', ]
      text_count = 0
      send event
    #.......................................................................................................
    else if select event, '.', 'text'
      text_count += +1
      send event
    #.......................................................................................................
    else if select event, '.', 'p'
      if text_count > 0
        send event
      else
        [ _, _, _, meta, ] = event
        send remark 'drop', "`.p` because it's empty", copy meta
      text_count = 0
    #.......................................................................................................
    else
      send event

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
    if ( event[ 0 ] in [ 'tex', 'text', ] ) or select event, '.', 'text'
      send event
    else unless is_stamped event
      [ type, name, text, meta, ] = event
      if text?
        if ( CND.isa_pod text )
          if ( Object.keys text ).length is 0
            text = ''
          else
            text = rpr text
      else
        text = ''
      if type in [ '.', '!', ] or type in MKTS.FENCES.left
        first             = type
        last              = name
      else
        first             = name
        last              = type
      event_txt         = first + last + ' ' + text
      send [ '.', 'warning', event_txt, ( copy meta ), ]
      send hide stamp event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.$show_warnings = ( S ) =>
  pre               = '█'
  post              = '█'
  return $ ( event, send ) =>
    ### TAINT this makes clear why we should not use '.' as type here; `warning` is a meta-event, not
    primarily a formatting instruction ###
    if select event, '.', 'warning'
      [ type, name, text, meta, ] = event
      message                     = @MKTX.TEX.fix_typography_for_tex text, S.options
      ### TAINT use location data ###
      send [ 'tex', "\\begin{mktsEnvWarning}#{message}\\end{mktsEnvWarning}" ]
    else
      send event


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$filter_tex = ( S ) ->
  return $ ( event, send ) =>
    if select event, 'tex'                        then send event[ 1 ]
    else if select event, '.', [ 'text', 'raw', ] then send event[ 2 ]
    else warn "unhandled event: #{JSON.stringify event}" unless is_stamped event


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@create_tex_write_tee = ( S ) ->
  ### TAINT get state via return value of MKTS.create_mdreadstream ###
  ### TAINT make execution of `$produce_mktscript` a matter of settings ###
  #.......................................................................................................
  readstream    = D.create_throughstream()
  writestream   = D.create_throughstream()
  # mktscript_in  = D.create_throughstream()
  # mktscript_out = D.create_throughstream()
  #.......................................................................................................
  # mktscript_in
  #   .pipe MKTS.$produce_mktscript                         S
  #   .pipe mktscript_out
  #.......................................................................................................
  readstream
    .pipe @MKTX.TEX.$fix_typography_for_tex               S
    .pipe @MKTX.DOCUMENT.$begin                           S
    .pipe @MKTX.DOCUMENT.$end                             S
    .pipe @MKTX.MIXED.$raw                                S
    .pipe @MKTX.MIXED.$footnote                           S
    .pipe @MKTX.MIXED.$remove_footnote_extra_paragraphs   S
    # .pipe @MKTX.COMMAND.$do                               S
    # .pipe @MKTX.COMMAND.$expansion                        S
    .pipe @MKTX.COMMAND.$new_page                         S
    .pipe @MKTX.COMMAND.$comment                          S
    # .pipe @MKTX.REGION.$correct_p_tags_before_regions     S
    .pipe @MKTX.COMMAND.$multi_column                     S
    .pipe @MKTX.REGION.$multi_column                      S
    .pipe @MKTX.REGION.$single_column                     S
    .pipe @MKTX.REGION.$keep_lines                        S
    .pipe @MKTX.REGION.$code                              S
    .pipe @MKTX.BLOCK.$heading                            S
    .pipe @MKTX.BLOCK.$hr                                 S
    .pipe @MKTX.BLOCK.$unordered_list                     S
    .pipe @MKTX.INLINE.$code_span                         S
    .pipe @MKTX.INLINE.$translate_i_and_b                 S
    .pipe @MKTX.INLINE.$em_and_strong                     S
    .pipe @MKTX.BLOCK.$paragraph                          S
    .pipe @MKTX.CLEANUP.$remove_empty_texts               S
    .pipe MKTSCRIPT_WRITER.$show_mktsmd_events            S
    # .pipe mktscript_in
    .pipe @MKTX.$show_warnings                            S
    .pipe @MKTX.$show_unhandled_tags                      S
    .pipe @$filter_tex                                    S
    .pipe MD_READER.$show_illegal_chrs                    S
    .pipe writestream
  #.......................................................................................................
  settings =
    # inputs:
    #   mktscript:        mktscript_in
    # outputs:
    #   mktscript:        mktscript_out
    S:                S
  #.......................................................................................................
  return D.TEE.from_readwritestreams readstream, writestream, settings

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
    handler                ?= ->
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
        handler null if handler?
    #.......................................................................................................
    S =
      options:              @options
      layout_info:          layout_info
    #.......................................................................................................
    ### TAINT should read MD source stream ###
    md_source               = njs_fs.readFileSync source_locator, encoding: 'utf-8'
    md_readstream           = MD_READER.create_md_read_tee md_source
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
  #.........................................................................................................
  md_readstream       = MD_READER.create_md_read_tee md_source
  tex_writestream     = @create_tex_write_tee S
  md_input            =  md_readstream.tee[ 'input'  ]
  md_output           =  md_readstream.tee[ 'output' ]
  tex_input           = tex_writestream.tee[ 'input'  ]
  tex_output          = tex_writestream.tee[ 'output' ]
  #.........................................................................................................
  S.resend            = md_readstream.tee[ 'S' ].resend
  #.........................................................................................................
  md_output
    .pipe tex_input
  tex_output
    # .pipe D.$join()
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
