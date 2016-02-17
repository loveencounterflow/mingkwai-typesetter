




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
debug '9387', MK
hide                      = MK.TS.MD_READER.hide.bind        MK.TS.MD_READER
copy                      = MK.TS.MD_READER.copy.bind        MK.TS.MD_READER
stamp                     = MK.TS.MD_READER.stamp.bind       MK.TS.MD_READER
unstamp                   = MK.TS.MD_READER.unstamp.bind     MK.TS.MD_READER
select                    = MK.TS.MD_READER.select.bind      MK.TS.MD_READER
is_hidden                 = MK.TS.MD_READER.is_hidden.bind   MK.TS.MD_READER
is_stamped                = MK.TS.MD_READER.is_stamped.bind  MK.TS.MD_READER



#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) =>
  S.COLUMNS ?= {}
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$regions_from_commands     S
    @$consolidate_columns       S
    @$slash                     S
    @$multi_column              S
    @$single_column             S
    ]

#-----------------------------------------------------------------------------------------------------------
@_begin_multi_column = ( S, column_count = 2 ) =>
  ### TAINT Column count must come from layout / options / MKTS-MD command ###
  ### TAINT make `\raggedcolumns` optional? ###
  column_count ?= S.document.column_count
  return [ 'tex', "\n\n\\vspace{\\mktsLineheight}\\begin{multicols}{#{column_count}}\\raggedcolumns{}" ]

#-----------------------------------------------------------------------------------------------------------
@_end_multi_column = ( S, column_count = 2 ) =>
  return [ 'tex', "\\end{multicols}\n\n" ]

#-----------------------------------------------------------------------------------------------------------
@$regions_from_commands = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    if select event, '!', 'multi-column'
      [ type, name, parameters, meta, ] = event
      send stamp hide copy event
      send [ '(', 'multi-column', parameters, ( copy meta ), ]
      # send stamp hide [ ')', '!',       name, ( copy meta ), ]
    #.......................................................................................................
    else if select event, '!', 'single-column'
      [ type, name, parameters, meta, ] = event
      send stamp hide copy event
      send [ '(', 'single-column', parameters, ( copy meta ), ]
      # send stamp hide [ ')', '!',       name, ( copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$consolidate_columns = ( S ) =>
  within_multi_column   = no
  within_single_column  = no
  stack                 = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, parameters, meta, ] = event
    #.......................................................................................................
    if select event, '(', [ 'single-column', 'multi-column', ]
      #.....................................................................................................
      if within_single_column
        extra_event = stack.pop()
        send copy [ ')', 'single-column', extra_event[ 2 ], meta, ]
        within_single_column = no
      #.....................................................................................................
      else if within_multi_column
        extra_event = stack.pop()
        send copy [ ')', 'multi-column', extra_event[ 2 ], meta, ]
        within_multi_column = no
    #.......................................................................................................
    if select event, '(', 'multi-column'
      send event
      stack.push event
      within_multi_column = yes
    #.......................................................................................................
    else if select event, '(', 'single-column'
      send event
      stack.push event
      within_single_column = yes
    #.......................................................................................................
    else if select event, ')', 'multi-column'
      send event
      within_multi_column = no
    #.......................................................................................................
    else if select event, ')', 'single-column'
      send event
      within_single_column = no
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$slash = ( S ) =>
  track   = MK.TS.MD_READER.TRACKER.new_tracker '(multi-column)'
  remark  = MK.TS.MD_READER._get_remark()
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '(multi-column)'
    track event
    if select event, '!', 'slash'
      [ type, name, text, meta, ] = event
      send stamp event
      if within_multi_column
        send [ ')', 'multi-column', null, ( copy meta ), ]
        ### TAINT consider to send MKTS macro ###
        send [ 'tex', "\\mktsEmptyLine\n" ]
        send [ '(', 'multi-column', null, ( copy meta ), ]
      else
        send remark 'drop', "`!slash` because not within `(multi-column)`", ( copy meta )
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$multi_column = ( S ) =>
  track         = MK.TS.MD_READER.TRACKER.new_tracker '(multi-column)'
  remark        = MK.TS.MD_READER._get_remark()
  column_count  = 1
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '(multi-column)'
    track event
    #.......................................................................................................
    if select event, [ '(', ')', ], 'multi-column'
      send stamp event
      [ type, name, parameters, meta, ] = event
      column_count                      = parameters?[ 0 ] ? S.document.column_count
      #.....................................................................................................
      if type is '('
        if within_multi_column
          send remark 'drop', "`(multi-column` because already within `(multi-column)`", ( copy meta )
        else
          send track @_begin_multi_column S, column_count
      #.....................................................................................................
      else
        if within_multi_column
          send track @_end_multi_column S, column_count
        else
          send remark 'drop', "`multi-column)` because not within `(multi-column)`", ( copy meta )
    #.......................................................................................................
    else if select event, ')', 'document'
      send track @_end_multi_column S, column_count if within_multi_column
      send event
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$single_column = ( S ) =>
  ### TAINT consider to implement command `change_column_count = ( send, n )` ###
  track         = MK.TS.MD_READER.TRACKER.new_tracker '(multi-column)'
  remark        = MK.TS.MD_READER._get_remark()
  column_count  = 1
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '(multi-column)'
    track event
    #.......................................................................................................
    if select event, [ '(', ')', ], 'multi-column'
      send event
      [ type, name, parameters, meta, ] = event
      column_count                      = parameters?[ 0 ] ? S.document.column_count
    #.......................................................................................................
    else if select event, [ '(', ')', ], 'single-column'
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '('
        if within_multi_column
          send remark 'insert', "`multi-column)`", copy meta
          send track @_end_multi_column S, column_count
          send stamp event
        else
          # send stamp event
          send remark 'drop', "`single-column` because not within `(multi-column)`", copy meta
      #.....................................................................................................
      else
        if within_multi_column
          send stamp event
          send remark 'insert', "`(multi-column`", copy meta
          send track @_begin_multi_column S, column_count
        else
          send remark 'drop', "`single-column` because not within `(multi-column)`", copy meta
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null
