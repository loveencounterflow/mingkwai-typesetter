


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


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$escape_for_tex = ( S ) ->
  ### TAINT should preserve raw text from before replacements ###
  return $ ( event, send ) =>
    return send event unless select event, '.', 'text'
    [ type, name, raw_text, meta, ] = event
    text = raw_text
    for [ pattern, replacement, ] in @$escape_for_tex._replacements
      text = text.replace pattern, replacement
    send [ type, name, text, meta, ]

#-----------------------------------------------------------------------------------------------------------
@$escape_for_tex._replacements = [
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


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( S ) ->
  ### TAINT which one should come first? ###
  pipeline = [
    # @$split           S
    @$format_cjk      S
    @$escape_for_tex  S
    ]
  return D.new_stream { pipeline, }

