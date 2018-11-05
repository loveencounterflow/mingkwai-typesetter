


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TEX-WRITER/MKTSTABLE'
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
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
ECS                       = require './eval-cs'
MKTS                      = require './main'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
jr                        = JSON.stringify
#...........................................................................................................
MKTS_TABLE                = require './mkts-table'
MKTS.MACRO_ESCAPER.register_raw_tag 'mkts-table-description'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  ### TAINT tie local state to events to avoid difficulties with non-synchronous / non-lockstepping
  transforms ###
  L = new_local_state()
  return D.TEE.from_pipeline [
    @$parse_description               S, L
    @$store_layout_event              S, L
    @$handle_content_events           S, L
    # D.$observe ( event ) -> info '23993', ( CND.grey '--------->' ), jr event
    @$handle_fields                   S, L
    @$dump_table_layout               S, L
    ]


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
new_local_state = ->
  R =
    selectors_and_content_events:   {}
    layout_events:                  {}
    content_buffer:                 null
    within_field:                   false
    layout_name_stack:              []
    ### TAINT we use this attribute to communicate the current selector from `$handle_fields()` back to
    `$handle_content_events()`; this works b/c we're assuming that all event handling is happening in
    lockstep. It might stop working as soon as the lockstepping is broken by an intervening asynchronous
    or buffering stream transform. ###
    ### TAINT used to store `layout_name` as well, already in `layout_name_stack` ###
    field_selector_stack:           []
  return R


#-----------------------------------------------------------------------------------------------------------
@is_within_table = ( S, L ) -> L.layout_name_stack.length > 0

#-----------------------------------------------------------------------------------------------------------
@get_current_layout_name = ( S, L ) ->
  unless ( R = L.layout_name_stack[ L.layout_name_stack.length - 1 ] )?
    throw new Error "#{badge} µ79868 layout stack empty"
  return R

