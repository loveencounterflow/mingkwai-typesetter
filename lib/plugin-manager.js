(function() {
  var $, $async, CND, D, alert, badge, debug, echo, help, info, isa_folder, join, log, njs_fs, njs_path, rpr, step, suspend, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'mkts/plugin-manager';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  suspend = require('coffeenode-suspend');

  step = suspend.step;

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  join = njs_path.resolve;

  isa_folder = function(route) {
    return (njs_fs.statSync(route)).isDirectory();
  };

  this.find_plugin_package_infos = function(plugin_home, settings) {
    var R, i, keyword, keywords, len, package_info, plugin_name, plugin_names, plugin_route, ref;
    keyword = (ref = settings != null ? settings['keyword'] : void 0) != null ? ref : 'mingkwai-typesetter-plugin';
    plugin_names = njs_fs.readdirSync(plugin_home);
    R = {};
    for (i = 0, len = plugin_names.length; i < len; i++) {
      plugin_name = plugin_names[i];
      if (plugin_name.startsWith('.')) {
        continue;
      }
      plugin_route = join(plugin_home, plugin_name);
      if (!isa_folder(plugin_route)) {
        continue;
      }
      package_info = require(join(plugin_route, 'package.json'));
      if ((keywords = package_info['keywords']) != null) {
        if (indexOf.call(keywords, keyword) >= 0) {
          R[plugin_route] = package_info;
        }
      }
    }
    return R;
  };

  if (module.parent == null) {
    debug(this.find_plugin_package_infos(join(__dirname, 'node_modules')));
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/plugin-manager.js.map
