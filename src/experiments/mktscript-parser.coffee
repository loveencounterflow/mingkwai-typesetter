
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'HTML-TAGS/TESTS'
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
test                      = require 'guy-test'
eq                        = CND.equals
jr                        = JSON.stringify
#...........................................................................................................
join                      = ( x, joiner = '' ) -> x.join joiner
assign                    = Object.assign
# XREGEXP                   = require 'xregexp'
PS                        = require 'pipestreams'
{ $, $async, }            = PS
new_pushable              = require 'pull-pushable'
assign                    = Object.assign
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.mark} #{d.type}:: #{jr d.value} #{jr d.stamped ? false}"

#-----------------------------------------------------------------------------------------------------------
@active_chr_pattern   = /// ///u
@active_chrs          = new Set()

#-----------------------------------------------------------------------------------------------------------
### thx to https://stackoverflow.com/a/3561711/7568091 ###
@_escape_for_regex = ( text ) -> text.replace @_escape_for_regex.pattern, '\\$&'
@_escape_for_regex.pattern = /[-\/\\^$*+?.()|[\]{}]/g

#-----------------------------------------------------------------------------------------------------------
@add_active_chrs = ( chrs... ) ->
  for chr in chrs
    unless ( CND.isa_text chr ) and ( chr.match /^.$/u )?
      throw new Error "expected single character, got #{rpr chr}"
    @active_chrs.add chr
  pattern               = '[' + ( ( ( @_escape_for_regex chr ) for chr from @active_chrs ).join '|' ) + ']'
  @active_chr_pattern   = new RegExp pattern, 'u'
  return null

#-----------------------------------------------------------------------------------------------------------
@add_active_chrs '<', '&', '*', '`', '^', '_'
help @active_chr_pattern

# debug @_escape_for_regex '*'
# debug @_escape_for_regex '/'
# debug @_escape_for_regex '^'
# debug @_escape_for_regex '\\'
# debug 'foo-bar'.match new RegExp '[x\\-a]'
# @add_active_chr '-'; help @active_chr_pattern
# @add_active_chr '^'; help @active_chr_pattern

#-----------------------------------------------------------------------------------------------------------
@f = ( S ) ->
  S.source    = new_pushable()
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

