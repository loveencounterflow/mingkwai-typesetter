(function() {
  var $, CACHE, CND, D, OPTIONS, alert, badge, debug, echo, help, info, log, ref, rpr, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/TEXLIVEPACKAGEINFO';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  D = require('pipedreams');

  $ = D.remit.bind(D);

  ref = require('./OPTIONS'), CACHE = ref.CACHE, OPTIONS = ref.OPTIONS;

  this.read_texlive_package_version = function(options, package_name, handler) {
    var key, method;
    key = "texlive-package-versions/" + package_name;
    method = (function(_this) {
      return function(done) {
        return _this._read_texlive_package_version(package_name, done);
      };
    })(this);
    CACHE.get(options, key, method, true, handler);
    return null;
  };

  this._read_texlive_package_version = function(package_name, handler) {

    /* Given a `package_name` and a `handler`, try to retrieve that package's info as reported by the TeX
    Live Manager command line tool (using `tlmgr info ${package_name}`), extract the `cat-version` entry and
    normalize it so it matches the [Semantic Versioning specs](http://semver.org/). If no version is found,
    the `handler` will be called with a `null` value instead of a string; however, if a version *is* found but
    does *not* match the SemVer specs after normalization, the `handler` will be called with an error.
    
    Normalization steps include removing leading `v`s, trailing letters, and leading zeroes.
     */
    var leading_zero_pattern, semver_pattern;
    leading_zero_pattern = /^0+(?!$)/;
    semver_pattern = /^([0-9]+)\.([0-9]+)\.?([0-9]*)$/;
    this.read_texlive_package_info(package_name, (function(_this) {
      return function(error, package_info) {
        var _, major, match, minor, o_version, patch, version;
        if (error != null) {
          return handler(error);
        }
        if ((version = o_version = package_info['cat-version']) == null) {
          warn("unable to detect version for package " + (rpr(package_name)));
          return handler(null, null);
        }
        version = version.replace(/[^0-9]+$/, '');
        version = version.replace(/^v/, '');
        if ((match = version.match(semver_pattern)) == null) {
          return handler(new Error("unable to parse version " + (rpr(o_version)) + " of package " + (rpr(name))));
        }
        _ = match[0], major = match[1], minor = match[2], patch = match[3];

        /* thx to http://stackoverflow.com/a/2800839/256361 */
        major = major.replace(leading_zero_pattern, '');
        minor = minor.replace(leading_zero_pattern, '');
        patch = patch.replace(leading_zero_pattern, '');
        major = major.length > 0 ? major : '0';
        minor = minor.length > 0 ? minor : '0';
        patch = patch.length > 0 ? patch : '0';
        return handler(null, major + "." + minor + "." + patch);
      };
    })(this));
    return null;
  };

  this.read_texlive_package_info = function(package_name, handler) {
    var Z, command, input, parameters, pattern;
    command = 'tlmgr';
    parameters = ['info', package_name];
    input = D.spawn_and_read_lines(command, parameters);
    Z = {};
    pattern = /^([^:]+):(.*)$/;
    input.pipe($((function(_this) {
      return function(line, send) {
        var _, match, name, value;
        if (line.length === 0) {
          return;
        }
        match = line.match(pattern);
        if (match == null) {
          return send.error(new Error("unexpected line: " + (rpr(line))));
        }
        _ = match[0], name = match[1], value = match[2];
        name = name.trim();
        value = value.trim();
        return Z[name] = value;
      };
    })(this))).pipe(D.$on_end(function() {
      return handler(null, Z);
    }));
    return null;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/TEXLIVEPACKAGEINFO.js.map
