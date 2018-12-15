
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
assign                    = Object.assign
jr                        = JSON.stringify
copy                      = ( P... ) -> assign {}, P...
rprx                      = ( d ) -> "#{d.mark} #{d.type}:: #{jr d.value} #{jr d.stamped ? false}"
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
  new_text_event
  new_push_source
  new_warning
  recycling
  select
  select_all
  stamp
  unwrap_recycled } = require './recycle'

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
  achrs                 = ( ( @_escape_for_regex chr ) for chr from @active_chrs ).join '|'
  @active_chr_pattern   = /// ^ (?<left> .*? ) (?<achrs> (?<achr> #{achrs} ) \k<achr>* ) (?<right> .* ) $ ///
                        # /// (?<!\\) (?<achr> (?<chr> [ \* ` + p ] ) \k<chr>* ) ///
  return null

#-----------------------------------------------------------------------------------------------------------
@add_active_chrs '<', '&', '*', '`', '^', '_', '𣥒'
# help @active_chr_pattern

# debug @_escape_for_regex '*'
# debug @_escape_for_regex '/'
# debug @_escape_for_regex '^'
# debug @_escape_for_regex '\\'
# debug 'foo-bar'.match new RegExp '[x\\-a]'
# @add_active_chr '-'; help @active_chr_pattern
# @add_active_chr '^'; help @active_chr_pattern


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@split_on_first_active_chr = ( text ) ->
  ### If `text` contains an active character, return a POD with the keys `left`, `achr`, and `right`, where
  `left` holds the (possibly empty) text before the first active character, `achr` holds the active
  character itself, and `right` holds the remaining, agaoin possibly empty, text (that may or may not contain
  further active characters). ###
  return null unless ( match = text.match @active_chr_pattern )?
  return match.groups

#-----------------------------------------------------------------------------------------------------------
@$split_on_first_active_chr = ( S ) ->
  return $ ( d, send ) =>
    ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
    return send d unless ( select d, '.', 'text' ) and ( not d.clean )
    if ( parts = @split_on_first_active_chr d.value )?
      { achr, achrs, left, right, } = parts
      send new_single_event 'achr-split', achrs, { achr, left, right, }, $: d
    else
      d.clean = true
      send d
    return null

#-----------------------------------------------------------------------------------------------------------
@$recycle_untouched_texts = ( S ) -> $ ( d, send ) =>
    if ( select d, '.', 'text' ) and ( not d.clean ) then send recycling d
    else send d
    return null

#-----------------------------------------------------------------------------------------------------------
@$warn_on_unhandled_achrs = ( S ) -> $ ( d, send ) =>
    if ( select d, '.', 'achr-split' )
      lnr     = d.$?.lnr  ? '?'
      text    = if d.$?.text? then ( rpr d.$.text ) else '?'
      message = "unhandled active characters #{rpr d.value} on line #{lnr} in #{text}"
      send new_warning 'µ99823', message, d, $: d
    else
      send d
    return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
provide_achrs_transforms = ->

  # #-----------------------------------------------------------------------------------------------------------
  # ### TAINT add `li` ###
  # @$em_and_strong = ( S ) ->
  #   stack   = []
  #   get_top = -> stack[ stack.length - 1 ] ? null
  #   within  = ( key ) -> key in stack
  #   return $ ( d, send ) =>
  #     if ( select d, '.', 'achr-split' ) and ( d.value is '***' )
  #       # if within 'em'
  #       ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
  #       send new_text_event d.left, { clean: true, $: d }
  #       if not within then  send new_start_event 'sf', 'em', $: d
  #       else                send new_stop_event  'sf', 'em', $: d
  #       send new_text_event d.right, $: d
  #       within = not within
  #     else
  #       send d
  #     return null

  #-----------------------------------------------------------------------------------------------------------
  @$em = ( S ) ->
    within = false
    return $ ( d, send ) =>
      if ( select d, '.', 'achr-split' ) and ( d.value is '*' )
        ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
        send new_text_event d.left, { clean: true, $: d }
        if not within then  send new_start_event 'sf', 'em', $: d
        else                send new_stop_event  'sf', 'em', $: d
        send new_text_event d.right, $: d
        within = not within
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$strong = ( S ) ->
    within = false
    return $ ( d, send ) =>
      if ( select d, '.', 'achr-split' ) and ( d.value is '**' )
        ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
        send new_text_event d.left, { clean: true, $: d }
        if not within then  send new_start_event 'sf', 'strong', $: d
        else                send new_stop_event  'sf', 'strong', $: d
        send new_text_event d.right, $: d
        within = not within
      else
        send d
      return null

  #-----------------------------------------------------------------------------------------------------------
  return @

