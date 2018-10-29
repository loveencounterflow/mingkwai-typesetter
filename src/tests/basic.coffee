




'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE/UNITS/TESTS'
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
UNITS                     = require '../mkts-table-units'

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
@[ "UNITS.parse_nonnegative_quantity 1" ] = ( T, done ) ->
  probes_and_matchers = [
    ["1mm",{"value":1,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["1.2mm",{"value":1.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["0.3\\mktsLineheight",{"value":0.3,"unit":"\\mktsLineheight","~isa":"MKTS/TABLE/quantity"}]
    ["123456.2mm",{"value":123456.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["300mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300 mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300 mm   ",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["0.3",null]
    ["-300mm",null]
    ["+300mm",null]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = UNITS.parse_nonnegative_quantity probe
    catch error
      if ( matcher is null ) and ( error.message.match /unable to parse .* as nonnegative quantity/ )?
        urge '36633', ( jr [ probe, matcher, ] )
        T.ok true
      else
        T.fail "unexpected error for probe #{rpr probe}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "UNITS.as_text 1" ] = ( T, done ) ->
  probes_and_matchers = [
    ["1mm","1mm"]
    ["1.2mm","1.2mm"]
    ["0.3\\mktsLineheight","0.3\\mktsLineheight"]
    ["123456.2mm","123456.2mm"]
    ["300mm","300mm"]
    [" 300mm","300mm"]
    [" 300 mm","300mm"]
    [" 300 mm   ","300mm"]
    ]
  #.........................................................................................................
  for [ probe_txt, matcher, ] in probes_and_matchers
    try
      probe   = UNITS.parse_nonnegative_quantity probe_txt
      result  = UNITS.as_text probe
    catch error
      T.fail "unexpected error for probe #{rpr probe_txt}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probe_txt, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "UNITS.parse_nonnegative_quantity 1"
    "UNITS.as_text 1"
    ]
  @_prune()
  @_main()








