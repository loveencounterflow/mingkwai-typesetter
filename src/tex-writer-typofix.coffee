


###

{\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}{\latin{} }{\cjk{}{\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}}}{\cjk{}{\cn{}里}}{\cjk{}{\cnxb{}{\cnxJzr{}}}}{\latin{} }{\cjk{}{\cn{}里}}{\cjk{}{\cnxa{}䊷}}{\mktsRsgFb{}இ}{\latin{} }{\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}

agfi {\cjk{}\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}里{\cnxb{}\cnxJzr{}} 里{\cnxa{}䊷}}{\mktsRsgFb{}இ} agfi

agfi {\cjk{}\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}里\cnxb{}\cnxJzr{}\cn 里\cnxa{}䊷}{\mktsRsgFb{}இ} agfi

###

###

typofix v1:
{\cjk{}{\cn{}里}{\cn{}里}{\cn\cnxa{}䊷}{\cn\cnxa{}䊷}{\cn{}里}{\cn{}里}{\cn{}里}{\cn{}里}{\cn{}里}}\\

typofix v2:
{\cjk{}{\cn{}里里}{\cnxa{}䊷䊷}{\cn{}里里里里里}}

typofix v2 intermediate:
{\CJK{}{\CN{}里里}{\CNXA{}䊷䊷}{\CN{}里里里里里}}
###



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
D                         = require '../../../pipedreams'
{ $ }                     = D
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
#...........................................................................................................
MKNCR                     = require '../../mingkwai-ncr'
Σ_glyph_description       = Symbol 'glyph-description'
jr                        = JSON.stringify

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$format_tex_specials = ( S ) ->
  ### TAINT should preserve raw text from before replacements ###
  return $ ( event, send ) =>
    return send event unless select event, '.', Σ_glyph_description
    [ type, name, description, meta, ]  = event
    { uchr, rsg, }                      = description
    return send event unless rsg is 'u-latn'
    switch uchr
      when '\\' then return send [ 'tex', '\\textbackslash{}',    ]
      when '{'  then return send [ 'tex', '\\{',                  ]
      when '}'  then return send [ 'tex', '\\}',                  ]
      when '$'  then return send [ 'tex', '\\$',                  ]
      when '#'  then return send [ 'tex', '\\#',                  ]
      when '%'  then return send [ 'tex', '\\%',                  ]
      when '_'  then return send [ 'tex', '\\_',                  ]
      when '^'  then return send [ 'tex', '\\textasciicircum{}',  ]
      when '~'  then return send [ 'tex', '\\textasciitilde{}',   ]
      when '&'  then return send [ 'tex', '\\&',                  ]
    return send event

