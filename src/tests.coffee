





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


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse accepts dot patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '.',     [ '.', null,   null, ], ]
    [ '.p',    [ '.', 'p',    null, ], ]
    [ '.text', [ '.', 'text', null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.FENCES.parse probe
    T.eq ( MKTS.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse accepts empty fenced patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '<>', [ '<', null, '>', ], ]
    [ '{}', [ '{', null, '}', ], ]
    [ '[]', [ '[', null, ']', ], ]
    [ '()', [ '(', null, ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.FENCES.parse probe
    T.eq ( MKTS.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse accepts unfenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ 'document',       [ null, 'document',     null, ], ]
    [ 'singlecolumn',   [ null, 'singlecolumn', null, ], ]
    [ 'code',           [ null, 'code',         null, ], ]
    [ 'blockquote',     [ null, 'blockquote',   null, ], ]
    [ 'em',             [ null, 'em',           null, ], ]
    [ 'xxx',            [ null, 'xxx',          null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.FENCES.parse probe
    T.eq ( MKTS.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse accepts fenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '<document>',     [ '<', 'document',     '>', ], ]
    [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
    [ '{code}',         [ '{', 'code',         '}', ], ]
    [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
    [ '(em)',           [ '(', 'em',           ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.FENCES.parse probe
    T.eq ( MKTS.FENCES.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse rejects empty string" ] = ( T, done ) ->
  T.throws "pattern must be non-empty, got ''", ( -> MKTS.FENCES.parse '' )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse rejects non-matching fences etc" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '(xxx}',  'fences don\'t match in pattern \'(xxx}\'',          ]
    [ '.)',     'fence \'.\' can not have right fence, got \'.)\'',  ]
    [ '.p)',    'fence \'.\' can not have right fence, got \'.p)\'', ]
    [ '.[',     'fence \'.\' can not have right fence, got \'.[\'',  ]
    [ '<',      'unmatched fence in \'<\'',                          ]
    [ '{',      'unmatched fence in \'{\'',                          ]
    [ '[',      'unmatched fence in \'[\'',                          ]
    [ '(',      'unmatched fence in \'(\'',                          ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    T.throws matcher, ( -> MKTS.FENCES.parse probe )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.FENCES.parse accepts non-matching fences when so configured" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '<document>',     [ '<', 'document',     '>', ], ]
    [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
    [ '{code}',         [ '{', 'code',         '}', ], ]
    [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
    [ '(em)',           [ '(', 'em',           ')', ], ]
    [ 'document>',      [ null, 'document',     '>', ], ]
    [ 'singlecolumn}',  [ null, 'singlecolumn', '}', ], ]
    [ 'code}',          [ null, 'code',         '}', ], ]
    [ 'blockquote]',    [ null, 'blockquote',   ']', ], ]
    [ 'em)',            [ null, 'em',           ')', ], ]
    [ '<document',      [ '<', 'document',     null, ], ]
    [ '{singlecolumn',  [ '{', 'singlecolumn', null, ], ]
    [ '{code',          [ '{', 'code',         null, ], ]
    [ '[blockquote',    [ '[', 'blockquote',   null, ], ]
    [ '(em',            [ '(', 'em',           null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.FENCES.parse probe
    T.eq ( MKTS.FENCES.parse probe, symmetric: no ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.new_tracker (short comprehensive test)" ] = ( T, done ) ->
  track = MKTS.TRACKER.new_tracker '(code)', '{multi-column}'
  probes_and_matchers = [
    [ [ '<', 'document',     ], [  no,  no, ], ]
    [ [ '{', 'multi-column', ], [  no, yes, ], ]
    [ [ '(', 'code',         ], [ yes, yes, ], ]
    [ [ '{', 'multi-column', ], [ yes, yes, ], ]
    [ [ '.', 'text',         ], [ yes, yes, ], ]
    [ [ '}', 'multi-column', ], [ yes, yes, ], ]
    [ [ ')', 'code',         ], [  no, yes, ], ]
    [ [ '}', 'multi-column', ], [  no,  no, ], ]
    [ [ '>', 'document',     ], [  no,  no, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    track probe
    whisper probe
    help '(code):', ( track.within '(code)' ), '{multi-column}:', ( track.within '{multi-column}' )
    T.eq ( track.within '(code)'          ), matcher[ 0 ]
    T.eq ( track.within '{multi-column}'  ), matcher[ 1 ]
  done()

#-----------------------------------------------------------------------------------------------------------
show_events = ( probe, events ) ->
  whisper probe
  echo "["
  for event in events
    echo "    #{JSON.stringify event}"
  echo "    ]"

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (1)" ] = ( T, done ) ->
  # settings  = bare: yes
  probe     = """`<<($>>eval block<<$)>>`"""
  warn "should merge texts"
  matcher   = [
    ["<","document",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<($>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    [">","document",null,{}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (2)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """`<<($>>eval block<<$)>>`"""
  warn "should merge texts"
  matcher   = [
    ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<($>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (3)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """`<<(\\$>>eval block<<\\$)>>`"""
  warn "should merge texts"
  matcher   = [
    ["(","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<(\\$>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","eval block",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","text","<<\\$)>>",{"line_nr":1,"col_nr":2,"markup":"`"}]
    [")","code",null,{"line_nr":1,"col_nr":2,"markup":"`"}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (4)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """<<!end>>"""
  warn "match remark?"
  matcher   = [
    ["!","end",null,{"line_nr":1,"col_nr":2,"markup":"","stamped":true}]
    ["#","info","encountered `<<!end>>` on line #1",{"line_nr":1,"col_nr":2,"markup":"","stamped":true,"badge":"$process_end_command"}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (5)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """<<!multi-column>>"""
  warn "should not contain `.p`"
  matcher   = [
    ["!","multi-column",null,{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (6)" ] = ( T, done ) ->
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
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (7)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    她說：「你好。」
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = [
    [".","text","她說：「你好。」",{"line_nr":1,"col_nr":2,"markup":""}]
    [".","p",null,{"line_nr":1,"col_nr":2,"markup":""}]
    ]
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md (8)" ] = ( T, done ) ->
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
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.mkts_events_from_md: footnotes" ] = ( T, done ) ->
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
  step ( resume ) =>
    result = yield MKTS.mkts_events_from_md probe, settings, resume
    # show_events probe, result
    T.eq matcher, result
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS_XXX.tex_from_md (1)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    A paragraph with *emphasis*.

    A paragraph with **bold text**.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    % begin of MD document
    A paragraph with {\\mktsStyleItalic{}emphasis\\/}.\\mktsShowpar\\par
    A paragraph with {\\mktsStyleBold{}bold text}.\\mktsShowpar\\par

    % end of MD document

    """
  step ( resume ) =>
    result = yield MKTS_XXX.tex_from_md probe, settings, resume
    echo result
    T.eq matcher.trim(), result.trim()
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS_XXX.mktscript_from_md (1)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    A paragraph with *emphasis*.

    A paragraph with **bold text**.
    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    1 █ <document
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
    >document
    # EOF
    """
  step ( resume ) =>
    result = yield MKTS.mktscript_from_md probe, settings, resume
    echo result
    T.eq matcher.trim(), result.trim()
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS_XXX.mktscript_from_md (2)" ] = ( T, done ) ->
  settings  = bare: yes
  probe     = """
    <<(multi-column>>

    <div>B</div>

    """
  # warn "missing `.p` inside `(multi-column)`"
  matcher   = """
    1 █ <document
    1 █ (multi-column
    1 █ .p
    1 █ (div
    1 █ .text 'B'
    1 █ )div
    1 █ .p
    #resend '`multi-column)`'
    1 █ )multi-column
    >document
    # EOF
    """
  step ( resume ) =>
    result = yield MKTS.mktscript_from_md probe, settings, resume
    echo result
    T.eq matcher.trim(), result.trim()
    # T.fail "not yet ready"
    done()


#===========================================================================================================
# MAIN
#-----------------------------------------------------------------------------------------------------------
@_main = ( handler ) ->
  test @, 'timeout': 2500


############################################################################################################
unless module.parent?
  @_main()

