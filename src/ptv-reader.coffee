
'use strict'

############################################################################################################
FS                        = require 'fs'
PATH                      = require 'path'
rpr                       = ( require 'util' ).inspect
minimatch                 = require 'minimatch'


#-----------------------------------------------------------------------------------------------------------
@split_line = ( line ) ->
  ### TAINT should check that type looks like `::...=` ###
  if ( match = line.trim().match /^(\S+)\s+::([^=]+)=\s*$/ )?
    [ _, path, type, ] = match
    value = ''
  else if ( match = line.trim().match /^(\S+)\s+::([^=]+)=\s+(.*)$/ )
    [ _, path, type, value, ] = match
  else
    throw new Error "not a legal PTV line: #{rpr line}"
  return { path, type, value, }

#-----------------------------------------------------------------------------------------------------------
@resolve = ( text, values ) ->
  return text.replace /\$\{([^}]+)}/, ( $0, $1, position, input ) ->
    return $0 if ( position > 0 ) and ( input[ position - 1 ] is '\\' )
    throw new Error "unknown key #{rpr $1}" if ( R = values[ $1 ] ) is undefined
    return R.value

#-----------------------------------------------------------------------------------------------------------
@hash_from_paths = ( paths... ) ->
  R = {}
  @update_hash_from_path path, R for path in paths
  return R

#-----------------------------------------------------------------------------------------------------------
@update_hash_from_path = ( path, R ) ->
  return @update_hash_from_text ( FS.readFileSync path, encoding: 'utf-8' ), R

#-----------------------------------------------------------------------------------------------------------
@update_hash_from_text = ( text, R ) ->
  for line in ( text.split '\n' )
    continue if ( line.match /^\s*$/ )?
    continue if ( line.match /^\s*#/ )?
    { path, type, value, }  = @split_line line
    value                   = @resolve value, R
    R[ path ]               = { type, value, }
  return R

#-----------------------------------------------------------------------------------------------------------
@cast_values = ( R ) ->
  ### TAINT does not validate literals ###
  for key, { type, value, } of R
    switch type
      when 'text'       then R[ key ] = value
      when 'boolean'    then R[ key ] = ( if ( value is 'true' ) then true else false )
      when 'integer'    then R[ key ] = parseInt value, 10
      when 'float'      then R[ key ] = parseFloat value
      else throw new Error "unknown type #{rpr type}"
  return R

#-----------------------------------------------------------------------------------------------------------
@options_as_facet_json = ( x ) ->
  return JSON.stringify x

#-----------------------------------------------------------------------------------------------------------
@options_as_untyped_json = ( x ) ->
  R = {}
  R[ key ] = facet.value for key, facet of x
  return JSON.stringify R

#-----------------------------------------------------------------------------------------------------------
@match = ( facets, pattern, settings ) ->
  R       = []
  matcher = new minimatch.Minimatch pattern, settings
  return ( [ key, value, ] for key, value of facets when matcher.match key )


############################################################################################################
unless module.parent?
  log   = console.log
  PTVR  = @
  log '42992', PTVR.resolve 'before\\${middle}after', {}
  log '42992', PTVR.resolve 'before${middle}after', { middle: value: '---something---' }
  log '42992', PTVR.hash_from_paths PATH.join __dirname, '../intershop.ptv'





