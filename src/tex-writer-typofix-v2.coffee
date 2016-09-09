


###

{\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}{\latin{} }{\cjk{}{\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}}}{\cjk{}{\cn{}里}}{\cjk{}{\cnxb{}{\cnxJzr{}}}}{\latin{} }{\cjk{}{\cn{}里}}{\cjk{}{\cnxa{}䊷}}{\mktsRsgFb{}இ}{\latin{} }{\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}

agfi {\cjk{}\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}里{\cnxb{}\cnxJzr{}} 里{\cnxa{}䊷}}{\mktsRsgFb{}இ} agfi

agfi {\cjk{}\cn{}{\tfRaise{-0.2}\cnxBabel{}癶}里\cnxb{}\cnxJzr{}\cn 里\cnxa{}䊷}{\mktsRsgFb{}இ} agfi

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
@$escape_for_tex = ( S ) ->
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
  return $ ( event, send ) =>
    return send event unless select event, '.', 'text'
    [ type, name, raw_text, meta, ] = event
    text    = raw_text
    glyphs  = MKNCR.chrs_from_text text
    for glyph in glyphs
      description = MKNCR.describe glyph
      { tag, }    = description
      ### TAINT not the real thing ###
      if tag? and 'cjk' in tag
        send [ 'tex', "{\\cjk\\cn{}#{glyph}}", ]
      else
        send [ '.', 'text', glyph, meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$split = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', 'text'
    [ type, name, text, meta, ] = event
    for glyph in MKNCR.chrs_from_text text
      send [ '.', Σ_glyph_description, glyph, meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$wrap = ( S ) ->
  return $ ( event, send ) =>
    return send event unless select event, '.', Σ_glyph_description
    [ type, name, glyph, meta, ] = event
    description = MKNCR.describe glyph
    send [ type, name, description, meta, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$unwrap = ( S ) ->
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
  ### TAINT which one should come first? ###
  pipeline = [
    @$split           S
    @$wrap            S
    # @$format_cjk      S
    @$escape_for_tex  S
    $ ( data ) -> urge '67201', data
    @$unwrap          S
    $ ( data ) -> help '67202', data
    ]
  return D.new_stream { pipeline, }

