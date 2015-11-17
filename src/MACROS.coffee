


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
MKTS                      = require './MKTS'
# hide                      = MKTS.hide.bind        MKTS
# copy                      = MKTS.copy.bind        MKTS
# stamp                     = MKTS.stamp.bind       MKTS
# select                    = MKTS.select.bind      MKTS
# is_hidden                 = MKTS.is_hidden.bind   MKTS
# is_stamped                = MKTS.is_stamped.bind  MKTS



#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@initialize_state = ( state ) =>
  state[ 'MACROS' ] =
    registry:   []
  return state

#-----------------------------------------------------------------------------------------------------------
@_match_first = ( patterns, text ) =>
  for pattern in patterns
    return R if ( R = text.match pattern )?
  return null

#-----------------------------------------------------------------------------------------------------------
@_register_content = ( S, kind, markup, raw, parsed = null ) =>
  registry  = S[ 'MACROS' ][ 'registry' ]
  idx     = registry.length
  key     = "#{kind}#{idx}"
  registry.push { key, markup, raw, parsed, }
  return key

#-----------------------------------------------------------------------------------------------------------
@_retrieve_entry = ( S, id ) =>
  throw new Error "unknown ID #{rpr id}" unless ( R = S[ 'MACROS' ][ 'registry' ][ id ] )?
  return R

#===========================================================================================================
# PATTERNS
#-----------------------------------------------------------------------------------------------------------
@PATTERNS = {}

#-----------------------------------------------------------------------------------------------------------
@html_comment_patterns = [
  ///                           # HTML comments...
    ( ^ | [^\\] )               # may be escaped with a backslash (NB: unlike as in HTML proper);
    <!--                        # the start with less-than, exclamation mark, double hyphen;
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
    ( [ . : ]                   # then: a dot or a colon;
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
      )*                        # repeated any number of times
      )
                                #
                                # Stop Tag
                                # =========
  <<                            # then: two left pointy brackets,
    ( \2 ? )                    # then: optionally, whatever appeared in the start tag,
    \)>>                        # then: right round bracket, then: two RPBs.
  ///g
  ]

#-----------------------------------------------------------------------------------------------------------
@region_patterns = [
  ///                           # A region macro...
                                #
                                # Start Tag
                                # =========
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  <<\(                          # then: two left pointy brackets, then: left round bracket,
    (                           #
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
      )*                        # repeated any number of times
      )
                                #
                                # Stop Tag
                                # =========
  <<                            # then: two left pointy brackets,
    ( \2 ? )                    # then: optionally, whatever appeared in the start tag,
    \)>>                        # then: right round bracket, then: two RPBs.
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
    ^ [ \s\S ]+ [^ \\ ] )       # or a number of chrs whose last one is not a backslash
  <<!end>>                      # then: the `<<!end>>` literal.
  ///                           # NB that this pattern is not global.
  ]

#-----------------------------------------------------------------------------------------------------------
@illegal_patterns = [
  ///                           # After applying all other macro patterns, treat as error: pattern that
  ( ^ | [^ \\ ] )               # starts either at the first chr or a chr other than backslash
  ( << | >> )                   # then: either two left or two right pointy brackets
  ( [ \s\S ] { 0, 10 } )        # followed by any characters (matched for diagnostic messages).
                                # In other words, you must not have two consecutive unescaped left pointy
                                # brackets in the MD source, even where those LPBs do not form a macro
                                # pattern.
  ///g
  ]

#===========================================================================================================
# ESCAPING
#-----------------------------------------------------------------------------------------------------------
@escape = ( S, text ) =>
  # debug '©II6XI', rpr text
  [ R, discard_count, ] = @escape.truncate_text_at_end_command_macro S, text
  whisper "detected <<!end>> macro; discarding approx. #{discard_count} characters" if discard_count > 0
  R = @escape.escape_chrs              S, R
  R = @escape.html_comments            S, R
  R = @escape.bracketed_raw_macros     S, R
  R = @escape.action_macros            S, R
  R = @escape.region_macros            S, R
  R = @escape.command_and_value_macros S, R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.truncate_text_at_end_command_macro = ( S, text ) =>
  return [ text, 0, ] unless ( match = @_match_first @end_command_patterns, text )?
  R = match[ 1 ]
  return [ R, text.length - R.length, ]

