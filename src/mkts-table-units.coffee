


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
@pattern                  = /^\s*(?<value>(?:\+|-)?[0-9]*\.?[0-9]*)\s*(?<unit>[^\s0-9]+)\s*$/

#-----------------------------------------------------------------------------------------------------------
@factors =
  mm:           1     ### mm ###
  cm:           10    ### mm ###
  m:            1000
  pt:           1 / ( 7227 / 2540 )  ### ~0.35mm ###
  lineheight:   5.26 ### preset, may change ###

#-----------------------------------------------------------------------------------------------------------
@_get_factor = ( unit ) ->
  throw new Error "(MKTS/TABLE µ88309) unknown unit #{rpr unit}" unless ( R = @factors[ unit ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@set_factor = ( source_unit, target_value, target_unit ) ->
  ### TAINT validate numbers ###
  unless target_unit is 'mm'
    throw new Error "(MKTS/TABLE µ43272) expected 'mm' as target unit, got #{rpr target_unit}"
  #.........................................................................................................
  @factors[ source_unit ] = target_value
  return null

#-----------------------------------------------------------------------------------------------------------
@new_quantity = ( x, unit = null ) ->
  unless unit?
    switch ( type = CND.type_of x )
      when 'text'                 then return @parse x
      when 'MKTS/TABLE/quantity'  then return Object.assign {}, x
      else throw new Error "(MKTS/TABLE µ88404) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
  return { '~isa': 'MKTS/TABLE/quantity', value: x, unit, }

#-----------------------------------------------------------------------------------------------------------
@parse = ( text ) ->
  # text = '1' + text unless ( text.match /^\s*[0-9]/ )?
  unless ( match = text.match @pattern )?
    throw new Error "(MKTS/TABLE µ88272) unable to parse #{rpr text}"
  #.........................................................................................................
  { value, unit, } = match.groups
  throw new Error "(MKTS/TABLE µ88272) unable to parse #{rpr text}" if value in [ '+', '-', ]
  value = '1' if value is ''
  #.........................................................................................................
  return @new_quantity ( parseFloat value ), unit

#-----------------------------------------------------------------------------------------------------------
@as_text = ( me, operator, operand ) ->
  return @as_text operand, operator, me if CND.isa_number me
  #.........................................................................................................
  unless ( type = CND.type_of me ) is 'MKTS/TABLE/quantity'
    throw new Error "(MKTS/TABLE µ88316) expected a 'MKTS/TABLE/quantity', got a #{rpr type}"
  #.........................................................................................................
  return "#{me.value}#{me.unit}" unless operator?
  #.........................................................................................................
  switch operator
    when '*' then return @as_text @multiply ( copy me ), operand
    else throw new Error "(MKTS/TABLE µ88360) unknown operand #{rpr operand}"

#-----------------------------------------------------------------------------------------------------------
@multiply = ( me, factor ) ->
  me        = @new_quantity me
  me.value *= factor
  return me

#-----------------------------------------------------------------------------------------------------------
@negate = ( me ) -> @multiply me, -1

#-----------------------------------------------------------------------------------------------------------
@conform = ( me, you ) ->
  ### Express one quantity in terms of the other. ###
  me        = @new_quantity me
  you       = @new_quantity you
  unless you.value is 1
    throw new Error "(MKTS/TABLE µ88309) unable to conform to a quantity with value other than 1, got #{rpr you}"
  me_value  = me.value  * @_get_factor me.unit
  you_value = you.value * @_get_factor you.unit
  you.value   = me_value / you_value
  return you

#-----------------------------------------------------------------------------------------------------------
@add = ( me, you ) ->
  me        = @new_quantity me
  you       = @new_quantity you
  me_value  = me.value  * @_get_factor me.unit
  you_value = you.value * @_get_factor you.unit
  return @conform ( @new_quantity me_value + you_value, 'mm' ), me.unit

#-----------------------------------------------------------------------------------------------------------
@integer_multiple = ( me, you ) ->
  ### Given a comparison quantity and a reference quantity, return a quantity
  whose unit is the unit of the reference quantity, and whose value is a whole
  number such that the length expressed by the comparison quantity will fit into
  resulting length by the smallest integer multiple of the reference length.
  For example, `integer_multiple '15.5mm', '5mm'` will result in `20mm`, because
  `20mm` is the smallest integer multiple of `5mm` that is longer than `15.5mm`. ###
  #.........................................................................................................
  me        = @new_quantity me
  you       = @new_quantity you
  me_value  = me.value  * @_get_factor me.unit
  you_value = you.value * @_get_factor you.unit
  ratio     = Math.ceil me_value / you_value
  return @multiply you, ratio

# #-----------------------------------------------------------------------------------------------------------
# @integer_multiple_minus_one = ( me, you ) ->
#   R =
#   return ( @integer_multiple me, you )






