
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTSCRIPT-PARSER-2/TESTS'
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
# XREGEXP                   = require 'xregexp'
MKTSP2                    = require '../experiments/mktscript-parser-2'
RCY                       = require '../experiments/recycle'
select                    = RCY.select
PS                        = require 'pipestreams'
{ $, $async, }            = PS



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
@_parse = ( text, handler ) ->
  S         = {}
  collector = null
  source    = RCY.new_push_source()
  pipeline  = []
  pipeline.push source
  # pipeline.push PS.$watch ( d ) => whisper '33301', jr d unless select d, '~', 'flush'
  pipeline.push MKTSP2.$parse_special_forms S
  # pipeline.push PS.$watch ( d ) => urge jr d
  # pipeline.push MKTSP2.$show_events         S
  pipeline.push PS.$watch ( d ) ->
    collector ?= []
    if RCY.select d, '~', 'flush'
      handler null, collector
      collector = null
    else
      collector.push d
    return null
  pipeline.push PS.$drain()
  PS.pull pipeline...
  source.push text
  source.push RCY.new_system_event 'flush'
  return null

#-----------------------------------------------------------------------------------------------------------
_reduce = ( d ) ->
  R = {}
  R[ key ] = value for key, value of d when key not in [ 'sigil', 'key', 'value', '$', ]
  return if ( Object.keys R ).length > 0 then jr R else ''

#-----------------------------------------------------------------------------------------------------------
@_as_mktscript = ( events ) ->
  R = []
  #.........................................................................................................
  for d in events
    #.......................................................................................................
    if ( select d, '.', 'text' )
      R.push d.value
    #.......................................................................................................
    else if ( select d, '~', 'warning' )
      R.push "<warning ref=#{rpr d.ref}>#{d.message}</warning>"
    #.......................................................................................................
    else if ( select d, '~', null )
      R.push "<~#{d.key}/>"
    #.......................................................................................................
    else if ( select d, '.', null )
      R.push "<#{d.key}/>"
    # #.......................................................................................................
    # else if ( select d, '(', 'sf' )
    #   R.push "<#{d.key} value=#{d.value}>"
    # #.......................................................................................................
    # else if ( select d, ')', 'sf' )
    #   R.push "<#{d.key} value=#{d.value}>"
    #.......................................................................................................
    else if ( select d, '(', null )
      ### TAINT add attributes ###
      R.push "<#{d.key}>"
    #.......................................................................................................
    else if ( select d, ')', null )
      ### TAINT add attributes ###
      R.push "</#{d.key}>"
    #.......................................................................................................
    else
      throw new Error "illegal event #{rpr d}"
  #.........................................................................................................
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@[ "htmlish-tag-parser" ] = ( T, done ) ->
  S = {}
  probes_and_matchers = [
    ["a line of text.","a line of text."]
    ["a line of *text*.","a line of <em>text</em>."]
    ["a line of 𣥒text*.","a line of <warning ref='µ99823'>unhandled active characters '𣥒' on line 1 in 'a line of 𣥒text*.'</warning>"]
    ["a **strong** and a *less strong* emphasis.","a <strong>strong</strong> and a <em>less strong</em> emphasis."]
    ["a *normal and a **strong** emphasis*.","a <em>normal and a <strong>strong</strong> emphasis</em>."]
    ["another *such and **such*** emphasis.","another <em>such and <strong>such</strong></em> emphasis."]
    ["lone *star","lone <em>star"]
    ["**lone *star*","<strong>lone <em>star</em>"]
    ["**lone *star**","<strong>lone <em>star</strong>"]
    ["*","<em>"]
    ["**","<strong>"]
    ["***","<em><strong>"]
    ["**double *star","<strong>double <em>star"]
    ["***em* strong**.","<strong><em>em</em> strong</strong>."]
    ["***strong** em*.","<em><strong>strong</strong> em</em>."]
    ["***em-strong***.","<em><strong>em-strong</strong></em>."]
    ]
  #.........................................................................................................
  for [ probe, matcher, ], idx in probes_and_matchers
    @_parse probe, ( error, result ) =>
      throw error if error?
      result = @_as_mktscript result
      echo ( if ( CND.equals result, matcher ) then CND.gold else CND.red ) jr [ probe, result, ]
      # T.eq result, matcher
    # urge '36633', ( jr { name, attributes, } )
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
    "htmlish-tag-parser"
    ]
  @_prune()
  @_main()

  # @_parse 'helo'




