// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var $, $async, CND, FS, NET, O, PATH, PS, RPC_SERVER, alert, badge, counts, debug, echo, help, info, rpr, urge, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = '(INTERSHOP/RPC/SECONDARY)';

  debug = CND.get_logger('debug', badge);

  alert = CND.get_logger('alert', badge);

  whisper = CND.get_logger('whisper', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  info = CND.get_logger('info', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  FS = require('fs');

  PATH = require('path');

  NET = require('net');

  //...........................................................................................................
  PS = require('pipestreams');

  ({$, $async} = PS);

  //...........................................................................................................
  this.RPC = require('./cxltx-demo');

  //...........................................................................................................
  O = require('./options');

  /* TAINT temporary */
  O.rpc = {};

  O.app = {};

  O.app.name = 'MKTS';

  O.rpc.port = 8910;

  O.rpc.host = '127.0.0.1';

  counts = {};

  //-----------------------------------------------------------------------------------------------------------
  this._socket_listen_on_all = function(socket) {
    socket.on('close', function() {
      return help('socket', 'close');
    });
    socket.on('connect', function() {
      return help('socket', 'connect');
    });
    socket.on('data', function() {
      return help('socket', 'data');
    });
    socket.on('drain', function() {
      return help('socket', 'drain');
    });
    socket.on('end', function() {
      return help('socket', 'end');
    });
    socket.on('error', function() {
      return help('socket', 'error');
    });
    socket.on('lookup', function() {
      return help('socket', 'lookup');
    });
    socket.on('timeout', function() {
      return help('socket', 'timeout');
    });
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._server_listen_on_all = function(server) {
    server.on('close', function() {
      return help('server', 'close');
    });
    server.on('connection', function() {
      return help('server', 'connection');
    });
    server.on('error', function() {
      return help('server', 'error');
    });
    server.on('listening', function() {
      return help('server', 'listening');
    });
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.listen = function(handler) {
    var server;
    //.........................................................................................................
    server = NET.createServer((socket) => {
      var S, on_stop, pipeline, source;
      socket.on('error', (error) => {
        return warn(`socket error: ${error.message}`);
      });
      //.......................................................................................................
      source = PS._nodejs_input_to_pull_source(socket);
      S = {socket};
      pipeline = [];
      on_stop = PS.new_event_collector('stop', () => {
        return socket.end();
      });
      //.......................................................................................................
      pipeline.push(source);
      pipeline.push(PS.$split());
      pipeline.push(this.$dispatch(S));
      pipeline.push($(function(result, send) {
        S.socket.write(result);
        return send(null);
      }));
      pipeline.push(on_stop.add(PS.$drain()));
      //.......................................................................................................
      PS.pull(...pipeline);
      return null;
    });
    //.........................................................................................................
    server.listen(O.rpc.port, O.rpc.host, () => {
      var family, host, port;
      ({
        address: host,
        port,
        family
      } = server.address());
      return help('µ97288', `${O.app.name} RPC server listening on ${family} ${host}:${port}`);
    });
    if (handler != null) {
      //.........................................................................................................
      return handler(null, server);
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$dispatch = function(S) {
    return $((line, send) => {
      var count, error, event, method_name, parameters;
      try {
        event = JSON.parse(`[${line}]`);
        [method_name, ...parameters] = event;
      } catch (error1) {
        error = error1;
        throw error;
      }
      //.......................................................................................................
      count = counts[method_name] = (counts[method_name] != null ? counts[method_name] : counts[method_name] = 0) + 1;
      if ((count === 1) || (count % 10 === 0)) {
        whisper('33673', `RPC: ${method_name}() #${count}`);
      }
      //.......................................................................................................
      send(this.do_rpc(S, method_name, parameters));
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.do_rpc = function(S, method_name, parameters) {
    var error, method;
    // S.counts.rpcs  += +1
    method = this.RPC[method_name];
    if (method == null) {
      throw new Error(`no such method: ${rpr(method_name)}`);
    }
    try {
      //.........................................................................................................
      return method.apply(this.RPC, parameters);
    } catch (error1) {
      error = error1;
      // S.counts.errors += +1
      throw error;
    }
    return null;
  };

  //###########################################################################################################
  if (module.parent == null) {
    RPC_SERVER = this;
    RPC_SERVER.listen();
  }

}).call(this);

//# sourceMappingURL=rpc-server.js.map
