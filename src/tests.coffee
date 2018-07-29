



############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/tests'
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
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
after                     = suspend.after
# eventually                = suspend.eventually
### TAINT experimentally using `later` in place of `setImmediate` ###
later                     = suspend.immediately
#...........................................................................................................
test                      = require 'guy-test'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
### TAINT to be replaced by global `MK.TS`: ###
MKTS                      = require './main'

############################################################################################################
### This is a mock for the `MK` global normally instantiated by `mingkwai/lib/main.js`. ###
unless global.MK?
  require '../../mingkwai'
  # CND.dir MK
  # CND.dir MK.TS
  # global.MK                 = {}
  # global.MK.TS              = require './main'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
show_events = ( probe, events ) ->
  whisper probe
  echo "["
  for event in events
    echo "    #{JSON.stringify event}"
  echo "    ]"

#-----------------------------------------------------------------------------------------------------------
copy_regex_non_global = ( re ) ->
  flags = ( if re.ignoreCase then 'i' else '' ) + \
          ( if re.multiline  then 'm' else '' ) +
          ( if re.sticky     then 'y' else '' )
  return new RegExp re.source, flags

#-----------------------------------------------------------------------------------------------------------
list_from_match = ( match ) ->
  return null unless match?
  R = Array.from match
  R.splice 0, 1
  return R

#-----------------------------------------------------------------------------------------------------------
match_first = ( patterns, probe ) ->
  for pattern in patterns
    return R if ( R = probe.match pattern )?
  return null

