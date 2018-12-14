
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
rprx                      = ( d ) -> "#{d.sigil} #{d.key}:: #{jr d.value ? null} #{jr d.stamped ? false}"

###


Pipestream Events v2
====================

d         := { sigil,          key, value, ... }    # implicit global namespace
          := { sigil, prefix,  key, value, ... }    # explicit namespace

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
@unwrap_recycled = ( d ) ->
  ### Given an event, return its value if its a `~recycle` event; otherwise, return the event itself. ###
  return if ( @is_recycling d ) then d.value else d

#-----------------------------------------------------------------------------------------------------------
@$unwrap_recycled = ->
  return $ ( d, send ) => send @unwrap_recycled d

#-----------------------------------------------------------------------------------------------------------
@$recycle = ( sender ) ->
  return PS.$watch ( d ) =>
    if ( @is_recycling d ) then sender d


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
  return assign { sigil, key, value, }, other... if value?
  return assign { sigil, key, }, other...

#-----------------------------------------------------------------------------------------------------------
@new_single_event   = ( key, value, other...  ) -> @new_event '.', key, value, other...
@new_start_event    = ( key, value, other...  ) -> @new_event '(', key, value, other...
@new_stop_event     = ( key, value, other...  ) -> @new_event ')', key, value, other...
@new_system_event   = ( key, value, other...  ) -> @new_event '~', key, value, other...
@new_end_event      =                           -> @new_system_event 'end'
@recycling          = ( d )                     -> @new_system_event 'recycle', d


############################################################################################################
L = @
do ->
  for key, value of L
    continue unless CND.isa_function value
    L[ key ] = value.bind L
  return null
