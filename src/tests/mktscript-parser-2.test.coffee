
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
@[ "htmlish-tag-parser" ] = ( T, done ) ->
  S = {}
  probes_and_matchers = [
    'a line of text.'
    'a line of *text*.'
    'a line of 𣥒text*.'
    'a **strong** and a *less strong* emphasis.'
    'a *normal and a **strong** emphasis*.'
    # 'another *such and **such*** emphasis.'
    # '***em* strong**.'
    # '***strong** em*.'
    # '***strong-em***.'
    # 'lone *star'
    ]
  #.........................................................................................................
  for [ probe, matcher, ], idx in probes_and_matchers
    parser = MKTSP2.new_parser S, ( error, d ) ->
      throw error if error?
      whisper '#'.repeat 50
      whisper '90283', jr d
    parser.parse probe
    # urge '36633', ( jr { name, attributes, } )
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
    "htmlish-tag-parser"
    ]
  @_prune()
  @_main()






