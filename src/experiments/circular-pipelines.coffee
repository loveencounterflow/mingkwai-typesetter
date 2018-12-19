
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
      return send d unless ( select d, '.', 'number' ) and ( @is_even d.value )
      send stamp d
      send recycling @new_number_event ( d.value / 2 )

  #-----------------------------------------------------------------------------------------------------------
  @$odd_numbers = ( S ) ->
    return $ ( d, send ) =>
      return send d unless ( select d, '.', 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
      send stamp d
      send recycling ( @new_number_event ( d.value * 3 + 1 ) )

  #-----------------------------------------------------------------------------------------------------------
  @$skip_known = ( S ) ->
    known = new Set()
    return $ ( d, send ) =>
      return send d unless select d, '.', 'number'
      return urge '->', d.value if known.has d.value
      send d
      known.add d.value

  #-----------------------------------------------------------------------------------------------------------
  @$terminate = ( S ) ->
    return $ ( d, send ) =>
      if ( select_all d, '.', 'number' ) and ( @is_one d.value )
        send stamp d
        send new_end_event()
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$throw_on_illegal = -> PS.$watch ( d ) ->
    if ( select_all d, '.', 'number' ) and ( type = CND.type_of d.value ) isnt 'number'
      throw new Error "found an illegal #{type} in #{rpr d}"
    return null

  #-----------------------------------------------------------------------------------------------------------
  @$main = ( S ) ->
    pipeline = []
    # pipeline.push COLLATZ.$skip_known           S
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
  S.source    = new_push_source()
  pipeline    = []
  #.........................................................................................................
  pipeline.push S.source
  pipeline.push $unwrap_recycled()
  pipeline.push PS.$delay 0.25
  # pipeline.push PS.$defer()
  pipeline.push COLLATZ.$main S
  pipeline.push PS.$watch ( d ) -> if ( select d, '~', 'end' ) then S.source.end()
  pipeline.push $recycle S.source.push
  # pipeline.push PS.$watch ( d ) -> whisper rpr d
  pipeline.push PS.$watch ( d ) -> help jr d
  #.........................................................................................................
  pipeline.push $ do ->
    collector = null
    ( d, send ) ->
      collector ?= []
      if select_all d, '~', 'collect'
        send collector
        collector = null
      else if select_all d, '.', 'number'
        collector.push d.value
  #.........................................................................................................
  pipeline.push PS.$watch ( d ) -> urge jr d
  pipeline.push PS.$drain -> help 'ok'
  PS.pull pipeline...
  #.........................................................................................................
  R       = ( value ) ->
    if CND.isa_number value then  S.source.push new_event '.', 'number', value
    else                          S.source.push value
  R.end   = -> S.source.end()
  return R


############################################################################################################
unless module.parent?
  S = {}
  send = @new_sender S
  urge '-----------'
  send 5
  send new_system_event 'collect'
  send 6
  send new_system_event 'collect'
  # for n in [ 2 .. 3 ]
  #   debug n
  #   do ( n ) ->
  #     send n
  #     # defer send n
  #     send new_system_event 'collect'
  #     urge '-----------'
  #   # # send.end()
  # # send new_system_event 'end'
  # send.end()

###

  #-----------------------------------------------------------------------------------------------------------
  @$odd_numbers = ( S ) ->
    unq         = 'þ108'
    syncnr      = 0
    open_syncs  = new Map()
    buffers     = {}
    #.........................................................................................................
    unq_from_sync = ( sync ) -> sync.replace ///^ ([^\/]+) \/ .* $///, '$1'
    is_my_sync    = ( unq, sync ) -> return unq is unq_from_sync sync
    #.........................................................................................................
    has_open_syncs = ( unq ) ->
      return false unless ( target = open_syncs.get unq )?
      return target.size > 0
    #.........................................................................................................
    open_sync   = ( unq ) ->
      syncnr += +1;
      R       = "#{unq}/#{syncnr}"
      open_syncs.set unq, ( target = new Set() ) unless ( target = open_syncs.get unq )?
      target.add R
      return R
    #.........................................................................................................
    close_sync = ( sync ) ->
      unq = unq_from_sync sync
      if ( target = open_syncs.get unq )?
        target.delete sync
        open_syncs.delete unq if target.size is 0
        return [] unless ( R = buffers[ sync ] )?
        delete buffers[ sync ]
        return R
    #.........................................................................................................
    sync_stack = []
    #.........................................................................................................
    return $async ( d, send, done ) =>
      whisper '88893', d, open_syncs if d.sync?
      ## # TAINT should close in stack order ## #
      #.....................................................................................................
      if ( select d, '~', 'sync' ) and ( is_my_sync unq, d.sync )
        sync_stack.pop()
        send x for x in close_sync d.sync
        return done()
      #.....................................................................................................
      if has_open_syncs unq
        most_recent_sync = sync_stack[ sync_stack.length - 1 ]
        debug '77663', most_recent_sync
        ( buffers[ most_recent_sync ]?= [] ).push d
        return done()
      #.....................................................................................................
      unless ( select d, '.', 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
        send d
        return done()
      #.....................................................................................................
      sync = open_sync unq
      sync_stack.push sync
      send stamp d
      send recycling ( @new_number_event ( d.value * 3 + 1 ) ), sync
      done()
###