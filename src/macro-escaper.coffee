


############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/MACROS'
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
D                         = require 'pipedreams'
$                         = D.remit.bind D
# $async                    = D.remit_async.bind D
#...........................................................................................................
# Markdown_parser           = require 'markdown-it'
# # Html_parser               = ( require 'htmlparser2' ).Parser
# new_md_inline_plugin      = require 'markdown-it-regexp'
#...........................................................................................................
# HELPERS                   = require './HELPERS'
#...........................................................................................................
# misfit                    = Symbol 'misfit'
MKTS                      = require './main'
@cloak                    = ( require './cloak' ).new()
# hide                      = MKTS.hide.bind        MKTS
# copy                      = MKTS.MD_READER.copy.bind        MKTS
# stamp                     = MKTS.stamp.bind       MKTS
# select                    = MKTS.MD_READER.select.bind      MKTS
# is_hidden                 = MKTS.is_hidden.bind   MKTS
# is_stamped                = MKTS.is_stamped.bind  MKTS


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@initialize_state = ( state ) =>
  state[ 'MACRO_ESCAPER' ] =
    registry:   []
  return state

#-----------------------------------------------------------------------------------------------------------
@_match_first = ( patterns, text ) =>
  for pattern in patterns
    return R if ( R = text.match pattern )?
  return null

#-----------------------------------------------------------------------------------------------------------
@_register_content = ( S, kind, markup, raw, parsed = null ) =>
  registry  = S[ 'MACRO_ESCAPER' ][ 'registry' ]
  idx     = registry.length
  key     = "#{kind}#{idx}"
  registry.push { key, markup, raw, parsed, }
  return key

#-----------------------------------------------------------------------------------------------------------
@_retrieve_entry = ( S, id ) =>
  throw new Error "unknown ID #{rpr id}" unless ( R = S[ 'MACRO_ESCAPER' ][ 'registry' ][ id ] )?
  return R

#===========================================================================================================
# PATTERNS
#-----------------------------------------------------------------------------------------------------------
@PATTERNS = {}

#-----------------------------------------------------------------------------------------------------------
@html_comment_patterns = [
  ///                           # HTML comments...
    <!--                        # start with less-than, exclamation mark, double hyphen;
    ( [ \s\S ]*? )              # then: anything, not-greedy, until we hit upon
    -->                         # a double-slash, then greater-than.
    ///g                        # (NB: end-of-comment cannot be escaped, because HTML).
  ]

#-----------------------------------------------------------------------------------------------------------
@action_patterns = [
  ///                           # A silent or vocal action macro...
                                #
                                # Start Tag
                                # =========
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<\(                          # then: two left pointy brackets, then: left round bracket,
    ( [ . : ] )                 # then: a dot or a colon;
    (
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        > (?! > )               #   or: a RPB not followed by yet another RPB
      )*                        # repeated any number of times
    )
    >>                          # then: two RPBs...
                                #
                                # Content
                                # =========
                                # Empty content.
                                #
                                # Stop Tag
                                # =========
  () <<                         # (then: an empty group; see below), then: two left pointy brackets,
    ( (?: \2 \3 )? )            # then: optionally, whatever appeared in the start tag,
    \)>>                        # then: right round bracket, then: two RPBs.
  ///g
  ,                             #...........................................................................
  ///                           # Alternatively (non-empty content):
                                #
                                # Start Tag
                                # =========
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<\(                          # then: two left pointy brackets, then: left round bracket,
    ( [ . : ] )                 # then: a dot or a colon;
    (
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        > (?! > )               #   or: a RPB not followed by yet another RPB
      )*                        # repeated any number of times
    )
    >>                          # then: two RPBs...
                                #
                                # Content
                                # =========
    (
      (?:                       # ...followed by content, which is:
        \\<                |    #   or: an escaped left pointy bracket (LPB)
        [^ < ]             |    #   or: anything but a LPB
        < (?! < )               #   or: a LPB not followed by yet another LPB
        )*                      # repeated any number of times
      [^ \\ ]                   # then: a character other than a backslash,
      )
                                #
                                # Stop Tag
                                # =========
  <<                            # then: two left pointy brackets,
    ( (?: \2 \3 )? )            # then: optionally, whatever appeared in the start tag,
    \)>>                        # then: right round bracket, then: two RPBs.
  ///g
  ]

#-----------------------------------------------------------------------------------------------------------
@region_patterns = [
  ///                           # A region macro tag...
                                #
                                # Start Tag
                                # =========
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<                            # then: two left pointy brackets
  ( \( )                        # then: left round bracket,
    (                           #
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        > (?! > )               #   or: a RPB not followed by yet another RPB
      )*                        # repeated any number of times
    )
    ()                          # then: empty group for no markup here
    >>                          # then: two RPBs.
  ///g
  ,
  ///                           # Stop Tag
                                # ========
                                #
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<                            # then: two left pointy brackets
    ()                          # then: empty group for no markup here
    ( |                         #
      [^ . : \\ ]
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        > (?! > )               #   or: a RPB not followed by yet another RPB
      )*                        # repeated any number of times
    )
    ( \) )                      # a right round bracket;
    >>                          # then: two RPBs.
  ///g
  ]

