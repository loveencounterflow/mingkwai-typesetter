

'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/PLUGINS/SLASHES-AS-TAGS'
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
MD_READER                 = require '../../md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
jr                        = JSON.stringify
#...........................................................................................................
### plugins must use pipestreams ###
PS                        = require 'pipestreams'
{ $, $async, }            = PS
TYPOFIX                   = require '../../tex-writer-typofix'

#-----------------------------------------------------------------------------------------------------------
@$tag_tag = ( S, settings ) ->
  ### TAINT can't nest tags ###
  tagname = "#{settings.prefix}-tag"
  within  = false
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', tagname
      within = true
      send stamp event
      send [ 'tex', '{\\mktsStyleCode{}', ]
    #.......................................................................................................
    else if select event, ')', tagname
      within = false
      send stamp event
      send [ 'tex', '}', ]
    #.......................................................................................................
    else if within and select event, '.', 'text'
      [ type, name, text, meta, ] = event
      # send stamp event
      send [ 'tex', '{\\mktsFontfileAsanamath{}⟪}', ]
      # send [ 'tex', '{\\mktsFontfileHanamina{}☰}', ]
      # text = TYPOFIX.escape_tex_specials "[#{text}]"
      text = TYPOFIX.escape_tex_specials "#{text}"
      send [ 'tex', text, ]
      send [ 'tex', '{\\mktsFontfileAsanamath{}⟫}', ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$tagsample = ( S, settings ) ->
  tagsample_name  = "#{settings.prefix}-tagsample"
  tag_name        = "#{settings.prefix}-tag"
  within  = false
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '(', tagsample_name
      within = true
      send stamp event
      # send [ 'tex', '{\\mktsStyleCode{}', ]
    #.......................................................................................................
    else if select event, ')', tagsample_name
      within = false
      send stamp event
      # send [ 'tex', '}', ]
    #.......................................................................................................
    else if within and select event, '.', 'text'
      [ type, name, text, meta, ] = event
      parts = text.split '::'
      #.....................................................................................................
      unless ( parts.length is 3 ) and ( parts.every ( x ) -> x.length > 0 )
        throw new Error "^slashes_as_tags@3338^ not a valid tagsample line: #{rpr text}"
      [ tag, fontnick, glyphs, ] = parts
      #.....................................................................................................
      tag       = tag.trim()
      fontnick  = fontnick.trim()
      glyphs    = glyphs.trim()
      #.....................................................................................................
      mktscript   = ''
      mktscript  += "<noindent/>"
      mktscript  += "<#{tag_name}>#{tag}</#{tag_name}><tab/>"
      mktscript  += "`#{fontnick}`<tab/>"
      mktscript  += "<fontnick>#{fontnick}</fontnick><tab/>"
      mktscript  += "<font name=#{fontnick}>音言主文馬</font>&nl;"
      # mktscript  += "<noindent/><#{tag_name}>#{tag}</#{tag_name}><tab/>`#{fontnick}`<tab/>`#{fontnick}`<tab/><font name=#{fontnick}>音言主文馬</font>&nl;"
      send [ '.', 'mktscript', mktscript, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$slashes_as_tags = ( S, settings ) ->
  pattern = /// \[\/ (?<tag> \S+ ) \/\] ///g
  return $ ( event, send ) =>
    if ( select event, '.', 'text' )
      [ type, name, text, meta, ] = event
      is_tag                      = true
      for part in text.split pattern
        is_tag = not is_tag
        #...................................................................................................
        unless is_tag
          send [ '.', 'text', part, ( copy meta ), ]
          continue
        send [ 'tex', '{\\mktsStyleCode{}', ]
        send [ '.', 'text', part, ( copy meta ), ]
        send [ 'tex', '}', ]
    else
      send event
    return null

#-----------------------------------------------------------------------------------------------------------
@main = ( S, settings ) ->
  pipeline = []
  pipeline.push @$tag_tag    S, settings
  pipeline.push @$tagsample  S, settings
  # pipeline.push @$slashes_as_tags    S, settings
  return PS.pull pipeline...



