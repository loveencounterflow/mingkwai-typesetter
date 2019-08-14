


############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/collect-glyph-descriptions'
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
MKNCR                     = require '../../../../mingkwai-ncr'
NUCW                      = require '../../../../ncr-unicode-cache-writer'
jr                        = JSON.stringify
get_cid                   = ( x ) -> x.codePointAt 0

#-----------------------------------------------------------------------------------------------------------
@cid_ranges = [
  # [ 0x0000, 0x4e10, ]
  [ 0x4da0, 0x4e10, ]
  [ ( get_cid '🉠' ), ( get_cid '🉥' ), ]
  [ ( get_cid '。' ), ( get_cid '。' ), ]
  ]

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@main_A = ->
  NUCW.read_isl ( error, isl ) =>
    return handler error if error?
    debug 'µ44322', isl
    for cid in [ first_cid .. last_cid ]
      glyph = String.fromCodePoint cid

  return

#-----------------------------------------------------------------------------------------------------------
@main_B = ->
  for cid_range in @cid_ranges
    [ first_cid
      last_cid  ] = cid_range
    for cid in [ first_cid .. last_cid ]
      glyph = String.fromCodePoint cid
      continue unless
      description     = MKNCR.describe glyph
      { uchr
        fncr
        rsg
        tag
        tex     }     = description
      is_cjk          = 'cjk' in tag
      is_ideograph    = is_cjk and 'ideograph' in tag
      tex_block       = tex?.block     ? null
      tex_cp          = tex?.codepoint ? null
      has_tex         = tex_block? and tex_block isnt '\\mktsRsgFb{}'
      continue unless is_cjk or has_tex
      # continue unless is_ideograph
      # debug 'µ55663', jr description
      debug 'µ55663', jr [ glyph, fncr, tex_block, tex_cp, ]
      # { block: tex_block, codepoint: tex_cp, }  = tex
  #.........................................................................................................
  return null




############################################################################################################
unless module.parent?
  @main_A()