# debug '234652', @action_patterns
# debug "abc<<(:js>>4 + 3<<:js)>>def".match @action_patterns[ 0 ]
# process.exit()

#-----------------------------------------------------------------------------------------------------------
@bracketed_raw_patterns = [
  ///                           # A bracketed raw macro
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<(<)                         # then: three left pointy brackets,
    (
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        >{1,2} (?! > )          #   or: one or two RPBs not followed by yet another RPB
      )*                        # repeated any number of times
    )
    >>>                         # then: three RPBs.
  ///g
  ]

# #-----------------------------------------------------------------------------------------------------------
# @raw_heredoc_pattern  = ///
#   ( ^ | [^\\] ) <<! raw: ( [^\s>]* )>> ( .*? ) \2
#   ///g

#-----------------------------------------------------------------------------------------------------------
@command_and_value_patterns = [
  ///                           # A command macro
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<                            # then: two left pointy brackets,
    ( [ ! $ ] )                 # then: an exclamation mark or a dollar sign,
    (
      (?:                       # then:
        \\>                |    #   or: an escaped right pointy bracket (RPB)
        [^ > ]             |    #   or: anything but a RPB
        > (?! > )               #   or: a RPB not followed by yet another RPB
      )*                        # repeated any number of times
    )
    >>                          # then: two RPBs.
  ///g
  ]

#-----------------------------------------------------------------------------------------------------------
### NB The end command macro looks like any other command except we can detect it with a much simpler
RegEx; we want to do that so we can, as a first processing step, remove it and any material that appears
after it, thereby inhibiting any processing of those portions. ###
@end_command_patterns = [
  ///                           # Then end command macro
  ( ^ |                         # starts either at the first chr
    ^ [ \s\S ]+? [^ \\ ] )      # or a minimal number of chrs whose last one is not a backslash
  <<!end>>                      # then: the `<<!end>>` literal.
  ///                           # NB that this pattern is not global.
  ]

#-----------------------------------------------------------------------------------------------------------
@illegal_patterns = [
  ///                           # After applying all other macro patterns, treat as error: pattern that
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  ( << | >> )                   # then: either two left or two right pointy brackets.
  ///g
  ]

#===========================================================================================================
# ESCAPING
#-----------------------------------------------------------------------------------------------------------
@escape = ( S, text ) =>
  # debug '©II6XI', rpr text
  [ R, discard_count, ] = @escape.truncate_text_at_end_command_macro S, text
  whisper "detected <<!end>> macro; discarding approx. #{discard_count} characters" if discard_count > 0
  R = @escape.escape_chrs               S, R
  R = @escape.html_comments             S, R
  R = @escape.bracketed_raw_macros      S, R
  R = @escape.action_macros             S, R
  R = @escape.region_macros             S, R
  R = @escape.command_and_value_macros  S, R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.truncate_text_at_end_command_macro = ( S, text ) =>
  return [ text, 0, ] unless ( match = @_match_first @end_command_patterns, text )?
  R = match[ 1 ]
  # urge '©ΣΩΗΔΨ', rpr R
  return [ R, text.length - R.length, ]

#-----------------------------------------------------------------------------------------------------------
@escape.escape_chrs                 = ( S, text ) => @cloak.backslashed.hide  @cloak.hide               text
@escape.unescape_escape_chrs        = ( S, text ) => @cloak.reveal            @cloak.backslashed.reveal text
@escape.remove_escaping_backslashes = ( S, text ) => @cloak.backslashed.remove text

#-----------------------------------------------------------------------------------------------------------
@escape.html_comments = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @html_comment_patterns
    R = R.replace pattern, ( _, content ) =>
      key = @_register_content S, 'comment', null, content, content.trim()
      return "\x15#{key}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.bracketed_raw_macros = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @bracketed_raw_patterns
    R = R.replace pattern, ( _, previous_chr, markup, content ) =>
      id = @_register_content S, 'raw', markup, content
      return "#{previous_chr}\x15#{id}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.action_macros = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @action_patterns
    R = R.replace pattern, ( _, previous_chr, markup, identifier, content, stopper ) =>
      # debug '©ΛΨ actions', ( rpr text ), [ previous_chr, markup, identifier, content, stopper, ]
      mode      = if markup is '.' then 'silent' else 'vocal'
      language  = identifier
      language  = 'coffee' if language is ''
      ### TAINT not using arguments peoperly ###
      id        = @_register_content S, 'action', [ mode, language, ], content
      return "#{previous_chr}\x15#{id}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.region_macros = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @region_patterns
    R = R.replace pattern, ( _, previous_chr, start_markup, identifier, stop_markup ) =>
      # debug '©ΛΨ regions', ( rpr text ), [ previous_chr, markup, identifier, content, stopper, ]
      markup  = if start_markup.length is 0 then stop_markup else start_markup
      id      = @_register_content S, 'region', markup, identifier
      return "#{previous_chr}\x15#{id}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.command_and_value_macros = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @command_and_value_patterns
    R = R.replace pattern, ( _, previous_chr, markup, content ) =>
      kind            = if markup is '!' then 'command' else 'value'
      key             = @_register_content S, kind, markup, content, null
      return "#{previous_chr}\x15#{key}\x13"
  #.........................................................................................................
  return R


