
'use strict'


############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SCRATCH/DYNAMIC-PIPELINES'
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
new_pushable              = require 'pull-pushable'
assign                    = Object.assign
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.mark} #{d.type}:: #{jr d.value}"

###


Pipestream Events v2
====================

d         := { mark,          type, value, ... }    # implicit global namespace
          := { mark, prefix,  type, value, ... }    # explicit namespace

# `d.mark` indicates 'regionality':

mark      := '.' # singleton                        # will become '!'   # or '</>' ?
          := '(' # start-of-region (SOR)            #                   # '<-'
          := ')' # end-of-region   (EOR)            #                   # '->'

# `prefix` indicates the namespace; where missing on an event or is `null`, `undefined` or `'global'`,
# it indicates the global namespace:

prefix    := null | undefined | 'global' | non-empty text

type      := non-empty text         # typename

value     := any                    # payload

###

#-----------------------------------------------------------------------------------------------------------
select = ( event, prefix, marks, types ) ->
  ### accepts 3 or 4 arguments; when 4, then second must be prefix (only one prefix allowed);
  `marks` and `types` may be text or list of texts. ###
  switch arity = arguments.length
    # when 2 then [ prefix, marks, types, ] = [ null, prefix, marks, ]
    when 3 then [ prefix, marks, types, ] = [ null, prefix, marks, ]
    when 4 then null
    else throw new Error "expected 3 to 4 arguments, got arity"
  prefix  = null if ( not prefix? ) or ( prefix is 'global' )
  marks  ?= null
  types  ?= null
  switch _type = CND.type_of prefix
    when 'null' then null
    when 'text' then return false unless event.prefix is prefix
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of marks
    when 'null' then null
    when 'text' then return false unless event.mark is marks
    when 'list' then return false unless event.mark in marks
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of types
    when 'null' then null
    when 'text' then return false unless event.type is types
    when 'list' then return false unless event.type in types
    else throw new Error "expected a text or a list, got a #{_type}"
  return true

#-----------------------------------------------------------------------------------------------------------
new_sync_sub_sender = ( transforms, send ) ->
  ### Given a transform, construct a pipeline with a pushable as its source, and
  return a function that accepts a send method and a data event. ###
  # The sub-sender works by temporarily attaching a hidden ###
  pushable      = new_pushable()
  pipeline  = []
  pipeline.push pushable
  pipeline.push transform for transform in transforms
  pipeline.push PS.$watch ( d ) -> send d
  pipeline.push PS.$drain()
  PS.pull pipeline...
  return ( d ) -> pushable.push d

#-----------------------------------------------------------------------------------------------------------
plugins_library =

  #-----------------------------------------------------------------------------------------------------------
  doubler: $ ( d, send ) ->
    if select d, '.', 'number'
      # send d
      send copy d, { value: 2 * d.value, }
    else
      whisper "no match: #{rprx d}"
      send d

  #-----------------------------------------------------------------------------------------------------------
  tripler: $ ( d, send ) ->
    if select d, '.', 'number'
      send d
      send copy d, { value: 3 * d.value, }
    else
      whisper "no match: #{rprx d}"
      send d

  #-----------------------------------------------------------------------------------------------------------
  # logger: PS.$watch ( d ) -> null
  logger: PS.$watch ( d ) -> whisper "intermediate: #{rprx d}"


#-----------------------------------------------------------------------------------------------------------
@$plugins = ( S ) ->
  pipeline          = []
  pipeline.push $ ( d, send ) =>
    self = @$plugins
    if select d, '.', 'plugin'
      debug 'plugin', rprx d
      throw new Error "unknown plugin #{rpr d.value}" unless ( plugin = plugins_library[ d.value ] )?
      self.plugins.push plugin
      self.sub_sender = new_sync_sub_sender self.plugins, send
    else if self.sub_sender?
      self.sub_sender d
    else
      send d
    return null
  #.........................................................................................................
  return PS.pull pipeline...
