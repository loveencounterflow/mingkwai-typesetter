
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/VALIDATOR/TESTS'
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
OVAL                      = require '../object-validator'



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
test_probe = ( T, validate, probe, matcher, do_compare = true ) ->
  result = null
  try
    result = validate probe
  catch error
    if ( matcher is null )
      ### TAINT opportunity for silent failure ###
      help '36633', ( jr [ probe, matcher, ] ), ( CND.grey '#!!! ' + error.message[ .. 50 ] )
      T.ok true
    else
      warn '36633', ( jr [ probe, matcher, ] )
      T.fail "unexpected error for probe #{rpr probe}: #{rpr error.message}"
    return null
  urge '36633', ( jr [ probe, result, ] )
  if do_compare
    if ( matcher is null ) and ( result isnt null )
      T.fail "expected error but got result #{jr result}"
    else
      T.eq result, matcher
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "basic" ] = ( T, done ) ->
  schema =
    properties:
      foo:  { type: 'integer', }
      bar:  { type: 'boolean', }
    required: [ 'foo', 'bar', ]
    additionalProperties: false
  #.........................................................................................................
  probes_and_matchers = [
    [{"foo":"1","bar":"true","baz":"true"},null]
    [{"foo":"1.1","bar":"f","baz":"true"},null]
    [{},null]
    [{"foo":1,"bar":true},{"foo":1,"bar":true}]
    [{"foo":"1","bar":"true"},{"foo":1,"bar":true}]
    ]
  #.........................................................................................................
  validate = OVAL.new_validator schema
  for [ probe, matcher, ] in probes_and_matchers
    test_probe T, validate, probe, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "scale tag schema" ] = ( T, done ) ->
  schema =
    postprocess: ( Q ) ->
      Q.lines = true if Q.lines is ''
      return Q
    properties:
      abs:    { type: 'number', }
      rel:    { type: 'number', }
      lines:  { type: [ 'boolean', 'string', ], }
    additionalProperties: false
    oneOf: [ { required: [ 'abs', ], }, { required: [ 'rel', ], }, ]
  #.........................................................................................................
  probes_and_matchers = [
    [{"abs":"0.8"},{"abs":0.8}]
    [{"abs":"0.8","lines":""},{"abs":0.8,"lines":true}]
    [{"rel":"0.8"},{"rel":0.8}]
    [{"rel":"0.8","lines":""},{"rel":0.8,"lines":true}]
    [{"lines":""},null]
    [{"rel":"1","abs":"2"},null]
    ]
  #.........................................................................................................
  validate = OVAL.new_validator schema
  for [ probe, matcher, ] in probes_and_matchers
    test_probe T, validate, probe, matcher, true
  #.........................................................................................................
  done()


############################################################################################################
unless module.parent?
  include = [
    "basic"
    "scale tag schema"
    ]
  @_prune()
  @_main()






