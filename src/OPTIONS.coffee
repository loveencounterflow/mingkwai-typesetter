




############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
njs_os                    = require 'os'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'OPTIONS'
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
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
# #...........................................................................................................
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
# $async                    = D.remit_async.bind D
# #...........................................................................................................
# ASYNC                     = require 'async'
# #...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require './HELPERS'
# TYPO                      = HELPERS[ 'TYPO' ]
# options                   = require './options'
# SEMVER                    = require 'semver'
CS                        = require 'coffee-script'
# options_route_fallback    = '../options.coffee'



#===========================================================================================================
# CACHE
#-----------------------------------------------------------------------------------------------------------
@CACHE = {}

#-----------------------------------------------------------------------------------------------------------
@CACHE.update = ( options ) ->
  cache             = options[ 'cache' ][ '%self' ]
  cache[ 'sysid' ]  = sysid = @_get_sysid()
  unless cache[ sysid ]?
    sys_cache         = {}
    cache[ sysid ]    = sys_cache
  @save options

#-----------------------------------------------------------------------------------------------------------
@CACHE.set = ( options, key, value, save = yes ) ->
  target          = options[ 'cache' ][ '%self' ][ options[ 'cache' ][ '%self' ][ 'sysid' ] ]
  target[ key ]  = value
  @save options if save?
  return null

#-----------------------------------------------------------------------------------------------------------
@CACHE.get = ( options, key, method, save = yes, handler = null ) ->
  cache   = options[ 'cache' ][ '%self' ]
  sysid   = cache[ 'sysid' ]
  target  = cache[  sysid  ]
  R       = target[ key ]
  if handler?
    if R is undefined
      method ( error, R ) =>
        return handler error if error?
        @set options, key, R, save
        handler null, R
    else
      handler null, R
  else
    if R is undefined
      @set options, key, ( R = method() ), save
    return R

#-----------------------------------------------------------------------------------------------------------
@CACHE.save = ( options ) ->
  locator = options[ 'cache' ][ 'locator' ]
  cache   = options[ 'cache' ][ '%self' ]
  njs_fs.writeFileSync locator, JSON.stringify cache, null, '  '

#-----------------------------------------------------------------------------------------------------------
@CACHE._get_sysid = -> "#{njs_os.hostname()}:#{njs_os.platform()}"


#===========================================================================================================
# OPTIONS
#-----------------------------------------------------------------------------------------------------------
@OPTIONS = {}

#-----------------------------------------------------------------------------------------------------------
@OPTIONS._require_coffee_file = ( route ) ->
  extensions = Object.keys require[ 'extensions' ]
  require 'coffee-script/register'
  R = require route
  for name in require[ 'extensions' ]
    delete require[ 'extensions' ][ name ] unless name in extensions
  return R

#-----------------------------------------------------------------------------------------------------------
@OPTIONS._eval_coffee_file = ( route ) ->
  rqr_route = require.resolve route
  source    = njs_fs.readFileSync rqr_route, encoding: 'utf-8'
  return CS.eval source, bare: true

#-----------------------------------------------------------------------------------------------------------
@OPTIONS.from_locator = ( options_locator ) ->
  return @_require_coffee_file options_locator
  # return @_eval_coffee_file options_locator




