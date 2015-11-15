(function() {
  var $, $async, CND, D, MKTS, MKTS_XXX, after, alert, badge, copy_regex_non_global, debug, echo, help, info, join, later, list_from_match, log, match_first, njs_path, rpr, show_events, step, suspend, test, urge, warn, whisper;

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

  show_events = function(probe, events) {
    var event, i, len;
    whisper(probe);
    echo("[");
    for (i = 0, len = events.length; i < len; i++) {
      event = events[i];
      echo("    " + (JSON.stringify(event)));
    }
    return echo("    ]");
  };

  copy_regex_non_global = function(re) {
    var flags;
    flags = (re.ignoreCase ? 'i' : '') + (re.multiline ? 'm' : '') + (re.sticky ? 'y' : '');
    return new RegExp(re.source, flags);
  };

  list_from_match = function(match) {
    var R;
    if (match == null) {
      return null;
    }
    R = Array.from(match);
    R.splice(0, 1);
    return R;
  };

  match_first = function(patterns, probe) {
    var R, i, len, pattern;
    for (i = 0, len = patterns.length; i < len; i++) {
      pattern = patterns[i];
      if ((R = probe.match(pattern)) != null) {
        return R;
      }
    }
    return null;
  };

  this["MKTS._ESC.truncate_text_at_end_command_macro"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["some text here <<!end>> and some there", ["some text here ", 23]], ["some text here <<!end>>", ["some text here ", 8]], ["<<!end>>", ["", 8]], ["", ["", 0]], ["<<!end>> and some there", ["", 23]], ["\\<<!end>> and some there", ["\\<<!end>> and some there", 0]], ["some text here \\<<!end>> and some there", ["some text here \\<<!end>> and some there", 0]], ["some text here <<!end>\\> and some there", ["some text here <<!end>\\> and some there", 0]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = MKTS._ESC.truncate_text_at_end_command_macro(probe);
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_macro_tags"] = function(T, done) {
    var S, i, len, matcher, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [
      [
        "some text here and some there", "some text here and some there", {
          "registry": [],
          "index": {}
        }
      ], [
        "some text here<!-- omit this --> and some there", "some text here\u0015comment0\u0013 and some there", {
          "registry": [
            {
              "key": "comment0",
              "raw": " omit this ",
              "parsed": null
            }
          ],
          "index": {}
        }
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      S = MKTS._ESC.initialize({});
      result = MKTS._ESC.escape_macro_tags(S, probe);
      help(JSON.stringify([probe, result, S._ESC]));
      T.eq(result, matcher);
    }
    return done();
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
