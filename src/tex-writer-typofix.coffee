



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
D                         = require 'pipedreams'
$                         = D.remit.bind D
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
#...........................................................................................................
### TAINT XNCHR will be phased out in favor of MKNCR ###
XNCHR                     = require './xnchr'
MKNCR                     = require '../../mingkwai-ncr'


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
      # urge '12312', event
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      style         = meta[ 'typofix' ] ? 'basic' # 'escape-ncrs' ]
      text          = @fix_typography_for_tex text, S.options, null, style
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_analyze_chr = ( S, chr, style, is_last ) ->
  #.........................................................................................................
  input = if style is 'escape-ncrs' then 'plain' else 'xncr'
  R     = MKNCR.describe chr, { input, }
  debug '33002', style, input, R.rsg, ( rpr chr ), ( rpr R.uchr )
  #.........................................................................................................
  switch R.rsg
    when 'jzr', 'jzr-fig' then R.chr = R.uchr
    when 'u-pua'          then R.rsg = 'jzr-fig'
    when 'u-latn'         then R.chr = @escape_for_tex chr
    else
      R.chr         = @escape_for_tex chr
      R.tex        ?= {}
      R.tex.block   = '\\latin'
  #.........................................................................................................
  ### OBS `chr` has still the value this method was called with, so styling should work even for `u-latn`
  characters ###
  R.is_whitespace = 'ascii-whitespace' in R.tag
  if R.is_whitespace then R.is_cjk        = null
  else                    R.is_cjk        = 'cjk' in R.tag
  # R.styled_chr    = @_style_chr S, R, chr, is_last
  # debug '77022', CND.rainbow JSON.stringify R
  return R

#-----------------------------------------------------------------------------------------------------------
@_style_chr = ( S, chr_info, chr, is_last ) ->
  ### TAINT parts of this code will be replaced by `mingkwai-ncr.glyph_style_as_tex` ###
  { csg
    rsg
    fncr
    is_cjk    }       = chr_info
  #.........................................................................................................
  unless csg in [ 'u', 'jzr', ]
    ### TAINT won't capture styling for `&`, `#` and so on ###
    return @escape_for_tex chr_info.chr
  #.........................................................................................................
  unless rsg_command?
    rsg_command = S.tex_command_by_rsgs[ 'fallback' ] ? null
    message     = "unknown RSG #{rpr rsg}: #{fncr} #{chr} (using fallback #{rpr rsg_command})"
    if S.send? then S.send remark 'warn', message, {}
    else            warn message
  rsg_command         = null if rsg_command in [ 'latin', ] # 'cn', ]
  style               = S.glyph_styles[ chr ]
  #.........................................................................................................
  if style?
    null
  #.........................................................................................................
  else if rsg_command?
    ### TAINT does not collect glyphs with same RSG ###
    if is_cjk and rsg_command isnt 'cn'
      R = "{\\cn\\#{rsg_command}{}#{chr_info[ 'uchr' ]}}"
    else
      R = "{\\#{rsg_command}{}#{chr_info[ 'uchr' ]}}"
  #.........................................................................................................
  else
    R = null
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
@_split_dangling_ws = ( text ) ->
  [ _, head, tail, ] = text.match @_split_dangling_ws.pattern
  return [ head, tail, ]
@_split_dangling_ws.pattern = /^([\s\S]*?)([\x20\t\n]*)$/
# @_split_dangling_ws.pattern = /^([\s\S]*?)(\s*)$/

#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( text, options, send = null, style ) =>
  S =
    ws_collector:                 []
    collector:                    []
    whitespace:                   '\x20\n\r\t'
    this_is_cjk:                  no
    last_was_cjk:                 no
    last_rsg_command:             null
    # has_cjk_glue:                 no
    R:                            null
  #.........................................................................................................
  [ text, dangling_ws, ]  = @_split_dangling_ws text
  chrs                    = XNCHR.chrs_from_text text
  last_idx                = chrs.length - 1
  open_bracket_count      = 0
  #.........................................................................................................
  for chr, chr_idx in chrs
    description   = @_analyze_chr S, chr, style, ( chr_idx is last_idx )
    { chr: glyph
      is_cjk
      csg
      cid
      tex }       = description
    tex_block     = tex?[ 'block'      ] ? null
    tex_codepoint = tex?[ 'codepoint'  ] ? null
    debug '79011', ( description[ 'tex' ]?[ 'block' ] ? '' ), ( description[ 'tex' ]?[ 'codepoint' ] ? '' ), glyph
    #.......................................................................................................
    if is_cjk # is true
      open_bracket_count += +1
      @_push S, "{"
      @_push S, "\\cjk"
      @_push S, "{}"
    #.......................................................................................................
    if tex_block?
      open_bracket_count += +1
      @_push S, "{"
      @_push S, tex_block
      @_push S, "{}"
    #.......................................................................................................
    if tex_codepoint?
      @_push S, tex_codepoint
    #.......................................................................................................
    else
      @_push S, glyph
    #.......................................................................................................
    while open_bracket_count > 0
      open_bracket_count += -1
      @_push S, "}"
  #.........................................................................................................
  return S.collector.join ''

_X_ = ->

  ### # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  ###
  ### # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  ###
  ### # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  ###

  #.......................................................................................................
  ### Whitespace is ambiguous; it is treated as CJK when coming between two unambiguous CJK characters and
  as non-CJK otherwise; to decide between these cases, we have to wait for the next non-whitespace
  character: ###
  if description.is_whitespace
    @_push_whitespace S, chr
    # continue
  #.......................................................................................................
  S.last_was_cjk  = S.this_is_cjk
  S.this_is_cjk   = description.is_cjk
  #.......................................................................................................
  ### In case we're entering a region of CJK characters, we have to start a group and issue a `\cjk`
  command; before we do that, any cached whitespace will be moved into the result. If we're leaving a
  CJK region, the group must be closed first and followed by any cached whitespace: ###
  if ( not S.last_was_cjk ) and ( S.this_is_cjk )
    @_push S, "{\\cjk{}"
  else if ( S.last_was_cjk ) and ( not S.this_is_cjk )
    @_push S, "}", yes
  #.......................................................................................................
  if description.styled_chr?
    # @_push "\\cjkgGlue" if S.this_is_cjk
    @_push S, description.styled_chr
  else
    @_push S, description.chr
  #.........................................................................................................
  ### TAINT here we should keep state across text chunks to decide on cases like
  `國 **b** 國` vs `國 **國** 國` ###
  @_push S
  @_push S, '}' if S.this_is_cjk
  @_push S, dangling_ws
  #.........................................................................................................
  return S.collector.join ''









