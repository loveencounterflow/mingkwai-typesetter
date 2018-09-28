
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
@listen = ( handler = null ) ->
  #.........................................................................................................
  server = NET.createServer ( socket ) =>
    XXX_t0 = Date.now()
    socket.on 'error', ( error ) => warn "socket error: #{error.message}"
    # info '33733', 'yo'
    #.......................................................................................................
    source    = PS._nodejs_input_to_pull_source socket
    counts    = { requests: 0, rpcs: 0, hits: 0, fails: 0, errors: 0, }
    S         = { socket, counts, }
    pipeline  = []
    on_stop   = PS.new_event_collector 'stop', =>
      help "socket.end() called"
      socket.end()
      debug '33844', ( Date.now() / XXX_t0 ) / 1000
    #.......................................................................................................
    pipeline.push source
    pipeline.push PS.$split()
    # pipeline.push PS.$show()
    # pipeline.push @$show_counts   S
    pipeline.push @$dispatch      S
    # pipeline.push PS.$show()
    pipeline.push $ ( result, send ) ->
      S.socket.write result
      send null
    pipeline.push on_stop.add PS.$drain()
    #.......................................................................................................
    PS.pull pipeline...
    return null
  #.........................................................................................................
  handler ?= =>
    { address: host, port, family, } = server.address()
    help "#{O.app.name} RPC server listening on #{family} #{host}:#{port}"
  #.........................................................................................................
  # ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
  # try FS.unlinkSync O.rpc.path catch error then warn error
  # server.listen O.rpc.path, handler
  # ### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
  server.listen O.rpc.port, O.rpc.host, handler
  return null

#-----------------------------------------------------------------------------------------------------------
@$show_counts = ( S ) ->
  return PS.$watch ( event ) ->
    S.counts.requests += +1
    if ( S.counts.requests % 1000 ) is 0
      urge JSON.stringify S.counts
    return null

#-----------------------------------------------------------------------------------------------------------
@$dispatch = ( S ) ->
  return $ ( line, send ) =>
    try
      event                       = JSON.parse "[#{line}]"
      [ method, parameters..., ]  = event
    catch error
      throw error
    #.......................................................................................................
    debug '33733', { method, parameters, }
    send @do_rpc S, method, parameters
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@do_rpc = ( S, method_name, parameters ) ->
  S.counts.rpcs  += +1
  method          = @RPC[ method_name ]
  unless method?
    throw new Error "no such method: #{rpr method_name}"
    # return @send_error S, "no such method: #{rpr method_name}"
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


