



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/MD-READER/TYPOFIX'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#-----------------------------------------------------------------------------------------------------------
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
#...........................................................................................................
# MKTS                      = require './main'

#-----------------------------------------------------------------------------------------------------------
@replacements =
  # Simple typographyc replacements
  #
  # (c) (C) → ©
  # (tm) (TM) → ™
  # (r) (R) → ®
  # +- → ±
  # (p) (P) -> §
  # ... → … (also ?.... → ?.., !.... → !..)
  # ???????? → ???, !!!!! → !!!, `,,` → `,`
  # -- → &ndash;, --- → &mdash;
  'copyright': [ /// \( c \) ///gi,                                       '©',      ]
  'ellipsis':  [ /// ( ^ | [ ^ . ] ) [.]{3} ( $ | [ ^ . ] ) ///gi,        '$1…$2',  ]


#-----------------------------------------------------------------------------------------------------------
@rewrite = ( S, text ) ->
  debug '0982', rpr text
  R = text
  for name, [ matchers, replacement, ] of @replacements
    matchers = [ matchers, ] unless CND.isa_list matchers
    for matcher in matchers
      R = R.replace matcher, replacement
  return R






