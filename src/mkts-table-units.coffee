


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE/UNITS'
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
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
assign                    = Object.assign
copy                      = ( x ) -> Object.assign {}, x
jr                        = JSON.stringify
@pattern                  = /^\s*(?<value>[0-9]+\.?[0-9]*)\s*(?<unit>[^\s0-9]+)\s*$/



#-----------------------------------------------------------------------------------------------------------
@parse_nonnegative_quantity = ( text ) ->
  unless ( match = text.match @pattern )?
    throw new Error "(MKTS/TABLE µ5375) unable to parse #{rpr text} as nonnegative quantity"
  #.........................................................................................................
  R       = assign {}, match.groups, { '~isa': 'MKTS/TABLE/quantity', }
  R.value = parseFloat R.value
  return R

#-----------------------------------------------------------------------------------------------------------
@as_text = ( me, operator, operand ) ->
  return @as_text operand, operator, me if CND.isa_number me
  #.........................................................................................................
  unless ( type = CND.type_of me ) is 'MKTS/TABLE/quantity'
    throw new Error "(MKTS/TABLE µ5375) expected a 'MKTS/TABLE/quantity', got a #{rpr type}"
  #.........................................................................................................
  return "#{me.value}#{me.unit}" unless operator?
  #.........................................................................................................
  switch operator
    when '*' then return @as_text @multiply ( copy me ), operand
    else throw new Error "(MKTS/TABLE µ6920) unknown operand #{rpr operand}"

#-----------------------------------------------------------------------------------------------------------
@multiply = ( me, factor ) ->
  me.value *= factor
  return me




