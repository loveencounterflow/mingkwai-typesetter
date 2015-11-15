





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
MKTS                      = require './MKTS'
MKTS_XXX                  = require './mkts-typesetter-interim'


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


# #===========================================================================================================
# # TESTS
# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS._ESC.action_patterns[ 0 ] matches action macro" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["<<(.>><<)>>",["",".","",""]]
#     ["<<(.>>xxx<<)>>",["",".","xxx",""]]
#     ["<<(.>>some code<<)>>",["",".","some code",""]]
#     ["abc<<(.>>4 + 3<<)>>def",["c",".","4 + 3",""]]
#     ["<<(:>><<)>>",["",":","",""]]
#     ["<<(:>>xxx<<)>>",["",":","xxx",""]]
#     ["<<(:>>some code<<)>>",["",":","some code",""]]
#     ["abc<<(:>>4 + 3<<)>>def",["c",":","4 + 3",""]]
#     ["abc<<(:>>bitfield \\>> 1 <<)>>def",["c",":","bitfield \\>> 1 ",""]]
#     ["abc<<(:>>bitfield >\\> 1 <<)>>def",["c",":","bitfield >\\> 1 ",""]]
#     ["abc<<(:js>>4 + 3<<)>>def",["c",":js","4 + 3",""]]
#     ["abc<<(.js>>4 + 3<<)>>def",["c",".js","4 + 3",""]]
#     ["abc<<(:js>>4 + 3<<:js)>>def",["c",":js","4 + 3",":js"]]
#     ["abc<<(.js>>4 + 3<<.js)>>def",["c",".js","4 + 3",".js"]]
#     ["abc<<(:js>>4 + 3<<:)>>def",null]
#     ["abc<<(.js>>4 + 3<<.)>>def",null]
#     ]
#   patterns = ( copy_regex_non_global pattern for pattern in MKTS._ESC.action_patterns )
#   for [ probe, matcher, ] in probes_and_matchers
#     result = list_from_match match_first patterns, probe
#     help JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS._ESC.bracketed_raw_patterns matches raw macro" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["<<<...raw material...>>>",["","<","...raw material..."]]
#     ["<<(.>>some code<<)>>",null]
#     ["<<<>>>",["","<",""]]
#     ["abcdef<<<\\XeLaTeX{}>>>ghijklm",["f","<","\\XeLaTeX{}"]]
#     ["abcdef<<<123\\>>>0>>>ghijklm",["f","<","123\\>>>0"]]
#     ["abcdef\\<<<123>>>ghijklm",null]
#     ["abcdef<\\<<123>>>ghijklm",null]
#     ["abcdef<<\\<123>>>ghijklm",null]
#     ["abcdef<<<123>>\\>ghijklm",null]
#     ]
#   patterns = ( copy_regex_non_global pattern for pattern in MKTS._ESC.bracketed_raw_patterns )
#   for [ probe, matcher, ] in probes_and_matchers
#     result = list_from_match match_first patterns, probe
#     help JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS._ESC.command_patterns matches command macro" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["<<!>>",["","!",""]]
#     ["<<!name>>",["","!","name"]]
#     ["abc<<!name>>def",["c","!","name"]]
#     ["abc<<!n>me>>def",["c","!","n>me"]]
#     ["abc<<!n>\\>me>>def",["c","!","n>\\>me"]]
#     ["abc<<!n\\>me>>def",["c","!","n\\>me"]]
#     ["abc\\<<!nme>>def",null]
#     ["<<$>>",["","$",""]]
#     ["<<$name>>",["","$","name"]]
#     ["abc<<$name>>def",["c","$","name"]]
#     ["abc<<$n>me>>def",["c","$","n>me"]]
#     ["abc<<$n>\\>me>>def",["c","$","n>\\>me"]]
#     ["abc<<$n\\>me>>def",["c","$","n\\>me"]]
#     ["abc\\<<$nme>>def",null]
#     ]
#   patterns = ( copy_regex_non_global pattern for pattern in MKTS._ESC.command_patterns )
#   for [ probe, matcher, ] in probes_and_matchers
#     result = list_from_match match_first patterns, probe
#     help JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS._ESC.illegal_patterns matches consecutive unescaped LPBs" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["helo world",null]
#     ["helo \\<< world",null]
#     ["helo <\\< world",null]
#     ["helo << world",[" ","<<"," world"]]
#     ]
#   patterns = ( copy_regex_non_global pattern for pattern in MKTS._ESC.illegal_patterns )
#   for [ probe, matcher, ] in probes_and_matchers
#     result = list_from_match match_first patterns, probe
#     help JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS._ESC.end_command_patterns matches end command macro" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["some text here <<!end>> and some there",["some text here "]]
#     ["some text here <<!end>>",["some text here "]]
#     ["<<!end>>",[""]]
#     ["",null]
#     ["<<!end>> and some there",[""]]
#     ["\\<<!end>> and some there",null]
#     ["some text here \\<<!end>> and some there",null]
#     ["some text here <<!end>\\> and some there",null]
#     ]
#   patterns = MKTS._ESC.end_command_patterns
#   for [ probe, matcher, ] in probes_and_matchers
#     result = list_from_match match_first patterns, probe
#     help JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS._ESC.truncate_text_at_end_command_macro" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here <<!end>> and some there",["some text here ",23]]
    ["some text here <<!end>>",["some text here ",8]]
    ["<<!end>>",["",8]]
    ["",["",0]]
    ["<<!end>> and some there",["",23]]
    ["\\<<!end>> and some there",["\\<<!end>> and some there",0]]
    ["some text here \\<<!end>> and some there",["some text here \\<<!end>> and some there",0]]
    ["some text here <<!end>\\> and some there",["some text here <<!end>\\> and some there",0]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = MKTS._ESC.truncate_text_at_end_command_macro probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS._ESC.escape_macro_tags" ] = ( T, done ) ->
  probes_and_matchers = [
    ["some text here and some there","some text here and some there",{"registry":[],"index":{}}]
    ["some text here<!-- omit this --> and some there","some text here\u0015comment0\u0013 and some there",{"registry":[{"key":"comment0","raw":" omit this ","parsed":null}],"index":{}}]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    S = MKTS._ESC.initialize {}
    result = MKTS._ESC.escape_macro_tags S, probe
    help JSON.stringify [ probe, result, S._ESC, ]
    T.eq result, matcher
  done()

#-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse accepts dot patterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ '.',     [ '.', null,   null, ], ]
#     [ '.p',    [ '.', 'p',    null, ], ]
#     [ '.text', [ '.', 'text', null, ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     # help ( rpr probe ), MKTS.FENCES.parse probe
#     T.eq ( MKTS.FENCES.parse probe ), matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse accepts empty fenced patterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ '<>', [ '<', null, '>', ], ]
#     [ '{}', [ '{', null, '}', ], ]
#     [ '[]', [ '[', null, ']', ], ]
#     [ '()', [ '(', null, ')', ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     # help ( rpr probe ), MKTS.FENCES.parse probe
#     T.eq ( MKTS.FENCES.parse probe ), matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse accepts unfenced named patterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ 'document',       [ null, 'document',     null, ], ]
#     [ 'singlecolumn',   [ null, 'singlecolumn', null, ], ]
#     [ 'code',           [ null, 'code',         null, ], ]
#     [ 'blockquote',     [ null, 'blockquote',   null, ], ]
#     [ 'em',             [ null, 'em',           null, ], ]
#     [ 'xxx',            [ null, 'xxx',          null, ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     # help ( rpr probe ), MKTS.FENCES.parse probe
#     T.eq ( MKTS.FENCES.parse probe ), matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse accepts fenced named patterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ '<document>',     [ '<', 'document',     '>', ], ]
#     [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
#     [ '{code}',         [ '{', 'code',         '}', ], ]
#     [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
#     [ '(em)',           [ '(', 'em',           ')', ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     # help ( rpr probe ), MKTS.FENCES.parse probe
#     T.eq ( MKTS.FENCES.parse probe ), matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse rejects empty string" ] = ( T, done ) ->
#   T.throws "pattern must be non-empty, got ''", ( -> MKTS.FENCES.parse '' )
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse rejects non-matching fences etc" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ '(xxx}',  'fences don\'t match in pattern \'(xxx}\'',          ]
#     [ '.)',     'fence \'.\' can not have right fence, got \'.)\'',  ]
#     [ '.p)',    'fence \'.\' can not have right fence, got \'.p)\'', ]
#     [ '.[',     'fence \'.\' can not have right fence, got \'.[\'',  ]
#     [ '<',      'unmatched fence in \'<\'',                          ]
#     [ '{',      'unmatched fence in \'{\'',                          ]
#     [ '[',      'unmatched fence in \'[\'',                          ]
#     [ '(',      'unmatched fence in \'(\'',                          ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     T.throws matcher, ( -> MKTS.FENCES.parse probe )
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.FENCES.parse accepts non-matching fences when so configured" ] = ( T, done ) ->
#   probes_and_matchers = [
#     [ '<document>',     [ '<', 'document',     '>', ], ]
#     [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
#     [ '{code}',         [ '{', 'code',         '}', ], ]
#     [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
#     [ '(em)',           [ '(', 'em',           ')', ], ]
#     [ 'document>',      [ null, 'document',     '>', ], ]
#     [ 'singlecolumn}',  [ null, 'singlecolumn', '}', ], ]
#     [ 'code}',          [ null, 'code',         '}', ], ]
#     [ 'blockquote]',    [ null, 'blockquote',   ']', ], ]
#     [ 'em)',            [ null, 'em',           ')', ], ]
#     [ '<document',      [ '<', 'document',     null, ], ]
#     [ '{singlecolumn',  [ '{', 'singlecolumn', null, ], ]
#     [ '{code',          [ '{', 'code',         null, ], ]
#     [ '[blockquote',    [ '[', 'blockquote',   null, ], ]
#     [ '(em',            [ '(', 'em',           null, ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     # help ( rpr probe ), MKTS.FENCES.parse probe
#     T.eq ( MKTS.FENCES.parse probe, symmetric: no ), matcher
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.TRACKER.new_tracker (short comprehensive test)" ] = ( T, done ) ->
#   track = MKTS.TRACKER.new_tracker '(code)', '{multi-column}'
#   probes_and_matchers = [
#     [ [ '<', 'document',     ], [  no,  no, ], ]
#     [ [ '{', 'multi-column', ], [  no, yes, ], ]
#     [ [ '(', 'code',         ], [ yes, yes, ], ]
#     [ [ '{', 'multi-column', ], [ yes, yes, ], ]
#     [ [ '.', 'text',         ], [ yes, yes, ], ]
#     [ [ '}', 'multi-column', ], [ yes, yes, ], ]
#     [ [ ')', 'code',         ], [  no, yes, ], ]
#     [ [ '}', 'multi-column', ], [  no,  no, ], ]
#     [ [ '>', 'document',     ], [  no,  no, ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     track probe
#     whisper probe
#     help '(code):', ( track.within '(code)' ), '{multi-column}:', ( track.within '{multi-column}' )
#     T.eq ( track.within '(code)'          ), matcher[ 0 ]
#     T.eq ( track.within '{multi-column}'  ), matcher[ 1 ]
#   done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (1)" ] = ( T, done ) ->
#   # settings  = bare: yes
#   probe     = """`<<($>>eval block<<$)>>`"""
#   warn "should merge texts"
#   matcher   = [
#     ["<","document",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<($>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     [">","document",null,{}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, resume
#     show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (2)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """`<<($>>eval block<<$)>>`"""
#   warn "should merge texts"
#   matcher   = [
#     ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<($>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (3)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """`<<(\\$>>eval block<<\\$)>>`"""
#   warn "should merge texts"
#   matcher   = [
#     ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<(\\$>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","text","<<\\$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (4)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """<<!end>>"""
#   warn "match remark?"
#   matcher   = [
#     ["!","end",null,{"line_nr":1,"col_nr":2,"markup":"","stamped":true}]
#     ["#","info","encountered `<<!end>>` on line #1",{"line_nr":1,"col_nr":2,"markup":"","stamped":true,"badge":"$process_end_command"}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (5)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """<<!multi-column>>"""
#   warn "should not contain `.p`"
#   matcher   = [
#     ["!","multi-column",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (6)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     aaa
#     <<(multi-column>>
#     bbb
#     <<multi-column)>>
#     ccc
#     """
#   warn "missing `.p` inside `(multi-column)`"
#   matcher   = [
#     [".","text","aaa\n",{"line_nr":1,"col_nr":6,"markup":""}]
#     ["(","multi-column",null,{"line_nr":1,"col_nr":6,"markup":""}]
#     [".","text","\nbbb\n",{"line_nr":1,"col_nr":6,"markup":""}]
#     [")","multi-column",null,{"line_nr":1,"col_nr":6,"markup":""}]
#     [".","text","\nccc",{"line_nr":1,"col_nr":6,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":6,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (7)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     她說：「你好。」
#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = [
#     [".","text","她說：「你好。」",{"line_nr":1,"col_nr":2,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md (8)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     A paragraph with *emphasis*.

#     A paragraph with **bold text**.
#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = [
#     [".","text","A paragraph with ",{"line_nr":1,"col_nr":2,"markup":""}]
#     ["(","em",null,{"line_nr":1,"col_nr":2,"markup":"*"}]
#     [".","text","emphasis",{"line_nr":1,"col_nr":2,"markup":""}]
#     [")","em",null,{"line_nr":1,"col_nr":2,"markup":"*"}]
#     [".","text",".",{"line_nr":1,"col_nr":2,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
#     [".","text","A paragraph with ",{"line_nr":3,"col_nr":4,"markup":""}]
#     ["(","strong",null,{"line_nr":3,"col_nr":4,"markup":"**"}]
#     [".","text","bold text",{"line_nr":3,"col_nr":4,"markup":""}]
#     [")","strong",null,{"line_nr":3,"col_nr":4,"markup":"**"}]
#     [".","text",".",{"line_nr":3,"col_nr":4,"markup":""}]
#     [".","p",null,{"line_nr":3,"col_nr":4,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS.mkts_events_from_md: footnotes" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     Here is an inline footnote^[whose text appears at the point of insertion],
#     followed by a referenced footnote[^1].

#     [^1]: Referenced footnotes must use matching references.
#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = [
#     [".","text","Here is an inline footnote",{"line_nr":1,"col_nr":3,"markup":""}]
#     ["(","footnote",0,{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","text","whose text appears at the point of insertion",{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":3,"markup":""}]
#     [")","footnote",0,{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","text",",\nfollowed by a referenced footnote",{"line_nr":1,"col_nr":3,"markup":""}]
#     ["(","footnote",1,{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","text","Referenced footnotes must use matching references.",{"line_nr":4,"col_nr":5,"markup":""}]
#     [".","p",null,{"line_nr":4,"col_nr":5,"markup":""}]
#     [")","footnote",1,{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","text",".",{"line_nr":1,"col_nr":3,"markup":""}]
#     [".","p",null,{"line_nr":1,"col_nr":3,"markup":""}]
#     ]
#   step ( resume ) =>
#     result = yield MKTS.mkts_events_from_md probe, settings, resume
#     # show_events probe, result
#     T.eq matcher, result
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS_XXX.tex_from_md (1)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     A paragraph with *emphasis*.

#     A paragraph with **bold text**.
#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = """
#     % begin of MD document
#     A paragraph with {\\mktsStyleItalic{}emphasis\\/}.\\mktsShowpar\\par
#     A paragraph with {\\mktsStyleBold{}bold text}.\\mktsShowpar\\par

#     % end of MD document

#     """
#   step ( resume ) =>
#     result = yield MKTS_XXX.tex_from_md probe, settings, resume
#     echo result
#     T.eq matcher.trim(), result.trim()
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS_XXX.mktscript_from_md (1)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     A paragraph with *emphasis*.

#     A paragraph with **bold text**.

#     Using <foo>HTML tags **inhibits** MD syntax</foo>.
#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = """
#     1 █ (document
#     1 █ .text 'A paragraph with '
#     1 █ (em
#     1 █ .text 'emphasis'
#     1 █ )em
#     1 █ .text '.'
#     1 █ .p
#     3 █ .text 'A paragraph with '
#     3 █ (strong
#     3 █ .text 'bold text'
#     3 █ )strong
#     3 █ .text '.'
#     3 █ .p
#     5 █ .text 'Using '
#     5 █ (foo
#     5 █ .text 'HTML tags '
#     5 █ (strong
#     5 █ .text 'inhibits'
#     5 █ )strong
#     5 █ .text ' MD syntax'
#     5 █ )foo
#     5 █ .text '.'
#     5 █ .p
#     )document
#     # EOF
#     """
#   step ( resume ) =>
#     result = yield MKTS.mktscript_from_md probe, settings, resume
#     echo result
#     T.eq matcher.trim(), result.trim()
#     done()

# #-----------------------------------------------------------------------------------------------------------
# @[ "MKTS_XXX.mktscript_from_md (2)" ] = ( T, done ) ->
#   settings  = bare: yes
#   probe     = """
#     <<(multi-column>>

#     <div>B</div>

#     """
#   # warn "missing `.p` inside `(multi-column)`"
#   matcher   = """
#     1 █ (document
#     1 █ (multi-column
#     1 █ .p
#     1 █ (div
#     1 █ .text 'B'
#     1 █ )div
#     1 █ .p
#     #resend '`multi-column)`'
#     1 █ )multi-column
#     )document
#     # EOF
#     """
#   step ( resume ) =>
#     result = yield MKTS.mktscript_from_md probe, settings, resume
#     echo result
#     T.eq matcher.trim(), result.trim()
#     # T.fail "not yet ready"
#     done()


#===========================================================================================================
# MAIN
#-----------------------------------------------------------------------------------------------------------
@_main = ( handler ) ->
  test @, 'timeout': 2500


############################################################################################################
unless module.parent?
  @_main()

