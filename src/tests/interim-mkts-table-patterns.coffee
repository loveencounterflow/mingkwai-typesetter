



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
@[ "MKTS_TABLE.fieldcells.source_pattern" ] = ( T, done ) ->
  probes_and_matchers = [
    ["A1..A4:\"japanese-text\"",{"selector":"A1..A4","aliases":"\"japanese-text\""}]
    ["  A1..A4  :  \"japanese-text\"  ",{"selector":"A1..A4","aliases":"\"japanese-text\"  "}]
    ["A1..A4",{"selector":"A1..A4"}]
    ["A1..A4:\"japanese-text\",\"headings\",\"foo\"",{"selector":"A1..A4","aliases":"\"japanese-text\",\"headings\",\"foo\""}]
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

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS_TABLE._parse_aliases" ] = ( T, done ) ->
  probes_and_matchers = [
    ["\"japanese-text\"",null]
    ["@japanese-text,@headings,@foo",["@japanese-text","@headings","@foo"]]
    [" @japanese-text,  @headings , @foo  ",["@japanese-text","@headings","@foo"]]
    ["@some-name",["@some-name"]]
    ["@some-name,",["@some-name"]]
    ["@some-name,,@other-name",null]
    ["@some-name,,",null]
    ["@some-name,@other-name,",["@some-name","@other-name"]]
    ["",[]]
    [null,[]]
    ]
  #.........................................................................................................
  # debug '93033', rpr MKTS_TABLE.fieldcells.source_pattern
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = MKTS_TABLE._parse_aliases null, probe
    catch error
      if ( matcher is null ) and ( error.message.match /aliases must be prefixed with '@'/ )?
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
@_get_sample_table_1 = ->
  R = MKTS_TABLE._new_description null
  MKTS_TABLE.name         R, 'moderately-freeform-table'
  MKTS_TABLE.debug        R, 'false'
  MKTS_TABLE.grid         R, 'D4'
  MKTS_TABLE.unitwidth    R, '1mm'
  MKTS_TABLE.unitheight   R, '1mm'
  MKTS_TABLE.columnwidth  R, '20'
  MKTS_TABLE.rowheight    R, '10'
  MKTS_TABLE.fieldcells   R, 'A1..A4:@japanese-text'        # fieldnr 1
  MKTS_TABLE.fieldcells   R, 'B1..D1'                       # fieldnr 2
  MKTS_TABLE.fieldcells   R, 'B2..D2'                       # fieldnr 3
  MKTS_TABLE.fieldcells   R, 'B3..B4'                       # fieldnr 4
  MKTS_TABLE.fieldcells   R, 'C3..D4:@overlap-topright'     # fieldnr 5
  MKTS_TABLE.fieldcells   R, 'C3..D4:@overlap-bottomright'  # fieldnr 6
  MKTS_TABLE.fieldcells   R, 'C3..D4:@overlap-topleft'      # fieldnr 7
  MKTS_TABLE.fieldcells   R, 'C3..D4:@overlap-bottomleft'   # fieldnr 8
  MKTS_TABLE.fieldcells   R, 'A1..A4:#fancy-id'             # fieldnr 9
  return R

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS_TABLE._resolve_aliases" ] = ( T, done ) ->
  table = @_get_sample_table_1()
  #.........................................................................................................
  probes_and_matchers = [
    ["@japanese-text",[1]]
    ["#fancy-id",[9]]
    ["@overlap-bottomleft,C3",[8,"C3"]]
    ["@overlap-bottomleft,C3..D4",[8,'C3..D4']]
    ["A1..C3",["A1..C3"]]
    ["A1..C3,@japanese-text",["A1..C3",1]]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = MKTS_TABLE._resolve_aliases table, probe
    catch error
      if ( matcher is null ) and ( error.message.match /aliases must be prefixed with '@'/ )?
        urge '36633', ( jr [ probe, matcher, ] )
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
    "MKTS_TABLE.fieldcells.source_pattern"
    "MKTS_TABLE._parse_aliases"
    "MKTS_TABLE._resolve_aliases"
    ]
  @_prune()
  @_main()








