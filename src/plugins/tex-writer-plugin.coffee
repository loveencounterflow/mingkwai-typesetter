


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/PLUGIN'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
# #...........................................................................................................
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
# #...........................................................................................................
# ASYNC                     = require 'async'
# #...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require '../helpers'
# TEXLIVEPACKAGEINFO        = require '../texlivepackageinfo'
# options_route             = '../options.coffee'
# { CACHE, OPTIONS, }       = require '../options-and-cache'
# SEMVER                    = require 'semver'
# #...........................................................................................................
# XNCHR                     = require '../xnchr'
# MKTS                      = require '../main'
# MKTSCRIPT_WRITER          = require '../mktscript-writer'
MD_READER                 = require '../md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
# MACRO_ESCAPER             = require '../macro-escaper'
# MACRO_INTERPRETER         = require '../macro-interpreter'
# LINEBREAKER               = require '../linebreaker'
# @COLUMNS                  = require '../tex-writer-columns'
# @MKTS_TABLE               = require '../tex-writer-mkts-table'
# AUX                       = require '../tex-writer-aux'
# YADDA                     = require '../yadda'
OVAL                      = require '../object-validator'
# UNITS                     = require '../mkts-table-units'
#...........................................................................................................
# Σ_formatted_warning       = Symbol 'formatted-warning'
promisify                 = ( require 'util' ).promisify
jr                        = JSON.stringify
plugins_sym               = Symbol 'plugins'


#-----------------------------------------------------------------------------------------------------------
@_resolve_arguments = ( S, Q ) =>
  reference_path                      = S.layout_info[ 'source-home' ]
  #.....................................................................................................
  if ( match = Q.src.match /// ^ (?<module_path> .+? ) \# (?<method_path> [^\#]+ ) $ /// )?
    { module_path, method_path, } = match.groups
    method_path                   = null if method_path is ''
  #.....................................................................................................
  else
    module_path = Q.src
    method_path = 'main'
  #.....................................................................................................
  crumbs  = if method_path? then method_path.split '.' else null
  locator = PATH.join reference_path, module_path
  #.....................................................................................................
  try
    module    = require locator
    callable  = module
    if crumbs?
      for crumb in crumbs
        callable = callable[ crumb ]
        throw new Error "not callable: #{rpr crumb} in #{rpr method_path}" unless CND.isa_function callable
  catch error
    alert '98987-1', "when trying to resolve #{rpr Q.src}"
    alert '98987-2', "starting with module #{rpr locator}"
    alert '98987-3', "an error occurred"
    throw error
  #.....................................................................................................
  return Object.assign {}, Q, { locator, module_path, method_path, callable, }

#-----------------------------------------------------------------------------------------------------------
@_prefix_from_event = ( S, event ) =>
  registry                    = S[ plugins_sym ]
  [ type, name, text, meta, ] = event
  debug '88595', 'prefix', name
  return true

#-----------------------------------------------------------------------------------------------------------
@$plugin = ( S ) =>
  schema =
    postprocess: ( Q ) =>
      throw new Error "µ38893 expected non-empty text, got #{jr Q}" unless Q.src.length     > 0
      throw new Error "µ38894 expected non-empty text, got #{jr Q}" unless Q.prefix.length  > 0
      return @_resolve_arguments S, Q
    #.......................................................................................................
    properties:
      src:        { type: 'string', }
      prefix:     { type: 'string', }
    #.......................................................................................................
    additionalProperties: false
    required:             [ 'src', 'prefix', ]
  #.........................................................................................................
  validate_and_cast = OVAL.new_validator schema
  registry          = S[ plugins_sym ] = {}
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'plugin'
      [ type, name, Q, meta, ] = event
      Q = validate_and_cast Q
      debug '33933', Q
      send stamp event
    #.......................................................................................................
    else if ( prefix = @_prefix_from_event S, event )?
      debug '10095', 'plugin', jr event
      send stamp event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null



