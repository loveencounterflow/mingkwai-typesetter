


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
@set_factor = ( source_unit, target_value, target_unit ) ->
  unless target_unit is 'mm'
    throw new Error "(MKTS/TABLE µ43272) expected 'mm' as target unit, got #{rpr target_unit}"
  ### TAINT validate numbers ###
  #.........................................................................................................
  @factors[ source_unit ] = target_value
  return null

#-----------------------------------------------------------------------------------------------------------
@new_quantity = ( value_or_literal, unit = null ) ->
  return @parse value_or_literal unless unit?
  value = value_or_literal
  return { '~isa': 'MKTS/TABLE/quantity', value, unit, }

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
  switch ( type = CND.type_of me )
    when 'text'                 then me = @new_quantity me
    when 'MKTS/TABLE/quantity'  then me = Object.assign {}, me
    else throw new Error "(MKTS/TABLE µ88404) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
  me.value *= factor
  return me

# #-----------------------------------------------------------------------------------------------------------
# @add = ( me, length ) ->
#   switch ( type = CND.type_of me )
#     when 'text'                 then me = @new_quantity me
#     when 'MKTS/TABLE/quantity'  then me = Object.assign {}, me
#     else throw new Error "(MKTS/TABLE µ88404) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
#   switch ( type = CND.type_of length )
#     when 'text'                 then length = @new_quantity length
#     when 'MKTS/TABLE/quantity'  then length = Object.assign {}, length
#     else throw new Error "(MKTS/TABLE µ88404) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
#   #.........................................................................................................
#   unless me.unit is length.unit
#     ### When both units are identical, we accept them trivially both without checking whether we know them.
#     If units differ, we convert both lengths to millimeters before doing the conversion; this will cause
#     unknown units to throw errors. ###
#     unless ( me_factor = @factors[ me.unit ] )?
#       throw new Error "(MKTS/TABLE µ88309) unknown unit #{rpr me.unit}"
#     unless ( ref_factor = @factors[ length.unit ] )?
#       throw new Error "(MKTS/TABLE µ88309) unknown unit #{rpr length.unit}"
#     me_value   *= me_factor
#     ref_value  *= ref_factor
#   #.........................................................................................................
#   ratio = Math.ceil me_value / ref_value
#   return @multiply ref, ratio
#   me.value *= length
#   return me

#-----------------------------------------------------------------------------------------------------------
@integer_multiple = ( me, ref ) ->
  ### TAINT should accept textual arguments ###
  ### Given a comparison quantity and a reference quantity, return a quantity
  whose unit is the unit of the reference quantity, and whose value is a whole
  number such that the length expressed by the comparison quantity will fit into
  resulting length by the smallest integer multiple of the reference length.

  For example, `integer_multiple '15.5mm', '5mm'` will result in `20mm`, because
  `20mm` is the smallest integer multiple of `5mm` that is longer than `15.5mm`. ###
  #.........................................................................................................
  switch ( type = CND.type_of me )
    when 'text'                 then me = @new_quantity me
    when 'MKTS/TABLE/quantity'  then me = Object.assign {}, me
    else throw new Error "(MKTS/TABLE µ88404) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
  switch ( type = CND.type_of ref )
    when 'text'                 then ref = @new_quantity ref
    when 'MKTS/TABLE/quantity'  then ref = Object.assign {}, ref
    else throw new Error "(MKTS/TABLE µ88448) expected a text or a 'MKTS/TABLE/quantity', got a #{rpr type}"
  #.........................................................................................................
  me_value  = me.value
  ref_value = ref.value
  #.........................................................................................................
  unless me.unit is ref.unit
    ### When both units are identical, we accept them trivially both without checking whether we know them.
    If units differ, we convert both lengths to millimeters before doing the conversion; this will cause
    unknown units to throw errors. ###
    unless ( me_factor = @factors[ me.unit ] )?
      throw new Error "(MKTS/TABLE µ88309) unknown unit #{rpr me.unit}"
    unless ( ref_factor = @factors[ ref.unit ] )?
      throw new Error "(MKTS/TABLE µ88309) unknown unit #{rpr ref.unit}"
    me_value   *= me_factor
    ref_value  *= ref_factor
  #.........................................................................................................
  ratio = Math.ceil me_value / ref_value
  return @multiply ref, ratio






