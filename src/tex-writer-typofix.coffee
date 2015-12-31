



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/tex-writer-typofix'
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
XNCHR                     = require './xnchr'
D                         = require 'pipedreams'
$                         = D.remit.bind D
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER



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
@escape_for_tex = ( text ) =>
  R = text
  for [ pattern, replacement, ], idx in @_tex_escape_replacements
    R = R.replace pattern, replacement
  return R

#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( S ) =>
  return $ ( event, send ) =>
    if select event, '.', 'text'
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      text          = @fix_typography_for_tex text, S.options
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@is_cjk_rsg = ( rsg, options ) => rsg in options[ 'tex' ][ 'cjk-rsgs' ]

#-----------------------------------------------------------------------------------------------------------
@_analyze_chr = ( S, chr ) ->
    #.......................................................................................................
    R = XNCHR.analyze chr
    #.......................................................................................................
    switch R.rsg
      when 'jzr-fig'  then R.chr = R.uchr
      when 'u-pua'    then R.rsg = 'jzr-fig'
      when 'u-latn'   then R.chr = @escape_for_tex chr
    #.......................................................................................................
    ### OBS `chr` has still the value this method was called with, so styling should work even for `u-latn`
    characters ###
    R.is_whitespace = chr   in S.whitespace
    R.is_cjk        = R.rsg in S.cjk_rsgs
    R.styled_chr    = @_style_chr S, R, chr
    return R

#-----------------------------------------------------------------------------------------------------------
@_style_chr = ( S, chr_info, chr ) ->
  { rsg
    fncr
    is_cjk    }       = chr_info
  rsg_command         = S.tex_command_by_rsgs[ rsg ]
  # debug '©28708', chr, rsg_command
  unless rsg_command?
    rsg_command = S.tex_command_by_rsgs[ 'fallback' ] ? null
    message     = "unknown RSG #{rpr rsg}: #{fncr} #{chr} (using fallback #{rpr rsg_command})"
    if S.send? then S.send remark 'warn', message, {}
    else            warn message
  rsg_command         = null if rsg_command in [ 'latin', 'cn', ]
  style               = S.glyph_styles[ chr ]
  #.........................................................................................................
  return null if ( not rsg_command? ) and ( not style? )
  #.........................................................................................................
  if style?
    ### TAINT use `cjkgGlue` only if `is_cjk` ###
    R         = []
    R.push "\\cjkgGlue{"
    rpl_push  = style[ 'push'   ] ? null
    rpl_raise = style[ 'raise'  ] ? null
    rpl_chr   = style[ 'glyph'  ] ? chr_info[ 'uchr' ]
    rpl_cmd   = style[ 'cmd'    ] ? rsg_command
    rpl_cmd   = null if rpl_cmd is 'cn'
    if      rpl_push? and rpl_raise?  then R.push "\\tfPushRaise{#{rpl_push}}{#{rpl_raise}}"
    else if rpl_push?                 then R.push "\\tfPush{#{rpl_push}}"
    else if               rpl_raise?  then R.push "\\tfRaise{#{rpl_raise}}"
    if rpl_cmd?                       then R.push "\\#{rpl_cmd}{}"
    R.push rpl_chr
    R.push "}\\cjkgGlue{}"
    R = R.join ''
  #.........................................................................................................
  else
    ### TAINT does not collect glyphs with same RSG ###
    # debug '©95429', chr_info
    R = "{\\#{rsg_command}{}#{chr_info[ 'uchr' ]}}"
    R = "\\cjkgGlue#{R}\\cjkgGlue{}" if is_cjk
  #.........................................................................................................
  S.last_rsg_command = rsg_command
  return R

#-----------------------------------------------------------------------------------------------------------
@_move_whitespace = ( S ) ->
  S.collector.splice S.collector.length, 0, S.ws_collector...
  S.ws_collector.length = 0
  return null

#-----------------------------------------------------------------------------------------------------------
@_push = ( S, chr, postpone_ws = no ) ->
  @_move_whitespace S unless postpone_ws
  S.collector.push chr if chr?
  @_move_whitespace S if     postpone_ws
  S.has_cjk_glue = no
  return null

#-----------------------------------------------------------------------------------------------------------
@_push_whitespace = ( S, chr ) ->
  S.ws_collector.push chr
  return null

#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( text, options, send = null ) =>
  S =
    cjk_rsgs:                     options[ 'tex' ]?[ 'cjk-rsgs' ] ? null
    glyph_styles:                 options[ 'tex' ]?[ 'glyph-styles'             ] ? {}
    tex_command_by_rsgs:          options[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
    ws_collector:                 []
    collector:                    []
    whitespace:                   '\x20\n\r\t'
    this_is_cjk:                  no
    last_was_cjk:                 no
    last_rsg_command:             null
    # has_cjk_glue:                 no
    R:                            null
  #.........................................................................................................
  throw new Error "need setting 'tex-command-by-rsgs'" unless S.tex_command_by_rsgs?
  throw new Error "need setting 'cjk-rsgs'" unless S.cjk_rsgs?
  #.........................................................................................................
  for chr in XNCHR.chrs_from_text text
    A = @_analyze_chr S, chr
    #.......................................................................................................
    ### Whitespace is ambiguous; it is treated as CJK when coming between two unambiguous CJK characters and
    as non-CJK otherwise; to decide between these cases, we have to wait for the next non-whitespace
    character: ###
    if A.is_whitespace
      @_push_whitespace S, chr
      continue
    #.......................................................................................................
    S.last_was_cjk  = S.this_is_cjk
    S.this_is_cjk   = A.is_cjk
    #.......................................................................................................
    ### In case we're entering a region of CJK characters, we have to start a group and issue a `\cjk`
    command; before we do that, any cached whitespace will be moved into the result. If we're leaving a
    CJK region, the group must be closed first and followed by any cached whitespace: ###
    if ( not S.last_was_cjk ) and ( S.this_is_cjk )
      @_push S, "\\cjkgGlue{\\cjk{}"
      # @_push S, "{\\cjk{}"
    else if ( S.last_was_cjk ) and ( not S.this_is_cjk )
      @_push S, "}\\cjkgGlue{}", yes
      # @_push S, "}", yes
    #.......................................................................................................
    if A.styled_chr?
      # @_push "\\cjkgGlue" if S.this_is_cjk
      @_push S, A.styled_chr
    else
      @_push S, A.chr
  #.........................................................................................................
  ### TAINT here we should keep state across text chunks to decide on cases like
  `國 **b** 國` vs `國 **國** 國` ###
  @_push S
  @_push S, '}\\cjkgGlue{}' if S.this_is_cjk
  return S.collector.join ''









