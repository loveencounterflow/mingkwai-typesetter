(function() {
  var $, $async, CND, D, MKTS, MKTS_XXX, after, alert, badge, debug, echo, help, info, join, later, log, njs_path, rpr, step, suspend, test, urge, warn, whisper;

  njs_path = require('path');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/tests';

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

  after = suspend.after;


  /* TAINT experimentally using `later` in place of `setImmediate` */

  later = suspend.immediately;

  test = require('guy-test');

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  MKTS = require('./MKTS');

  MKTS_XXX = require('./mkts-typesetter-interim');

  this["MKTS_XXX.tex_from_md (1)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "A paragraph with *emphasis*.\n\nA paragraph with **bold text**.";
    matcher = "% begin of MD document\nA paragraph with {\\mktsStyleItalic{}emphasis\\/}.\\mktsShowpar\\par\nA paragraph with {\\mktsStyleBold{}bold text}.\\mktsShowpar\\par\n\n% end of MD document\n";
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS_XXX.tex_from_md(probe, settings, resume));
        echo(result);
        T.eq(matcher.trim(), result.trim());
        return done();
      };
    })(this));
  };

  this["MKTS_XXX.mktscript_from_md (1)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "A paragraph with *emphasis*.\n\nA paragraph with **bold text**.";
    matcher = "1 █ <document\n1 █ .text 'A paragraph with '\n1 █ (em\n1 █ .text 'emphasis'\n1 █ )em\n1 █ .text '.'\n1 █ .p\n3 █ .text 'A paragraph with '\n3 █ (strong\n3 █ .text 'bold text'\n3 █ )strong\n3 █ .text '.'\n3 █ .p\n>document\n# EOF";
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mktscript_from_md(probe, settings, resume));
        echo(result);
        T.eq(matcher.trim(), result.trim());
        return done();
      };
    })(this));
  };

  this._main = function(handler) {
    return test(this, {
      'timeout': 2500
    });
  };

  if (module.parent == null) {
    this._main();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/tests.js.map
