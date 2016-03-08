




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
    @$slash                     S
    @$columns                   S
    # $ ( event, send ) =>
    #   if select event, [ '(', ')', ], 'multi-columns'
    #     [ _, _, [ column_count, ], _, ] = event
    #     send event unless column_count is 1
    #   else
    #     send event
    @$transform_to_tex          S
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
@$slash = ( S ) ->
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
@$transform_to_tex = ( S ) ->
  last_was_heading  = no
  buffer            = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, parameters, meta, ] = event
    # debug '34211', event
    #.......................................................................................................
    if select event, ')', 'h'
      send event
      urge '12331', "last_was_heading"
      last_was_heading = yes
    #.......................................................................................................
    else if select event, '(', 'multi-columns'
      send hide stamp event
      [ column_count, ] = parameters
      if column_count > 1
        # send [ 'tex', "{\\setlength{\\parskip}{0mm}~\\par}%TEX-WRITER/COLUMNS/$transform-to-tex\n" ]
        unless last_was_heading
          # debug '11234', "sending vspace b/c last wasnt heading"
          send [ 'tex', "\\vspace{\\parskip}%TEX-WRITER/COLUMNS/$transform-to-tex\n" ]
        else
          # debug '11234', "omitting vspace b/c last was heading"
        send [ 'tex', "\\begin{multicols}{#{column_count}}\\raggedcolumns{}" ]
      last_was_heading = no
    #.......................................................................................................
    else if select event, ')', 'multi-columns'
      # send stamp event
      [ column_count, ] = parameters
      if column_count > 1
        send [ 'tex', "\\end{multicols}\n\n" ]
      last_was_heading = no
    #.......................................................................................................
    else
      send event
      last_was_heading = no
    #.......................................................................................................
    return null