#-----------------------------------------------------------------------------------------------------------
nice_text_rpr = ( text ) ->
  ### Ad-hoc method to print out text in a readable, CoffeeScript-compatible, triple-quoted way. Line breaks
  (`\\n`) will be shown as line breaks, so texts should not be as spaghettified as they appear with
  JSON.stringify (the last line break of a string is, however, always shown in its symbolic form so it
  won't get swallowed by the CoffeeScript parser). Code points below U+0020 (space) are shown as
  `\\x00`-style escapes, taken up less space than `\u0000` escapes while keeping things explicit. All
  double quotes will be prepended with a backslash. ###
  R = text
  R = R.replace /[\x00-\x09\x0b-\x19]/g, ( $0 ) ->
    cid_hex = ( $0.codePointAt 0 ).toString 16
    cid_hex = '0' + cid_hex if cid_hex.length is 1
    return "\\x#{cid_hex}"
  R = R.replace /"/g, '\\"'
  R = R.replace /\n$/g, '\\n'
  R = '\n"""' + R + '"""'
  return R

#-----------------------------------------------------------------------------------------------------------
@call_transform = ( stream, transform, handler ) ->
  ### Given a `stream`, `transform` and a callback `handler`, pipe stream into transform, `D.$collect` all
  results into a list, and call handler with that list as second argument. The callback is mandatory even
  if the stream is synchronous because it may be paused, in which case you'll want to resume it at a
  convenient point in time. ###
  throw new Error "expected 2 or 3 arguments, got #{arity}" unless 2 <= ( arity = arguments.length ) <= 3
  stream
    .pipe transform()
    .pipe @$collect ( result, send ) =>
      return handler null, result
  return null

#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.action_patterns match action macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["<<(.>><<)>>",[".","","",""]]
    ["<<(.>>xxx<<)>>",[".","","xxx",""]]
    ["<<(.>>some code<<)>>",[".","","some code",""]]
    ["abc<<(.>>4 + 3<<)>>def",[".","","4 + 3",""]]
    ["<<(:>><<)>>",[":","","",""]]
    ["<<(:>>xxx<<)>>",[":","","xxx",""]]
    ["<<(:>>some code<<)>>",[":","","some code",""]]
    ["abc<<(:>>4 + 3<<)>>def",[":","","4 + 3",""]]
    ["abc<<(:>>bitfield \\>> 1 <<)>>def",[":","","bitfield \\>> 1 ",""]]
    ["abc<<(:>>bitfield >\\> 1 <<)>>def",[":","","bitfield >\\> 1 ",""]]
    ["abc<<(:js>>4 + 3<<)>>def",[":","js","4 + 3",""]]
    ["abc<<(.js>>4 + 3<<)>>def",[".","js","4 + 3",""]]
    ["abc<<(:js>>4 + 3<<:js)>>def",[":","js","4 + 3",":js"]]
    ["abc<<(.js>>4 + 3<<.js)>>def",[".","js","4 + 3",".js"]]
    ["abc<<(:js>>4 + 3<<:)>>def",null]
    ["abc<<(.js>>4 + 3<<.)>>def",null]
    ]
  patterns = ( copy_regex_non_global pattern for pattern in MKTS.MACRO_ESCAPER.action_patterns )
  for [ probe, matcher, ] in probes_and_matchers
    result = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.region_patterns match region macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["<<(>><<)>>",["(","",""]]
    ["<<(bold>><<)>>",["(","bold",""]]
    ["<<(bold>><<bold)>>",["(","bold",""]]
    ["<<(foo>><<bar)>>",["(","foo",""]]
    ["yadda <<(foo>>grom<<bar)>> blah <<)>>",["(","foo",""]]
    ["yadda <<bar)>> blah <<)>>",["","bar",")"]]
    ]
  patterns = ( copy_regex_non_global pattern for pattern in MKTS.MACRO_ESCAPER.region_patterns )
  for [ probe, matcher, ] in probes_and_matchers
    result = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.bracketed_raw_patterns matches raw macro" ] = ( T, done ) ->
  probes_and_matchers = [
    ["<<<...raw material...>>>",["<","...raw material..."]]
    ["<<<...raw material...>>>\nxxx",["<","...raw material..."]]
    ["<<(.>>some code<<)>>",null]
    ["<<<>>>",["<",""]]
    ["abcdef<<<\\XeLaTeX{}>>>ghijklm",[ '<', '\u001088\u0011eLaTeX{}' ]]
    ["abcdef<<<123\\>>>0>>>ghijklm",[ '<', '123\u001062\u0011>>0' ]]
    ["abcdef\\<<<123>>>ghijklm",null]
    ["abcdef<\\<<123>>>ghijklm",null]
    ["abcdef<<\\<123>>>ghijklm",null]
    ["abcdef<<<123>>\\>ghijklm",null]
    ]
  patterns = ( copy_regex_non_global pattern for pattern in MKTS.MACRO_ESCAPER.bracketed_raw_patterns )
  for [ probe, matcher, ] in probes_and_matchers
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape.escape_chrs S, probe
    result  = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.command_and_value_patterns matches command macro" ] = ( T, done ) ->
  probes_and_matchers = [
    ["<<!>>",["!",""]]
    ["<<!name>>",["!","name"]]
    ["abc<<!name>>def",["!","name"]]
    ["abc<<!n>me>>def",["!","n>me"]]
    ["abc<<!n>\\>me>>def",[ '!', 'n>\u001062\u0011me' ]]
    ["abc<<!n\\>me>>def",[ '!', 'n\u001062\u0011me' ]]
    ["abc\\<<!nme>>def",null]
    ["<<$>>",["$",""]]
    ["<<$name>>",["$","name"]]
    ["abc<<$name>>def",["$","name"]]
    ["abc<<$n>me>>def",["$","n>me"]]
    ["abc<<$n>\\>me>>def",[ '$', 'n>\u001062\u0011me' ]]
    ["abc<<$n\\>me>>def",[ '$', 'n\u001062\u0011me' ]]
    ["abc\\<<$nme>>def",null]
    ]
  patterns = ( copy_regex_non_global pattern for pattern in MKTS.MACRO_ESCAPER.command_and_value_patterns )
  for [ probe, matcher, ] in probes_and_matchers
    S           = MKTS.MACRO_ESCAPER.initialize_state {}
    probe       = MKTS.MACRO_ESCAPER.escape.escape_chrs S, probe
    result      = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.illegal_patterns matches consecutive unescaped LPBs" ] = ( T, done ) ->
  probes_and_matchers = [
    ["helo world",null]
    ["helo \\<< world",null]
    ["helo <\\< world",null]
    ["helo << world",["<<"]]
    ["helo >> world",[">>"]]
    ]
  patterns = ( copy_regex_non_global pattern for pattern in MKTS.MACRO_ESCAPER.illegal_patterns )
  for [ probe, matcher, ] in probes_and_matchers
    S           = MKTS.MACRO_ESCAPER.initialize_state {}
    probe       = MKTS.MACRO_ESCAPER.escape.escape_chrs S, probe
    result      = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.end_command_patterns matches end command macro" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here <<!end>> and some there",["some text here "]]
    ["some text here <<!end>>",["some text here "]]
    ["<<!end>>",[""]]
    ["",null]
    ["<<!end>> and some there",[""]]
    ["\\<<!end>> and some there",null]
    ["some text here \\<<!end>> and some there",null]
    ["some text here <<!end>\\> and some there",null]
    ]
  patterns = MKTS.MACRO_ESCAPER.end_command_patterns
  for [ probe, matcher, ] in probes_and_matchers
    result = list_from_match match_first patterns, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.truncate_text_at_end_command_macro" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here <<!end>> and some there",["some text here ",23]]
    ["some text here <<!end>>",["some text here ",8]]
    ["<<!end>>",["",8]]
    ["",["",0]]
    ["<<!end>> and some there",["",23]]
    ["\\<<!end>> and some there",["\\<<!end>> and some there",0]]
    ["some text here \\<<!end>> and some there",["some text here \\<<!end>> and some there",0]]
    ["some text here <<!end>\\> and some there",["some text here <<!end>\\> and some there",0]]
    ["\n\nfoo bar\n\n\n\n<<!end>>\ndiscarded",["\n\nfoo bar\n\n\n\n",18]]
    ["\n\nfoo bar\n\n\n\n<<!end>>\ndiscarded<<!end>>\ndiscarded as well",["\n\nfoo bar\n\n\n\n",44]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = MKTS.MACRO_ESCAPER.escape.truncate_text_at_end_command_macro null, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.html_comments" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here and some there","some text here and some there",[]]
    ["some text here<!-- omit this --> and some there","some text here\u0015comment0\u0013 and some there",[{"key":"comment0","markup":null,"raw":" omit this ","parsed":"omit this"}]]
    ["some text here\\<!-- omit this --> and some there","some text here\u001060\u0011!-- omit this --> and some there",[]]
    ["abcd<<<some raw content>>>efg","abcd<<<some raw content>>>efg",[]]
    ]
  for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
    S           = MKTS.MACRO_ESCAPER.initialize_state {}
    text_result = probe
    text_result = MKTS.MACRO_ESCAPER.escape.escape_chrs               S, text_result
    text_result = MKTS.MACRO_ESCAPER.escape.html_comments S, text_result
    help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
    T.eq text_result, text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.bracketed_raw_macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here<<!foo>>and some there","some text here<<!foo>>and some there",[]]
    ["abcd<<<some raw content>>>efg","abcd\u0015raw0\u0013efg",[{"key":"raw0","markup":"<","raw":"some raw content","parsed":null}]]
    ["abcd\\<<<some raw content>>>efg",'abcd\u001060\u0011<<some raw content>>>efg',[]]
    ]
  for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
    S           = MKTS.MACRO_ESCAPER.initialize_state {}
    probe       = MKTS.MACRO_ESCAPER.escape.escape_chrs S, probe
    text_result = MKTS.MACRO_ESCAPER.escape.bracketed_raw_macros S, probe
    help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
    T.eq text_result, text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.action_macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["<<(.>><<)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"","parsed":null}]]
    ["<<(.>><<.)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"","parsed":null}]]
    ["<<(.>>xxx<<)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"xxx","parsed":null}]]
    ["<<(.>>xxx<<.)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"xxx","parsed":null}]]
    ["<<(.>>some code<<)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"some code","parsed":null}]]
    ["<<(.>>some code<<.)>>","\u0015action0\u0013",[{"key":"action0","markup":["silent","coffee"],"raw":"some code","parsed":null}]]
    ["abc<<(.>>4 + 3<<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["silent","coffee"],"raw":"4 + 3","parsed":null}]]
    ["<<(:>><<)>>","\u0015action0\u0013",[{"key":"action0","markup":["vocal","coffee"],"raw":"","parsed":null}]]
    ["<<(:>>xxx<<)>>","\u0015action0\u0013",[{"key":"action0","markup":["vocal","coffee"],"raw":"xxx","parsed":null}]]
    ["<<(:>>some code<<)>>","\u0015action0\u0013",[{"key":"action0","markup":["vocal","coffee"],"raw":"some code","parsed":null}]]
    ["abc<<(:>>4 + 3<<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["vocal","coffee"],"raw":"4 + 3","parsed":null}]]
    ["abc<<(:>>bitfield \\>> 1 <<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["vocal","coffee"],"raw":"bitfield \\>> 1 ","parsed":null}]]
    ["abc<<(:>>bitfield >\\> 1 <<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["vocal","coffee"],"raw":"bitfield >\\> 1 ","parsed":null}]]
    ["abc<<(:js>>4 + 3<<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["vocal","js"],"raw":"4 + 3","parsed":null}]]
    ["abc<<(.js>>4 + 3<<)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["silent","js"],"raw":"4 + 3","parsed":null}]]
    ["abc<<(:js>>4 + 3<<:js)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["vocal","js"],"raw":"4 + 3","parsed":null}]]
    ["abc<<(.js>>4 + 3<<.js)>>def","abc\u0015action0\u0013def",[{"key":"action0","markup":["silent","js"],"raw":"4 + 3","parsed":null}]]
    ["abc<<(:js>>4 + 3<<:)>>def","abc<<(:js>>4 + 3<<:)>>def",[]]
    ["abc<<(.js>>4 + 3<<.)>>def","abc<<(.js>>4 + 3<<.)>>def",[]]
    ]
  for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
    S = MKTS.MACRO_ESCAPER.initialize_state {}
    text_result = MKTS.MACRO_ESCAPER.escape.action_macros S, probe
    # log CND.white rpr probe
    # urge rpr text_result
    help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
    T.eq text_result, text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
  # debug '©ΤΓΘΤΝ', MKTS.MACRO_ESCAPER.action_and_region_patterns[ 0 ]
  # debug '©ΤΓΘΤΝ', MKTS.MACRO_ESCAPER.action_and_region_patterns[ 1 ]
  # T.fail 'not ready'
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.command_and_value_macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here <<!foo>> and some there","some text here \u0015command0\u0013 and some there",[{"key":"command0","markup":"!","raw":"foo","parsed":null}]]
    ["some text here <<$foo>> and some there","some text here \u0015value0\u0013 and some there",[{"key":"value0","markup":"$","raw":"foo","parsed":null}]]
    ["some text here \\<<!foo>> and some there",'some text here \u001060\u0011<!foo>> and some there',[]]
    ["some text here \\<<$foo>> and some there",'some text here \u001060\u0011<$foo>> and some there',[]]
    ["some text here<!-- omit this --> and some there","some text here<!-- omit this --> and some there",[]]
    ["abcd<<<some raw content>>>efg","abcd<<<some raw content>>>efg",[]]
    ]
  for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
    S           = MKTS.MACRO_ESCAPER.initialize_state {}
    probe       = MKTS.MACRO_ESCAPER.escape.escape_chrs S, probe
    text_result = MKTS.MACRO_ESCAPER.escape.command_and_value_macros S, probe
    help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
    T.eq text_result, text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
  done()

# # # #-----------------------------------------------------------------------------------------------------------
# # # @[ "MKTS.MACRO_ESCAPER.escape 1" ] = ( T, done ) ->
# # #   probes_and_matchers = [
# # #     ["<<(multi-column 3>>\nsome text here<!-- omit this --> and some there\n<<)>>\n<<(multi-column 2>>\nThis text will appear in two-column<!-- omit this --> layout.\n<!--some code-->\n<<(:>>some code<<)>>\n<<)>>\n<<!end>>\n<<!command>><<(:action>><<)>>","\u0015region4\u0013\nsome text here\u0015comment0\u0013 and some there\n\u0015region5\u0013\n\u0015region6\u0013\nThis text will appear in two-column\u0015comment1\u0013 layout.\n\u0015comment2\u0013\n\u0015action3\u0013\n\u0015region7\u0013\n",[{"key":"comment0","markup":null,"raw":" omit this ","parsed":"omit this"},{"key":"comment1","markup":null,"raw":" omit this ","parsed":"omit this"},{"key":"comment2","markup":null,"raw":"some code","parsed":"some code"},{"key":"action3","markup":["vocal","coffee"],"raw":"some code","parsed":null},{"key":"region4","markup":"multi-column 3","raw":"<<(multi-column 3>>","parsed":null},{"key":"region5","markup":"multi-column 3","raw":"<<)>>","parsed":null},{"key":"region6","markup":"multi-column 2","raw":"<<(multi-column 2>>","parsed":null},{"key":"region7","markup":"multi-column 2","raw":"<<)>>","parsed":null}]]
# # #     ]
# # #   for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
# # #     S = MKTS.MACRO_ESCAPER.initialize_state {}
# # #     text_result = MKTS.MACRO_ESCAPER.escape S, probe
# # #     help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
# # #     T.eq text_result, text_matcher
# # #     T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
# # #   done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape 2" ] = ( T, done ) ->
  probes_and_matchers = [[
    """<<(multi-column 3>>
      some text here<!-- HTML comment 1 --> and some there
      <<)>>
      <<(multi-column 2>>
      This text will appear in two-column<!-- HTML comment 2 --> layout.
      <<(:>>some code<<)>>
      <<)>>
      <<!end>>
      <<!command>><<(:action>><<)>>
      """
    ,
      """\x15region3\x13
      some text here\x15comment0\x13 and some there
      \x15region5\x13
      \x15region4\x13
      This text will appear in two-column\x15comment1\x13 layout.
      \x15action2\x13
      \x15region6\x13\n"""
    ,
      [
        {"key":"comment0","markup":null,"raw":" HTML comment 1 ","parsed":"HTML comment 1"}
        {"key":"comment1","markup":null,"raw":" HTML comment 2 ","parsed":"HTML comment 2"}
        {"key":"action2","markup":["vocal","coffee"],"raw":"some code","parsed":null}
        {"key":"region3","markup":"(","raw":"multi-column 3","parsed":null}
        {"key":"region4","markup":"(","raw":"multi-column 2","parsed":null}
        {"key":"region5","markup":")","raw":"","parsed":null}
        {"key":"region6","markup":")","raw":"","parsed":null}
        ]
      ]]
  for [ probe, text_matcher, registry_matcher, ] in probes_and_matchers
    S = MKTS.MACRO_ESCAPER.initialize_state {}
    text_result = MKTS.MACRO_ESCAPER.escape S, probe
    urge nice_text_rpr probe
    info nice_text_rpr text_result
    help JSON.stringify entry for entry in S.MACRO_ESCAPER[ 'registry' ]
    T.eq text_result,             text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ],  registry_matcher
  # T.fail "not ready"
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.$expand.$html_comments" ] = ( T, done ) ->
  probes_and_matchers = [[
    """<<(multi-column 3>>
      some text here<!-- HTML comment 1 --> and some there
      <<)>>
      <<(multi-column 2>>
      This text will appear in two-column<!-- HTML comment 2 --> layout.
      <<(:>>some code<<)>>
      <<)>>
      <<!end>>
      <<!command>><<(:action>><<)>>
      """
    ,
      [
        [".","text","\u0015region3\u0013\nsome text here",{}]
        [".","comment"," HTML comment 1 ",{}]
        [".","text"," and some there\n\u0015region5\u0013\n\u0015region4\u0013\nThis text will appear in two-column",{}]
        [".","comment"," HTML comment 2 ",{}]
        [".","text"," layout.\n\u0015action2\u0013\n\u0015region6\u0013\n",{}]
      ]
      ]]
  for [ pre_probe, matcher, ] in probes_and_matchers
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape S, pre_probe
    input   = D.stream_from_text probe
    stream  = input
      .pipe $ ( text, send ) =>
        send [ '.', 'text', text, {}, ]
    D.call_transform stream, ( => MKTS.MACRO_ESCAPER.$expand.$html_comments S ), ( error, result ) =>
      log CND.white JSON.stringify event for event in result
      T.eq result, matcher
      done()
    input.resume()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.$expand.$action_macros" ] = ( T, done ) ->
  probes_and_matchers = [[
    """some text with <<(:>>vocal action<<)>>.
      <<(.js>>and( "a silent action" )<<.js)>>
      """
  ,
    [
      [".","text","some text with ",{}]
      [".","action","vocal action",{"mode":"vocal","language":"coffee"}]
      [".","text",".\n",{}]
      [".","action","and( \"a silent action\" )",{"mode":"silent","language":"js"}]
      ]
    ]]
  for [ pre_probe, matcher, ] in probes_and_matchers
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape S, pre_probe
    input   = D.stream_from_text probe
    stream  = input
      .pipe $ ( text, send ) =>
        send [ '.', 'text', text, {}, ]
    D.call_transform stream, ( => MKTS.MACRO_ESCAPER.$expand.$action_macros S ), ( error, result ) =>
      log CND.white JSON.stringify event for event in result
      T.eq result, matcher
      # T.fail "not ready"
      done()
    input.resume()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.$expand.$raw_macros" ] = ( T, done ) ->
  probes_and_matchers = [
    #.......................................................................................................
    [ """<<(multi-column 3>>
      some text here<<<\\LaTeX{}>>> and some there
      <<)>>
      """
    ,
    [
      # [".","text","\u0015region1\u0013\nsome text here",{}]
      # [".","raw","\\LaTeX{}",{}]
      # [".","text"," and some there\n\u0015region2\u0013",{}]
      [".","text","\u0015region1\u0013\nsome text here",{}]
      [".","raw","\u001076\u0011aTeX{}",{}]
      [".","text"," and some there\n\u0015region2\u0013",{}]
      ]
    ],
    #.......................................................................................................
    [ """some text here
      <<<\\dotfill{}>>>
      and some there
      """
    ,
    [
      [".","text","some text here\n",{}]
      [".","raw","\u0010100\u0011otfill{}",{}]
      [".","text","\nand some there",{}]
      ]
    ],
    #.......................................................................................................
    ]
  #.........................................................................................................
  count = 0
  for [ pre_probe, matcher, ] in probes_and_matchers
    info '\n' + pre_probe
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape S, pre_probe
    input   = D.stream_from_text probe
    stream  = input
      .pipe $ ( text, send ) =>
        send [ '.', 'text', text, {}, ]
    D.call_transform stream, ( => MKTS.MACRO_ESCAPER.$expand.$raw_macros S ), ( error, result ) =>
      log CND.white JSON.stringify event for event in result
      T.eq result, matcher
      # T.fail "not ready"
      count += +1
      done() if count >= probes_and_matchers.length
    input.resume()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.$expand.$command_and_value_macros" ] = ( T, done ) ->
  probes_and_matchers = [[
    """<<(multi-column 3>>
      a command <<!LATEX>> and a value <<$pagenr>>.
      <<)>>
      """
  ,
    [
      [".","text","\u0015region0\u0013\na command ",{}]
      ["!","LATEX",null,{}]
      [".","text"," and a value ",{}]
      ["$","pagenr",null,{}]
      [".","text",".\n\u0015region1\u0013",{}]
      ]
    ]]
  for [ pre_probe, matcher, ] in probes_and_matchers
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape S, pre_probe
    # debug '©ΖΡΤΣΓ', S
    input   = D.stream_from_text probe
    stream  = input
      .pipe $ ( text, send ) =>
        send [ '.', 'text', text, {}, ]
    D.call_transform stream, ( => MKTS.MACRO_ESCAPER.$expand.$command_and_value_macros S ), ( error, result ) =>
      log CND.white JSON.stringify event for event in result
      T.eq result, matcher
      # T.fail "not ready"
      done()
    input.resume()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse accepts dot patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '.',     [ '.', null,   null, ], ]
    [ '.p',    [ '.', 'p',    null, ], ]
    [ '.text', [ '.', 'text', null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.MD_READER.FENCES.parse probe
    T.eq ( MKTS.MD_READER.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse accepts empty fenced patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    # [ '<>', [ '<', null, '>', ], ]
    # [ '{}', [ '{', null, '}', ], ]
    # [ '[]', [ '[', null, ']', ], ]
    [ '()', [ '(', null, ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.MD_READER.FENCES.parse probe
    T.eq ( MKTS.MD_READER.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse accepts unfenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ 'document',       [ null, 'document',     null, ], ]
    [ 'singlecolumn',   [ null, 'singlecolumn', null, ], ]
    [ 'code',           [ null, 'code',         null, ], ]
    [ 'blockquote',     [ null, 'blockquote',   null, ], ]
    [ 'em',             [ null, 'em',           null, ], ]
    [ 'xxx',            [ null, 'xxx',          null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.MD_READER.FENCES.parse probe
    T.eq ( MKTS.MD_READER.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse accepts fenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    # [ '<document>',     [ '<', 'document',     '>', ], ]
    # [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
    # [ '{code}',         [ '{', 'code',         '}', ], ]
    # [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
    [ '(em)',           [ '(', 'em',           ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.MD_READER.FENCES.parse probe
    T.eq ( MKTS.MD_READER.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse rejects empty string" ] = ( T, done ) ->
  T.throws "pattern must be non-empty, got ''", ( -> MKTS.MD_READER.FENCES.parse '' )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse rejects non-matching fences etc" ] = ( T, done ) ->
  probes_and_matchers = [
    ["(xxx}","unmatched fence in '(xxx}'"]
    [".)","fence '.' can not have right fence, got '.)'"]
    [".p)","fence '.' can not have right fence, got '.p)'"]
    ["(xxx","unmatched fence in '(xxx'"]
    ["(","unmatched fence in '('"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      debug '©ΒΩΦΥΨ', JSON.stringify [ probe, MKTS.MD_READER.FENCES.parse probe ]
    catch error
      warn '©ΒΩΦΥΨ', JSON.stringify [ probe, error[ 'message' ], ]
    T.throws matcher, ( -> MKTS.MD_READER.FENCES.parse probe )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.FENCES.parse accepts non-matching fences when so configured" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '(em)',           [ '(', 'em',           ')', ], ]
    [ 'em)',            [ null, 'em',           ')', ], ]
    [ '(em',            [ '(', 'em',           null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.MD_READER.FENCES.parse probe
    T.eq ( MKTS.MD_READER.FENCES.parse probe, symmetric: no ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.TRACKER.new_tracker().track rejects unregistered pattern" ] = ( T, done ) ->
  track = MKTS.MD_READER.TRACKER.new_tracker '(code)', '(em)'
  T.throws "untracked pattern '(code-span)'", ( => track.within '(code-span)' )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MD_READER.TRACKER.new_tracker (short comprehensive test)" ] = ( T, done ) ->
  track = MKTS.MD_READER.TRACKER.new_tracker '(code-span)', '(em)'
  probes_and_matchers = [
    [["(","code-span"],[true,false]]
    [["(","em"],[true,true]]
    [[".","text"],[true,true]]
    [[")","em"],[true,false]]
    [[".","text"],[true,false]]
    [[")","code-span"],[false,false]]
    [[".","text"],[false,false]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    track probe
    within_code_span  = track.within '(code-span)'
    within_em         = track.within '(em)'
    help JSON.stringify [ probe, [ within_code_span, within_em, ], ]
    T.eq ( track.within '(code-span)' ), matcher[ 0 ]
    T.eq ( track.within '(em)'        ), matcher[ 1 ]
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (1)" ] = ( T, done ) ->
  # settings  = bare: yes
  probe     = """123 `abc<<(:>>vocal action<<)>>def` 456"""
  warn "should merge texts"
  matcher   = [
    ["(","document",null,{"line_nr":1,"col_nr":2,"markup":""}]
    [".","text","123 ",{"line_nr":1,"col_nr":2,"markup":""}]
    ["(","code-span",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","abc",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","action","vocal action",{"line_nr":1,"col_nr":2,"markup":"","mode":"vocal","language":"coffee","hidden":true,"stamped":true}]
    [".","warning","action on line 1: vocal is not defined",{"line_nr":1,"col_nr":2,"markup":"","mode":"vocal","language":"coffee"}]
    [".","text","def",{"line_nr":1,"col_nr":2,"markup":""}]
    [")","code-span",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text"," 456",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    [")","document",null,{}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (2)" ] = ( T, done ) ->
  settings  = bare: yes
  # probe     = """abc<<(:js>>f( 42 );<<:js)>>def"""
  probe     = """abc<<(:js>>42;<<:js)>>def"""
  warn "should merge texts"
  matcher   = [
    [".","text","abc",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","action","42;",{"line_nr":1,"col_nr":2,"markup":"","mode":"vocal","language":"js","hidden":true,"stamped":true}]
    [".","text","42",{"line_nr":1,"col_nr":2,"markup":"","mode":"vocal","language":"js"}]
    [".","text","def",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (3)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """abc\\<<(:js\\>>f( 42 );\\<<:js)\\>>def"""
  warn "should merge texts"
  matcher   = [
    [".","text","abc\\<<(:js\\>>f( 42 );\\<<:js)\\>>def",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (4)" ] = ( T, done ) ->
  settings  = bare: no
  probe     = """<<!end>>"""
  warn "match remark?"
  matcher   = [
    ["(","document",null,{}]
    [".","command","empty-document",{}]
    [")","document",null,{}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (5)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """<<!multi-column>>"""
  warn "should not contain `.p`"
  matcher   = [
    ["!","multi-column",[],{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (6)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    aaa
    <<(multi-column>>
    bbb
    <<multi-column)>>
    ccc
    """
  warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","aaa\n",{"line_nr":1,"col_nr":6,"markup":""}]
    ["(","multi-column",null,{"line_nr":1,"col_nr":6,"markup":""}]
    [".","text","\nbbb\n",{"line_nr":1,"col_nr":6,"markup":""}]
    [")","multi-column",null,{"line_nr":1,"col_nr":6,"markup":""}]
    [".","text","\nccc",{"line_nr":1,"col_nr":6,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":6,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (6a) auto-close dangling tags" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    aaa
    <<(multi-column>>
    bbb
    """
  warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","aaa\n",{"line_nr":1,"col_nr":4,"markup":""}]
    ["(","multi-column",null,{"line_nr":1,"col_nr":4,"markup":""}]
    [".","text","\nbbb",{"line_nr":1,"col_nr":4,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":4,"markup":""}]
    ["#","resend","`multi-column)`",{"badge":"$close_dangling_open_tags","stamped":true}]
    [")","multi-column",null,{"line_nr":1,"col_nr":4,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (7)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    她說：「你好。」
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","她說：「你好。」",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (8)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    A paragraph with *emphasis*.

    A paragraph with **bold text**.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","A paragraph with ",{"line_nr":1,"col_nr":2,"markup":""}]
    ["(","em",null,{"line_nr":1,"col_nr":2,"markup":"*"}]
    [".","text","emphasis",{"line_nr":1,"col_nr":2,"markup":""}]
    [")","em",null,{"line_nr":1,"col_nr":2,"markup":"*"}]
    [".","text",".",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    [".","text","A paragraph with ",{"line_nr":3,"col_nr":4,"markup":""}]
    ["(","strong",null,{"line_nr":3,"col_nr":4,"markup":"**"}]
    [".","text","bold text",{"line_nr":3,"col_nr":4,"markup":""}]
    [")","strong",null,{"line_nr":3,"col_nr":4,"markup":"**"}]
    [".","text",".",{"line_nr":3,"col_nr":4,"markup":""}]
    [".","p",null,{"line_nr":3,"col_nr":4,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md: footnotes" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    Here is an inline footnote^[whose text appears at the point of insertion],
    followed by a referenced footnote[^1].

    [^1]: Referenced footnotes must use matching references.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","Here is an inline footnote",{"line_nr":1,"col_nr":3,"markup":""}]
    ["(","footnote",0,{"line_nr":1,"col_nr":3,"markup":""}]
    [".","text","whose text appears at the point of insertion",{"line_nr":1,"col_nr":3,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":3,"markup":""}]
    [")","footnote",0,{"line_nr":1,"col_nr":3,"markup":""}]
    [".","text",",\nfollowed by a referenced footnote",{"line_nr":1,"col_nr":3,"markup":""}]
    ["(","footnote",1,{"line_nr":1,"col_nr":3,"markup":""}]
    [".","text","Referenced footnotes must use matching references.",{"line_nr":4,"col_nr":5,"markup":""}]
    [".","p",null,{"line_nr":4,"col_nr":5,"markup":""}]
    [")","footnote",1,{"line_nr":1,"col_nr":3,"markup":""}]
    [".","text",".",{"line_nr":1,"col_nr":3,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":3,"markup":""}]
    ]
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mkts_events_from_md probe, settings, resume
    show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TEX_WRITER.tex_from_md (1)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    A paragraph with *emphasis*.

    A paragraph with **bold text**.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    % begin of MD document
    A paragraph with {\\mktsStyleItalic{}emphasis\\/}.

    A paragraph with {\\mktsStyleBold{}bold text}.


    % end of MD document

    """
  step ( resume ) ->
    result = yield MKTS.TEX_WRITER.tex_from_md probe, settings, resume
    # echo result
    T.eq matcher.trim(), result.trim()
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TEX_WRITER.tex_from_md (2)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    The <<<\\LaTeX{}>>> Logo: `<<<\\LaTeX{}>>>` The <<<\\\\LaTeX{}>>> Logo: `<<<\\\\LaTeX{}>>>`
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    % begin of MD document
    The \\LaTeX{} Logo: {\\mktsStyleCode{}\\LaTeX{}} The \\\\LaTeX{} Logo: {\\mktsStyleCode{}\\\\LaTeX{}}


    % end of MD document\n"""
  step ( resume ) ->
    result = yield MKTS.TEX_WRITER.tex_from_md probe, settings, resume
    # echo result
    info nice_text_rpr result
    T.eq matcher.trim(), result.trim()
    # T.fail "review `CLEANUP.$remove_empty_p_tags` in tex-writer; can't work w/ present event structure"
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TEX_WRITER.tex_from_md (3)" ] = ( T, done ) ->
  settings  = bare: yes
  # probe     = """
  #   ```keep-lines squish: yes
  #   <<<\\dotfill>>>𠦝<<<\\dotfill>>>x
  #   𠦝月 朝　　　　<<<\\hfill{}>>>1
  #   ```
  #   """
  probe     = """
    ```keep-lines squish: yes
    1
    2
    <<<\\dotfill>>>
    3
    ```
    """
  matcher   = """
    % begin of MD document
    {\\mktsTightParagraphs{}1\\par
    2\\par
    \\dotfill\\null\\par
    3\\par
    }
    % end of MD document\n"""
  step ( resume ) ->
    result = yield MKTS.TEX_WRITER.tex_from_md probe, settings, resume
    # echo result
    info nice_text_rpr result
    T.eq matcher.trim(), result.trim()
    # T.fail "review `CLEANUP.$remove_empty_p_tags` in tex-writer; can't work w/ present event structure"
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mktscript_from_md (1)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    A paragraph with *emphasis*.

    A paragraph with **bold text**.

    Using <foo>HTML tags **inhibits** MD syntax</foo>.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    1 █ (document
    1 █ .text 'A paragraph with '
    1 █ (em
    1 █ .text 'emphasis'
    1 █ )em
    1 █ .text '.'
    1 █ .p
    3 █ .text 'A paragraph with '
    3 █ (strong
    3 █ .text 'bold text'
    3 █ )strong
    3 █ .text '.'
    3 █ .p
    5 █ .text 'Using '
    5 █ (foo
    5 █ .text 'HTML tags '
    5 █ (strong
    5 █ .text 'inhibits'
    5 █ )strong
    5 █ .text ' MD syntax'
    5 █ )foo
    5 █ .text '.'
    5 █ .p
    )document
    # EOF
    """
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mktscript_from_md probe, settings, resume
    echo result
    T.eq matcher.trim(), result.trim()
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MKTSCRIPT_WRITER.mktscript_from_md (2) auto-close dangling tags" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    <<(multi-column>>

    <div>B</div>

    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    1 █ (document
    1 █ (multi-column
    1 █ .p
    1 █ (div
    1 █ .text 'B'
    1 █ )div
    1 █ .p
    #resend '`multi-column)`'
    1 █ )multi-column
    )document
    # EOF
    """
  step ( resume ) ->
    result = yield MKTS.MKTSCRIPT_WRITER.mktscript_from_md probe, settings, resume
    echo result
    T.eq matcher.trim(), result.trim()
    # T.fail "not yet ready"
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.escape.region_macros" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here <<(>><<)>>","some text here \u0015region0\u0013\u0015region1\u0013",[{"key":"region0","markup":"(","raw":"","parsed":null},{"key":"region1","markup":")","raw":"","parsed":null}]]
    ["some text here <<(em>><<)>>","some text here \u0015region0\u0013\u0015region1\u0013",[{"key":"region0","markup":"(","raw":"em","parsed":null},{"key":"region1","markup":")","raw":"","parsed":null}]]
    ["some text here <<(em>>and some there<<)>><<(more>>markup<<)>>","some text here \u0015region0\u0013and some there\u0015region2\u0013\u0015region1\u0013markup\u0015region3\u0013",[{"key":"region0","markup":"(","raw":"em","parsed":null},{"key":"region1","markup":"(","raw":"more","parsed":null},{"key":"region2","markup":")","raw":"","parsed":null},{"key":"region3","markup":")","raw":"","parsed":null}]]
    ["some text here <<(em>>and some there<<foo)>>","some text here \u0015region0\u0013and some there\u0015region1\u0013",[{"key":"region0","markup":"(","raw":"em","parsed":null},{"key":"region1","markup":")","raw":"foo","parsed":null}]]
    ]
  for [ probe, text_matcher, registry_matcher, ], idx in probes_and_matchers
    S = MKTS.MACRO_ESCAPER.initialize_state {}
    text_result = MKTS.MACRO_ESCAPER.escape.region_macros S, probe
    # debug '63746', idx
    # debug '74623', CND.equals text_result, text_matcher
    # log CND.white rpr probe
    # urge rpr text_result
    # help JSON.stringify [ probe, text_result, S.MACRO_ESCAPER[ 'registry' ], ]
    T.eq text_result, text_matcher
    T.eq S.MACRO_ESCAPER[ 'registry' ], registry_matcher
  # T.fail 'not ready'
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.MACRO_ESCAPER.$expand.$region_macros" ] = ( T, done ) ->
  probes_and_matchers = [[
    """<<(multi-column 3>>
      some text here<!-- omit this --> and some there
      <<)>>
      <<(multi-column 2>>
      This text will appear in two-column<!-- omit this --> layout.
      <!--some code-->
      <<(:>>some code<<)>>
      <<)>>
      <<!end>>
      <<!command>><<(:action>><<)>>
      """
  ,
    [
      ["(","multi-column 3",null,{}]
      [".","text","\nsome text here\u0015comment0\u0013 and some there\n",{}]
      [")","multi-column 3",null,{}]
      [".","text","\n",{}]
      ["(","multi-column 2",null,{}]
      [".","text","\nThis text will appear in two-column\u0015comment1\u0013 layout.\n\u0015comment2\u0013\n\u0015action3\u0013\n",{}]
      [")","multi-column 2",null,{}]
      [".","text","\n",{}]
      ]
    ]]
  for [ pre_probe, matcher, ] in probes_and_matchers
    S       = MKTS.MACRO_ESCAPER.initialize_state {}
    probe   = MKTS.MACRO_ESCAPER.escape S, pre_probe
    input   = D.stream_from_text probe
    stream  = input
      .pipe $ ( text, send ) =>
        send [ '.', 'text', text, {}, ]
    D.call_transform stream, ( => MKTS.MACRO_ESCAPER.$expand.$region_macros S ), ( error, result ) =>
      log CND.white JSON.stringify event for event in result
      for event, idx in result
        matcher_event = matcher[ idx ]
        T.eq event, matcher_event
      #   log idx, ( CND.equals event, matcher_event ), ( JSON.stringify event ), ( JSON.stringify matcher_event )
      # T.fail "not ready"
      done()
    input.resume()

#-----------------------------------------------------------------------------------------------------------
@[ "TEX_WRITER_TYPOFIX.fix_typography_for_tex" ] = ( T, done ) ->
  S                                 = {}
  { CACHE, OPTIONS, }               = require './options-and-cache'
  TEX_WRITER_TYPOFIX                = require './tex-writer-typofix'
  options_route                     = '../options.coffee'
  options_locator                   = require.resolve njs_path.resolve __dirname, options_route
  options_home                      = njs_path.dirname options_locator
  S.options                         = OPTIONS.from_locator options_locator
  format                            = ( text ) => text.trim().replace /\x20/g, '∗'
  #.........................................................................................................
  probes_and_matchers = [
    ["x𠇋𠇋𠇋x","x{\\cjk{}{\\cnxb{}𠇋𠇋𠇋}}x"]
    ["Brick tea ! ","Brick∗tea∗!"]
    ["&\\#","\\&\\textbackslash{}\\#"]
    ["國","{\\cjk{}{\\cn{}國}}"]
    ["x國x","x{\\cjk{}{\\cn{}國}}x"]
    ["a 國 b","a∗{\\cjk{}{\\cn{}國}}∗b"]
    ["國 國","{\\cjk{}{\\cn{}國}}∗{\\cjk{}{\\cn{}國}}"]
    ["𠇋𠇋","{\\cjk{}{\\cnxb{}𠇋𠇋}}"]
    ["x𠇋x","x{\\cjk{}{\\cnxb{}𠇋}}x"]
    ["a 𠇋 b","a∗{\\cjk{}{\\cnxb{}𠇋}}∗b"]
    ["卩","{\\cjk{}{\\cn{}{\\tfPush{-0.4}卩}}}"]
    ["x卩x","x{\\cjk{}{\\cn{}{\\tfPush{-0.4}卩}}}x"]
    ["x 卩 x","x∗{\\cjk{}{\\cn{}{\\tfPush{-0.4}卩}}}∗x"]
    ["x 國𠇋國 x","x∗{\\cjk{}{\\cn{}國}{\\cnxb{}𠇋}{\\cn{}國}}∗x"]
    ["x 國卩國𠇋 x","x∗{\\cjk{}{\\cn{}國{\\tfPush{-0.4}卩}國}{\\cnxb{}𠇋}}∗x"]
    ["x𠇋𠇋𠇋x","x{\\cjk{}{\\cnxb{}𠇋𠇋𠇋}}x"]
    ["Brick tea 紧压茶都是用红茶 is delicious","Brick∗tea∗{\\cjk{}{\\cn{}紧压茶都是用红茶}}∗is∗delicious"]
    ["Brick tea\n紧压茶都 是\t\n用红茶 is\ndelicious","Brick∗tea\n{\\cjk{}{\\cn{}紧压茶都}}∗{\\cjk{}{\\cn{}是}}\t\n{\\cjk{}{\\cn{}用红茶}}∗is\ndelicious"]
    ["压茶卩红茶","{\\cjk{}{\\cn{}压茶{\\tfPush{-0.4}卩}红茶}}"]
    ["压茶𠇋卩红茶","{\\cjk{}{\\cn{}压茶}{\\cnxb{}𠇋}{\\cn{}{\\tfPush{-0.4}卩}红茶}}"]
    ["压茶𠇋卩","{\\cjk{}{\\cn{}压茶}{\\cnxb{}𠇋}{\\cn{}{\\tfPush{-0.4}卩}}}"]
    ["ℂ∪ℚ","ℂ∪ℚ"]
    ["&jzr#xe232;","{\\cjk{}{\\cnjzr{}}}"]
    ["& \\ #癶乛國",'\\&∗\\textbackslash{}∗\\#{\\cjk{}{\\cn{}{\\tfRaise{-0.2}\\cnxBabel{}癶}}{\\cnjzr{}{\\tfPushRaise{0.5}{-0.2}}}{\\cn{}{\\tfRaise{-0.2}乛}國}}']
    ["Brick tea 紧压茶卩癶都是用红茶 is delicious","Brick∗tea∗{\\cjk{}{\\cn{}紧压茶{\\tfPush{-0.4}卩}{\\tfRaise{-0.2}\\cnxBabel{}癶}}{\\cnjzr{}{\\tfRaise{0.1}\\cnxJzr{}}}{\\cn{}都是用红茶}}∗is∗delicious"]
    ["x&#x65;x&morohashi#x12ab;x&jzr#xe000;x","xex\\&morohashi\\#x12ab;x{\\cjk{}{\\cnjzr{}}}x"]
    ]
  # warn "missing `.p` inside `(multi-column)`"
  #.........................................................................................................
  step ( resume ) ->
    for [ probe, matcher, ] in probes_and_matchers
      result  = yield TEX_WRITER_TYPOFIX.fix_typography_for_tex S, probe, resume
      result  = format result
      # echo '    ' + JSON.stringify [ probe, result, ]
      T.eq ( format matcher ), result
    done()
  #.........................................................................................................
  return null


#===========================================================================================================
# MAIN
#-----------------------------------------------------------------------------------------------------------
@_main = ( handler ) ->
  test @, 'timeout': 2500

#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null '  '
  include = [
    #-------------------------------------------------------------------------------------------------------
    # NOT WORKING
    #-------------------------------------------------------------------------------------------------------
    # "MKTS.MACRO_ESCAPER.command_and_value_patterns matches command macro"
    # "MKTS.MACRO_ESCAPER.escape.command_and_value_macros"
    # "MKTS.MACRO_ESCAPER.$expand.$command_and_value_macros"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (1)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (2)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (3)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (4)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (5)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (6)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (6a) auto-close dangling tags"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (7)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md (8)"
    # "MKTS.MKTSCRIPT_WRITER.mkts_events_from_md: footnotes"
    # "MKTS.MKTSCRIPT_WRITER.mktscript_from_md (1)"
    # "MKTS.MKTSCRIPT_WRITER.mktscript_from_md (2) auto-close dangling tags"
    # "MKTS.MACRO_ESCAPER.$expand.$region_macros"

    #-------------------------------------------------------------------------------------------------------
    # WORKING
    #-------------------------------------------------------------------------------------------------------
    "MKTS.MACRO_ESCAPER.bracketed_raw_patterns matches raw macro"
    "MKTS.MACRO_ESCAPER.escape.bracketed_raw_macros"
    "MKTS.MACRO_ESCAPER.$expand.$raw_macros"
    "MKTS.MACRO_ESCAPER.action_patterns match action macros"
    "MKTS.MACRO_ESCAPER.region_patterns match region macros"
    "MKTS.MACRO_ESCAPER.illegal_patterns matches consecutive unescaped LPBs"
    "MKTS.MACRO_ESCAPER.end_command_patterns matches end command macro"
    "MKTS.MACRO_ESCAPER.escape.truncate_text_at_end_command_macro"
    "MKTS.MACRO_ESCAPER.escape.html_comments"
    "MKTS.MACRO_ESCAPER.escape.action_macros"
    "MKTS.MACRO_ESCAPER.escape 2"
    "MKTS.MACRO_ESCAPER.$expand.$html_comments"
    "MKTS.MACRO_ESCAPER.$expand.$action_macros"
    "MKTS.MD_READER.FENCES.parse accepts dot patterns"
    "MKTS.MD_READER.FENCES.parse accepts empty fenced patterns"
    "MKTS.MD_READER.FENCES.parse accepts unfenced named patterns"
    "MKTS.MD_READER.FENCES.parse accepts fenced named patterns"
    "MKTS.MD_READER.FENCES.parse rejects empty string"
    "MKTS.MD_READER.FENCES.parse rejects non-matching fences etc"
    "MKTS.MD_READER.FENCES.parse accepts non-matching fences when so configured"
    "MKTS.MD_READER.TRACKER.new_tracker().track rejects unregistered pattern"
    "MKTS.MD_READER.TRACKER.new_tracker (short comprehensive test)"
    "MKTS.MACRO_ESCAPER.escape.region_macros"
    "MKTS.TEX_WRITER.tex_from_md (1)"
    "MKTS.TEX_WRITER.tex_from_md (2)"
    "MKTS.TEX_WRITER.tex_from_md (3)"
    "TEX_WRITER_TYPOFIX.fix_typography_for_tex"
    ]
  @_prune()
  @_main()

