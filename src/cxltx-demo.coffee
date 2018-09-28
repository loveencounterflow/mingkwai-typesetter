

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'CXLTX/DEMO'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
echo                      = CND.echo.bind CND

 # 4661697 - 2797018

#-----------------------------------------------------------------------------------------------------------
@as_here_x_ref = ( x, x_unit, delta, delta_unit ) ->
  ### convert from `sp` (scaled points) to tenths of mm ###
  x         = ( parseFloat x ) / 186467.9
  delta     = parseFloat delta
  throw new Error "expected a number, got #{rpr x}"       unless CND.isa_number x
  throw new Error "expected a number, got #{rpr delta}"   unless CND.isa_number delta
  throw new Error "expected 'sp', got #{rpr x_unit}"      unless x_unit is 'sp'
  throw new Error "expected 'mm', got #{rpr delta_unit}"  unless delta_unit is 'mm'
  x         = x - delta
  R         = x.toFixed 1
  return if R is '-0.0' then '0.0' else R

#-----------------------------------------------------------------------------------------------------------
unless module.parent?
  CXLTX = @
  [ _, _, method_name, P..., ] = process.argv
  # debug '34474', P
  echo CXLTX[ method_name ] P...


