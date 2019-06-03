





'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TABLE/LAYOUT-READER/SQY'
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
jr                        = JSON.stringify
# ### TAINT cyclic dependency ###
# MKTS_TABLE                = require './mkts-table'
MKTS_TABLE_API            = require './mkts-table-api'
SQY                       = require 'sqy'
misfit                    = Symbol 'misfit'



#-----------------------------------------------------------------------------------------------------------
@read_layout = ( S, L, event, source ) ->
  ### TAINT take advantage of Nearley's streaming API ###
  ### TAINT simplify dispatcher code ###
  try
    tokens = SQY.parse source
  catch error
    warn """
      when trying to parse source

      #{source}

      an error was encountered: #{rpr error.message}"""
    throw error
  #.........................................................................................................
  R = null
  #.........................................................................................................
  for t in tokens
    # whisper '88373', jr t
    _ = misfit
    #.......................................................................................................
    switch t.type
      when 'cheat'
        alert '25521', "cheating"
        MKTS_TABLE = require './mkts-table'
        MKTS_TABLE.columnwidth  R, '20'
        MKTS_TABLE.rowheight    R, '20'
        continue
      when 'create_layout'
        R = MKTS_TABLE_API.create_layout S, event.meta, t.id
        continue
    #.......................................................................................................
    unless R?
      throw new Error "µ9893 must create layout before #{t.type}"
    #.......................................................................................................
    switch t.type
      when 'set_grid'           then _ = MKTS_TABLE_API.set_grid          R, t.size
      when 'set_debug'          then _ = MKTS_TABLE_API.set_debug         R, t.value
      when 'set_unit_lengths'   then _ = MKTS_TABLE_API.set_unit_lengths  R, t.value, t.unit
      when 'set_lane_sizes'     then _ = MKTS_TABLE_API.set_lane_sizes    R, t.direction, t.value
      when 'set_default_gaps'   then _ = MKTS_TABLE_API.set_default_gaps  R, t.feature, t.value
    #.......................................................................................................
    continue unless _ is misfit
    unless R.grid?
      throw new Error "µ9894 must set grid before #{t.type}"
    #.......................................................................................................
    switch t. type
      when 'create_field'       then _ = MKTS_TABLE_API.create_field      R, t.id, t.selector
      when 'set_sel_border'     then _ = MKTS_TABLE_API.set_borders       R, t.selectors, t.edges, t.style
      when 'set_sel_alignment'  then _ = MKTS_TABLE_API.set_alignment     R, t.selectors, t.direction, t.align
      when 'set_sel_background' then _ = MKTS_TABLE_API.set_background    R, t.selectors, t.style
      when 'set_field_gaps'     then _ = MKTS_TABLE_API.set_field_gaps    R, t.selectors, t.edges, t.feature, t.value
    #.......................................................................................................
    continue unless _ is misfit
    warn "unhandled token type #{rpr t.type}"
  #.........................................................................................................
  ### TAINT will abandon this kind of fails handling ###
  if R.fails.length > 0
    alert '44093', fail for fail in R.fails
    throw new Error "µ9894 detected fails"
  #.........................................................................................................
  return R