@$plugins.plugins         = []
@$plugins.sub_sender      = null

#-----------------------------------------------------------------------------------------------------------
@get_outer_pipeline = ( S ) ->
  source      = ( n for n in [ 1 .. 10 ] by +1 )
  # source      = ( n for n in [ 1 .. 2e4 ] by +1 )
  source      = ( { mark: '.', type: 'number', value, } for value in source )
  interlude_1 = { mark: '.', type: 'plugin', value: 'doubler', }
  # interlude_2 = { mark: '.', type: 'plugin', value: 'frobulator', }
  interlude_2 = { mark: '.', type: 'plugin', value: 'logger', }
  interlude_3 = { mark: '.', type: 'plugin', value: 'tripler', }
  interlude_4 = { mark: '.', type: 'something', value: 'anything', }
  source      = [
    source[ 0 .. 1 ]...
    interlude_1
    source[ 2 .. 3 ]...
    interlude_2
    interlude_3
    source[ 4 .. 6 ]...
    interlude_4
    source[ 6 .. ]... ]
  source      = PS.new_value_source source
  #.........................................................................................................
  on_stop     = PS.new_event_collector 'stop', -> help 'ok'
  pipeline    = []
  #.........................................................................................................
  pipeline.push source
  pipeline.push PS.$watch ( d ) -> whisper '> source ', rprx d
  pipeline.push @$plugins S
  pipeline.push PS.$watch ( d ) -> help '> sink   ', rprx d
  pipeline.push on_stop.add PS.$drain()
  #.........................................................................................................
  t0 = Date.now()
  PS.pull pipeline...
  t1 = Date.now()
  debug ( ( t1 - t0 ) / 1000 ).toFixed 3
  return null

unless module.parent?
  S = {}
  @get_outer_pipeline S

  ###
  # x = {}
  # y_sym = Symbol 'y'
  # x[ y_sym ] = 42
  # debug '55542', x
  # x2 = copy x
  # debug x is x2
  # debug '55542', x2

  pull = require('pull-stream')
  urge 'this tick'
  setImmediate -> urge 'next tick'

  p1 = []
  p1.push pull.values [1,2,3]
  p1.push pull.map ( x ) -> 2 * x
  p1.push pull.log()
  # pull p1...

  async_map_example = ->
    p2 = []
    p2.push pull.values [ 1 .. 4 ]
    p2.push pull.map ( x ) -> whisper 'A', x; return x
    p2.push pull.asyncMap ( x, handler ) ->
      setTimeout ( -> handler null, 2 * x ), 2000
      setTimeout ( -> handler null, Math.PI * x ), 1000
    # p2.push pull.map ( x ) -> debug 'A', x; return x
    # p2.push pull.asyncMap ( x, handler ) ->
    #   setImmediate -> handler null, 2 * x
    #   # setImmediate -> handler new Error 'oops' if x is 120
    p2.push pull.map ( x ) -> help 'B', x; return x
    # p2.push pull.log()
    p2.push pull.drain()
    pull p2...

  log = ( error, d ) ->
    throw error if error?
    urge d

  pull      = require('pull-stream')
  paramap   = require('pull-paramap')
  width     = 1
  async_job = ( data, cb ) ->
    whisper data
    # cb null, data
    cb null, data + 1.5
    # cb null, data + 1.256
    return null
  p1 = []
  p1.push pull.values [ 1, 3, 5, 7, ]
  p1.push paramap async_job, width
  p1.push pull.collect log
  pull p1...

  ```
  //  pull(
  //    pull.values([ 1, 3, 5, 7, ]),
  //    //perform an async job in parallel,
  //    //and return results in the order they arrive
  //    paramap(function (data, cb) {
  //      async_job(data, cb)
  //    }, null, false), // optional flag `inOrder`, default true
  //    pull.collect( log )
  //  )
  ```
  ###