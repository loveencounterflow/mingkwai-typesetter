(function() {
  var CND, alert, badge, debug, echo, help, info, log, njs_fs, njs_path, rpr, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/main';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  this.HELPERS = require('./helpers');

  this.MACRO_ESCAPER = require('./macro-escaper');

  this.MACRO_INTERPRETER = require('./macro-interpreter');

  this.MD_READER = require('./md-reader');

  this.TEX_WRITER = require('./tex-writer');

  this.MKTSCRIPT_WRITER = require('./mktscript-writer');

  this.PLUGIN_MANAGER = require('./plugin-manager');

  this.XNCHR = require('./xnchr');

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map
