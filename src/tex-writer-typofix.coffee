


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
  ### TAINT should preserve raw text from before replacements ###
  ### TAINT must look for stream end ###
  ### TAINT use piped streams for logic ###
  cjk_collector       = []
  _send               = null
  last_texcmd_block   = null
  #.........................................................................................................
  ### TAINT code duplication ###
  flush = =>
    return unless cjk_collector.length > 0
    cjk_collector.push "}" if last_texcmd_block?
    cjk_collector.push "}"
    ### TAINT that `\\cjk{}` part should come from the MKNCR Unicode InterSkipList ###
    ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
    tex                   = "{\\cjk{}" + cjk_collector.join ''
    # tex                   = "{\\CJK{}" + cjk_collector.join ''
    ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
    last_texcmd_block     = null
    cjk_collector.length  = 0
    _send [ 'tex', tex, ]
    return null
  #.........................................................................................................
  return $ 'null', ( event, send ) =>
    _send = send
    #.......................................................................................................
    if event?
      if select event, '.', Σ_glyph_description
        [ type, name, description, meta, ]              = event
        { uchr, rsg, tag, tex: texcmd, }                = description
        { block: texcmd_block, codepoint: texcmd_cp, }  = texcmd
        ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
        # texcmd_block = texcmd_block.toUpperCase()
        ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
        is_cjk                                          = 'cjk' in tag
        # debug '90708', { tex_cmd_block, tex_cmd_cp}
        # is_ascii_whistespace                = 'cjk' in tag
        if is_cjk
          if last_texcmd_block isnt texcmd_block
            ### close previous open TeX block command, if any: ###
            cjk_collector.push '}' if last_texcmd_block?
            cjk_collector.push '{'
            cjk_collector.push texcmd_block
            last_texcmd_block = texcmd_block
          tex   = texcmd_cp
          tex  ?= uchr
          cjk_collector.push tex
        #...................................................................................................
        else
          flush()
          send event
      #.....................................................................................................
      else
        flush()
        send event
    #.......................................................................................................
    else
      flush()
    #.......................................................................................................
    return null


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
    send [ type, name, description, meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$consolidate_tex_events = ( S ) ->
  collector     = []
  _send         = null
  #.........................................................................................................
  flush = =>
    return unless collector.length > 0
    tex               = collector.join ''
    collector.length  = 0
    _send [ 'tex', tex, ]
    return null
  #.........................................................................................................
  return $ 'null', ( event, send ) =>
    _send = send
    if event?
      if select event, 'tex'
        [ _, tex, ] = event
        collector.push tex
      else
        flush()
        send event
    else
      flush()

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