#-----------------------------------------------------------------------------------------------------------
@get_current_field_selector = ( S, L ) ->
  unless ( R = L.field_selector_stack[ L.field_selector_stack.length - 1 ] )?
    throw new Error "#{badge} µ58212 field_selector_stack stack empty"
  return R[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@get_enclosing_layout_name = ( S, L ) ->
  ### I've come to thoroughly dislike zero-based indexing paired with non-existing negative indexes.
  We all should be writing `d[ 1 ]`, `d[ 2 ]` for the first and second elements from the left, and
  `d[ -1 ]`, `d[ -2 ]` for the first and second elements from the right end of a list. ###
  length    = L.layout_name_stack.length
  last_idx  = L.layout_name_stack.length - 1
  return null if length < 2
  return L.layout_name_stack[ last_idx - 1 ]

#-----------------------------------------------------------------------------------------------------------
@pop_layout_name = ( S, L ) ->
  R = @get_current_layout_name S, L
  L.layout_name_stack.pop()
  return R

#-----------------------------------------------------------------------------------------------------------
@layout_from_name = ( S, L, layout_name ) ->
  unless ( R = L.layout_events[ layout_name ] )?
    throw new Error "#{badge} µ47753 unknown layout #{rpr layout_name}"
  return R[ 2 ]

#-----------------------------------------------------------------------------------------------------------
@push_layout_name = ( S, L, layout_name ) ->
  unless L.layout_events[ layout_name ]?
    throw new Error "#{badge} µ42558 unknown layout #{rpr layout_name}"
  L.layout_name_stack.push layout_name
  return null

#-----------------------------------------------------------------------------------------------------------
@store_layout_event = ( S, L, event ) ->
  [ _, _, layout, _, ] = event
  if L.layout_events[ layout.name ]?
    throw new Error "#{badge} µ36339 refusing to re-define layout #{rpr layout.name}"
  L.layout_events[ layout.name ] = event
  @_initialize_layout S, L, layout.name
  return null

#-----------------------------------------------------------------------------------------------------------
@_initialize_layout = ( S, L, layout_name ) ->
  L.selectors_and_content_events[ layout_name ] = []
  return null

#-----------------------------------------------------------------------------------------------------------
@new_content_buffer = ( S, L, layout_name, selector ) ->
  unless ( target = L.selectors_and_content_events[ layout_name ] )?
    throw new Error "#{badge} µ24692 unknown layout #{rpr layout_name}"
  R = [ selector, ]
  target.push R
  return R

#-----------------------------------------------------------------------------------------------------------
@push_field_selector = ( S, L, layout_name, selector ) ->
  L.field_selector_stack.push [ layout_name, selector, ]
  return null

#-----------------------------------------------------------------------------------------------------------
@pop_field_selector = ( S, L ) ->
  if L.field_selector_stack.length < 1
    throw new Error "#{badge} µ49782 field selector stack empty"
  return L.field_selector_stack.pop()

#-----------------------------------------------------------------------------------------------------------
@content_buffers_from_layout_name = ( S, L, layout_name ) ->
  unless ( R = L.selectors_and_content_events[ layout_name ] )?
    throw new Error "#{badge} µ65671 unknown layout #{rpr layout_name}"
  return R

#-----------------------------------------------------------------------------------------------------------
@get_selectors_and_content_events = ( S, L, layout_name ) ->
  unless ( R = L.selectors_and_content_events[ layout_name ] )?
    debug '88733', L.selectors_and_content_events
    debug '88733', Object.keys L.selectors_and_content_events
    throw new Error "#{badge} µ95392 unknown layout #{rpr layout_name}"
  return R

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$dump_table_layout = ( S, L ) -> D.$observe ( event ) ->
  return unless select event, '.', 'MKTS/TABLE/layout', true
  help '99871', ( CND.blue rpr event[ 2 ] )

#-----------------------------------------------------------------------------------------------------------
@$parse_description = ( S, L ) ->
  within_mkts_table = false
  return $ ( event, send ) =>
    #.......................................................................................................
    ### TAINT change tag to sth like `mkts-table-layout` ###
    if select event, '.', 'mkts-table-description'
      [ type, name, text, meta, ] = event
      [ layout, sandbox, ]        = @get_mkts_table_description_and_sandbox S, event
      try
        ECS.evaluate text, { language: 'coffee', sandbox, }
      catch error
        warn "when trying to evaluate CS source text for <mkts-table> (source line ##{meta.line_nr}),"
        warn "an error occurred"
        throw error
      send stamp event
      send [ '.', 'MKTS/TABLE/layout', layout, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$store_layout_event = ( S, L ) ->
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '.', 'MKTS/TABLE/layout'
      @store_layout_event S, L, event
      send stamp event
    else
      send event
    return null

#-----------------------------------------------------------------------------------------------------------
@$handle_content_events = ( S, L ) ->
  return $ ( event, send ) =>
    #.......................................................................................................
    ### When table contents start, we register that and do not send anything: ###
    if select event, '(', 'mkts-table-content'
      [ _, _, Q, _, ]       = event
      ### OBS attribute is named 'layout' but contains layout name ###
      unless Q.layout?
        throw new Error "#{badge} µ29245 missing required attribute `layout` for <mkts-table-content>: #{rpr event}"
      @push_layout_name S, L, Q.layout
      send stamp event
    #.......................................................................................................
    ### When table contents end, we send all the sub-events needed to draw the table, and then the
    description-end and description events: ###
    else if select event, ')', 'mkts-table-content'
      #.....................................................................................................
      layout_name                   = @get_current_layout_name          S, L
      layout                        = @layout_from_name                 S, L, layout_name
      selectors_and_content_events  = @get_selectors_and_content_events S, L, layout_name
      enclosing_layout_name         = @get_enclosing_layout_name        S, L
      enclosing_layout              = null
      # if enclosing_layout_name?
      #   enclosing_layout              = @layout_from_name                 S, L, enclosing_layout_name
      #   debug '38883', enclosing_layout
      content_events                = MKTS_TABLE._walk_events layout, selectors_and_content_events, \
        L.layout_name_stack, L.field_selector_stack
      #.....................................................................................................
      if enclosing_layout_name?
        current_field_selector    = @get_current_field_selector S, L
        enclosing_content_events  = @content_buffers_from_layout_name S, L, enclosing_layout_name
        enclosed_content_events   = [ current_field_selector, content_events..., ]
        enclosing_content_events.push enclosed_content_events
      #.....................................................................................................
      else
        send sub_event for sub_event from content_events
      #.....................................................................................................
      send stamp event
      @pop_layout_name S, L
    #.......................................................................................................
    else
      send event
    return null

#-----------------------------------------------------------------------------------------------------------
@$handle_fields = ( S, L ) ->
  content_buffer  = null
  layout_name     = null
  within_field    = false
  return $ ( event, send ) =>
    return send event unless @is_within_table S, L
    # debug '43474', ( CND.truth @is_within_table S, L ), jr event
    #.......................................................................................................
    ### If we are within table contents, we collect all field events and their contents as table field
    contents; outside that, whitespace events are ignored, and other material generates errors: ###
    #.......................................................................................................
    if select event, '(', 'field'
      layout_name = @get_current_layout_name  S, L
      ### TAINT should throw error when <field> nested within <field> *without* intervening <mkts-table-content> ###
      # if within_field
      #   throw new Error "#{badge} µ39418 detected nested <field> tag (#{jr event}) in table #{rpr layout_name}"
      within_field              = true
      [ type, name, Q, meta, ]  = event
      unless Q? and Q.key?
        throw new Error "#{badge} µ33810 missing <field> tag attribute 'key' in table #{rpr layout_name} (#{jr event})"
      ### TAINT this is exactly the kind of dangerous 'could have happened anywhere, anytime' state mutation
      that advocates of immutable state are warning us about: ###
      @push_field_selector S, L, layout_name, Q.key
      content_buffer            = @new_content_buffer S, L, layout_name,  Q.key
      return send stamp event
    #.......................................................................................................
    if select event, ')', 'field'
      within_field              = false
      content_buffer            = null
      @pop_field_selector S, L
      return send stamp event
    #.......................................................................................................
    if within_field
      # debug '37734', layout_name, jr event
      content_buffer.push event
      return null
    #.......................................................................................................
    ### Ignore whitespace between fields: ###
    if ( select event, '.', 'text' ) and ( event[ 2 ].match /^\s*$/ )?
      # whisper '27762', jr event
      return null
    #.......................................................................................................
    ### TAINT should be a fail, not an exception: ###
    # throw new Error "detected illegal content: #{jr event}"
    # warn '27762', ( within_field ), jr event
    # return null
    #.......................................................................................................
    send event
    return null

#-----------------------------------------------------------------------------------------------------------
@get_mkts_table_description_and_sandbox = ( S, event ) ->
  ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
  curried so that the current context (`me`) that contains the processed details as defined so far as well
  as data on the general typesetting context. All names are templating functions, such that each may be
  called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
  table is being defined. ###
  me      = MKTS_TABLE._new_description S
  me.meta = event[ 3 ]
  ### ... more typesetting detail attached here ... ###
  #.........................................................................................................
  f = ->
    @name                 = ( raw_parts ) -> MKTS_TABLE.name                  me, raw_parts.join ''
    @debug                = ( raw_parts ) -> MKTS_TABLE.debug                 me, raw_parts.join ''
    @grid                 = ( raw_parts ) -> MKTS_TABLE.grid                  me, raw_parts.join ''
    @fill_gap             = ( raw_parts ) -> MKTS_TABLE.fill_gap              me, raw_parts.join ''
    @padding              = ( raw_parts ) -> MKTS_TABLE.padding               me, raw_parts.join ''
    @margin               = ( raw_parts ) -> MKTS_TABLE.margin                me, raw_parts.join ''
    @unitwidth            = ( raw_parts ) -> MKTS_TABLE.unitwidth             me, raw_parts.join ''
    @unitheight           = ( raw_parts ) -> MKTS_TABLE.unitheight            me, raw_parts.join ''
    @columnwidth          = ( raw_parts ) -> MKTS_TABLE.columnwidth           me, raw_parts.join ''
    @rowheight            = ( raw_parts ) -> MKTS_TABLE.rowheight             me, raw_parts.join ''
    @fieldcells           = ( raw_parts ) -> MKTS_TABLE.fieldcells            me, raw_parts.join ''
    @fieldborder          = ( raw_parts ) -> MKTS_TABLE.fieldborder           me, raw_parts.join ''
    @fieldalignvertical   = ( raw_parts ) -> MKTS_TABLE.fieldalignvertical    me, raw_parts.join ''
    @fieldalignhorizontal = ( raw_parts ) -> MKTS_TABLE.fieldalignhorizontal  me, raw_parts.join ''
    return @
  #.........................................................................................................
  return [ me, ( f.apply {} ), ]



