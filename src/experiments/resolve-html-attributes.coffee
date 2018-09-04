

############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/MD-READER'
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
assign                    = Object.assign


#-----------------------------------------------------------------------------------------------------------
@_cast_attribute_value = ( x ) -> return if x is '' then null else x

#-----------------------------------------------------------------------------------------------------------
@_resolve_html_attribute = ( facets ) ->
  assign {}, ( { "#{facet.name}": ( @_cast_attribute_value facet.value ) } for facet in facets )...


############################################################################################################
facets = [ { name: 'frame', value: '' },
  { name: 'illegal-name', value: '' },
  { name: 'foo', value: '' },
  { name: 'bar', value: '' },
  { name: 'thickness', value: '1mm' } ]

urge @_resolve_html_attribute facets
urge @_resolve_html_attribute []