#-----------------------------------------------------------------------------------------------------------
@escape.escape_chrs = ( S, text ) =>
  R = text
  R = R.replace /\x10/g, '\x10A'
  R = R.replace /\x15/g, '\x10X'
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.unescape_escape_chrs = ( S, text ) =>
  R = text
  R = R.replace /\x10X/g, '\x15'
  R = R.replace /\x10A/g, '\x10'
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.html_comments = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @html_comment_patterns
    R = R.replace pattern, ( _, previous_chr, content ) =>
      key = @_register_content S, 'comment', null, content, content.trim()
      return "#{previous_chr}\x15#{key}\x13"
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
    R = R.replace pattern, ( _, previous_chr, starter, content, stopper ) =>
      mode      = starter[ 0 ]
      mode      = if mode is '.' then 'silent' else 'vocal'
      language  = starter[ 1 .. ]
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
    R = R.replace pattern, ( _, previous_chr, starter, content, stopper ) =>
      ### TAINT not using arguments peoperly ###
      starter_rpr = "<<(#{starter}>>"
      stopper_rpr = "<<#{stopper})>>"
      starter_id  = @_register_content S, 'region', starter, starter_rpr
      stopper_id  = @_register_content S, 'region', starter, stopper_rpr
      return "#{previous_chr}\x15#{starter_id}\x13#{content}\x15#{stopper_id}\x13"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@escape.command_and_value_macros = ( S, text ) =>
  R = text
  #.........................................................................................................
  for pattern in @command_and_value_patterns
    R = R.replace pattern, ( _, previous_chr, markup, content ) =>
      kind            = if markup is '!' then 'command' else 'value'
      parsed_content  = '???'
      key             = @_register_content S, kind, markup, content, parsed_content
      return "#{previous_chr}\x15#{key}\x13"
  #.........................................................................................................
  return R


#===========================================================================================================
# EXPANDING
#-----------------------------------------------------------------------------------------------------------
@raw_id_pattern       = ///
  \x15 raw ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@html_comment_id_pattern = ///
  \x15 comment ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@do_id_pattern   = ///
  \x15 do ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@action_id_pattern   = ///
  \x15 action ( [ 0-9 ]+ ) \x13
  ///g

#-----------------------------------------------------------------------------------------------------------
@$expand_html_comments = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if MKTS.select event, '.', [ 'text', 'code', ]
      is_comment                  = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @html_comment_id_pattern
        is_comment = not is_comment
        if is_comment
          id      = parseInt stretch, 10
          entry   = @_retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '.', 'comment', content, ( MKTS.copy meta ), ]
        else
          send [ type, name, stretch, ( MKTS.copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$expand_actions = ( S ) =>
  ### TAINT code duplication ###
  track = MKTS.TRACKER.new_tracker '(code)', '{code}'
  return $ ( event, send ) =>
    within_code = track.within '(code)', '{code}'
    track event
    #.......................................................................................................
    ### TAINT wrong selector ###
    if MKTS.select event, '.', [ 'text', 'code', 'comment', ]
      is_command                  = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @action_id_pattern
        is_command = not is_command
        if is_command
          id      = parseInt stretch, 10
          entry   = @_retrieve_entry S, id
          if within_code
            content = entry[ 'raw' ]
            send [ '.', 'text', content, ( MKTS.copy meta ), ]
          else
            content = entry[ 'parsed' ]
            ### should never happen: ###
            debug '©ΘΔΩΕΥ', rpr content
            debug '©ΘΔΩΕΥ', rpr stretch
            throw new Error "not registered correctly: #{rpr stretch}"  unless CND.isa_list content
            [ left_fence, action_name, right_fence, ] = content
            fence = left_fence ? right_fence
            send [ fence, action_name, null, ( MKTS.copy meta ), ]
        else
          send [ type, name, stretch, ( MKTS.copy meta ), ] unless stretch.length is 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$expand_raw_spans  = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if MKTS.select event, '.', [ 'text', 'code', 'comment', ]
      is_raw                      = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @raw_id_pattern
        is_raw = not is_raw
        if is_raw
          id      = parseInt stretch, 10
          entry   = @_retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '.', 'raw', content, ( MKTS.copy meta ), ]
        else
          send [ type, name, stretch, ( MKTS.copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$expand_do_spans  = ( S ) =>
  ### TAINT code duplication ###
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT wrong selector ###
    if MKTS.select event, '.', [ 'text', 'code', 'comment', ]
      is_do                       = yes
      [ type, name, text, meta, ] = event
      for stretch in text.split @do_id_pattern
        is_do = not is_do
        if is_do
          id      = parseInt stretch, 10
          entry   = @_retrieve_entry S, id
          content = entry[ 'raw' ]
          send [ '!', 'do', content, ( MKTS.copy meta ), ]
        else
          send [ type, name, stretch, ( MKTS.copy meta ), ]
    #.......................................................................................................
    else
      send event

