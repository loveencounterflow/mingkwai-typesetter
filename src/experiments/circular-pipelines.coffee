
'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SCRATCH/CIRCULAR-PIPELINES'
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
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.sigil} #{d.key}:: #{jr d.value ? null} #{jr d.stamped ? false}"
# echo '{ ' + ( ( name for name of require './recycle' ).sort().join '\n  ' ) + " } = require './recycle'"
{ $recycle
  $unwrap_recycled
  is_recycling
  is_stamped
  is_system
  new_end_event
  new_event
  new_single_event
  new_start_event
  new_stop_event
  new_system_event
  new_push_source
  recycling
  select
  select_all
  stamp
  unwrap_recycled } = require './recycle'


#-----------------------------------------------------------------------------------------------------------
provide_collatz = ->


  #-----------------------------------------------------------------------------------------------------------
  @new_number_event = ( value, other... ) ->
    return new_single_event 'number', value, other...

  #-----------------------------------------------------------------------------------------------------------
  @is_one  = ( n ) -> n is 1
  @is_odd  = ( n ) -> n %% 2 isnt 0
  @is_even = ( n ) -> n %% 2 is 0

  #-----------------------------------------------------------------------------------------------------------
  @$even_numbers = ( S ) ->
    return $ ( d, send ) =>
      if ( select d, '.', 'number' ) and ( @is_even d.value )
        send stamp d
        send recycling @new_number_event ( d.value / 2 )
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$odd_numbers = ( S ) ->
    return $ ( d, send ) =>
      if ( select d, '.', 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
      # if ( select d, sigil: '.', key: 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
      # if ( select_single d, null, 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
      # if ( select_single d, 'kwic:number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
        send stamp d
        send recycling @new_number_event ( d.value * 3 + 1 )
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$skip_known = ( S ) ->
    known = new Set()
    return $ ( d, send ) =>
      if select d, '.', 'number'
        unless known.has d.value
          send d
          known.add d.value
        else
          urge '->', d.value
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$terminate = ( S ) ->
    return $ ( d, send ) =>
      if ( select_all d, '.', 'number' ) and ( is_one d.value )
        send stamp d
        send new_end_event()
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$main = ( S ) ->
    pipeline = []
    pipeline.push COLLATZ.$skip_known           S
    pipeline.push COLLATZ.$even_numbers         S
    pipeline.push COLLATZ.$odd_numbers          S
    # pipeline.push COLLATZ.$terminate            S
    return PS.pull pipeline...

  #-----------------------------------------------------------------------------------------------------------
  return @
COLLATZ = provide_collatz.apply {}

#-----------------------------------------------------------------------------------------------------------
@new_sender = ( S ) ->
  S.source    = new_push_source()
  on_stop     = PS.new_event_collector 'stop', -> help 'ok'
  pipeline    = []
  #.........................................................................................................
  pipeline.push S.source
  pipeline.push $unwrap_recycled()
  pipeline.push COLLATZ.$main S
  pipeline.push PS.$watch ( d ) -> help jr d
  # pipeline.push PS.$watch ( d ) -> help '> sink  ', rprx d unless is_meta d
  pipeline.push PS.$watch ( d ) -> if ( select d, '~', 'end' ) then S.source.end()
  pipeline.push $recycle S.source.push
  #.........................................................................................................
  pipeline.push on_stop.add PS.$drain()
  PS.pull pipeline...
  #.........................................................................................................
  R       = ( value ) -> S.source.push new_event '.', 'number', value
  R.end   = -> S.source.end()
  return R


############################################################################################################
unless module.parent?
  S = {}
  send = @new_sender S
  urge '-----------'
  send 42
  urge '-----------'
  for n in [ 1 .. 5 ]
    send -n
    urge '-----------'
  # # send.end()