ACHRS_TRANSFORMS = provide_achrs_transforms.apply {}


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$show_events = ( S ) ->
  level       = 0
  delta       = 0
  indentation = '  '
  #.........................................................................................................
  rpr_lnr     = ( d ) -> CND.gold d.$?.lnr ? '?'
  start       = ( d ) -> ( rpr_lnr d ) + indentation
  reduce      = ( d ) ->
    R = {}
    R[ key ] = value for key, value of d when key not in [ 'sigil', 'key', 'value', '$', ]
    return if ( Object.keys R ).length > 0 then jr R else ''
  #.........................................................................................................
  return PS.$watch ( d ) =>
    if delta isnt 0
      level        += delta
      delta         = 0
      indentation   = ( '  '.repeat level ) + '  '
    #.......................................................................................................
    if select d, '~', 'warning'
      warn ( start d ) + CND.red "warning ref #{d.ref}: #{d.message}"
      warn ( start d ) + CND.red "generated by event: #{jr d.value}"
    #.......................................................................................................
    else if ( select d, '~', null )
      whisper ( start d ) + jr d
    #.......................................................................................................
    else if ( select d, '.', 'text' )
      help ( start d ) + ( CND.white rpr d.value )
    #.......................................................................................................
    else if ( select d, [ '(', ')' ], null )
      color = if ( d.sigil is '(' ) then CND.lime else CND.red
      help ( start d ) + color "#{d.sigil} #{d.key}: #{jr d.value} #{reduce d}"
      delta = if ( d.sigil is '(' ) then +1 else -1
    #.......................................................................................................
    else
      urge ( start d ) + jr d
    #.......................................................................................................
    return null

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$parse_special_forms = ( S ) ->

  #---------------------------------------------------------------------------------------------------------
  lnr                 = 0
  mktsp2_push_source  = null
  gsend               = null

  #---------------------------------------------------------------------------------------------------------
  @$_as_text_event = ( d ) -> $ ( d, send ) =>
    ### Convert texts in to text events, adjust line nrs ###
    ### TAINT should split texts into lines ###
    if CND.isa_text d
      lnr  += +1
      d     = new_text_event d, $: { lnr, text: d, }
    else if ( select '.', 'text' ) and d.$?.lnr?
      lnr   = d.$.lnr
    #.......................................................................................................
    send d

  #---------------------------------------------------------------------------------------------------------
  @get_transformer = =>
    pipeline    = []
    pipeline.push PS.$watch ( d ) => whisper '12091', jr d
    pipeline.push @$_as_text_event()
    #.......................................................................................................
    pipeline.push $ ( d, send ) =>
      gsend               = send
      mktsp2_push_source ?= @get_mktsp2_push_source()
      mktsp2_push_source.push d
      return null
    #.......................................................................................................
    return PS.pull pipeline...

  #---------------------------------------------------------------------------------------------------------
  @get_mktsp2_push_source = =>
    source      = new_push_source()
    pipeline    = []
    #.......................................................................................................
    pipeline.push source
    # pipeline.push PS.$watch ( d ) => whisper jr d
    pipeline.push $unwrap_recycled()
    #.......................................................................................................
    pipeline.push @$split_on_first_active_chr         S
    pipeline.push ACHRS_TRANSFORMS.$em                S
    pipeline.push ACHRS_TRANSFORMS.$strong            S
    pipeline.push @$recycle_untouched_texts           S
    pipeline.push @$warn_on_unhandled_achrs           S
    #.......................................................................................................
    pipeline.push PS.$watch ( d ) => if ( select d, '~', 'end' ) then source.end()
    pipeline.push $recycle source.push
    #.......................................................................................................
    pipeline.push PS.$watch ( d ) -> gsend d
    pipeline.push PS.$drain()
    PS.pull pipeline...
    #.......................................................................................................
    return source

  #---------------------------------------------------------------------------------------------------------
  return @get_transformer()


############################################################################################################
unless module.parent?
  S = {}
  texts = [
    'a line of text.'
    'a line of *text*.'
    'a line of 𣥒text*.'
    'a **strong** and a *less strong* emphasis.'
    'a *normal and a **strong** emphasis*.'
    # 'another *such and **such*** emphasis.'
    # '***em* strong**.'
    # '***strong** em*.'
    # '***strong-em***.'
    'lone *star'
    ]
  MKTSP2    = @
  source    = new_push_source()
  pipeline  = []
  pipeline.push source
  pipeline.push PS.$watch ( d ) => whisper '33301', jr d
  pipeline.push MKTSP2.$parse_special_forms S
  # pipeline.push PS.$watch ( d ) => urge jr d
  pipeline.push MKTSP2.$show_events         S
  pipeline.push PS.$drain()
  PS.pull pipeline...

  for text in texts
    whisper '#'.repeat 50
    source.push text

  # pattern = /// (?<!\\) (?<achr> (?<chr> [ \* ` + p ] ) \k<chr>* ) ///
  # # pattern = /// (?<!\\) (?<achr> ( [ \* ` + p ] ) \2* ) ///
  # # pattern = /// (?<!\\) ( ( [ \* ` + p ] ) \2* ) ///
  # debug 'flappy'.match pattern
  # debug 'fla\\ppy'.match pattern


