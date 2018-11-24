


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/VALIDATOR'
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
jr                        = JSON.stringify
Ajv                       = require 'ajv'


#-----------------------------------------------------------------------------------------------------------
@_message_from_error = ( data, error ) ->
  R = []
  R.push "OVAL µ33892 property #{error.dataPath}: #{error.message} (got #{rpr error.data})"
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@_message_from_errors = ( data, errors ) ->
  R = []
  R.push @_message_from_error data, error for error in errors
  R.push ''
  R.push jr data
  R.push ''
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@new_validator = ( schema, settings = null ) ->
  delete schema.postprocess if ( postprocess = schema.postprocess )?
  postprocess      ?= ( data ) -> data
  defaults          = { coerceTypes: true, allErrors: true, verbose: true, }
  settings          = Object.assign {}, settings, defaults
  ajv               = new Ajv settings
  validate_and_cast = ajv.compile schema
  return ( data ) =>
    R = CND.deep_copy data
    unless validate_and_cast R
      throw new Error @_message_from_errors R, validate_and_cast.errors
    return postprocess R


############################################################################################################
unless module.parent?
  OVAL = @

  schema =
    # properties:
    #   foo:  { type: 'integer', }
    #   bar:  { type: 'boolean', }
    # required: [ 'foo', 'bar', ]
    # additionalProperties: false
    properties:
      abs:    { type: 'number', }
      rel:    { type: 'number', }
      lines:  { type: [ 'boolean', 'string', ], }
    # required:             [ 'foo', 'bar', ]
    additionalProperties: false

  validate  = OVAL.new_validator schema

  probes = [
    { abs: '0.8', }
    { abs: '0.8', lines: '', }
    { rel: '0.8', }
    { rel: '0.8', lines: '', }
    # { foo: '1', bar: 'true', baz: 'true' }
    # { foo: '1.1', bar: 'f', baz: 'true' }
    # {}
    # { foo: '1', bar: 'true', }
    ]
  for data in probes
    echo()
    try
      debug validate data
    catch error
      warn error.message
      continue
    help data



