
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = '(INTERSHOP/RPC/SECONDARY)'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
FS                        = require 'fs'
PATH                      = require 'path'
NET                       = require 'net'
#...........................................................................................................
PS                        = require 'pipestreams'
{ $
  $async }                = PS
#...........................................................................................................
@RPC                      = require './cxltx-demo'
#...........................................................................................................
O                         = require './options'
### TAINT temporary ###
O.rpc                     = {}
O.app                     = {}
O.app.name                = 'MKTS'
O.rpc.port                = 8910
O.rpc.host                = '127.0.0.1'
counts                    = {}

#-----------------------------------------------------------------------------------------------------------
@_socket_listen_on_all = ( socket ) ->
  socket.on 'close',      -> help 'socket', 'close'
  socket.on 'connect',    -> help 'socket', 'connect'
  socket.on 'data',       -> help 'socket', 'data'
  socket.on 'drain',      -> help 'socket', 'drain'
  socket.on 'end',        -> help 'socket', 'end'
  socket.on 'error',      -> help 'socket', 'error'
  socket.on 'lookup',     -> help 'socket', 'lookup'
  socket.on 'timeout',    -> help 'socket', 'timeout'
  return null

#-----------------------------------------------------------------------------------------------------------
@_server_listen_on_all = ( server ) ->
  server.on 'close',      -> help 'server', 'close'
  server.on 'connection', -> help 'server', 'connection'
  server.on 'error',      -> help 'server', 'error'
  server.on 'listening',  -> help 'server', 'listening'
  return null

#-----------------------------------------------------------------------------------------------------------
@listen = ( handler ) ->
  #.........................................................................................................
  server = NET.createServer ( socket ) =>
    socket.on 'error', ( error ) => warn "socket error: #{error.message}"
    #.......................................................................................................
    source    = PS._nodejs_input_to_pull_source socket
    counts    = {}
    S         = { socket, counts, }
    pipeline  = []
    on_stop   = PS.new_event_collector 'stop', => socket.end()
    #.......................................................................................................
    pipeline.push source
    pipeline.push PS.$split()
    pipeline.push @$dispatch      S
    pipeline.push $ ( result, send ) ->
      S.socket.write result
      send null
    pipeline.push on_stop.add PS.$drain()
    #.......................................................................................................
    PS.pull pipeline...
    return null
  #.........................................................................................................
  server.listen O.rpc.port, O.rpc.host, =>
    { address: host, port, family, } = server.address()
    help "#{O.app.name} RPC server listening on #{family} #{host}:#{port}"
  #.........................................................................................................
  return handler null, server if handler?
  return null

#-----------------------------------------------------------------------------------------------------------
@$dispatch = ( S ) ->
  return $ ( line, send ) =>
    try
      event                             = JSON.parse "[#{line}]"
      [ method_name, parameters..., ]   = event
    catch error
      throw error
    #.......................................................................................................
    count = counts[ method_name ] = ( counts[ method_name ] ?= 0 ) + 1
    if ( count is 1 ) or ( count % 5 is 0 )
      whisper '33673', "RPC: #{method_name}() ##{count}"
    #.......................................................................................................
    send @do_rpc S, method_name, parameters
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@do_rpc = ( S, method_name, parameters ) ->
  S.counts.rpcs  += +1
  method          = @RPC[ method_name ]
  unless method?
    throw new Error "no such method: #{rpr method_name}"
  #.........................................................................................................
  try
    return method.apply @RPC, parameters
  catch error
    S.counts.errors += +1
    throw error
  return null


############################################################################################################
unless module.parent?
  RPC_SERVER = @
  RPC_SERVER.listen()


