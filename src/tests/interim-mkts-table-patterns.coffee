



'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE/INTERIM/PATTERN/TESTS'
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
MKTS_TABLE                = require '../mkts-table'

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
    ["A1..A4:\"japanese-text\"",{"selector":"A1..A4","alias":"japanese-text"}]
    ["  A1..A4  :  \"japanese-text\"  ",{"selector":"A1..A4","alias":"japanese-text"}]
    ["A1..A4",{"selector":"A1..A4"}]
    ]
  #.........................................................................................................
  # debug '93033', rpr MKTS_TABLE.fieldcells.source_pattern
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = probe.match MKTS_TABLE.fieldcells.source_pattern
      result = result.groups
      ( delete result[ key ] if result[ key ] in [ '', undefined, ] ) for key of result
    catch error
      if false # ( matcher is null ) and ( error.message.match /unable to parse .* as nonnegative quantity/ )?
        # urge '36633', ( jr [ probe, matcher, ] )
        T.ok true
      else
        T.fail "unexpected error for probe #{rpr probe}: #{rpr error.message}"
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "UNITS.parse_nonnegative_quantity 1"
    "UNITS.as_text 1"
    "UNITS.as_text 2"
    "UNITS.as_text 3"
    ]
  @_prune()
  @_main()








