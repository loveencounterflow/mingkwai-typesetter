
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'HTML-TAGS/TESTS'
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
test                      = require 'guy-test'
eq                        = CND.equals
jr                        = JSON.stringify
#...........................................................................................................
join                      = ( x, joiner = '' ) -> x.join joiner
XREGEXP                   = require 'xregexp'



#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  test @, 'timeout': 30000

#-----------------------------------------------------------------------------------------------------------
get_patterns = ( tag_name ) -> {
  start: ///<#{tag_name}>|<#{tag_name}\s+(?<attributes>[^>]*)(?<!\/)>///g
  stop:  ///<\/#{tag_name}>///g }

#-----------------------------------------------------------------------------------------------------------
@[ "basic" ] = ( T, done ) ->
  probes_and_matchers = [
    ["div","what<div>helo",true,null]
    ["div","what<div a=10>helo",true,"a=10"]
    ["div","what<div path=foo/bar>helo",true,"path=foo/bar"]
    ["div","what<div path=foo/bar/>helo",false,null]
    ["div","what<div path='foo/bar/'>helo",true,"path='foo/bar/'"]
    ["frob","what<frob/>helo",false,null]
    ]
  #.........................................................................................................
  for [ tag_name, probe, is_hit_matcher, attributes_matcher, ] in probes_and_matchers
    start_tag_pattern = ///<#{tag_name}>|<#{tag_name}\s+(?<attributes>[^>]*)(?<!\/)>///
    result      = probe.match start_tag_pattern
    is_hit      = result?
    attributes  = result?.groups?.attributes ? null
    urge '36633', ( jr [ tag_name, probe, is_hit, attributes, ] )
    T.eq is_hit, is_hit_matcher
    T.eq attributes, attributes_matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "start pattern" ] = ( T, done ) ->
  probes_and_matchers = [
    ["div","what<div>helo",["<div>"]]
    ["div","what<div a=10>helo",["<div a=10>"]]
    ["div","what<div path=foo/bar>helo<div>x</div></div>",["<div path=foo/bar>","<div>"]]
    ["div","what<div path=foo/bar/ frob=42 ding>helo",["<div path=foo/bar/ frob=42 ding>"]]
    ["div","what<div path='foo/bar/'>helo",["<div path='foo/bar/'>"]]
    ["div","what<div path=foo/bar/>helo",null]
    ["frob","what<frob/>helo",null]
    ]
  #.........................................................................................................
  for [ tag_name, probe, matcher, ] in probes_and_matchers
    patterns    = get_patterns tag_name
    result      = probe.match patterns.start
    urge '36633', ( jr [ tag_name, probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "recursive" ] = ( T, done ) ->
  probes_and_matchers = [
    ["div","what<div>helo\n</div>",[{"name":"between","value":"what"},{"name":"left","value":"<div>"},{"name":"match","value":"helo\n"},{"name":"right","value":"</div>"}]]
    ["div","what<div a=10>helo</div>",[{"name":"between","value":"what"},{"name":"left","value":"<div a=10>"},{"name":"match","value":"helo"},{"name":"right","value":"</div>"}]]
    ["raw","what<raw path=foo/bar>helo</raw>",[{"name":"between","value":"what"},{"name":"left","value":"<raw path=foo/bar>"},{"name":"match","value":"helo"},{"name":"right","value":"</raw>"}]]
    ["raw","what<raw path=foo/bar/>helo",[{"name":"between","value":"what<raw path=foo/bar/>helo"}]]
    ["raw","what<raw path='foo/bar/'>helo</raw>",[{"name":"between","value":"what"},{"name":"left","value":"<raw path='foo/bar/'>"},{"name":"match","value":"helo"},{"name":"right","value":"</raw>"}]]
    ["frob","what<frob/>helo",[{"name":"between","value":"what<frob/>helo"}]]
    ]
  #.........................................................................................................
  settings  = { valueNames: [ 'between', 'left', 'match', 'right', ], }
  for [ tag_name, probe, matcher, ] in probes_and_matchers
    { start, stop, }  = get_patterns tag_name
    try
      result = XREGEXP.matchRecursive probe, start.source, stop.source, 'g', settings
    catch error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    result      = ( { name, value, } for { name, value, } in result )
    urge '36633', ( jr [ tag_name, probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "parse attributes" ] = ( T, done ) ->
  probes_and_matchers = [
    ["div","what<div>helo\n</div>",[{"name":"between","value":"what"},{"name":"left","value":"<div>"},{"name":"match","value":"helo\n"},{"name":"right","value":"</div>"}]]
    ["div","what<div a=10>helo</div>",[{"name":"between","value":"what"},{"name":"left","value":"<div a=10>"},{"name":"match","value":"helo"},{"name":"right","value":"</div>"}]]
    ["raw","what<raw path=foo/bar>helo</raw>",[{"name":"between","value":"what"},{"name":"left","value":"<raw path=foo/bar>"},{"name":"match","value":"helo"},{"name":"right","value":"</raw>"}]]
    ["raw","what<raw path=foo/bar/>helo",[{"name":"between","value":"what<raw path=foo/bar/>helo"}]]
    ["raw","what<raw path='foo/bar/'>helo</raw>",[{"name":"between","value":"what"},{"name":"left","value":"<raw path='foo/bar/'>"},{"name":"match","value":"helo"},{"name":"right","value":"</raw>"}]]
    ["frob","what<frob/>helo",[{"name":"between","value":"what<frob/>helo"}]]
    ]
  #.........................................................................................................
  settings  = { valueNames: [ 'between', 'left', 'match', 'right', ], }
  for [ tag_name, probe, matcher, ] in probes_and_matchers
    { start, stop, }  = get_patterns tag_name
    try
      result = XREGEXP.matchRecursive probe, start.source, stop.source, 'g', settings
    catch error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    result      = ( { name, value, } for { name, value, } in result )
    urge '36633', ( jr [ tag_name, probe, result, ] )
    # T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "htmlish-tag-parser" ] = ( T, done ) ->
  probes_and_matchers = [
    # ["<embedded-file>",]
    # ["<embedded-file name=foobar>",]
    # ["<embedded-file name='foobar'>",]
    # ["<embedded-file name=\"foobar\">",]
    # ["<xy:embedded-file>",]
    # ["<xy:embedded-file name=foobar>",]
    # ["<xy:embedded-file name='foobar'>",]
    # ["<xy:embedded-file name=\"foobar\">",]
    # ["<xy:embedded-file>",]
    # ["<xy:embedded-file name=foobar/>",]
    # ["<xy:embedded-file name='foobar'/>",]
    # ["<xy:embedded-file name=\"foobar\"/>",]
    ["<tag/> x"]
    ["<tag> x"]
    ["<br/> x"]
    ["<br> x"]
    # ["some text with a <tag/> in it"]
    # ["some text with a <br/> in it"]
    ]
  #.........................................................................................................
  PARSE5 = require 'parse5'
  for [ probe, matcher, ] in probes_and_matchers
    for node in ( PARSE5.parseFragment probe ).childNodes
      delete node.namespaceURI
      delete node.parentNode
      debug '98932', node
      name        = node.tagName
      attributes  = node.attrs
      tree        = node.childNodes
      urge '36633', ( jr { name, attributes, } )
    # T.eq result, matcher
  #.........................................................................................................
  done()

  # for [ probe, matcher, ] in probes_and_matchers
  #   result = probe.match start_tag_pattern
  #   try
  #   catch error
  #     # throw error


############################################################################################################
unless module.parent?
  include = [
    "basic"
    "start pattern"
    "recursive"
    "parse attributes"
    # "htmlish-tag-parser"
    ]
  @_prune()
  @_main()






