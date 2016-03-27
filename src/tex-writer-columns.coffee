




############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/TEX-WRITER/COLUMNS'
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
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
MKTS                      = require './main'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
# hide                      = MK.TS.MD_READER.hide.bind        MK.TS.MD_READER
# copy                      = MK.TS.MD_READER.copy.bind        MK.TS.MD_READER
# stamp                     = MK.TS.MD_READER.stamp.bind       MK.TS.MD_READER
# unstamp                   = MK.TS.MD_READER.unstamp.bind     MK.TS.MD_READER
# select                    = MK.TS.MD_READER.select.bind      MK.TS.MD_READER
# is_hidden                 = MK.TS.MD_READER.is_hidden.bind   MK.TS.MD_READER
# is_stamped                = MK.TS.MD_READER.is_stamped.bind  MK.TS.MD_READER



#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) ->
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$initialize_state          S
    @$end_columns_with_document S
    @$region_slash              S
    @$command_slash             S
    @$columns                   S
    @$transform_to_pretex       S
    # @$transform_pretex_to_tex   S
    ]

#===========================================================================================================
# STREAM TRANSFORMS
#-----------------------------------------------------------------------------------------------------------
@$initialize_state = ( S ) ->
  sandbox   = {}
  is_first  = yes
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '~', 'change'
      [ _, _, changeset, _, ] = event
      sandbox                 = MK.TS.DIFFPATCH.patch changeset, sandbox
      send event
    #.......................................................................................................
    else if is_first and select event, '~', 'flush'
      is_first        = no
      [ ..., meta, ]  = event
      sandbox_backup  = MK.TS.DIFFPATCH.snapshot sandbox
      throw new Error "namespace collision: `S.sandbox.COLUMNS` already defined" if sandbox[ 'COLUMNS' ]?
      sandbox[ 'COLUMNS' ] =
        count: 2 # default number of columns in document **when using multiple columns**
        stack: [ @_new_setting(), ]
      changeset = MKTS.DIFFPATCH.diff sandbox_backup, sandbox
      send [ '~', 'change', changeset, ( copy meta ), ] if changeset.length > 0
      send event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$end_columns_with_document = ( S ) ->
  remark = MK.TS.MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, ')', 'document'
      [ ..., meta, ] = event
      send [ '!', 'columns', [ 1, ], ( copy meta, 'multi-columns': 'omit-open', ), ]
      send event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$region_slash = ( S ) ->
  track         = MD_READER.TRACKER.new_tracker '(slash)'
  event_buffer  = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_slash = track.within '(slash)'
    track event
    #.......................................................................................................
    if select event, '(', 'slash'
      send stamp event
      event_buffer = []
    #.......................................................................................................
    else if select event, ')', 'slash'
      [ ..., meta, ] = event
      send stamp copy event
      send [ '!', 'slash', event_buffer, ( copy meta ), ]
      event_buffer = null
    #.......................................................................................................
    else if within_slash
      event_buffer.push event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$command_slash = ( S ) ->
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '!', 'slash'
      [ type, name, parameters, meta, ] = event
      send stamp hide copy event
      #.....................................................................................................
      # send [ '!', 'columns', [ 'push', ], ( copy meta ), ]
      send [ '!', 'columns', [ 1, ], ( copy meta ), ]
      #.....................................................................................................
      if CND.isa_list parameters
        for x in parameters
          ### TAINT should formally check for `event`ness of value ###
          if CND.isa_list x
            send x
          else
            send [ '.', 'warning', "ignoring argument to <<!slash>>: #{rpr x}", ( copy meta ), ]
      #.....................................................................................................
      send [ '!', 'columns', [  'pop', ], ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$columns = ( S ) ->
  remark  = MK.TS.MD_READER._get_remark()
  sandbox = {}
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '~', 'change'
      [ _, _, changeset, _, ] = event
      sandbox                 = MK.TS.DIFFPATCH.patch changeset, sandbox
      send event
    #.......................................................................................................
    else if select event, '!', 'columns'
      [ type, name, parameters, meta, ] = event
      parameters.push sandbox.COLUMNS.count if parameters.length is 0
      [ parameter, ] = parameters
      switch type = CND.type_of parameter
        #...................................................................................................
        when 'text'
          switch parameter
            when 'pop'
              send stamp hide copy event
              @_restore_column_count sandbox, event, send
            else
              send stamp hide copy event
              message = "unknown text argument #{rpr parameter}"
              send [ '.', 'warning', message, ( copy meta ), ]
        #...................................................................................................
        when 'number'
          unless ( parameter > 0 ) and ( ( Math.floor parameter ) is parameter )
            send stamp hide copy event
            message = "expected non-zero positive integer, got #{rpr parameter}"
            return send [ '.', 'warning', message, ( copy meta ), ]
          send stamp hide copy event
          @_change_column_count sandbox, event, send, parameter
        #...................................................................................................
        else
          send stamp hide copy event
          message = "expected a text or a number, got a #{parameter_type}"
          send [ '.', 'warning', message, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_new_setting = ( P... ) ->
  R =
    count: 1 # number of columns at current point
  return Object.assign R, P...

#-----------------------------------------------------------------------------------------------------------
@_push              = ( sandbox, setting ) -> sandbox.COLUMNS.stack.push setting
@_pop               = ( sandbox )          -> sandbox.COLUMNS.stack.pop()
@_get_column_count  = ( sandbox )          -> sandbox.COLUMNS.stack[ @_get_stack_idx sandbox ][ 'count' ]
@_get_stack_idx     = ( sandbox )          -> sandbox.COLUMNS.stack.length - 1

#-----------------------------------------------------------------------------------------------------------
@_change_column_count = ( sandbox, event, send, column_count ) ->
  @_stop_column_region  sandbox, event, send
  @_start_column_region sandbox, event, send, column_count

#-----------------------------------------------------------------------------------------------------------
@_restore_column_count = ( sandbox, event, send ) ->
  @_stop_column_region  sandbox, event, send
  @_pop sandbox
  column_count = @_get_column_count sandbox
  @_start_column_region sandbox, event, send, column_count

#-----------------------------------------------------------------------------------------------------------
@_start_column_region = ( sandbox, event, send, column_count ) ->
  # send stamp hide copy event
  @_push sandbox, @_new_setting { count: column_count, }
  # debug '©66343', event, column_count
  # debug '©66343', S.sandbox.COLUMNS.stack
  # if column_count isnt 1
  [ ..., meta, ]  = event
  ### TAINT this event should be namespaced and handled only right before output ###
  unless meta[ 'multi-columns' ] is 'omit-open'
    send [ '(', 'multi-columns', [ column_count, ], ( copy meta ), ]
  return null

#-----------------------------------------------------------------------------------------------------------
@_stop_column_region = ( sandbox, event, send ) ->
  ### No-op in case we're in base ('ambient', 'document') state ###
  # urge '77262', sandbox.sandbox.COLUMNS.stack
  # send stamp hide copy event
  return if ( @_get_stack_idx sandbox ) is 0
  column_count    = @_get_column_count sandbox
  # last_state      = @_pop sandbox
  ### No-op in case we're already in single-column state ###
  # return if column_count is 1
  [ ..., meta, ]  = event
  ### TAINT this event should be namespaced and handled only right before output ###
  # debug '928772', [ ')', 'multi-columns', [ column_count, ], ( copy meta ), ]
  send [ ')', 'multi-columns', [ column_count, ], ( copy meta ), ]


#===========================================================================================================
# TRANSFORM TO TEX
#-----------------------------------------------------------------------------------------------------------
@$transform_to_pretex = ( S ) ->
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, parameters, meta, ] = event
    #.......................................................................................................
    if select event, '(', 'multi-columns'
      send hide stamp event
      [ column_count, ] = parameters
      if column_count > 1
        send stamp [ '(', 'COLUMNS/group', null, ( copy meta, tex: 'pass-through', ), ]
        send stamp [ '.', 'COLUMNS/tex', "\\vspace{\\parskip}%TEX-WRITER/COLUMNS/$transform-to-tex\n", ( copy meta, tex: 'pass-through', ), ]
        send stamp [ '.', 'COLUMNS/tex', "\\begin{multicols}{#{column_count}}\\raggedcolumns{}", ( copy meta, tex: 'pass-through', ), ]
    #.......................................................................................................
    else if select event, ')', 'multi-columns'
      # send stamp event
      [ column_count, ] = parameters
      if column_count > 1
        send stamp [ '.', 'COLUMNS/tex', "\\end{multicols}\n\n", ( copy meta, tex: 'pass-through', ), ]
        send stamp [ ')', 'COLUMNS/group', null, ( copy meta, tex: 'pass-through', ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$XXX_transform_pretex_to_tex = ( S ) ->
  buffer          = []
  within_group    = no
  all_whitespace  = yes
  ws_pattern      = /// ^ [ \x20 \t \n ]* $ ///
  #.........................................................................................................
  return $ ( event, send ) =>
    # urge '99876', event
    if CND.isa_text event
      type  = null
      name  = null
      text  = event
      meta  = null
    else
      [ type, name, text, meta, ] = event
    #.......................................................................................................
    if select event, '(', 'COLUMNS/group'
      # help '975', ( JSON.stringify event )[ .. 50 ]
      within_group = yes
    #.......................................................................................................
    else if select event, ')', 'COLUMNS/group'
      # warn '975', ( JSON.stringify event )[ .. 50 ]
      if all_whitespace
        whisper "ignoring multicols b/c group only contains whitespace"
      else
        send sub_text for sub_text in buffer
      ### TAINT code duplication with the above ###
      buffer.length   = 0
      within_group    = no
      all_whitespace  = yes
    #.......................................................................................................
    else if select event, '.', 'COLUMNS/tex'
      # urge '975', ( JSON.stringify event )[ .. 50 ]
      buffer.push text
      # send text
    #.......................................................................................................
    else
      if within_group
        all_whitespace = all_whitespace and ws_pattern.test text
        buffer.push text
        debug '975', event if text is undefined
        # whisper '975', all_whitespace, rpr text
      else
        # info '975', ( JSON.stringify event )[ .. 50 ]
        send event
    #.......................................................................................................
    return null





