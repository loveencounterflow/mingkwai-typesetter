

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
@as_here_x_ref = ( n ) ->
  ### convert from `sp` (scaled points) to tenths of mm ###
  n         = ( parseFloat n ) / 1864679 * 100
  R         = n.toFixed 0
  last_idx  = R.length - 1
  prefix    = R[ ...  last_idx ]
  suffix    = R[      last_idx ]
  ### TAINT doing `toFixed 1` would have sufficed as such but we want to be able use any construct for the
  decimal ###
  return "#{prefix}.{}#{suffix}"

#-----------------------------------------------------------------------------------------------------------
unless module.parent?
  CXLTX = @
  [ _, _, method_name, P..., ] = process.argv
  echo CXLTX[ method_name ] P...


