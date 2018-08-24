




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
PS                        = require 'pipestreams'
{ $, $async, }            = PS


#-----------------------------------------------------------------------------------------------------------
@fetch_aux_data = ( S, handler ) ->
  Z           = {}
  source      = PS.new_file_source S.layout_info[ 'aux-locator' ]
  on_stop     = PS.new_event_collector 'stop', ->
    help "read data from #{S.layout_info[ 'aux-locator' ]}"
    handler null, Z
  pipeline    = []
  pipeline.push source
  pipeline.push PS.$split()
  # pipeline.push PS.$show()
  pipeline.push @$read_linerefs     S, Z
  pipeline.push @$read_xypositions  S, Z
  pipeline.push on_stop.add PS.$drain()
  PS.pull pipeline...
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@$read_linerefs = ( S, Z ) ->
  ### Reads references made by package `lineno` provided reference labels start with `mkts-linenr-` ###
  ### \newlabel{mkts-linenr-foobar}{{\getpagewiselinenumber {5}}{1}} ###
  pattern = /^\\newlabel\{mkts-linenr-([^}]+)\}\{\{\\getpagewiselinenumber \{([\d]+)\}\}\{([\d]+)\}\}$/
  target  = Z.linenrs = {}
  return $ ( line, send ) ->
    match                         = line.match pattern
    return send line unless match?
    [ _, name, linenr, pagenr, ]  = match
    pagenr                        = parseInt pagenr, 10
    linenr                        = parseInt linenr, 10
    target[ name ]                = { pagenr, linenr, }
    return null

#-----------------------------------------------------------------------------------------------------------
@$read_xypositions = ( S, Z ) ->
  ### Reads (x,y) position references made by package `zref-savepos` ###
  ### \zref@newlabel{mkts-pos-foobar}{\posx{2797018}\posy{50159889}} ###
  pattern = /^\\zref@newlabel\{([^}]+)\}\{\\posx\{([\d]+)\}\\posy\{([\d]+)\}\}$/
  target  = Z.xypositions = {}
  return $ ( line, send ) ->
    match                         = line.match pattern
    return send line unless match?
    [ _, name, x, y, ]            = match
    x                             = parseInt x, 10
    y                             = parseInt y, 10
    target[ name ]                = { x, y, }
    return null


# unless module.parent?
#   pattern = /^\\zref@newlabel\{([^}]+)\}\{\\posx\{([\d]+)\}\\posy\{([\d]+)\}\}$/
#   debug ( '\\zref@newlabel{mkts-pos-foobar}{\\posx{2797018}\\posy{50159889}}' ).match pattern



