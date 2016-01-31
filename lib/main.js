(function() {
  var CND, alert, badge, debug, echo, help, info, log, njs_fs, njs_path, plugin, plugin_info, plugin_info_by_routes, plugin_name, plugin_route, plugins, route, rpr, urge, warn, whisper;

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

  route = njs_path.resolve(process.cwd(), 'node_modules');

  help('7238', process.cwd());

  help('7238', route);

  plugins = {};

  plugin_info_by_routes = this.PLUGIN_MANAGER.find_plugin_package_infos(route);

  for (plugin_route in plugin_info_by_routes) {
    plugin_info = plugin_info_by_routes[plugin_route];
    plugin_name = plugin_info['name'];
    debug('234627', plugin_route);
    plugins[plugin_name] = require(plugin_route);
  }

  urge('93274', Object.keys(this.TEX_WRITER));

  for (plugin_name in plugins) {
    plugin = plugins[plugin_name];
    urge('93274', plugin_name, Object.keys(plugin));
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/main.js.map
