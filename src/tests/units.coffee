




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
@[ "UNITS.parse 1" ] = ( T, done ) ->
  probes_and_matchers = [
    ["1mm",{"value":1,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["1.2mm",{"value":1.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["0.3\\mktsLineheight",{"value":0.3,"unit":"\\mktsLineheight","~isa":"MKTS/TABLE/quantity"}]
    ["123456.2mm",{"value":123456.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["300mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300 mm",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" 300 mm   ",{"value":300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["-1mm",{"value":-1,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["-1.2mm",{"value":-1.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["-0.3\\mktsLineheight",{"value":-0.3,"unit":"\\mktsLineheight","~isa":"MKTS/TABLE/quantity"}]
    ["-123456.2mm",{"value":-123456.2,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["-300mm",{"value":-300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" -300mm",{"value":-300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" -300 mm",{"value":-300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    [" -300 mm   ",{"value":-300,"unit":"mm","~isa":"MKTS/TABLE/quantity"}]
    ["0.3",null]
    ["-0.3",null]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = UNITS.parse probe
    catch error
      if ( matcher is null ) and ( error.message.match /unable to parse/ )?
        # urge '36633', ( jr [ probe, matcher, ] )
        T.ok true
      else
        T.fail "unexpected error for probe #{rpr probe}: #{rpr error.message}"
      continue
    # urge '36633', ( jr [ probe, result, ] )
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
      probe   = UNITS.parse probe_txt
      result  = UNITS.as_text probe
    catch error
      T.fail "unexpected error for probe #{rpr probe_txt}: #{rpr error.message}"
      continue
    # urge '36633', ( jr [ probe_txt, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "UNITS.as_text 2" ] = ( T, done ) ->
  probes_and_matchers = [
    [["1mm","*",2],"2mm"]
    [["1.2mm","*",2],"2.4mm"]
    [["0.3\\mktsLineheight","*",2],"0.6\\mktsLineheight"]
    [["123456.2mm","*",2],"246912.4mm"]
    [["300mm","*",2],"600mm"]
    [[" 300mm","*",2],"600mm"]
    [[" 300 mm","*",2],"600mm"]
    [[" 300 mm   ","*",2],"600mm"]
    ]
  #.........................................................................................................
  for [ probes, matcher, ] in probes_and_matchers
    [ unit_probe_txt, operator_probe, factor_probe, ] = probes
    unit_probe                                        = UNITS.parse unit_probe_txt
    try
      result  = UNITS.as_text unit_probe, operator_probe, factor_probe
    catch error
      T.fail "unexpected error for probe #{rpr probes}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probes, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "UNITS.as_text 3" ] = ( T, done ) ->
  probes_and_matchers = [
    [["1mm","*",2],"2mm"]
    [["1.2mm","*",2],"2.4mm"]
    [["0.3\\mktsLineheight","*",2],"0.6\\mktsLineheight"]
    [["123456.2mm","*",2],"246912.4mm"]
    [["300mm","*",2],"600mm"]
    [[" 300mm","*",2],"600mm"]
    [[" 300 mm","*",2],"600mm"]
    [[" 300 mm   ","*",2],"600mm"]
    ]
  #.........................................................................................................
  for [ probes, matcher, ] in probes_and_matchers
    [ unit_probe_txt, operator_probe, factor_probe, ] = probes
    unit_probe                                        = UNITS.parse unit_probe_txt
    try
      result  = UNITS.as_text factor_probe, operator_probe, unit_probe
    catch error
      T.fail "unexpected error for probe #{rpr probes}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probes, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "UNITS.as_text 3" ] = ( T, done ) ->
  probes_and_matchers = [
    [["1mm","*",],"2mm"]
    [["1.2mm","*",null],"2.4mm"]
    ]
  #.........................................................................................................
  for [ probes, matcher, ] in probes_and_matchers
    [ unit_probe_txt, operator_probe, factor_probe, ] = probes
    unit_probe                                        = UNITS.parse unit_probe_txt
    try
      result  = UNITS.as_text factor_probe, operator_probe, unit_probe
    catch error
      if ( error.message.match /expected a 'MKTS\/TABLE\/quantity', got a/ )?
        T.ok true
      else
        T.fail "unexpected error for probe #{rpr probes}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probes, result, ] )
    # T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "integer multiples" ] = ( T, done ) ->
  probes_and_matchers = [
    [["15mm","5mm"],{"~isa":"MKTS/TABLE/quantity","value":15,"unit":"mm"}]
    [["14.5mm","5mm"],{"~isa":"MKTS/TABLE/quantity","value":15,"unit":"mm"}]
    [["15.5mm","5mm"],{"~isa":"MKTS/TABLE/quantity","value":20,"unit":"mm"}]
    [["15mm","0.5cm"],{"~isa":"MKTS/TABLE/quantity","value":1.5,"unit":"cm"}]
    [["14.5mm","0.5cm"],{"~isa":"MKTS/TABLE/quantity","value":1.5,"unit":"cm"}]
    [["15.5mm","0.5cm"],{"~isa":"MKTS/TABLE/quantity","value":2,"unit":"cm"}]
    [["5.25mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":1,"unit":"lineheight"}]
    [["5.26mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":1,"unit":"lineheight"}]
    [["5.27mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":2,"unit":"lineheight"}]
    [["0.525cm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":1,"unit":"lineheight"}]
    [["0.526cm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":1,"unit":"lineheight"}]
    [["0.527cm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":2,"unit":"lineheight"}]
    [["15mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":3,"unit":"lineheight"}]
    [["14.5mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":3,"unit":"lineheight"}]
    [["15.5mm","lineheight"],{"~isa":"MKTS/TABLE/quantity","value":3,"unit":"lineheight"}]
    [["15mm","2lineheight"],{"~isa":"MKTS/TABLE/quantity","value":4,"unit":"lineheight"}]
    [["14.5mm","2lineheight"],{"~isa":"MKTS/TABLE/quantity","value":4,"unit":"lineheight"}]
    [["15.5mm","2lineheight"],{"~isa":"MKTS/TABLE/quantity","value":4,"unit":"lineheight"}]
    ]
  #.........................................................................................................
  for [ probes, matcher, ] in probes_and_matchers
    [ cmp_probe_txt, ref_probe_txt, ] = probes
    cmp_probe       = UNITS.parse cmp_probe_txt
    ref_probe       = UNITS.parse ref_probe_txt
    cmp_probe_copy  = Object.assign {}, cmp_probe
    ref_probe_copy  = Object.assign {}, ref_probe
    try
      result  = UNITS.integer_multiple cmp_probe, ref_probe
    catch error
      if ( matcher is null ) and ( error.message.match /expected a 'MKTS\/TABLE\/quantity', got a/ )?
        T.ok true
      else
        T.fail "unexpected error for probe #{rpr probes}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probes, result, ] )
    T.eq cmp_probe, cmp_probe_copy
    T.eq ref_probe, ref_probe_copy
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "UNITS.parse 1"
    "UNITS.as_text 1"
    "UNITS.as_text 2"
    "UNITS.as_text 3"
    "integer multiples"
    ]
  @_prune()
  @_main()








