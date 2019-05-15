


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/PLUGINS'
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
PIPEDREAMS3B7B            = require 'pipedreams-3b7b'
# PIPEDREAMS                = require 'pipedreams'
# PIPEDREAMS.$              = PIPEDREAMS.remit.bind PIPEDREAMS
# PIPEDREAMS.$async         = PIPEDREAMS.remit_async.bind PIPEDREAMS
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
new_pushable              = require 'pull-pushable'
PS                        = require 'pipestreams'
# { $, $async, }            = PS
### TAINT temporary kludge ###
finished_sym              = Symbol.for 'finished'

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
    reference = module
    callable  = module
    if crumbs?
      for crumb in crumbs
        reference = callable
        callable  = callable[ crumb ]
    throw new Error "not callable: #{rpr method_path}" unless CND.isa_function callable
    callable = callable.bind reference
  catch error
    alert '98987-1', "when trying to resolve #{rpr Q.src}"
    alert '98987-2', "starting with module #{rpr locator}"
    alert '98987-3', "an error occurred"
    throw error
  #.....................................................................................................
  return Object.assign {}, Q, { locator, module_path, method_path, callable, }

#-----------------------------------------------------------------------------------------------------------
new_sync_sub_sender = ( transforms ) ->
  ### Given a transform, construct a pipeline with a pushable as its source, and
  return a function that accepts a data event to be processed by the pipeline. ###
  # The sub-sender works by temporarily attaching a hidden ###
  pushable  = new_pushable()
  collector = []
  pipeline  = []
  callback  = null
  pipeline.push pushable
  pipeline.push PS.$ ( d, send ) -> send d; send [ '~', finished_sym, ]
  pipeline.push transform for transform in transforms
  pipeline.push PS.$ ( d, send ) ->
    if select d, '~', finished_sym
      send collector
      collector = []
    else
      collector.push d
  pipeline.push PS.$watch ( d ) -> callback d
  pipeline.push PS.$drain()
  PS.pull pipeline...
  return ( d, send ) -> callback = send; pushable.push d

#-----------------------------------------------------------------------------------------------------------
@$plugins = ( S ) =>
  self    = @$plugins
  schema  =
    postprocess: ( Q ) =>
      throw new Error "µ38893 expected non-empty text, got #{jr Q}" unless Q.src.length     > 0
      throw new Error "µ38894 expected non-empty text, got #{jr Q}" unless Q.prefix.length  > 0
      throw new Error "µ38895 unable to redefine prefix #{rpr Q.prefix}" if self.known_prefixes.has Q.prefix
      self.known_prefixes.add Q.prefix
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
  #.........................................................................................................
  return PIPEDREAMS3B7B.$async ( event, send, end ) =>
    if select event, '.', 'plugin'
      [ type, name, Q, meta, ]  = event
      Q                         = validate_and_cast Q
      self.callables.push [ Q.callable, { prefix: Q.prefix, }, ]
      send stamp event
      send.done()
      #.....................................................................................................
      ### TAINT shouldn't build a new pipeline for each event ###
      plugins               = ( ( callable S, settings ) for [ callable, settings, ] in self.callables )
      self.send_to_plugins  = new_sync_sub_sender plugins
    #.......................................................................................................
    else if self.callables.length > 0
      self.send_to_plugins event, ( events ) -> send event for event in events; send.done()
    #.......................................................................................................
    else
      send event
      send.done()
    #.......................................................................................................
    end() if end?
    return null
@$plugins.callables           = []
@$plugins.known_prefixes      = new Set()
@$plugins.send_to_plugins     = null


