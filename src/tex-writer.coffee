


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
PIPEDREAMS                = require '../../../pipedreams'
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
@MKTS_TABLE               = require './tex-writer-mkts-table'
AUX                       = require './tex-writer-aux'
YADDA                     = require './yadda'
OVAL                      = require './object-validator'
UNITS                     = require './mkts-table-units'
#...........................................................................................................
Σ_formatted_warning       = Symbol 'formatted-warning'
jr                        = JSON.stringify
promisify                 = ( require 'util' ).promisify


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
  @options.layout ?= {}
  if @options.layout.lineheight?
    @options.layout.lineheight = UNITS.new_quantity @options.layout.lineheight
  #.........................................................................................................
  CACHE.update @options
#...........................................................................................................
@compile_options()

#-----------------------------------------------------------------------------------------------------------
@write_mkts_master = ( S, handler ) ->
  lines             = []
  write             = lines.push.bind lines
  help "writing #{S.layout_info[ 'master-locator'  ]}"
  #-------------------------------------------------------------------------------------------------------
  write ""
  write "% #{S.layout_info[ 'master-locator'  ]}"
  write "% do not edit this file"
  write "% generated from #{S.options.locator}"
  write "% on #{new Date()}"
  write ""
  write "\\documentclass[a4paper,twoside]{book}"
  write ""
  #-------------------------------------------------------------------------------------------------------
  # DEFS
  #.......................................................................................................
  if S.options.defs?
    write ""
    write "% DEFS"
    for name, value of S.options.defs
      write "\\def\\#{name}{#{value}}"
  #-------------------------------------------------------------------------------------------------------
  # NEWCOMMANDS
  #.......................................................................................................
  if S.options.newcommands?
    write ""
    write "% NEWCOMMANDS"
    for name, value of S.options.newcommands
      warn "implicitly converting newcommand value for #{name}"
      value = njs_path.resolve __dirname, '..', value
      write "\\newcommand{\\#{name}}{%\n#{value}%\n}"
  #-------------------------------------------------------------------------------------------------------
  # IN-DOCUMENT CONFIGURATION
  #.......................................................................................................
  write ""
  write "% IN-DOCUMENT CONFIGURATION"
  ### TAINT use default configuration *.ptv file ###
  ### TAINT make more general; ATM can only decide on boolean ###
  S.configuration[ 'document/geometry/show/textgrid'    ]?= false
  S.configuration[ 'document/geometry/show/papergrid'   ]?= false
  S.configuration[ 'document/geometry/show/linebands'   ]?= false
  S.configuration[ 'document/geometry/show/columns'     ]?= false
  S.configuration[ 'document/geometry/show/baselines'   ]?= false
  S.configuration[ 'document/geometry/show/ascenders'   ]?= false
  S.configuration[ 'document/geometry/show/descenders'  ]?= false
  S.configuration[ 'document/geometry/show/medians'     ]?= false
  S.configuration[ 'document/geometry/show/debug'       ]?= false
  S.configuration[ 'document/geometry/show/debugorigin' ]?= false
  S.configuration[ 'document/geometry/show/gutter'      ]?= false
  for key, value of S.configuration
    unless ( key.match /^document\/geometry\/show\// )?
      warn "ignoring configuration key #{rpr key}"
      continue
    continue unless value
    gkey  = key.replace /^.*?([^\/]+)$/g, '$1'
    tex   = "\\PassOptionsToPackage{#{gkey}}{mkts-page-geometry}%"
    info '55569', "in-document configuration -> #{tex}"
    write tex
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
  write ""
  write "% FONTS"
  write "\\usepackage{fontspec}"
  #.......................................................................................................
  for { texname, otf, home, subfolder, filename, } in S.options.fonts.files
    font_settings = []
    #.......................................................................................................
    if home is ''
      ### use standard settings ###
      null
    #.......................................................................................................
    else
      home              ?= S.options.fonts.home
      home              = njs_path.join home, subfolder if subfolder?
      home              = "#{home}/" unless home.endsWith '/'
      font_settings.push [ "Path=#{home}", ]
    #.......................................................................................................
    font_settings.push otf if otf?
    font_settings_txt = font_settings.join ','
    # debug '66733', ( jr { texname, otf, home, subfolder, filename, } ), rpr font_settings_txt
    ### TAINT should properly escape values ###
    # write "\\newfontface{\\#{texname}}{#{filename}}[#{font_settings_txt}]"
    ### TAINT this is an experiment to confine font loading to what is needed in the document
    at hand. Strangely enough, calling the below commands will redefine them, although they do get
    executed; still, redefining a *font* doesn't seem to bother XeLaTeX much and indeed, only
    the needed fonts are loaded. Also, we could capture the output of the font commands and
    compile a list of all used fonts. ###
    ### TAINT Mystery: redefinition doesn't work, processing time skyrockets ###
    write "\\newfontface{\\#{texname}}{#{filename}}[#{font_settings_txt}]%"
    # write "\\newcommand{\\#{texname}}{%"
    # write "\\renewcommand{\\#{texname}}{\\#{texname}XXX}%"
    # write "\\renewcommand{\\#{texname}}{\\typeout{\\trmGreen{using #{texname}}}}%"
    # write "\\typeout{\\trmWhite{defining #{texname}}}%"
    # # write "\\newfontface{\\#{texname}XXX}{#{filename}}[#{font_settings_txt}]%"
    # # write "\\#{texname}XXX%"
    # write "}"
  write ""
  #-------------------------------------------------------------------------------------------------------
  # STYLES
  #......................................................................................................
  write ""
  write "% STYLES"
  if ( styles = S.options[ 'styles' ] )?
    write "\\newcommand{\\#{name}}{%\n#{value}%\n}" for name, value of styles
  #-------------------------------------------------------------------------------------------------------
  if ( mktsLineheight = S.options.layout?.lineheight ? null )?
    mktsLineheight_txt = UNITS.as_text mktsLineheight
    write ""
    write "% LENGTHS"
    write "\\setlength{\\mktsLineheight}{#{mktsLineheight_txt}}%"
    write "\\setlength{\\mktsCurrentLineheight}{\\mktsLineheight}%"
  #-------------------------------------------------------------------------------------------------------
  write ""
  write "% CONTENT"
  #-------------------------------------------------------------------------------------------------------
  # INCLUDES
  #.......................................................................................................
  write ""
  write "\\input{#{S.layout_info[ 'content-locator' ]}}"
  write ""
  #-------------------------------------------------------------------------------------------------------
  write "\\end{document}"
  #-------------------------------------------------------------------------------------------------------
  text = lines.join '\n'
  njs_fs.writeFile S.layout_info[ 'master-locator'  ], text, handler


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@MKTX =
  TYPOFIX:      require './tex-writer-typofix'
  SH:           require './tex-writer-sh'
  CALL:         require './tex-writer-call'
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
    return send event unless select event, [ '!', '.', ], 'new-page'
    send stamp event
    [ type, name, text, meta, ] = event
    ### TAINT make insertion of `\null` (which causes invisible content to be placed onto the page to ensure
    a page break will indeed happen) conditional, so we can insert page breaks that are suppressed when
    the current page is still fresh ###
    send [ 'tex', "\\null\\newpage{}", ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$blank_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless select event, [ '!', '.', ], 'blank-page'
    send stamp event
    [ type, name, text, meta, ] = event
    send [ 'tex', "\\mktsBlankPage{}", ]

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
  is_first_document_tag   = true
  bare                    = S.bare ? false
  within_document         = false
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, [ '.', '(', ], 'document'
      throw new Error "encountered repeated `<document/>` tag (#{jr event})" unless is_first_document_tag
      within_document             = true
      is_first_document_tag       = false
      [ type, name, text, meta, ] = event
      send stamp event
      unless bare
        send [ 'tex', "\n% begin of MD document\n", ]
        send [ 'tex', "\\begin{document}\\mktsStyleNormal{}", ]
        ### TAINT this should not be here, be part of style, be configurable ###
        send [ 'tex', "\\spaceskip 0.75ex plus 0.75ex minus 0.5ex \\relax%\n", ]
    #.......................................................................................................
    else if select event, ')', 'document'
      within_document             = false
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null


# #-----------------------------------------------------------------------------------------------------------
# @$document = ( S ) =>
#   buffer                  = []
#   start_document_event    = null
#   before_document_command = yes
#   send_                   = null
#   before_flush            = yes
#   bare                    = S.bare ? no
#   #.........................................................................................................
#   flush_as = ( what ) =>
#     send_ [ 'tex', "\n% begin of MD document\n", ] unless bare
#     if what is 'preamble' and buffer.length > 0
#       send_ [ 'tex', "% (extra preamble inserted from MD document)\n", ]
#       send_ event for event in buffer
#     send_ stamp start_document_event
#     send_ [ 'tex', "\\begin{document}\\mktsStyleNormal{}", ] unless bare
#     if what is 'document'
#       send_ event for event in buffer
#     buffer.length           = 0
#     before_document_command = no
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     send_ = send
#     #.......................................................................................................
#     if before_flush
#       send event
#       before_flush = no if select event, '~', 'flush'
#     #.......................................................................................................
#     else if select event, ')', 'document'
#       flush_as 'document' if before_document_command
#       send [ 'tex', "\n% end of MD document\n", ] unless bare
#       send stamp event
#     #.......................................................................................................
#     else if select event, '!', 'document'
#       send stamp event
#       flush_as 'preamble'
#     #.......................................................................................................
#     else if before_document_command
#       if select event, '(', 'document'
#         start_document_event = event
#       else
#         buffer.push event
#     #.......................................................................................................
#     else
#       send event

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
      unless squish = parameters?[ 0 ]?[ 'squish' ] ? yes
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
  h_nrs             = [ 1, 1, 1, 1, ]
  h_idx             = -1
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'h'
      [ type, name, level, meta, ] = event
      h_idx                += +1
      h_key                 = "h-#{h_idx}"
      meta.h               ?= {}
      meta.h.idx            = h_idx
      meta.h.key            = h_key
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
        when 4
          send [ 'tex', "{\\mktsHFour{}", ]
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
        when 4
          send [ 'tex', "\\mktsHFourBeg}%\n\n",        ]
        else return send [ '.', 'warning', "heading level #{level} not implemented", ( copy meta ), ]
      #.....................................................................................................
      send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$crossrefs = ( S ) =>
  crossrefs       = {}
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '!', [ 'crossref-anchor', ]
      # debug '33393', event
      ### count   = crossrefs[ text ] = ( crossrefs[ text ] ? 0 ) + 1 ###
      ### key     = "#{text}-#{count}" ###
      key     = text
      send [ 'tex', "\\label{#{key}}", ]
      send stamp event
    #.......................................................................................................
    else if select event, '!', [ 'crossref-link', ]
      # debug '33394', event
      ### count   = crossrefs[ text ] = ( crossrefs[ text ] ? 0 ) + 1 ###
      ### key     = "#{text}-#{count}" ###
      key     = text
      send [ 'tex', "\\mktsPagerefArrow{#{key}}", ]
      send stamp event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

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
    #.......................................................................................................
    return null

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
      [ type, name, text, meta, ] = event
      send stamp event
      #.....................................................................................................
      unless headings?
        return send [ '.', 'warning', "expecting toc-headings event before this", ( copy meta ), ]
      #.....................................................................................................
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
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$yadda = ( S ) =>
  ### TAINT in the case of Chinese (`<yadda lang=zh nr=1/>`), using the `nr` attribute will not reproduce
  the same text across runs. ###
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'yadda'
      send stamp event
      [ type, name, Q, meta, ] = event
      #.....................................................................................................
      if Q.paragraphs?
        p_count = parseInt Q.paragraphs, 10
        for nr in [ 1 .. p_count ] by +1
          send [ '.', 'text', ( YADDA.generate Q ) + '\n\n', ( copy meta ), ]
      #.....................................................................................................
      else
        send [ '.', 'text', ( YADDA.generate Q ), ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$fncr = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'fncr'
      [ type, name, parameters, meta, ] = event
      { csg, srsg, cid, }               = parameters
      send stamp event
      send [ 'tex', "\\mktsFncr{#{csg}}{#{srsg}}{#{cid}}" ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$box = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', 'box'
      [ type, name, Q, meta, ] = event
      send stamp event
      command = if Q.border? then 'framebox' else 'makebox'
      if Q.width? then  send [ 'tex', "\\#{command}[#{Q.width}]{", ]
      else              send [ 'tex', "\\#{command}{", ]
    #.......................................................................................................
    else if select event, ')', 'box'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$tiny = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', 'tiny'
      [ type, name, Q, meta, ] = event
      send stamp event
      send [ 'tex', "{\\mktsTiny{}", ]
    #.......................................................................................................
    else if select event, ')', 'tiny'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$scale = ( S ) =>
  schema =
    postprocess: ( Q ) ->
      if Q.lines?
        Q.lines = true if Q.lines is ''
      else
        Q.lines = false
      return Q
    #.......................................................................................................
    properties:
      abs:    { type: 'number', }
      rel:    { type: 'number', }
      lines:  { type: [ 'boolean', 'string', ], }
    #.......................................................................................................
    additionalProperties: false
    oneOf: [ { required: [ 'abs', ], }, { required: [ 'rel', ], }, ]
  #.........................................................................................................
  validate_and_cast = OVAL.new_validator schema
  block_stack       = []
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, [ '(', '.', ], 'scale'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      send stamp event
      #.....................................................................................................
      if Q.abs?
        factor      = Q.abs
        command     = 'mktsScaleText'
      else
        factor      = Q.rel
        command     = 'mktsScaleTextRelative'
      #.....................................................................................................
      block_stack.push Q.lines
      brace     = if type is '(' then '{' else ''
      send [ 'tex', "#{brace}\\#{command}{#{factor}}", ]
    #.......................................................................................................
    else if select event, ')', 'scale'
      send stamp event
      is_block  = block_stack.pop() ? false
      par       = if is_block then '\\par' else ''
      send [ 'tex', "#{par}}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$stretch = ( S ) =>
  schema =
    properties:
      abs:    { type: 'number', }
      rel:    { type: 'number', }
    #.......................................................................................................
    additionalProperties: false
    oneOf: [ { required: [ 'abs', ], }, { required: [ 'rel', ], }, ]
  #.........................................................................................................
  validate_and_cast = OVAL.new_validator schema
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, [ '(', '.', ], 'stretch'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      send stamp event
      #.....................................................................................................
      if Q.abs?
        factor  = Q.abs
        command = 'mktsStretchLinesAbsolute'
      else
        factor  = Q.rel
        command = 'mktsStretchLinesRelative'
      #.....................................................................................................
      factor_txt  = ( factor.toFixed 6 ).replace /\.?0+$/, ''
      brace       = if type is '(' then '{' else ''
      send [ 'tex', "#{brace}\\#{command}{#{factor}}", ]
    #.......................................................................................................
    else if select event, ')', 'stretch'
      send stamp event
      send [ 'tex', "\\par}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$vspace = ( S ) =>
  schema =
    properties:
      abs:    { type: 'number', }
      rel:    { type: 'number', }
    #.......................................................................................................
    additionalProperties: false
    oneOf: [ { required: [ 'abs', ], }, { required: [ 'rel', ], }, ]
  #.........................................................................................................
  validate_and_cast = OVAL.new_validator schema
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'vspace'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      send stamp event
      #.....................................................................................................
      if Q.abs?
        factor  = Q.abs
        command = 'mktsVspaceAbsolute'
      else
        factor  = Q.rel
        command = 'mktsVspaceRelative'
      #.....................................................................................................
      send [ 'tex', "\\par\\#{command}{#{factor}}", ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$landscape = ( S ) =>
  open_tag_count    = 0
  schema            = { additionalProperties: false, }
  validate_and_cast = OVAL.new_validator schema
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, [ '(', '.', ], 'landscape'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      send stamp event
      open_tag_count += +1
      send [ 'tex', "\\begin{landscape}", ]
    #.......................................................................................................
    else if select event, ')', 'landscape'
      send [ 'tex', "\\end{landscape}", ]
    #.......................................................................................................
    else if select event, ')', 'document'
      while open_tag_count > 0
        open_tag_count += -1
        send [ 'tex', "\\end{landscape}", ]
      send event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.BLOCK.$pre = ( S ) =>
#   MACRO_ESCAPER.register_raw_tag 'pre'
#   schema            =
#     properties:           {}
#     additionalProperties: false
#   validate_and_cast = OVAL.new_validator schema
#   within_pre        = false
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     if select event, [ '(', '.', ], 'pre'
#       send stamp event
#       if within_pre
#         return send [ '.', 'warning', "can't nest <pre> within <pre>: #{rpr event}", ( copy meta ), ]
#       [ type, name, Q, meta, ]  = event
#       { text, attributes, }     = Q
#       attributes                = validate_and_cast attributes
#       within_pre                = true
#     #.......................................................................................................
#     else if select event, ')', 'pre'
#       within_pre = false
#     #.......................................................................................................
#     else
#       if within_pre
#         debug '44932', 'pre', event
#       else
#         send event
#     #.......................................................................................................
#     return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$nudge = ( S ) =>
  schema =
    properties:
      push:    { type: 'number', }
      raise:   { type: 'number', }
    #.......................................................................................................
    additionalProperties: false
    # oneOf: [ { required: [ 'push', ], }, { required: [ 'raise', ], }, ]
  validate_and_cast = OVAL.new_validator schema
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', 'nudge'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      push  = Q.push ? 0
      throw new Error "expected a number for push, got #{rpr event}" unless CND.isa_number push
      raise = Q.raise ? 0
      throw new Error "expected a number for raise, got #{rpr event}" unless CND.isa_number raise
      send stamp event
      send [ 'tex', "{\\mktsPushRaise{#{push}}{#{raise}}", ]
    #.......................................................................................................
    else if select event, ')', 'nudge'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$turn = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', 'turn'
      [ type, name, Q, meta, ] = event
      angle = Q.angle ? '90'
      angle = parseFloat angle
      throw new Error "expected a number for angle, got #{rpr event}" unless CND.isa_number angle
      send stamp event
      send [ 'tex', "\\mktsTurn{#{angle}}{", ]
    #.......................................................................................................
    else if select event, ')', 'turn'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$xfsc = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'xfsc'
      [ type, name, Q, meta, ] = event
      send stamp event
      send [ 'tex', "\\mktsXfsc{#{Q.sc}}{#{Q.symbol}}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$text_alignment = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, [ '(', '.', ], [ 'left', 'right', 'center', 'justify', ]
      [ type, name, Q, meta, ]  = event
      p                         = name[ 0 ].toUpperCase() + name[ 1 .. ]
      if type is '.' then  send [ 'tex',  "\\mkts#{p}{}", ]
      else                 send [ 'tex', "{\\mkts#{p}{}", ]
      send stamp event
    #.......................................................................................................
    else if select event, ')', [ 'left', 'right', 'center', 'justify', ]
      [ type, name, Q, meta, ]  = event
      send [ 'tex', "\\par}\n", ]
      send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$hfill = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', [ 'hfil', 'hfill', ]
      [ type, name, Q, meta, ] = event
      send stamp event
      send [ 'tex', "\\#{name}{}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$here_x = ( S ) =>
  prv_nr = 0
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'here-x'
      send stamp event
      [ type, name, Q, meta, ]  = event
      prefix                    = name[ ... name.length - 2 ]
      prv_nr                   += +1
      Q.key                    ?= "h#{prv_nr}"
      send [ 'tex', "\\#{prefix}x{#{Q.key}}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.$insert = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'insert'
      send stamp event
      [ type, name, Q, meta, ]  = event
      path    = HELPERS.resolve_document_relative_path S, Q.src
      content = njs_fs.readFileSync path, { encoding: 'utf-8', }
      switch Q.mode ? 'literal'
        when 'literal'
          send [ '.', 'text', content, ( copy meta ), ]
        when 'mktscript'
          send [ '.', 'mktscript', '<document/>' + content, ( copy meta ), ]
        when 'raw'
          send [ 'tex', content, ]
        else
          send [ '.', 'warning', "unknown mode #{rpr Q.mode} in #{rpr event}", ( copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$custom_entities = ( S ) =>
  ### Define custom XML entities in `options.coffee` under key `entities` ###
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'entity'
      [ _, _, key, meta, ]  = event
      entry                 = S.options.entities[ key ]
      #.....................................................................................................
      return send event unless entry?
      unless entry.type? and entry.value?
        send [ '.', 'warning', "entry for entity #{rpr key} needs both 'type' and 'value', got #{rpr entry}", ( copy meta ), ]
        return null
      #.....................................................................................................
      switch entry.type
        when 'text'
          send [ '.', 'text', entry.value, ( copy meta ), ]
          send stamp event
        when 'tex'
          send [ 'tex', entry.value, ]
          send stamp event
        else
          send event
    #.......................................................................................................
    else if select event, '.', 'spurious-ampersand'
      [ _, _, key, meta, ]  = event
      send [ '.', 'warning', "spurious ampersand #{rpr key}", ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$fontlist = ( S ) =>
  within_fontlist = false
  buffer          = []
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', 'fontlist'
      send stamp event
      within_fontlist = true
    #.......................................................................................................
    else if select event, ')', 'fontlist'
      send stamp event
      within_fontlist             = false
      sample                      = buffer.join ''
      buffer.length               = 0
      #.....................................................................................................
      send [ 'tex', "\\begin{tabbing}\n" ]
      send [ 'tex', "\\phantom{XXXXXXXXXXXXXXXXXXXXXXXXX} \\= \\phantom{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX} \\\\\n" ]
      #.....................................................................................................
      for { texname, } in S.options[ 'fonts' ][ 'files' ]
        shortname = texname.replace /^mktsFontfile/, ''
        tex       = "#{shortname} \\> {\\#{texname}{}#{sample}} \\\\\n"
        send [ 'tex', tex, ]
      #.....................................................................................................
      send [ 'tex', "\\end{tabbing}\n" ]
    #.......................................................................................................
    else if within_fontlist and select event, '.', 'text'
      [ type, name, text, meta, ] = event
      # send stamp event
      buffer.push text
    #.......................................................................................................
    else
      if within_fontlist
        [ type, name, text, meta, ] = event
        send [ '.', 'warning', "ignoring event #{type}", ( copy meta ? {} ), ]
      else
        send event
    #.......................................................................................................
    return null


#===========================================================================================================
#
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
        # send [ 'tex', "\n%% PARAGRAPH ##{S.paragraph_nr})\n" ]
        send [ 'tex', '\n\n' ]
      else
        # send [ 'tex', "\n%% PARAGRAPH ##{S.paragraph_nr})\n" ]
        send stamp event
        send @MKTX.BLOCK._end_paragraph()
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph_2 = ( S ) =>
  within_paragraph    = false
  seen_text_event     = false
  collector           = []
  close_paragraph     = false
  within_noindent     = false
  is_first_par        = true
  has_noindent_tag    = false
  # is_fresh            = true
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', [ 'h', 'multi-columns', 'blockquote', ],  true then is_first_par        = true
    if select event, ')', [ 'blockquote', 'ul', 'code',         ],  true then is_first_par        = true
    if select event, '.', [ 'hr', 'hr2',                        ],  true then is_first_par        = true
    if select event, '(', [ 'ul', 'keep-lines',                 ],  true then within_noindent     = true
    if select event, ')', [ 'ul', 'keep-lines',                 ],  true then within_noindent     = false
    # if select event, '(', [ 'h',                                ],  true then is_fresh            = false
    #.......................................................................................................
    if select event, '.', 'noindent'
      send stamp event
      has_noindent_tag  = yes
    #.......................................................................................................
    else if select event, '~', 'start-paragraph', true
      within_paragraph  = yes
      seen_text_event   = no
      S.paragraph_nr   += +1
      # send [ 'tex', "\n%% (PARAGRAPH ##{S.paragraph_nr}\n" ]
    #.......................................................................................................
    else if select event, '.', 'p'
      has_noindent_tag  = no
      within_paragraph  = no
      seen_text_event   = no
      # send [ 'tex', "\n}\n" ]
      send cached_event for cached_event in collector
      collector.length = 0
      if close_paragraph
        close_paragraph = no
        # send [ 'tex', "\n}% )p\n" ]
    #.......................................................................................................
    else if within_paragraph
      if seen_text_event
        ### If we're within a paragraph, but some material has aleady gone down the line, then there's
        nothing to do here: ###
        send event
      else
        ### Otherwise, we either have to cache the current event, or else—if the current event is a text
        event—we have to send all cached events, then the prefix to a new paragraph, and then the text event
        itself. ###
        unless select event, '.', 'text'
          collector.push event
        else
          ### TAINT can omit either of these two ###
          seen_text_event = yes
          close_paragraph = yes
          #.................................................................................................
          ### Send all the events encountered so far; typically, these will include commands to set up
          columns etc.: ###
          send cached_event for cached_event in collector
          collector.length = 0
          #.................................................................................................
          ### Check whether we're typesetting the first text portion after a headline, the start of a
          blockquote or similar and send additional material as needed: ###
          has_indent        = not is_first_par
          is_first_par    = false
          #.................................................................................................
          if within_noindent or has_noindent_tag or ( not has_indent ) # or is_fresh
            # is_fresh = false
            null
          else
            send [ 'tex', "\\mktsIndent{}" ]
            # send [ 'tex', "¶ " ]
          #.................................................................................................
          ### Finally, send the first text portion of the paragraph itself: ###
          send event
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
      # send [ 'tex', "{\\mktsFontfileHanamina{}\\prPushRaise{-0.4}{-0.1}{⚫}\\hspace{-0.75mm}}" ]
      # send [ 'tex', "{\\mktsFontfileCwtexqheibold{}\\prPushRaise{-0.4}{-0.1}{▷}\\hspace{-1.75mm}}" ]
      # send [ 'tex', "{\\mktsFontfileHanamina{}◼}\\hspace{3mm}L" ]
      # send [ 'tex', "{\\mktsFontfileCwtexqheibold{}\\prPushRaise{-0.4}{-0.1}{▷}}" ]
      send [ 'tex', S.options.entities[ 'ulsymbol' ][ 'value' ] ]
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
  0 compress (above & below; default)
  1 normal (spacing, one line above & below)
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
    # #.......................................................................................................
    # ### re-interpret `<hr>`: ###
    # if select event, '(', 'hr'
    #   is_synthetic_event                        = true
    #   [ type, name, parameters, meta, ]         = event
    #   event[ 0 ]                                = '.'
    #   event[ 1 ]                                = 'hr2'
    #   event[ 2 ]                                = { slash: false, above: 0, one: '-', two: null, three: null, below: 0 }
    # #.......................................................................................................
    # if select event, ')', 'hr'
    #   return send stamp event
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
  within_smallcaps  = false
  within_em         = false
  within_code_span  = false
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '(', [ 'smallcaps-lower', ], true
      send event
      within_smallcaps = true
    #.......................................................................................................
    else if select event, ')', [ 'smallcaps-lower', ], true
      send event
      within_smallcaps = false
    #.......................................................................................................
    if select event, '(', [ 'em', ], true
      send event
      within_em = true
    #.......................................................................................................
    else if select event, ')', [ 'em', ], true
      send event
      within_em = false
    #.......................................................................................................
    else if select event, '(', [ 'code-span', 'tt', ]
      send stamp event
      if within_em
        send [ 'tex', '{\\mktsStyleCodeItalic{}', ]
      else if within_smallcaps
        send [ 'tex', '{\\mktsStyleCode{}\\mktsUnderline{', ]
      else
        send [ 'tex', '{\\mktsStyleCode{}', ]
      within_code_span = true
    #.......................................................................................................
    else if select event, ')', [ 'code-span', 'tt', ]
      send stamp event
      if within_smallcaps then  send [ 'tex', "}}", ]
      else                      send [ 'tex', "}", ]
      within_code_span = false
    #.......................................................................................................
    else if select event, '(', [ 'code-box', 'tt', ]
      send stamp event
      ### NOTE can dispend with `\makebox` as underline inhibits linebreaks as well ###
      if within_smallcaps then  send [ 'tex', '{\\mktsStyleCode{}\\mktsUnderline{', ]
      else                      send [ 'tex', '\\makebox{{\\mktsStyleCode{}', ]
      within_code_span = true
    #.......................................................................................................
    else if select event, ')', [ 'code-box', 'tt', ]
      send stamp event
      send [ 'tex', "}}", ]
      within_code_span = false
    #.......................................................................................................
    else if within_code_span and select event, '.', 'text'
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
      src = HELPERS.resolve_document_relative_path S, meta[ 'src' ]
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
      [ type, name, Q, meta, ] = event
      send stamp hide copy event
      send remark 'convert', "raw to TeX", copy meta
      { text, attributes, } = Q
      text                  = MACRO_ESCAPER.escape.unescape_escape_chrs S, text
      # debug '9382', [ 'tex', text, ]
      send [ 'tex', text, ]
      # send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.MIXED.$table = ( S ) =>
  track                     = MD_READER.TRACKER.new_tracker '(table)', '(th)'
  remark                    = MD_READER._get_remark()
  buffered_field_separator  = null
  description               = null
  row_count                 = null
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    within_table                = track.within '(table)'
    within_th                   = track.within '(th)'
    track event
    #.......................................................................................................
    return send event unless within_table or select event, '(', 'table'
    #.......................................................................................................
    if within_th and select event, '.', 'text'
      send [ '(', 'strong', null, ( copy meta ), ]
      send stamp event
      send [ ')', 'strong', null, ( copy meta ), ]
    #.......................................................................................................
    else if select event, ')', 'tr'
      row_count                += +1
      buffered_field_separator  = null
      send stamp hide copy event
      ### thx to http://tex.stackexchange.com/a/159260 ###
      if row_count is description[ 'row_count' ]
        send [ 'tex', "\\\\\n", ]
        # send [ 'tex', "\\\\[\\mktsTabularLineheightDeltaLast]\n", ]
      else
        send [ 'tex', "\\\\\n", ]
        # send [ 'tex', "\\\\[\\mktsTabularLineheightDelta]\n", ]
      # last_zerohline_idx = send [ 'tex', "\\mktsZerohline\n", ]
    #.......................................................................................................
    else
      send buffered_field_separator if buffered_field_separator
      buffered_field_separator = null
      #.....................................................................................................
      if select event, '(', 'table'
        send stamp hide copy event
        col_styles  = []
        row_count   = 0
        description = meta[ 'table' ]
        for alignment in description[ 'alignments' ]
          switch alignment
            when 'left'   then col_styles.push 'l'
            when 'center' then col_styles.push 'c'
            when 'right'  then col_styles.push 'r'
            else               col_styles.push 'l'
        col_styles  = '| ' + ( col_styles.join ' | ' ) + ' |'
        send [ 'tex', "{", ]
        send [ 'tex', "\\mktsVspace{1}", ] ### TAINT arbitrary length ###
        send [ 'tex', "\\begin{tabular}[pos]{ #{col_styles} }\n", ]
      #.....................................................................................................
      else if select event, ')', 'table'
        send stamp hide copy event
        send [ 'tex', "\\hline\n", ]
        send [ 'tex', "\\end{tabular}\n", ]
        send [ 'tex', "\\mktsVspace{1}", ] ### TAINT arbitrary length ###
        send [ 'tex', "}", ]
        send [ 'tex', "\n\n", ]
        description = null
        row_count   = null
      #.....................................................................................................
      else if select event, '(', 'tbody'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'tbody'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, '(', 'td'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'td'
        send stamp hide copy event
        buffered_field_separator = [ 'tex', " & ", ]
      #.....................................................................................................
      else if select event, '(', 'th'
        send stamp hide copy event
      #.....................................................................................................
      else if select event, ')', 'th'
        send stamp hide copy event
        buffered_field_separator = [ 'tex', " & ", ]
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
        send stamp [ '(', 'footnote', null, {}, ]
        send [ 'tex', "{\\mktsEnStyleMarkNotes\\mktsEnMarkBefore#{fn_nr}\\mktsEnMarkAfter{}}", ]
        send fn_event for fn_event in fn_cache
        send stamp [ ')', 'footnote', null, {}, ]
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
      # send stamp event
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
      # send stamp event
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
    delta = if ( type is '(' ) then +1 else -1
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
      event_txt = "unhandled event: #{jr event}"
      send [ '.', 'warning', event_txt, ( copy meta ), ]
      # send stamp hide copy event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.$show_warnings = ( S ) =>
  warnings = []
  return $ ( event, send, end ) =>
    #.......................................................................................................
    if event?
      if select event, '.', 'warning'
        [ type, name, text, meta, ] = event
        line_nr                     = meta.line_nr  ? '?'
        col_nr                      = meta.col_nr   ? '?'
        ### TAINT fix location, use proper file name even for generated mktscript events ###
        source_locator              = S.layout_info[ 'source-locator' ]
        source_locator              = '<STRING>' if ( source_locator.match /<STRING>/ )?
        text                        = "#{text} (#{source_locator}#{line_nr}:#{col_nr})"
        warn '39833-1', text
        warnings.push event
        send event
      else
        send event
    #.......................................................................................................
    if end?
      if warnings.length > 0
        send [ 'tex', '\\newpage{}' ]
        send [ 'tex', "{\\mktsHTwo{}\\zlabel{mktsGeneratedWarnings}Generated Warnings}\n\n", ]
        for event in warnings
          [ type, name, text, meta, ] = event
          warn '39833-2', text
          send [ '.', 'warning', text, ( copy meta ), ]
          send [ 'tex', '\\par\n' ]
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.$format_warnings = ( S ) =>
  self = @
  return $async ( event, done ) =>
    ### TAINT this makes clear why we should not use '.' as type here; `warning` is a meta-event, not
    primarily a formatting instruction ###
    #.......................................................................................................
    if select event, '.', 'warning'
      [ type, name, text, meta, ] = event
      step ( resume ) ->
        message       = yield self.MKTX.TYPOFIX.fix_typography_for_tex S, text, resume
        message_tex   = "\\begin{mktsEnvWarning}#{message}\\end{mktsEnvWarning}"
        message_event = [ '.', Σ_formatted_warning, message_tex, ( copy meta ), ]
        done message_event
    #.......................................................................................................
    else
      done event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.$warnings_as_tex = ( S ) =>
  warnings = []
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', Σ_formatted_warning
      [ _, _, message_tex, meta, ]  = event
      tex_event                     = [ 'tex', message_tex, ]
      warnings.push tex_event
      send tex_event
    #.......................................................................................................
    else if select event, ')', 'document'
      if warnings.length > 0
        for tex_event in warnings
          send tex_event
          send [ 'tex', "\n\n", ]
        send event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null


#-----------------------------------------------------------------------------------------------------------
@MKTX.$consolidate_mktscript_events = ( S ) ->
  # remark      = MD_READER._get_remark()
  collector   = []
  first_meta  = null
  return $ ( event, send ) =>
    if select event, '.', 'mktscript'
      [ type, name, text, meta, ] = event
      first_meta                 ?= meta
      collector.push text
    else
      # debug '83726', collector
      if collector.length > 0
        send [ '.', 'mktscript', ( collector.join '\n' ), ( copy first_meta ), ]
        first_meta        = null
        collector.length  = 0
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.$mktscript = ( S ) =>
  return PIPEDREAMS.$async ( event, send, end ) =>
    #.......................................................................................................
    if event?
      if select event, '.', 'mktscript'
        [ type, name, mktscript, meta, ]   = event
        send stamp event
        tex_source  = await ( promisify @tex_from_md.bind @ ) mktscript, { bare: yes, }
        send [ 'tex', tex_source, ]
        send.done()
      else
        send event
        send.done()
    else
      send.done()
    #.......................................................................................................
    end() if end?
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
      warn "unhandled event: #{jr event}"
      send.error new Error "unhandled events not allowed at this point; got #{jr event}"

#-----------------------------------------------------------------------------------------------------------
@$show_events = ( S ) ->
  return D.$observe ( event ) =>
    whisper JSON.stringify event

#-----------------------------------------------------------------------------------------------------------
@$add_text_locators = ( S ) ->
  stack         = []
  event         = null
  column_stack  = [ 1, ]
  matches       = ( type, name ) -> MD_READER.select event, type, name, yes
  return D.$observe ( _event ) =>
    event = _event
    [ type, name, text, meta, ] = event
    return if matches [ '~', 'tex', ]
    #.......................................................................................................
    if matches [ '(', '!', ], [ 'multi-columns', 'columns', ]
      if ( parameter = event[ 2 ][ 0 ] ) is 'pop'
        column_stack.pop()
      else
        column_stack.push parameter
    #.......................................................................................................
    else if matches [ '(', '!', ], [ 'multi-columns', 'columns', ]
      column_stack.pop()
    #.......................................................................................................
    else if matches '('
      unless name in [ 'document', 'COLUMNS/group', ]
        stack.push name
    #.......................................................................................................
    else if matches ')'
      stack.pop() unless name is 'document'
    #.......................................................................................................
    else if matches '.', 'text'
      column_count  = column_stack[ column_stack.length - 1 ]
      meta.locator  = [ 'c' + ( rpr column_count ), stack..., ].join '/'
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$show_start_and_end_2 = ( S ) ->
  ### TAINT will buffer all texts ###
  is_first    = true
  buffer      = []
  event_count = 0
  t0          = null
  t1          = null
  return $ ( event, send, end ) =>
    #.......................................................................................................
    if event?
      event_count += +1
      #.....................................................................................................
      if is_first
        is_first  = false
        t0        = Date.now()
      #.....................................................................................................
      if select event, '.', 'text'
        [ type, name, text, meta, ] = event
        buffer.push text
      #.....................................................................................................
      send event
    #.......................................................................................................
    if end?
      t1            = Date.now()
      dts           = ( t1 - t0 ) / 1000
      max_chr_count = 200
      raw_text      = buffer.join ' '
      chr_count     = raw_text.length ### NOTE approximate count ###
      text_count    = buffer.length
      cpe_txt       = ( chr_count / text_count ).toFixed 1 ### characters per text event ###
      eps_txt       = ( event_count / dts ).toFixed 1 ### events per second ###
      if chr_count > max_chr_count
        info '33442', rpr ( raw_text[ ... max_chr_count ] + ' ... ' + raw_text[ chr_count - max_chr_count ... ] )
      else
        info '33442', rpr raw_text
      ### TAINT compare text size with buffer length; characters per text event ###
      urge '\n' + """
        needed #{dts}s for #{event_count} events (#{eps_txt} events / s)
        (#{buffer.length} text events, #{cpe_txt} chrs / text event)"""
      buffer.length = 0
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$show_text_locators = ( S ) ->
  return D.$observe ( event ) =>
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      help ( CND.grey '22311' ), ( CND.lime ( meta.locator ? '????????????' ) ) + ' ' + ( CND.white rpr text )
    #.......................................................................................................
    return null


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
    .pipe @MKTX.$insert                                     S
    .pipe @MKTX.SH.$spawn                                   S
    .pipe @MKTX.CALL.$call_await                            S
    .pipe @MKTX.CALL.$call_stream                           S
    .pipe @MKTX.$consolidate_mktscript_events               S
    .pipe @MKTX.$mktscript                                  S
    .pipe @MKTX.INLINE.$custom_entities                     S
    .pipe plugins_tee
    # .pipe D.$observe ( event ) -> info ( CND.grey '--------->' ), ( CND.blue event[ 0 ] + event[ 1 ] )
    .pipe MACRO_ESCAPER.$expand.$remove_backslashes         S
    # .pipe MKTSCRIPT_WRITER.$show_mktsmd_events              S
    .pipe MKTSCRIPT_WRITER.$produce_mktscript               S
    .pipe @$document                                        S
    #.......................................................................................................
    ### tags that produce tags ###
    #.......................................................................................................
    ### stuff using new HTML-ish syntax ###
    .pipe @MKTS_TABLE.$main                                 S
    .pipe @MKTX.INLINE.$here_x                              S
    .pipe @MKTX.INLINE.$box                                 S
    .pipe @MKTX.INLINE.$hfill                               S
    .pipe @MKTX.INLINE.$tiny                                S
    .pipe @MKTX.INLINE.$scale                               S
    .pipe @MKTX.BLOCK.$stretch                              S
    .pipe @MKTX.BLOCK.$vspace                               S
    .pipe @MKTX.BLOCK.$landscape                            S
    # .pipe @MKTX.BLOCK.$pre                                  S
    .pipe @MKTX.INLINE.$nudge                               S
    .pipe @MKTX.INLINE.$turn                                S
    .pipe @MKTX.INLINE.$fncr                                S
    .pipe @MKTX.INLINE.$xfsc                                S
    .pipe @MKTX.BLOCK.$text_alignment                       S
    .pipe @MKTX.BLOCK.$fontlist                             S
    #.......................................................................................................
    .pipe @MKTX.BLOCK.$blockquote                           S
    .pipe @MKTX.INLINE.$link                                S
    .pipe @MKTX.MIXED.$footnote                             S
    .pipe @MKTX.MIXED.$footnote.$remove_extra_paragraphs    S
    .pipe @MKTX.COMMAND.$new_page                           S
    .pipe @MKTX.COMMAND.$blank_page                         S
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
    .pipe @$add_text_locators                               S
    .pipe MACRO_INTERPRETER.$capture_change_events          S
    .pipe @MKTX.CLEANUP.$remove_empty_texts                 S
    .pipe @MKTX.CLEANUP.$consolidate_texts                  S
    # .pipe @$show_events                                     S
    # .pipe @$show_text_locators                              S
    .pipe @$show_start_and_end_2                            S
    .pipe @MKTX.BLOCK.$paragraph_2                          S
    .pipe @MKTX.COMMAND.$crossrefs                          S
    # .pipe D.$observe ( event ) -> info '23993', ( CND.grey '--------->' ), CND.grey jr event
    .pipe @MKTX.TYPOFIX.$fix_typography_for_tex             S
    # .pipe D.$observe ( event ) -> ( info '23993', ( CND.grey '--------->' ), jr event ) unless event[ 3 ]?.stamped
    #.......................................................................................................
    .pipe do =>
      S.event_count = 0
      return D.$observe ( event ) =>
        S.event_count += +1
    .pipe @MKTX.INLINE.$mark                                S
    .pipe @MKTX.$show_unhandled_tags                        S
    .pipe @MKTX.$show_warnings                              S
    .pipe @MKTX.$format_warnings                            S
    .pipe @MKTX.$warnings_as_tex                            S
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
@_get_on_content_output_close = ( S ) ->
  return =>
    #.......................................................................................................
    await ( promisify @write_mkts_master.bind @ ) S
    await ( promisify HELPERS.write_pdf.bind HELPERS ) S.layout_info
    #.......................................................................................................
    S.t1              = +new Date()
    dt_s              = ( S.t1 - S.t0 ) / 1000
    dt_s_txt          = dt_s.toFixed 3
    chrs_per_s_txt    = (   S.chr_count / dt_s ).toFixed 3
    events_per_s_txt  = ( S.event_count / dt_s ).toFixed 3
    chr_count_txt     = ƒ S.chr_count
    event_count_txt   = ƒ S.event_count
    help "#{   chr_count_txt.padStart 10, ' '}       chrs (approx.)"
    help "#{ event_count_txt.padStart 10, ' '}     events (approx.)"
    help "#{        dt_s_txt.padStart 14, ' '}          s"
    help "#{  chrs_per_s_txt.padStart 14, ' '}   chrs / s"
    help "#{events_per_s_txt.padStart 14, ' '} events / s"
    process.exit 0

#-----------------------------------------------------------------------------------------------------------
@_new_state = ( source_route, settings ) ->
  validate    = ( settings ? {} ).validate ? true
  R           =
    options:              @options
    layout_info:          HELPERS.new_layout_info @options, source_route, validate
    paragraph_nr:         0
    configuration:        {}
  return R

#-----------------------------------------------------------------------------------------------------------
@pdf_from_md = ( source_route, handler ) ->
  RPC_SERVER              = require './rpc-server'
  server                  = await ( promisify RPC_SERVER.listen.bind RPC_SERVER )()
  process.on 'exit', ->
    help '44092', "RPC server closing"
    server.close()
  #.......................................................................................................
  S                       = @_new_state source_route
  content_output          = njs_fs.createWriteStream S.layout_info[ 'content-locator' ]
  content_output.on 'close', @_get_on_content_output_close S
  #.......................................................................................................
  ### TAINT should read MD source stream ###
  md_source               = njs_fs.readFileSync S.layout_info[ 'source-locator'  ], encoding: 'utf-8'
  md_readstream           = MD_READER.create_md_read_tee S, md_source
  tex_writestream         = @create_tex_write_tee S
  md_input                = md_readstream.tee[    'input'  ]
  md_output               = md_readstream.tee[    'output' ]
  tex_input               = tex_writestream.tee[  'input'  ]
  tex_output              = tex_writestream.tee[  'output' ]
  #.......................................................................................................
  # S.aux                   = yield AUX.fetch_aux_data S, resume
  S.resend                = md_readstream.tee[ 'S' ].resend
  #.......................................................................................................
  md_output.pipe          tex_input
  tex_output.pipe         content_output
  #.......................................................................................................
  md_input.resume()
  return null


#===========================================================================================================
# TEX FROM MD
#-----------------------------------------------------------------------------------------------------------
XXX_tex_from_md_nr = 0
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
  ### TAINT use method to produce new state ###
  S                       = @_new_state source_route, { validate: false, }
  S.bare                  = settings[ 'bare' ] ? no
  #.........................................................................................................
  XXX_tex_from_md_nr += +1
  md_readstream       = MD_READER.create_md_read_tee S, md_source
  tex_writestream     = @create_tex_write_tee S
  md_input            =   md_readstream.tee[ 'input'  ]
  md_output           =   md_readstream.tee[ 'output' ]
  tex_input           = tex_writestream.tee[ 'input'  ]
  tex_output          = tex_writestream.tee[ 'output' ]
  #.........................................................................................................
    # S.aux                   = yield AUX.fetch_aux_data S, resume
  S.resend            = md_readstream.tee[ 'S' ].resend
  #.........................................................................................................
  md_output
    .pipe tex_input
  tex_output
    # .pipe D.$show '>>>>>>>>>>>>>>>>>>'
    .pipe $collect_and_call handler
  #.........................................................................................................
  D.run ( => md_input.resume() ), @_handle_error
  return null



############################################################################################################
# unless module.parent?
#   # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
#   # @pdf_from_md 'texts/demo'
#   TW = @
#   require '../../mingkwai'
#   do ->
#     mktscript = """
#     # Headline

#     Some *important* text. <box>boxed</box>

#     """
#     # mktscript = """<box>boxed</box>"""
#     promisify = ( require 'util' ).promisify
#     tex_source  = await ( promisify TW.tex_from_md.bind TW ) mktscript, { bare: yes, }
#     debug '45532', rpr tex_source.trim()
#     debug '45532', '###'

#   # debug '©nL12s', MKTS.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
#   # debug '©nL12s', MKTS.as_tex_text 'helo さし'
#   # event = [ '(', 'single-column', ]
#   # event = [ ')', 'single-column', ]
#   # event = [ '(', 'new-page', ]
#   # debug '©Gpn1J', select event, [ '(', ')'], [ 'single-column', 'new-page', ]

