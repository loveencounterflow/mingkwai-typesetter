


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
D                         = require 'pipedreams'
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