#===========================================================================================================
# EXPANDING
#-----------------------------------------------------------------------------------------------------------
@raw_id_pattern = ///
  \x15 raw ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@html_comment_id_pattern = ///
  \x15 comment ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@action_id_pattern = ///
  \x15 action ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@region_id_pattern = ///
  \x15 region ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@command_and_value_id_pattern = ///
  \x15 (?: command | value ) ( [ 0-9 ]+ ) \x13
  ///g


#===========================================================================================================
# EXPANDERS
#-----------------------------------------------------------------------------------------------------------
@$expand = ( S ) ->
  pipeline = [
    @$expand.$command_and_value_macros  S
    @$expand.$region_macros             S
    @$expand.$action_macros             S
    @$expand.$raw_macros                S
    @$expand.$html_comments             S
    @$expand.$escape_chrs               S
    # @$expand.$escape_illegals           S
    ]
  #.......................................................................................................
  settings =
    # inputs:
    #   mktscript:        mktscript_in
    # outputs:
    #   mktscript:        mktscript_out
    S:                S
  #.......................................................................................................
  return D.TEE.from_pipeline pipeline, settings

#-----------------------------------------------------------------------------------------------------------
@$expand.$html_comments = ( S ) =>
  return @_get_expander S, @html_comment_id_pattern, ( meta, entry ) =>
    content       = entry[ 'raw' ]
    return [ '.', 'comment', content, ( MKTS.MD_READER.copy meta ), ]

#-----------------------------------------------------------------------------------------------------------
@$expand.$raw_macros  = ( S ) =>
  return @_get_expander S, @raw_id_pattern, ( meta, entry ) =>
    content       = entry[ 'raw' ]
    return [ '.', 'raw', content, ( MKTS.MD_READER.copy meta ), ]

#-----------------------------------------------------------------------------------------------------------
@$expand.$action_macros  = ( S ) =>
  return @_get_expander S, @action_id_pattern, ( meta, entry ) =>
    [ mode
      language ]  = entry[ 'markup' ]
    content       = entry[ 'raw' ]
    return [ '.', 'action', content, ( MKTS.MD_READER.copy meta, { mode, language, } ), ]

#-----------------------------------------------------------------------------------------------------------
@$expand.$region_macros = ( S ) =>
  return @_get_expander S, @region_id_pattern, ( meta, entry ) =>
    { raw
      markup }    = entry
    return [ markup, raw, null, ( MKTS.MD_READER.copy meta ), ]

#-----------------------------------------------------------------------------------------------------------
@$expand.$command_and_value_macros = ( S ) =>
  return @_get_expander S, @command_and_value_id_pattern, ( meta, entry ) =>
    { raw
      markup }    = entry
    macro_type    = if markup is '!' then 'command' else 'value'
    return [ '.', macro_type, raw, ( MKTS.MD_READER.copy meta ), ]

#-----------------------------------------------------------------------------------------------------------
@$expand.$escape_chrs = ( S ) =>
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'text'
      [ type, name, text, meta, ] = event
      # debug '9573485', rpr text
      # debug '9573485', rpr @escape.unescape_escape_chrs S, text
      send [ type, name, ( @escape.unescape_escape_chrs S, text ), meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$expand.$remove_backslashes = ( S ) =>
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'text'
      [ type, name, text, meta, ] = event
      debug '83457', rpr text
      debug '83457', rpr @escape.remove_escaping_backslashes S, text
      send [ type, name, ( @escape.remove_escaping_backslashes S, text ), meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$expand.$escape_illegals = ( S ) =>
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'text'
      [ type, name, text, meta, ] = event
      debug '©38889', rpr text
      #.....................................................................................................
      for pattern in @illegal_patterns
        stretches = []
        #...................................................................................................
        for raw_stretch, idx in text.split pattern
          if ( idx % 3 ) is 1 then  stretches[ stretches.length - 1 ] += raw_stretch
          else                      stretches.push raw_stretch
        #...................................................................................................
        is_plain  = no
        for stretch in stretches
          is_plain = not is_plain
          unless is_plain
            # debug '©10012', stretch
            { line_nr }   = meta
            error_message = "illegal macro pattern on line #{line_nr}: #{rpr stretch}"
            send [ '.', 'warning', error_message, ( MKTS.MD_READER.copy meta ), ]
          else
            send [ type, name, stretch, ( MKTS.MD_READER.copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event


#===========================================================================================================
# GENERIC EXPANDER
#-----------------------------------------------------------------------------------------------------------
@_get_expander = ( S, pattern, method ) =>
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.MD_READER.select event, '.', 'text'
      is_plain                    = no
      [ type, name, text, meta, ] = event
      for stretch in text.split pattern
        is_plain = not is_plain
        unless is_plain
          id                  = parseInt stretch, 10
          entry               = @_retrieve_entry S, id
          send method meta, entry
        else
          send [ type, name, stretch, ( MKTS.MD_READER.copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event





