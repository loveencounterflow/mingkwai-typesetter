


############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/TEXLIVEPACKAGEINFO'
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
#...........................................................................................................
{ CACHE, OPTIONS, }       = require './OPTIONS'


#-----------------------------------------------------------------------------------------------------------
@read_texlive_package_version = ( options, package_name, handler ) ->
  key     = "texlive-package-versions/#{package_name}"
  method  = ( done ) => @_read_texlive_package_version package_name, done
  CACHE.get options, key, method, yes, handler
  return null

#-----------------------------------------------------------------------------------------------------------
@_read_texlive_package_version = ( package_name, handler ) ->
  ### Given a `package_name` and a `handler`, try to retrieve that package's info as reported by the TeX
  Live Manager command line tool (using `tlmgr info ${package_name}`), extract the `cat-version` entry and
  normalize it so it matches the [Semantic Versioning specs](http://semver.org/). If no version is found,
  the `handler` will be called with a `null` value instead of a string; however, if a version *is* found but
  does *not* match the SemVer specs after normalization, the `handler` will be called with an error.

  Normalization steps include removing leading `v`s, trailing letters, and leading zeroes. ###
  leading_zero_pattern  = /^0+(?!$)/
  semver_pattern        = /^([0-9]+)\.([0-9]+)\.?([0-9]*)$/
  @read_texlive_package_info package_name, ( error, package_info ) =>
    return handler error if error?
    #.......................................................................................................
    unless ( version = o_version = package_info[ 'cat-version' ] )?
      warn "unable to detect version for package #{rpr package_name}"
      return handler null, null
      # return handler new Error "unable to detect version for package #{rpr package_name}"
    #.......................................................................................................
    version = version.replace /[^0-9]+$/, ''
    version = version.replace /^v/, ''
    #.......................................................................................................
    unless ( match = version.match semver_pattern )?
      return handler new Error "unable to parse version #{rpr o_version} of package #{rpr name}"
    #.......................................................................................................
    [ _, major, minor, patch, ] = match
    ### thx to http://stackoverflow.com/a/2800839/256361 ###
    major = major.replace leading_zero_pattern, ''
    minor = minor.replace leading_zero_pattern, ''
    patch = patch.replace leading_zero_pattern, ''
    major = if major.length > 0 then major else '0'
    minor = if minor.length > 0 then minor else '0'
    patch = if patch.length > 0 then patch else '0'
    #.......................................................................................................
    handler null, "#{major}.#{minor}.#{patch}"
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@read_texlive_package_info = ( package_name, handler ) ->
  command     = 'tlmgr'
  parameters  = [ 'info', package_name, ]
  input       = D.spawn_and_read_lines command, parameters
  Z           = {}
  pattern     = /^([^:]+):(.*)$/
  #.........................................................................................................
  input
    #.......................................................................................................
    .pipe $ ( line, send ) =>
      return if line.length is 0
      match = line.match pattern
      return send.error new Error "unexpected line: #{rpr line}" unless match?
      [ _, name, value, ] = match
      name                = name.trim()
      value               = value.trim()
      Z[ name ]           = value
    #.......................................................................................................
    .pipe D.$on_end -> handler null, Z
  #.........................................................................................................
  return null
