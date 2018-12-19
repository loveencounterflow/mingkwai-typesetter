
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTSCRIPT-PARSER-2'
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
  new_flush_event
  new_warning
  recycling
  select
  select_all
  stamp
  unwrap_recycled } = require './recycle'

#-----------------------------------------------------------------------------------------------------------
is_empty                  = ( x ) ->
  return ( x.length is 0 ) if x.length?
  return ( x.size   is 0 ) if x.size?
  throw new Error "unable to determine length of a #{CND.type_of x}"

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
    if ( select d, '.', 'text' ) and ( not d.clean )
      send recycling d
    else
      send d
    return null

#-----------------------------------------------------------------------------------------------------------
@$warn_on_unhandled_achrs = ( S ) -> $ ( d, send ) =>
    if ( select d, '.', 'achr-split' )
      lnr     = d.$?.lnr  ? '?'
      text    = if d.$?.text? then ( rpr d.$.text ) else '?'
      message = "unhandled active characters #{rpr d.value} on line #{lnr} in #{text}"
      send new_text_event d.left, { clean: true, $: d } unless is_empty d.left
      send new_warning 'µ99823', message, d, $: d
    else
      send d
    return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
provide_achrs_transforms = ->

  #-----------------------------------------------------------------------------------------------------------
  ### TAINT add `li` ###
  @$em_and_strong_1 = ( S ) ->
    #.........................................................................................................
    return $ ( d, send ) =>
      #.......................................................................................................
      is_achr = select d, '.', 'achr-split'
      #.......................................................................................................
      if is_achr and ( d.value in [ '*', '**', '***', ] )
        send new_text_event d.left, { clean: true, $: d } unless is_empty d.left
        switch d.value
          when '*'    then send new_event ')(', 'em',         null, $: d
          when '**'   then send new_event ')(', 'strong',     null, $: d
          when '***'  then send new_event ')(', 'em-strong',  null, $: d
        send new_text_event d.right, $: d unless is_empty d.right
      #.......................................................................................................
      else
        send d
      #.......................................................................................................
      return null

  #-----------------------------------------------------------------------------------------------------------
  @$em_and_strong_2 = ( S ) ->
    send        = null
    buffer      = []
    open_tags   = []
    get_top     = -> open_tags[ open_tags.length - 1 ]
    # within_any  = ( key ) -> key in open_tags
    within      = ( key ) -> get_top() is key
    open        = ( key ) -> open_tags.push key
    # close       = ( key ) -> open_tags[ .. ] = open_tags.filter ( x ) -> x isnt key; return null
    close       = ( key ) ->
      if ( key is get_top() )
        open_tags.pop()
      else
        throw "stack error: expected #{rpr key}, but stack is #{rpr open_tags}"
      return null
    flush       = -> send buffer.shift() while buffer.length > 0
    #.........................................................................................................
    return $ ( d, _send ) =>
      whisper '29998', ( within 'em-strong' ), ( if d.key is 'flush' then CND.steel else CND.grey ) jr d
      send = _send
      if select d, '~', 'flush'
        if within 'em-strong'
          close 'em-strong'
          debug CND.white '99930-1', "close 'em-strong'"
          send new_start_event  'em',     null, $: d
          send new_start_event  'strong', null, $: d
        flush()
        return send d
      #.......................................................................................................
      if select d, ')(', 'em-strong'
        help '89887-1', d.$
        help '89887-2', open_tags, within 'em-strong'
        help '89887-3', buffer
        if within 'em-strong'
          # debug '77222-1'
          close 'em-strong'
          # debug CND.white '99930-2', "close 'em-strong'"
          send new_start_event  'em',     null, $: d
          send new_start_event  'strong', null, $: d
          flush()
          send new_stop_event   'strong', null, $: d
          send new_stop_event   'em',     null, $: d
        else if ( within 'em' ) or ( within 'strong' )
          # debug '77222-2'
          loop
            if within 'em'
              close 'em'
              send new_stop_event 'em', null, $: d
            else if within 'strong'
              close 'strong'
              send new_stop_event 'strong', null, $: d
            else
              break
        else
          open 'em-strong'
          # debug '77222-3', open_tags, within 'em-strong'
      #.......................................................................................................
      else if select d, ')(', 'em'
        if within 'em-strong'
          close 'em-strong'
          # debug CND.white '99930-3', "close 'em-strong'"
          open 'strong'
          send new_stop_event   'em',     null, $: d
        else if within 'em'
          close 'em'
          send new_stop_event   'em',     null, $: d
        else
          open 'em'
          send new_start_event  'em',     null, $: d
      #.......................................................................................................
      else if select d, ')(', 'strong'
        if within 'em-strong'
          close 'em-strong'
          # debug CND.white '99930-4', "close 'em-strong'"
          open 'em'
          send new_stop_event   'strong', null, $: d
        else if within 'strong'
          close 'strong'
          send new_stop_event   'strong', null, $: d
        else
          open 'strong'
          send new_start_event  'strong', null, $: d
      #.......................................................................................................
      else if within 'em-strong'
        buffer.push d
        # debug '10002', jr buffer
      #.......................................................................................................
      else
        send d
      #.......................................................................................................
      # urge '89887-fin', open_tags, within 'em-strong'
      return null

  # #-----------------------------------------------------------------------------------------------------------
  # @$em = ( S ) ->
  #   within = false
  #   return $ ( d, send ) =>
  #     if ( select d, '.', 'achr-split' ) and ( d.value is '*' )
  #       ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
  #       send new_text_event d.left, { clean: true, $: d }
  #       if not within then  send new_start_event 'sf', 'em', $: d
  #       else                send new_stop_event  'sf', 'em', $: d
  #       send new_text_event d.right, $: d
  #       within = not within
  #     else
  #       send d
  #     return null

  # #-----------------------------------------------------------------------------------------------------------
  # @$strong = ( S ) ->
  #   within = false
  #   return $ ( d, send ) =>
  #     if ( select d, '.', 'achr-split' ) and ( d.value is '**' )
  #       ### using ad-hoc `clean` attribute to indicate that text does not contain active characters ###
  #       send new_text_event d.left, { clean: true, $: d }
  #       if not within then  send new_start_event 'sf', 'strong', $: d
  #       else                send new_stop_event  'sf', 'strong', $: d
  #       send new_text_event d.right, $: d
  #       within = not within
  #     else
  #       send d
  #     return null

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
      level         = Math.max 0, level + delta
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

  #---------------------------------------------------------------------------------------------------------
  @$_as_text_event = ( d ) -> $ ( d, send ) =>
    ### Convert texts in to text events, adjust line nrs ###
    ### TAINT should split texts into lines ###
    if CND.isa_text d
      lnr  += +1
      d     = new_text_event d, $: { lnr, text: d, }
    else if ( select d, '.', 'text' ) and d.$?.lnr?
      lnr   = d.$.lnr
    #.......................................................................................................
    send d

  #---------------------------------------------------------------------------------------------------------
  @get_transformer = =>
    mktsp2_push_source  = null
    pipeline            = []
    # pipeline.push PS.$watch ( d ) => whisper '12091', jr d
    pipeline.push @$_as_text_event()
    #.......................................................................................................
    pipeline.push $async ( d, send, done ) =>
    # pipeline.push $ ( d, send ) =>
      mktsp2_push_source ?= @get_mktsp2_push_source()
      mktsp2_push_source.push new_system_event 'send-and-done', { send, done, }
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
    pipeline.push ACHRS_TRANSFORMS.$em_and_strong_1   S
    pipeline.push ACHRS_TRANSFORMS.$em_and_strong_2   S
    # pipeline.push ACHRS_TRANSFORMS.$em                S
    # pipeline.push ACHRS_TRANSFORMS.$strong            S
    pipeline.push @$recycle_untouched_texts           S
    pipeline.push @$warn_on_unhandled_achrs           S
    #.......................................................................................................
    pipeline.push PS.$watch ( d ) => if ( select d, '~', 'end' ) then source.end()
    pipeline.push $recycle source.push
    #.......................................................................................................
    pipeline.push do =>
      senders = null
      PS.$watch ( d ) ->
        if select d, '~', 'send-and-done'
          debug '29922', d
          senders = d
        else
          senders.send d
          senders.done()
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
    # 'a line of text.'
    # 'a line of *text*.'
    # 'a line of 𣥒text*.'
    # 'a **strong** and a *less strong* emphasis.'
    'a *normal and a **strong** emphasis*.'
    # 'another *such and **such*** emphasis.'
    # '***em* strong**.'
    # '***strong** em*.'
    'triple ***strong-em***.'
    'lone *star'
    'triple lone ***star'
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
    source.push new_flush_event()

  # pattern = /// (?<!\\) (?<achr> (?<chr> [ \* ` + p ] ) \k<chr>* ) ///
  # # pattern = /// (?<!\\) (?<achr> ( [ \* ` + p ] ) \2* ) ///
  # # pattern = /// (?<!\\) ( ( [ \* ` + p ] ) \2* ) ///
  # debug 'flappy'.match pattern
  # debug 'fla\\ppy'.match pattern