#-----------------------------------------------------------------------------------------------------------
@$format_cjk = ( S ) ->
  ### NOTE same pattern as in `$consolidate_tex_events` ###
  ### TAINT should preserve raw text from before replacements ###
  ### TAINT use piped streams for logic? ###
  ### TAINT unify with `$format_non_cjk` ###
  ### TAINT do not use a collector, may potentially store text of entire document in memory ###
  cjk_collector       = []
  send                = null
  event               = null
  last_texcmd_block   = null
  #.........................................................................................................
  flush_and_send_event = =>
    if cjk_collector.length > 0
      cjk_collector.push "}" if last_texcmd_block?
      cjk_collector.push "}"
      tex                   = "{\\cjk{}" + cjk_collector.join ''
      last_texcmd_block     = null
      cjk_collector.length  = 0
      send [ 'tex', tex, ]
    send event if event?
    return null
  #.........................................................................................................
  return $ 'null', ( _event, _send ) =>
    send  = _send
    event = _event
    #.......................................................................................................
    return flush_and_send_event() unless event?
    return flush_and_send_event() unless select event, '.', Σ_glyph_description
    #.......................................................................................................
    [ type, name, description, meta, ]              = event
    { uchr, rsg, tag, tex: texcmd, }                = description
    is_cjk                                          = 'cjk' in tag
    return flush_and_send_event() unless is_cjk
    #.......................................................................................................
    if texcmd?
      { block: texcmd_block, codepoint: texcmd_cp, }  = texcmd
    else
      send [ '.', 'warning', "missing TeX command in description for codepoint: #{description}", ( copy meta ), ]
      texcmd_block  = "\\cn{}"
      texcmd_cp     = null
    #.......................................................................................................
    if last_texcmd_block isnt texcmd_block
      ### close previous open TeX block command, if any: ###
      cjk_collector.push '}' if last_texcmd_block?
      cjk_collector.push '{'
      cjk_collector.push texcmd_block
      last_texcmd_block = texcmd_block
    #.......................................................................................................
    tex   = texcmd_cp
    tex  ?= uchr
    cjk_collector.push tex
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$format_non_cjk = ( S ) ->
  ### TAINT code duplication ###
  ### TAINT unify with `$format_cjk` ###
  ignore_texcmd_blocks  = [ '\\latin{}', '\\mktsRsgFb{}', ]
  # ignore_texcmd_blocks  = [ '\\latin{}', ]
  #.........................................................................................................
  return $ ( _event, _send ) =>
    send  = _send
    event = _event
    #.......................................................................................................
    return send event unless select event, '.', Σ_glyph_description
    debug '34744', jr event
    #.......................................................................................................
    [ type, name, description, meta, ]              = event
    { uchr, rsg, tag, tex: texcmd, }                = description
    return send event if 'cjk' in tag
    return send event unless texcmd?
    #.......................................................................................................
    { block: texcmd_block, codepoint: texcmd_cp, }  = texcmd
    # debug '79876', texcmd, texcmd in ignore_texcmd_blocks
    # return send event if texcmd_block in ignore_texcmd_blocks
    texcmd_block = null if texcmd_block in ignore_texcmd_blocks
    return send event if ( not texcmd_block? ) and ( not texcmd_cp? )
    #.......................................................................................................
    collector = []
    collector.push "{#{texcmd_block}" if texcmd_block?
    collector.push if texcmd_cp? then texcmd_cp else uchr
    collector.push "}" if texcmd_block?
    tex       = collector.join ''
    send [ 'tex', tex, ]
    #.......................................................................................................
    return null

# #-----------------------------------------------------------------------------------------------------------
# @$format_cjk = ( S ) ->
#   ### NOTE same pattern as in `$consolidate_tex_events` ###
#   ### TAINT should preserve raw text from before replacements ###
#   ### TAINT use piped streams for logic? ###
#   cjk_collector         = []
#   send                  = null
#   event                 = null
#   last_texcmd_block     = null
#   script                = 'latin'
#   last_script           = script
#   ignore_texcmd_blocks  = [ '\\latin{}', ]
#   must_close_group      = no
#   #.........................................................................................................
#   flush_and_send_event = =>
#     if cjk_collector.length > 0
#       cjk_collector.push "}" if last_texcmd_block?
#       cjk_collector.push "}"
#       tex                   = "{\\cjk{}" + cjk_collector.join ''
#       last_texcmd_block     = null
#       cjk_collector.length  = 0
#       send [ 'tex', tex, ]
#     send event if event?
#     return null
#   #.........................................................................................................
#   return $ 'null', ( _event, _send ) =>
#     send  = _send
#     event = _event
#     #.......................................................................................................
#     return flush_and_send_event() unless event?
#     return flush_and_send_event() unless select event, '.', Σ_glyph_description
#     #.......................................................................................................
#     [ type, name, description, meta, ]  = event
#     { uchr, rsg, tag, tex: texcmd, }    = description
#     script                              = if ( 'cjk' in tag ) then 'cjk' else 'latin'
#     flush_and_send_event() if script isnt last_script
#     last_script                         = script
#     #.......................................................................................................
#     if texcmd?
#       { block: texcmd_block, codepoint: texcmd_cp, }  = texcmd
#     else
#       send [ '.', 'warning', "missing TeX command in description for codepoint: #{description}", ( copy meta ), ]
#       texcmd_block  = null
#       texcmd_cp     = null
#     #.......................................................................................................
#     if last_texcmd_block isnt texcmd_block
#       ### close previous open TeX block command, if any: ###
#       if must_close_group
#         cjk_collector.push '}' if cjk_collector?
#         must_close_group = no
#       debug "30222", rpr texcmd_block, texcmd_block in ignore_texcmd_blocks
#       if texcmd_block in ignore_texcmd_blocks
#         must_close_group  = no
#       else
#         must_close_group  = yes
#         cjk_collector.push '{'
#         cjk_collector.push texcmd_block
#       last_texcmd_block = texcmd_block
#     #.......................................................................................................
#     tex   = texcmd_cp
#     tex  ?= uchr
#     cjk_collector.push tex
#     #.......................................................................................................
#     return null


