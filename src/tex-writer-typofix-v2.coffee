


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


#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( S ) =>
  #.........................................................................................................
  pipeline = [
    @_$f        S
    ]
  #.........................................................................................................
  return D.new_stream { pipeline, }

#-----------------------------------------------------------------------------------------------------------
@_$f = ( S ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '.', 'text'
      urge '12312', event
      return send event
      #.....................................................................................................
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      ### NB `meta[ 'typofix' ]` is currently only used by mingkwai-typesetter-jizura to signal portions of
      text where NCRs should appear verbatim ( when set to 'escape-ncrs'), rather than interpreted
      (where possible) as Unicode glyphs. We leave the implementation of that feature as an exercise for
      later, and simply emit a warning here in case `typofix_style` turns out to be anything but `basic`.
      ###
      typofix_style = meta[ 'typofix' ] ? 'basic'
      text          = @fix_typography_for_tex text, S.options, null, style
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@_$process_text = ( S ) ->
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    help '12313', event
    send event



