





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
  # debug '77129', source
  R = null
  #.........................................................................................................
  for t in SQY.parse source
    whisper '88373', jr t
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

# #-----------------------------------------------------------------------------------------------------------
# @get_mkts_table_description_and_sandbox = ( S, L, event ) ->
#   ### This method makes the format-defining names of the MKTS Table Formatter available at the top level,
#   curried so that the current context (`me`) that contains the processed details as defined so far as well
#   as data on the general typesetting context. All names are templating functions, such that each may be
#   called as `grid'4x4'`, `merge'[a1]..[a4]'` and so on from the source within the MKTS document where the
#   table is being defined. ###
#   me      = MKTS_TABLE._new_description S
#   me.meta = event[ 3 ]
#   ### ... more typesetting detail attached here ... ###
#   #.........................................................................................................
#   f = =>
#     @copy                 = ( raw_parts ) => @_API_copy S, L, me, raw_parts.join ''
#     #.........................................................................................................
#     @name                 = ( raw_parts ) -> MKTS_TABLE.name                  me, raw_parts.join ''
#     @debug                = ( raw_parts ) -> MKTS_TABLE.debug                 me, raw_parts.join ''
#     @grid                 = ( raw_parts ) -> MKTS_TABLE.grid                  me, raw_parts.join ''
#     @fill_gap             = ( raw_parts ) -> MKTS_TABLE.fill_gap              me, raw_parts.join ''
#     @padding              = ( raw_parts ) -> MKTS_TABLE.padding               me, raw_parts.join ''
#     @margin               = ( raw_parts ) -> MKTS_TABLE.margin                me, raw_parts.join ''
#     @unitwidth            = ( raw_parts ) -> MKTS_TABLE.unitwidth             me, raw_parts.join ''
#     @unitheight           = ( raw_parts ) -> MKTS_TABLE.unitheight            me, raw_parts.join ''
#     @columnwidth          = ( raw_parts ) -> MKTS_TABLE.columnwidth           me, raw_parts.join ''
#     @rowheight            = ( raw_parts ) -> MKTS_TABLE.rowheight             me, raw_parts.join ''
#     @fieldcells           = ( raw_parts ) -> MKTS_TABLE.fieldcells            me, raw_parts.join ''
#     @fieldborder          = ( raw_parts ) -> MKTS_TABLE.fieldborder           me, raw_parts.join ''
#     @fieldalignvertical   = ( raw_parts ) -> MKTS_TABLE.fieldalignvertical    me, raw_parts.join ''
#     @fieldalignhorizontal = ( raw_parts ) -> MKTS_TABLE.fieldalignhorizontal  me, raw_parts.join ''
#     return @
#   #.........................................................................................................
#   return [ me, ( f.apply {} ), ]






