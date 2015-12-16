



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

# #-----------------------------------------------------------------------------------------------------------
# @_get_cjk_interchr_glue = ( options ) => options[ 'tex' ]?[ 'cjk-interchr-glue' ] ? '\ue080'


#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( text, options, send = null ) =>
  ### An improved version of `XELATEX.tag_from_chr` ###
  ### TAINT should accept settings, fall back to `require`d `options.coffee` ###
  glyph_styles                  = options[ 'tex' ]?[ 'glyph-styles'             ] ? {}
  ### Legacy mode: force one command per non-latin character. This is OK for Chinese texts,
  but a bad idea for all other scripts; in the future, MKTS's TeX formatting commands like
  `\cn{}` will be rewritten to make this setting superfluous. ###
  advance_each_chr              = options[ 'tex' ]?[ 'advance-each-chr'         ] ? no
  tex_command_by_rsgs           = options[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
  last_command                  = null
  R                             = []
  chunk                         = []
  last_rsg                      = null
  remark                        = if send? then @_get_remark() else null
  this_is_cjk                   = no
  last_was_cjk                  = no
  this_is_whitespace            = no
  last_was_whitespace           = no
  whitespace_cache              = []
  replacement                   = null
  has_cjk_glue                  = no
  #.........................................................................................................
  unless tex_command_by_rsgs?
    throw new Error "need setting 'tex-command-by-rsgs'"
  #.........................................................................................................
  advance_whitespace = =>
    chunk.splice chunk.length, 0, whitespace_cache...
    whitespace_cache.length = 0
  #.........................................................................................................
  advance = =>
    if chunk.length > 0
      # debug '©zDJqU', last_command, JSON.stringify chunk.join '.'
      R.push chunk.join ''
      R.push "}" unless last_command in [ null, 'latin', 'cn', ]
    chunk.length = 0
    return null
  #.........................................................................................................
  for chr in XNCHR.chrs_from_text text
    ### Treat whitespace specially ###
    if ( this_is_whitespace = chr in [ '\x20', '\n', '\r', '\t', ] )
      whitespace_cache.push chr
      continue
    #.......................................................................................................
    { chr
      uchr
      fncr
      rsg   }   = XNCHR.analyze chr
    #.......................................................................................................
    switch rsg
      when 'jzr-fig'  then chr = uchr
      when 'u-pua'    then rsg = 'jzr-fig'
      when 'u-latn'   then chr = @escape_for_tex chr
    #.......................................................................................................
    this_is_cjk = @is_cjk_rsg rsg, options
    if ( not last_was_cjk ) and ( this_is_cjk )
      advance_whitespace()
      # advance()
      chunk.push "{\\cjk{}"
    else if ( last_was_cjk ) and ( not this_is_cjk )
      chunk.push "}"
      advance_whitespace()
    else if whitespace_cache.length > 0
      advance_whitespace()
    last_was_cjk = this_is_cjk
    #.......................................................................................................
    ### TAINT if chr is a TeX active ASCII chr like `$`, `#`, then it will be escaped at this point
    and no more match entries in `glyph_styles` ###
    # debug '©53938-1', chr, rsg, tex_command_by_rsgs[ rsg ]
    if ( replacement = glyph_styles[ chr ] )?
      advance()
      ### TAINT duplication from below: ###
      command   = tex_command_by_rsgs[ 'fallback' ] ? null
      rpl       = []
      rpl.push '\\cjkgGlue' unless has_cjk_glue
      rpl.push '{'
      rpl_push  = replacement[ 'push'   ] ? null
      rpl_raise = replacement[ 'raise'  ] ? null
      rpl_chr   = replacement[ 'glyph'  ] ? chr
      rpl_cmd   = replacement[ 'cmd'    ] ? command
      rpl_cmd   = null if rpl_cmd is 'cn'
      if      rpl_push? and rpl_raise?  then rpl.push "\\tfPushRaise{#{rpl_push}}{#{rpl_raise}}"
      else if rpl_push?                 then rpl.push "\\tfPush{#{rpl_push}}"
      else if               rpl_raise?  then rpl.push "\\tfRaise{#{rpl_raise}}"
      if rpl_cmd?                       then rpl.push "\\#{rpl_cmd}{}"
      rpl.push rpl_chr
      rpl.push '\\cjkgGlue}'
      R.push rpl.join ''
      has_cjk_glue  = yes
      last_command  = null
      continue
    #.......................................................................................................
    else
      has_cjk_glue = no
    #.......................................................................................................
    unless ( command = tex_command_by_rsgs[ rsg ] )?
      command = tex_command_by_rsgs[ 'fallback' ] ? null
      message = "unknown RSG #{rpr rsg}: #{fncr} #{chr} (using fallback #{rpr command})"
      if send? then send remark 'warn', message, {}
      else          warn message
    #.......................................................................................................
    unless command?
      advance()
      chunk.push chr
      continue
    #.......................................................................................................
    # debug '©53938-2', chr, rsg, tex_command_by_rsgs[ rsg ]
    if advance_each_chr or last_command isnt command
      advance()
      last_command = command
      ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
      unless command in [ 'latin', 'cn', ]
        # command = 'cn'
        chunk.push "{\\#{command}{}"
      # chunk.push "{\\#{command}{}" unless command is 'latin'
      ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
    #.......................................................................................................
    chunk.push chr
  #.........................................................................................................
  chunk.push "}" if this_is_cjk
  advance_whitespace() if whitespace_cache.length > 0
  advance()
  return R.join ''

