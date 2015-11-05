



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/MKTS-interim'
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
HELPERS                   = require './HELPERS'
# options                   = require './options'
TEXLIVEPACKAGEINFO        = require './TEXLIVEPACKAGEINFO'
options_route             = '../options.coffee'
{ CACHE, OPTIONS, }       = require './OPTIONS'
SEMVER                    = require 'semver'
#...........................................................................................................
MKTS                      = require './MKTS'
hide                      = MKTS.hide.bind        MKTS
copy                      = MKTS.copy.bind        MKTS
stamp                     = MKTS.stamp.bind       MKTS
select                    = MKTS.select.bind      MKTS
is_hidden                 = MKTS.is_hidden.bind   MKTS
is_stamped                = MKTS.is_stamped.bind  MKTS

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
  DOCUMENT:   {}
  COMMAND:    {}
  REGION:     {}
  BLOCK:      {}
  INLINE:     {}
  MIXED:      {}
  CLEANUP:    {}

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$do = ( S ) =>
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
    #.......................................................................................................
    if select event, '!', 'do'
      [ type, action, cs_source, meta, ] = event
      # warn "re-defining command #{rpr identifier}" if S.definitions[ identifier ]?
      # S.definitions[ identifier ] = []
      js_source = CS.compile cs_source, { bare: true, filename: local_filename, }
      urge '4742', js_source
      VM.runInContext js_source, sandbox, { filename: local_filename, }
      # debug '©YMF7F', sandbox
      # debug '©YMF7F', S.local.definitions
      send stamp hide event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$expansion = ( S ) =>
  remark = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '!'
      [ type, identifier, _, meta, ] = event
      if ( definition = S.local.definitions.get identifier )?
        # send stamp hide event
        send stamp hide [ '(', '!', identifier, ( copy meta ), ]
        # send copy sub_event for sub_event in definition
        # debug '@16', rpr definition
        send remark 'resend', "expanding `#{identifier}`", ( copy meta )
        S.resend definition # [ '.', 'text', definition, ( copy meta ), ]
        send stamp hide [ ')', '!', identifier, ( copy meta ), ]
      else
        send event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, '!', 'new-page'
    send stamp event
    send [ 'tex', "\\null\\newpage{}", ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$comment = ( S ) =>
  remark = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, '.', 'comment'
    [ type, name, text, meta, ] = event
    send remark 'drop', "`.comment`: #{rpr text}", copy meta

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$begin= ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '<', 'document'
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
    if select event, '>', 'document'
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
      send [ '{', 'multi-column', text, ( copy meta ), ]
      send stamp hide [ ')', '!', name, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$multi_column = ( S ) =>
  track   = MKTS.TRACKER.new_tracker '{multi-column}'
  remark  = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    if select event, [ '{', '}', ], 'multi-column'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        if within_multi_column
          send remark 'drop', "`{multi-column` because already within `{multi-column}`". copy meta
        else
          send track @MKTX.REGION._begin_multi_column()
      #.....................................................................................................
      else
        if within_multi_column
          send track @MKTX.REGION._end_multi_column()
        else
          send remark 'drop', "`multi-column}` because not within `{multi-column}`". copy meta
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$single_column = ( S ) =>
  ### TAINT consider to implement command `change_column_count = ( send, n )` ###
  track   = MKTS.TRACKER.new_tracker '{multi-column}'
  remark  = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if select event, [ '{', '}', ], 'single-column'
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
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
  track = MKTS.TRACKER.new_tracker '{keep-lines}'
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
    else if select event, [ '{', '}', ], 'keep-lines'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
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
  track = MKTS.TRACKER.new_tracker '{code}'
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
    else if select event, [ '{', '}', ], 'code'
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        send [ 'tex', "\\begingroup\\mktsObeyAllLines\\mktsStyleCode{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  restart_multicols = no
  track             = MKTS.TRACKER.new_tracker '{multi-column}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if select event, [ '[', ']', ], [ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', ]
      # debug '@rg19TQ', event
      send stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      # OPEN
      #.....................................................................................................
      if type is '['
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
  track = MKTS.TRACKER.new_tracker '{code}', '{keep-lines}'
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
    if select event, '[', 'ul'
      [ type, name, text, meta, ] = event
      { markup } = meta
      ### TAINT won't work in nested lists ###
      ### TAINT make configurable ###
      item_markup_tex = tex_by_md_markup[ markup ] ? tex_by_md_markup[ 'fallback' ]
      send stamp event
      send [ 'tex', '\\begin{itemize}' ]
    #.......................................................................................................
    else if select event, '[', 'li'
      send stamp event
      send [ 'tex', "\\item[#{item_markup_tex}] " ]
    #.......................................................................................................
    else if select event, ']', 'li'
      send stamp event
      send [ 'tex', '\n' ]
    #.......................................................................................................
    else if select event, ']', 'ul'
      send stamp event
      send [ 'tex', '\\end{itemize}' ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$hr = ( S ) =>
  remark = MKTS._get_remark()
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
@MKTX.INLINE.$code = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ '(', ')', ], 'code'
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
  track   = MKTS.TRACKER.new_tracker '{raw}', '[raw]', '(raw)', '{definitions}'
  # remark  = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_raw = track.within '{raw}', '[raw]', '(raw)', '{definitions}'
    track event
    #.......................................................................................................
    if select event, '.', 'raw'
      send stamp event
    else if within_raw and select event, '.', 'text'
      throw new Error "should never happen"
      [ type, name, text, meta, ] = event
      raw_text = meta[ 'raw' ]
      ### TAINT could the added `{}` conflict with some (La)TeX commands? ###
      # send remark 'convert', "escaped to raw text", copy meta
      send stamp [ '.', 'raw', raw_text, meta, ]
    #.......................................................................................................
    # else if select event, [ '{', '}', '[', ']', '(', ')', ], 'raw'
    else if select event, [ '}', ']', ], 'raw'
      send stamp event
      send @MKTX.BLOCK._end_paragraph()
    else if select event, [ '{', '[', '(', ')', ], 'raw'
      null
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
  remark = MKTS._get_remark()
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
  remark      = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ ']', '}', ]
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
  remark                  = MKTS._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    # debug '©MwBAv', event
    #.......................................................................................................
    if select event, 'tex'
      send event
    #.......................................................................................................
    else if select event, '<', 'document'
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
    else if select event, [ '{', '[', ]
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
@$filter_tex = ->
  return $ ( event, send ) =>
    if select event, 'tex'                        then send event[ 1 ]
    else if select event, '.', [ 'text', 'raw', ] then send event[ 2 ]
    else warn "unhandled event: #{JSON.stringify event}" unless is_stamped event

#===========================================================================================================
# PDF FROM MD
#-----------------------------------------------------------------------------------------------------------
@pdf_from_md = ( source_route, handler ) ->
  D.run =>
    step ( resume ) =>
      handler                ?= ->
      layout_info             = HELPERS.new_layout_info @options, source_route
      yield @write_mkts_master layout_info, resume
      source_locator          = layout_info[ 'source-locator'  ]
      content_locator         = layout_info[ 'content-locator' ]
      tex_output              = njs_fs.createWriteStream content_locator
      # debug '©y9meI', layout_info
      # process.exit()
      ### TAINT should read MD source stream ###
      text                    = njs_fs.readFileSync source_locator, encoding: 'utf-8'
      input                   = MKTS.create_mdreadstream text
      #---------------------------------------------------------------------------------------------------------
      ### TAINT get state via return value of MKTS.create_mdreadstream ###
      S =
        options:              @options
        layout_info:          layout_info
        input:                input
        # resend:               ( event ) => input.write event
        resend:               input.XXX_resend
      #---------------------------------------------------------------------------------------------------------
      tex_output.on 'close', =>
        HELPERS.write_pdf layout_info, ( error ) =>
          throw error if error?
          handler null if handler?
      #---------------------------------------------------------------------------------------------------------
      input
        .pipe MKTS.$fix_typography_for_tex                    @options
        .pipe @MKTX.DOCUMENT.$begin                           S
        .pipe @MKTX.DOCUMENT.$end                             S
        .pipe @MKTX.MIXED.$raw                                S
        .pipe @MKTX.MIXED.$footnote                           S
        .pipe @MKTX.MIXED.$remove_footnote_extra_paragraphs   S
        .pipe @MKTX.COMMAND.$do                               S
        .pipe @MKTX.COMMAND.$expansion                        S
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
        .pipe @MKTX.INLINE.$code                              S
        # .pipe @MKTX.INLINE.$italic_correction                 S
        .pipe @MKTX.INLINE.$translate_i_and_b                 S
        .pipe @MKTX.INLINE.$em_and_strong                     S
        # .pipe @MKTX.BLOCK.$remove_empty_p_tags                S
        .pipe @MKTX.BLOCK.$paragraph                          S
        # .pipe D.$observe ( event ) =>
        #   if MKTS.select event, 'text'
        #     # info JSON.stringify event
        #     debug event
        #   else
        #     # whisper JSON.stringify event
        .pipe @MKTX.CLEANUP.$remove_empty_texts               S
        .pipe MKTS.$close_dangling_open_tags                  S
        .pipe MKTS.$show_mktsmd_events                        S
        .pipe MKTS.$write_mktscript                           S
        .pipe MKTS.$show_unhandled_tags                       S
        .pipe @$filter_tex()
        .pipe MKTS.$show_illegal_chrs                         S
        .pipe tex_output
      #---------------------------------------------------------------------------------------------------------
      input.resume()
  , ( error ) =>
    alert error[ 'message' ]
    stack = error[ 'stack' ] ? "(no stacktrace available)"
    whisper '\n' + ( stack.split '\n' )[ .. 10 ].join '\n'
    whisper '...'
    process.exit 1


############################################################################################################
unless module.parent?
  # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
  @pdf_from_md 'texts/demo'

  # debug '©nL12s', MKTS.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
  # debug '©nL12s', MKTS.as_tex_text 'helo さし'
  # event = [ '{', 'single-column', ]
  # event = [ '}', 'single-column', ]
  # event = [ '{', 'new-page', ]
  # debug '©Gpn1J', select event, [ '{', '}'], [ 'single-column', 'new-page', ]

