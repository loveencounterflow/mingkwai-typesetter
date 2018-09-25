// Generated by CoffeeScript 2.3.1
(function() {
  'use strict';
  var CND, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MOJIKURA3/exception-handler';

  log = CND.get_logger('plain', badge);

  debug = CND.get_logger('debug', badge);

  info = CND.get_logger('info', badge);

  warn = CND.get_logger('warn', badge);

  alert = CND.get_logger('alert', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  //-----------------------------------------------------------------------------------------------------------
  this.exit_handler = function(exception) {
    var head, i, len, line, message, print, ref, tail;
    // debug '55567', rpr exception
    print = alert;
    message = 'ROGUE EXCEPTION: ' + ((ref = exception.message) != null ? ref : "an unrecoverable condition occurred");
    if (exception.where != null) {
      message += '\n--------------------\n' + exception.where + '\n--------------------';
    }
    [head, ...tail] = message.split('\n');
    print(CND.reverse(' ' + head + ' '));
    for (i = 0, len = tail.length; i < len; i++) {
      line = tail[i];
      warn(line);
    }
    /* TAINT should have a way to set exit code explicitly */
    whisper(((exception.stack.split('\n')).slice(0, 16).join('\n')) + '\n...');
    return process.exit(1);
  };

  process.on('uncaughtException', this.exit_handler);

  process.on('unhandledRejection', this.exit_handler);

}).call(this);

//# sourceMappingURL=exception-handler.js.map