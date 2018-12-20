
'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/EXPERIMENTS/CIRCULAR-PIPELINES'
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
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
# $async                    = D.remit_async.bind D
PS                        = require 'pipestreams'
{ $, $async, }            = PS
assign                    = Object.assign
after                     = ( dts, f ) -> setTimeout f, dts * 1000
defer                     = setImmediate
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.sigil} #{d.key}:: #{jr d.value ? null} #{jr d.stamped ? false}"
# echo '{ ' + ( ( name for name of require './recycle' ).sort().join '\n  ' ) + " } = require './recycle'"
PS2                       = require './recycle'
{ select
  select_all
  stamp }                 = PS2

#-----------------------------------------------------------------------------------------------------------
provide_collatz = ->

  #-----------------------------------------------------------------------------------------------------------
  @new_number_event = ( value, other... ) ->
    return PS2.new_single_event 'number', value, other...

  #-----------------------------------------------------------------------------------------------------------
  @is_one  = ( n ) -> n is 1
  @is_odd  = ( n ) -> n %% 2 isnt 0
  @is_even = ( n ) -> n %% 2 is 0

  #-----------------------------------------------------------------------------------------------------------
  @$even_numbers = ( S ) ->
    return $ ( d, send ) =>
      return send d unless ( select d, '!', 'number' ) and ( @is_even d.value )
      send stamp d
      send PS2.recycling @new_number_event ( d.value / 2 ), from: d.value
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$odd_numbers = ( S ) ->
    return $ ( d, send ) =>
      if ( select d, '!', 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
        ### If data event matches condition, stamp it and send it on with new data event: ###
        send stamp d
        send PS2.recycling ( @new_number_event ( d.value * 3 + 1 ), from: d.value )
      else
        send d
      return null

  # #-----------------------------------------------------------------------------------------------------------
  # @$odd_numbers = ( S ) ->
  #   return $ ( d, send ) =>
  #     return send d unless ( select d, '!', 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
  #     send stamp d
  #     send PS2.recycling ( @new_number_event ( d.value * 3 + 1 ) )

  #-----------------------------------------------------------------------------------------------------------
  @$skip_known = ( S ) ->
    known = new Set()
    return $ ( d, send ) =>
      return send d unless select d, '!', 'number'
      return urge '->', d.value if known.has d.value
      send d
      known.add d.value

  #-----------------------------------------------------------------------------------------------------------
  @$terminate = ( S ) ->
    return $ ( d, send ) =>
      if ( select_all d, '!', 'number' ) and ( @is_one d.value )
        send stamp d
        send PS2.new_end_event()
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$throw_on_illegal = -> PS.$watch ( d ) ->
    if ( select_all d, '!', 'number' ) and ( type = CND.type_of d.value ) isnt 'number'
      throw new Error "found an illegal #{type} in #{rpr d}"
    return null

  #-----------------------------------------------------------------------------------------------------------
  @$main = ( S ) ->
    pipeline = []
    # pipeline.push COLLATZ.$skip_known           S
    # pipeline.push PS.$delay 1
    pipeline.push COLLATZ.$even_numbers         S
    pipeline.push COLLATZ.$odd_numbers          S
    pipeline.push COLLATZ.$throw_on_illegal     S
    # pipeline.push COLLATZ.$terminate            S
    return PS.pull pipeline...

  #-----------------------------------------------------------------------------------------------------------
  return @
COLLATZ = provide_collatz.apply {}

#-----------------------------------------------------------------------------------------------------------
@new_sender = ( S ) ->
  S.source    = PS2.new_push_source()
  pipeline    = []
  #.........................................................................................................
  pipeline.push S.source
  # pipeline.push PS.$watch ( d ) -> urge '37744-1', jr d
  pipeline.push PS2.$unwrap_recycled()
  # # pipeline.push PS.$delay 0.25
  # pipeline.push PS.$defer()
  # pipeline.push PS.$watch ( d ) -> whisper '37744-2', jr d
  pipeline.push COLLATZ.$main S
  # pipeline.push PS.$watch ( d ) -> if ( select d, '~', 'end' ) then S.source.end()
  pipeline.push PS2.$recycle S.source.push
  # pipeline.push PS.$watch ( d ) -> help jr d
  #.........................................................................................................
  pipeline.push do ->
    collector = null
    return $ ( d, send ) ->
      collector ?= []
      if select_all d, '~', 'collect'
        send stamp d
        send PS2.new_event '!', 'numbers', collector
        collector = null
      else if select_all d, '!', 'number'
        collector.push d.value
      else
        send d
      return null
  #.........................................................................................................
  # pipeline.push PS.$watch ( d ) -> help '37744-3', jr d
  #.........................................................................................................
  pipeline.push do ->
    collector = []
    return $ 'null', ( d, send ) ->
      if d?
        if select_all d, '!', 'number'
          collector.push d.value
        else
          send d
      else
        send collector
  #.........................................................................................................
  pipeline.push PS.$watch ( d ) -> help '37744-4', jr d
  pipeline.push PS.$drain -> help 'ok'
  PS.pull pipeline...
  #.........................................................................................................
  R       = ( value ) ->
    if CND.isa_number value then  S.source.push PS2.new_event '!', 'number', value
    else                          S.source.push value
  R.end   = -> S.source.end()
  return R


############################################################################################################
unless module.parent?
  S = {}
  send = @new_sender S
  urge '-----------'
  send 5
  send PS2.new_system_event 'collect'
  send 6
  send PS2.new_system_event 'collect'
  # for n in [ 2 .. 3 ]
  #   debug n
  #   do ( n ) ->
  #     send n
  #     # defer send n
  #     send PS2.new_system_event 'collect'
  #     urge '-----------'
  #   # # send.end()
  # # send PS2.new_system_event 'end'
  # send.end()