#===========================================================================================================
# SPLITTING, WRAPPING, UNWRAPPING
#-----------------------------------------------------------------------------------------------------------
@$split = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', 'text'
    [ type, name, text, meta, ] = event
    for glyph in MKNCR.chrs_from_text text
      send [ '.', Σ_glyph_description, glyph, meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$wrap_as_glyph_description = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', Σ_glyph_description
    [ type, name, glyph, meta, ] = event
    description = MKNCR.describe glyph
    { csg, }    = description
    if csg in [ 'u', 'jzr', ]
      send [ type, name, description, meta, ]
    else
      ### NOTE In case the CSG is not an 'inner' one (either Unicode or Jizura), the glyph can only
      have been represented as an extended NCR (a string like `&morohashi#x12ab;`). In that case,
      we send all the constituent US-ASCII glyphs separately so the NCR will be rendered literally. ###
      for sub_glyph in Array.from glyph
        send [ type, name, ( MKNCR.describe sub_glyph ), meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$consolidate_tex_events = ( S ) ->
  ### NOTE same pattern as in `$format_cjk` ###
  collector     = []
  send          = null
  event         = null
  #.........................................................................................................
  flush_and_send_event = =>
    if collector.length > 0
      tex               = collector.join ''
      collector.length  = 0
      send [ 'tex', tex, ]
    #.......................................................................................................
    send event if event?
    return null
  #.........................................................................................................
  return $ 'null', ( _event, _send ) =>
    send  = _send
    event = _event
    #.......................................................................................................
    return flush_and_send_event() unless event?
    return flush_and_send_event() unless select event, 'tex'
    #.......................................................................................................
    [ _, tex, ] = event
    collector.push tex
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$unwrap_glyph_description = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', Σ_glyph_description
    [ type, name, description, meta, ] = event
    # debug '70333', description
    glyph = description[ 'uchr' ]
    ### TAINT send `tex` or `text` event? ###
    send [ 'tex', glyph, ]
    return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( S ) ->
  pipeline = [
    @$split                     S
    @$wrap_as_glyph_description S
    @$format_cjk                S
    @$format_non_cjk            S
    @$format_tex_specials       S
    @$unwrap_glyph_description  S
    @$consolidate_tex_events    S
    # $ ( event ) -> help '65099', rpr event[ 1 ] if select event, 'tex'
    ]
  return D.new_stream { pipeline, }

#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( S, text, handler ) ->
  collector = []
  input     = D.new_stream()
  input
    .pipe @$fix_typography_for_tex S
    .pipe $ ( event ) =>
      return unless select event, 'tex'
      [ _, tex,] = event
      collector.push tex
    .pipe $ 'finish', =>
      handler null, collector.join ''
  #.........................................................................................................
  D.send  input, [ '.', 'text', text, {}, ]
  D.end   input
  #.........................................................................................................
  return null


# ############################################################################################################
# unless module.parent?
#   debug '83744', MKNCR.describe '&#x3000;'



