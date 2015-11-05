(function() {
  var CND, CS, alert, badge, debug, echo, help, info, log, njs_fs, njs_os, njs_path, rpr, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  njs_path = require('path');

  njs_fs = require('fs');

  njs_os = require('os');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'OPTIONS';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  CS = require('coffee-script');

  this.CACHE = {};

  this.CACHE.update = function(options) {
    var cache, sys_cache, sysid;
    cache = options['cache']['%self'];
    cache['sysid'] = sysid = this._get_sysid();
    if (cache[sysid] == null) {
      sys_cache = {};
      cache[sysid] = sys_cache;
    }
    return this.save(options);
  };

  this.CACHE.set = function(options, key, value, save) {
    var target;
    if (save == null) {
      save = true;
    }
    target = options['cache']['%self'][options['cache']['%self']['sysid']];
    target[key] = value;
    if (save != null) {
      this.save(options);
    }
    return null;
  };

  this.CACHE.get = function(options, key, method, save, handler) {
    var R, cache, sysid, target;
    if (save == null) {
      save = true;
    }
    if (handler == null) {
      handler = null;
    }
    cache = options['cache']['%self'];
    sysid = cache['sysid'];
    target = cache[sysid];
    R = target[key];
    if (handler != null) {
      if (R === void 0) {
        return method((function(_this) {
          return function(error, R) {
            if (error != null) {
              return handler(error);
            }
            _this.set(options, key, R, save);
            return handler(null, R);
          };
        })(this));
      } else {
        return handler(null, R);
      }
    } else {
      if (R === void 0) {
        this.set(options, key, (R = method()), save);
      }
      return R;
    }
  };

  this.CACHE.save = function(options) {
    var cache, locator;
    locator = options['cache']['locator'];
    cache = options['cache']['%self'];
    return njs_fs.writeFileSync(locator, JSON.stringify(cache, null, '  '));
  };

  this.CACHE._get_sysid = function() {
    return (njs_os.hostname()) + ":" + (njs_os.platform());
  };

  this.OPTIONS = {};

  this.OPTIONS._require_coffee_file = function(route) {
    var R, extensions, i, len, name, ref;
    extensions = Object.keys(require['extensions']);
    require('coffee-script/register');
    R = require(route);
    ref = require['extensions'];
    for (i = 0, len = ref.length; i < len; i++) {
      name = ref[i];
      if (indexOf.call(extensions, name) < 0) {
        delete require['extensions'][name];
      }
    }
    return R;
  };

  this.OPTIONS._eval_coffee_file = function(route) {
    var rqr_route, source;
    rqr_route = require.resolve(route);
    source = njs_fs.readFileSync(rqr_route, {
      encoding: 'utf-8'
    });
    return CS["eval"](source, {
      bare: true
    });
  };

  this.OPTIONS.from_locator = function(options_locator) {
    return this._require_coffee_file(options_locator);
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/OPTIONS.js.map
