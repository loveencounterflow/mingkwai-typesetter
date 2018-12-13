
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
new_pushable              = require 'pull-pushable'
assign                    = Object.assign
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.mark} #{d.type}:: #{jr d.value} #{jr d.stamped ? false}"

###


Pipestream Events v2
====================

d         := { mark,          type, value, ... }    # implicit global namespace
          := { mark, prefix,  type, value, ... }    # explicit namespace

# `d.mark` indicates 'regionality':

mark      := '.' # proper singleton
mark      := '~' # meta singleton
          := '(' # start-of-region (SOR)    # '<'
          := ')' # end-of-region   (EOR)    # '>'

# `prefix` indicates the namespace; where missing on an event or is `null`, `undefined` or `'global'`,
# it indicates the global namespace:

prefix    := null | undefined | 'global' | non-empty text

type      := non-empty text         # typename

value     := any                    # payload

###

#-----------------------------------------------------------------------------------------------------------
stamp = ( d ) ->
  d.stamped = true
  return d

#-----------------------------------------------------------------------------------------------------------
recycle         = ( d       ) -> new_event '~', 'recycle', d
uncycle         = ( d       ) -> if ( select_all d, '~', 'recycle' ) then d.value else d
$uncycle        =             -> $ ( d, send ) -> send uncycle d
try_to_recycle  = ( d       ) -> if ( select d, '~', 'recycle' ) then d.value else null
$try_to_recycle = ( resend  ) -> PS.$watch ( d ) -> if ( e = try_to_recycle d )? then resend d
is_meta         = ( d       ) -> select_all d, '~', null

#-----------------------------------------------------------------------------------------------------------
select = ( d, prefix, marks, types ) ->
  ### Reject all stamped events: ###
  return if ( d.stamped is true ) then false
  return if ( d.recycle is true ) then false
  ### TAINT avoid to test twice for arity ###
  switch arity = arguments.length
    when 3 then return select_all d, prefix, marks ### d, marks, types ###
    when 4 then return select_all d, prefix, marks, types
    else throw new Error "expected 3 to 4 arguments, got arity"

#-----------------------------------------------------------------------------------------------------------
select_all = ( d, prefix, marks, types ) ->
  ### accepts 3 or 4 arguments; when 4, then second must be prefix (only one prefix allowed);
  `marks` and `types` may be text or list of texts. ###
  switch arity = arguments.length
    # when 2 then [ prefix, marks, types, ] = [ null, prefix, marks, ]
    when 3 then [ prefix, marks, types, ] = [ null, prefix, marks, ]
    when 4 then null
    else throw new Error "expected 3 to 4 arguments, got arity"
  #.........................................................................................................
  prefix  = null if ( not prefix? ) or ( prefix is 'global' )
  marks  ?= null
  types  ?= null
  switch _type = CND.type_of prefix
    when 'null' then null
    when 'text' then return false unless d.prefix is prefix
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of marks
    when 'null' then null
    when 'text' then return false unless d.mark is marks
    when 'list' then return false unless d.mark in marks
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of types
    when 'null' then null
    when 'text' then return false unless d.type is types
    when 'list' then return false unless d.type in types
    else throw new Error "expected a text or a list, got a #{_type}"
  return true

#-----------------------------------------------------------------------------------------------------------
new_event = ( mark, type, value, other... ) ->
  value ?= null
  return assign { mark, type, value, }, other...

#-----------------------------------------------------------------------------------------------------------
new_number_event = ( value, other... ) ->
  return new_event '.', 'number', value, other...


provide_xxx = ->
  #-----------------------------------------------------------------------------------------------------------
  return @
# COLLATZ = provide_collatz.apply {}

#-----------------------------------------------------------------------------------------------------------
@new_sender = ( S ) ->
  S.source    = new_pushable()
  #.........................................................................................................
  on_stop     = PS.new_event_collector 'stop', -> help 'ok'
  pipeline    = []
  #.........................................................................................................
  pipeline.push S.source
  pipeline.push $uncycle()
  # pipeline.push COLLATZ.$main S
  pipeline.push PS.$watch ( d ) -> help '> sink  ', rprx d unless is_meta d
  #.........................................................................................................
  pipeline.push PS.$watch ( d ) -> if ( select d, '~', 'end' ) then S.source.end()
  pipeline.push $try_to_recycle S.source.push.bind S.source
  #.........................................................................................................
  pipeline.push on_stop.add PS.$drain()
  PS.pull pipeline...
  #.........................................................................................................
  R       = ( value ) -> S.source.push new_event '.', 'number', value
  R.end   = -> S.source.end()
  return R


############################################################################################################
unless module.parent?
  # S = {}
  # send = @new_sender S
  # urge '-----------'
  # send 42
  # urge '-----------'
  # for n in [ 1 .. 5 ]
  #   send -n
  #   urge '-----------'
  # # # send.end()
  EFILE = require './embedded-file'
  EFILE.read_embedded_file __filename


###<embedded-file>





</embedded-file>###


