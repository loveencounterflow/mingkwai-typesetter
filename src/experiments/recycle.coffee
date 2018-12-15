
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
_new_push_source          = require 'pull-pushable'
assign                    = Object.assign
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.sigil} #{d.key}:: #{jr d.value ? null} #{jr d.stamped ? false}"

###


Pipestream Events v2
====================

d         := { sigil,          key, value, ..., $, }    # implicit global namespace
          := { sigil, prefix,  key, value, ..., $, }    # explicit namespace

# `d.sigil` indicates 'regionality':

sigil     := '.' # proper singleton
          := '~' # system singleton
          := '(' # start-of-region (SOR)    # '<'
          := ')' # end-of-region   (EOR)    # '>'

# `prefix` indicates the namespace; where missing on an event or is `null`, `undefined` or `'global'`,
# it indicates the global namespace:

prefix    := null | undefined | 'global' | non-empty text

key       := non-empty text         # typename

value     := any                    # payload

$         := pod                    # system-level attributes, to be copied from old to new events

###


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@stamp = ( d ) ->
  ### Set the `stamped` attribute on event to sigil it as processed. Stamped events will not be selected
  by the `select` method, only by the `select_all` method. ###
  d.stamped = true
  return d


#===========================================================================================================
# RECYCLING
#-----------------------------------------------------------------------------------------------------------
@$unwrap_recycled = -> return $ ( d, send ) => send @unwrap_recycled d
@unwrap_recycled = ( d ) ->
  ### Given an event, return its value if its a `~recycle` event; otherwise, return the event itself. ###
  return if ( @is_recycling d ) then d.value else d

#-----------------------------------------------------------------------------------------------------------
@$recycle = ( push ) ->
  ### Stream transform to send events either down the pipeline (using `send`) or
  to an alternate destination, using the `push` method ( the only argument to
  this function). Normally, this will be the `push` method of a push source, but
  it could be any function that accepts a single event as argument. ###
  return $ ( d, send ) =>
    if ( @is_recycling d ) then push d else send d
    return null

#-----------------------------------------------------------------------------------------------------------
@new_push_source = ->
  ### Return a `pull-streams` `pushable`. Methods `push` and `end` will be bound to the instance
  so they can be freely passed around. ###
  R       = _new_push_source()
  R.push  = R.push.bind R
  R.end   = R.end.bind R
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@select = ( d, prefix, sigils, keys ) ->
  ### Reject all stamped and recycle events: ###
  return false if @is_stamped   d
  return false if @is_recycling d
  ### TAINT avoid to test twice for arity ###
  switch arity = arguments.length
    when 3 then return @select_all d, prefix, sigils ### d, sigils, keys ###
    when 4 then return @select_all d, prefix, sigils, keys
    else throw new Error "expected 3 to 4 arguments, got arity"

# #-----------------------------------------------------------------------------------------------------------
# @select_system = ( d, prefix, keys ) ->
#   ### TAINT avoid to test twice for arity ###
#   switch arity = arguments.length
#     when 2 then return @select_all d, prefix, sigils ### d, sigils, keys ###
#     when 3 then return @select_all d, prefix, sigils, keys
#     else throw new Error "expected 3 to 4 arguments, got arity"

#-----------------------------------------------------------------------------------------------------------
@select_all = ( d, prefix, sigils, keys ) ->
  ### accepts 3 or 4 arguments; when 4, then second must be prefix (only one prefix allowed);
  `sigils` and `keys` may be text or list of texts. ###
  switch arity = arguments.length
    # when 2 then [ prefix, sigils, keys, ] = [ null, prefix, sigils, ]
    when 3 then [ prefix, sigils, keys, ] = [ null, prefix, sigils, ]
    when 4 then null
    else throw new Error "expected 3 to 4 arguments, got arity"
  #.........................................................................................................
  prefix  = null if ( not prefix? ) or ( prefix is 'global' )
  sigils  ?= null
  keys  ?= null
  switch _type = CND.type_of prefix
    when 'null' then null
    when 'text' then return false unless d.prefix is prefix
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of sigils
    when 'null' then null
    when 'text' then return false unless d.sigil is sigils
    when 'list' then return false unless d.sigil in sigils
    else throw new Error "expected a text or a list, got a #{_type}"
  switch _type = CND.type_of keys
    when 'null' then null
    when 'text' then return false unless d.key is keys
    when 'list' then return false unless d.key in keys
    else throw new Error "expected a text or a list, got a #{_type}"
  return true


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@is_system = ( d ) ->
  ### Return whether event is a system event (i.e. whether its `sigil` equals `'~'`). ###
  return d.sigil is '~'

#-----------------------------------------------------------------------------------------------------------
@is_recycling = ( d ) ->
  ### Return whether event is a recycling wrapper event. ###
  return ( d.sigil is '~' ) and ( d.key is 'recycle' )

#-----------------------------------------------------------------------------------------------------------
@is_stamped = ( d ) ->
  ### Return whether event is stamped (i.e. already processed). ###
  return d.stamped ? false


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@new_event = ( sigil, key, value, other... ) ->
  ### When `other` contains a key `$`, it is treated as a hint to copy
  system-level attributes; if the value of key `$` is a POD that has itself a
  key `$`, then a copy of that value is used. This allows to write `new_event
  ..., $: d` to copy system-level attributes such as source locations to a new
  event. ###
  if value? then  R = assign { sigil, key, value, }, other...
  else            R = assign { sigil, key,        }, other...
  ### TAINT consider to resolve recursively ###
  if ( CND.isa_pod R.$ ) and ( CND.isa_pod R.$.$ ) then R.$ = copy R.$.$
  return R

#-----------------------------------------------------------------------------------------------------------
@new_single_event   = ( key, value, other...  ) -> @new_event '.', key, value, other...
@new_start_event    = ( key, value, other...  ) -> @new_event '(', key, value, other...
@new_stop_event     = ( key, value, other...  ) -> @new_event ')', key, value, other...
@new_system_event   = ( key, value, other...  ) -> @new_event '~', key, value, other...
@new_end_event      =                           -> @new_system_event 'end'
@new_text_event     = (      value, other...  ) -> @new_single_event 'text',    value, other...
@recycling          = ( d )                     -> @new_system_event 'recycle', d

#-----------------------------------------------------------------------------------------------------------
@new_warning = ( ref, message, d, other...  ) ->
  @new_system_event 'warning', d, { ref, message, }, other...


############################################################################################################
L = @
do ->
  for key, value of L
    continue unless CND.isa_function value
    L[ key ] = value.bind L
  return null
