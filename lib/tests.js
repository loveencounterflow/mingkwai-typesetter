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

  this["MKTS._ESC.action_patterns[ 0 ] matches action macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<(.>><<)>>", ["", ".", "", ""]], ["<<(.>>xxx<<)>>", ["", ".", "xxx", ""]], ["<<(.>>some code<<)>>", ["", ".", "some code", ""]], ["abc<<(.>>4 + 3<<)>>def", ["c", ".", "4 + 3", ""]], ["<<(:>><<)>>", ["", ":", "", ""]], ["<<(:>>xxx<<)>>", ["", ":", "xxx", ""]], ["<<(:>>some code<<)>>", ["", ":", "some code", ""]], ["abc<<(:>>4 + 3<<)>>def", ["c", ":", "4 + 3", ""]], ["abc<<(:>>bitfield \\>> 1 <<)>>def", ["c", ":", "bitfield \\>> 1 ", ""]], ["abc<<(:>>bitfield >\\> 1 <<)>>def", ["c", ":", "bitfield >\\> 1 ", ""]], ["abc<<(:js>>4 + 3<<)>>def", ["c", ":js", "4 + 3", ""]], ["abc<<(.js>>4 + 3<<)>>def", ["c", ".js", "4 + 3", ""]], ["abc<<(:js>>4 + 3<<:js)>>def", ["c", ":js", "4 + 3", ":js"]], ["abc<<(.js>>4 + 3<<.js)>>def", ["c", ".js", "4 + 3", ".js"]], ["abc<<(:js>>4 + 3<<:)>>def", null], ["abc<<(.js>>4 + 3<<.)>>def", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS._ESC.action_patterns;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        results.push(copy_regex_non_global(pattern));
      }
      return results;
    })();
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.bracketed_raw_patterns matches raw macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<<...raw material...>>>", ["", "<", "...raw material..."]], ["<<(.>>some code<<)>>", null], ["<<<>>>", ["", "<", ""]], ["abcdef<<<\\XeLaTeX{}>>>ghijklm", ["f", "<", "\\XeLaTeX{}"]], ["abcdef<<<123\\>>>0>>>ghijklm", ["f", "<", "123\\>>>0"]], ["abcdef\\<<<123>>>ghijklm", null], ["abcdef<\\<<123>>>ghijklm", null], ["abcdef<<\\<123>>>ghijklm", null], ["abcdef<<<123>>\\>ghijklm", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS._ESC.bracketed_raw_patterns;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        results.push(copy_regex_non_global(pattern));
      }
      return results;
    })();
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.command_and_value_patterns matches command macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<!>>", ["", "!", ""]], ["<<!name>>", ["", "!", "name"]], ["abc<<!name>>def", ["c", "!", "name"]], ["abc<<!n>me>>def", ["c", "!", "n>me"]], ["abc<<!n>\\>me>>def", ["c", "!", "n>\\>me"]], ["abc<<!n\\>me>>def", ["c", "!", "n\\>me"]], ["abc\\<<!nme>>def", null], ["<<$>>", ["", "$", ""]], ["<<$name>>", ["", "$", "name"]], ["abc<<$name>>def", ["c", "$", "name"]], ["abc<<$n>me>>def", ["c", "$", "n>me"]], ["abc<<$n>\\>me>>def", ["c", "$", "n>\\>me"]], ["abc<<$n\\>me>>def", ["c", "$", "n\\>me"]], ["abc\\<<$nme>>def", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS._ESC.command_and_value_patterns;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        results.push(copy_regex_non_global(pattern));
      }
      return results;
    })();
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.illegal_patterns matches consecutive unescaped LPBs"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["helo world", null], ["helo \\<< world", null], ["helo <\\< world", null], ["helo << world", [" ", "<<", " world"]]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS._ESC.illegal_patterns;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        results.push(copy_regex_non_global(pattern));
      }
      return results;
    })();
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.end_command_patterns matches end command macro"] = function(T, done) {
    var i, len, matcher, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["some text here <<!end>> and some there", ["some text here "]], ["some text here <<!end>>", ["some text here "]], ["<<!end>>", [""]], ["", null], ["<<!end>> and some there", [""]], ["\\<<!end>> and some there", null], ["some text here \\<<!end>> and some there", null], ["some text here <<!end>\\> and some there", null]];
    patterns = MKTS._ESC.end_command_patterns;
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.truncate_text_at_end_command_macro"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["some text here <<!end>> and some there", ["some text here ", 23]], ["some text here <<!end>>", ["some text here ", 8]], ["<<!end>>", ["", 8]], ["", ["", 0]], ["<<!end>> and some there", ["", 23]], ["\\<<!end>> and some there", ["\\<<!end>> and some there", 0]], ["some text here \\<<!end>> and some there", ["some text here \\<<!end>> and some there", 0]], ["some text here <<!end>\\> and some there", ["some text here <<!end>\\> and some there", 0]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = MKTS._ESC.truncate_text_at_end_command_macro(null, probe);
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_html_comments"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      ["some text here and some there", "some text here and some there", []], [
        "some text here<!-- omit this --> and some there", "some text here\u0015comment0\u0013 and some there", [
          {
            "key": "comment0",
            "markup": null,
            "raw": " omit this ",
            "parsed": "omit this"
          }
        ]
      ], ["some text here\\<!-- omit this --> and some there", "some text here\\<!-- omit this --> and some there", []], ["abcd<<<some raw content>>>efg", "abcd<<<some raw content>>>efg", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_html_comments(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_bracketed_raw_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      ["some text here<<!foo>>and some there", "some text here<<!foo>>and some there", []], [
        "abcd<<<some raw content>>>efg", "abcd\u0015raw0\u0013efg", [
          {
            "key": "raw0",
            "markup": "<",
            "raw": "some raw content",
            "parsed": null
          }
        ]
      ], ["abcd\\<<<some raw content>>>efg", "abcd\\<<<some raw content>>>efg", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_bracketed_raw_macros(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_region_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "some text here <<(em>>and some there<<em)>>", "some text here \u0015region0\u0013and some there\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "em",
            "raw": "<<(em>>",
            "parsed": null
          }, {
            "key": "region1",
            "markup": "em",
            "raw": "<<em)>>",
            "parsed": null
          }
        ]
      ], ["some text here \\<<(em>>and some there<<em)>>", "some text here \\<<(em>>and some there<<em)>>", []], [
        "some text here <<(em>>and some there\\<<em)>>", "some text here \u0015region0\u0013and some there\\\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "em",
            "raw": "<<(em>>",
            "parsed": null
          }, {
            "key": "region1",
            "markup": "em",
            "raw": "<<em)>>",
            "parsed": null
          }
        ]
      ], [
        "some text here <<(em>>and some there<<)>>", "some text here \u0015region0\u0013and some there\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "em",
            "raw": "<<(em>>",
            "parsed": null
          }, {
            "key": "region1",
            "markup": "em",
            "raw": "<<)>>",
            "parsed": null
          }
        ]
      ], ["some text here \\<<(em>>and some there<<)>>", "some text here \\<<(em>>and some there<<)>>", []], [
        "some text here <<(em>>and some there\\<<)>>", "some text here \u0015region0\u0013and some there\\\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "em",
            "raw": "<<(em>>",
            "parsed": null
          }, {
            "key": "region1",
            "markup": "em",
            "raw": "<<)>>",
            "parsed": null
          }
        ]
      ], ["some text here <<(em>>and some there<<foo)>>", "some text here <<(em>>and some there<<foo)>>", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_region_macros(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_action_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "<<(.>><<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["silent", "coffee"],
            "raw": "",
            "parsed": null
          }
        ]
      ], [
        "<<(.>>xxx<<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["silent", "coffee"],
            "raw": "xxx",
            "parsed": null
          }
        ]
      ], [
        "<<(.>>some code<<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["silent", "coffee"],
            "raw": "some code",
            "parsed": null
          }
        ]
      ], [
        "abc<<(.>>4 + 3<<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["silent", "coffee"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], [
        "<<(:>><<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "",
            "parsed": null
          }
        ]
      ], [
        "<<(:>>xxx<<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "xxx",
            "parsed": null
          }
        ]
      ], [
        "<<(:>>some code<<)>>", "\u0015action0\u0013", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "some code",
            "parsed": null
          }
        ]
      ], [
        "abc<<(:>>4 + 3<<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], [
        "abc<<(:>>bitfield \\>> 1 <<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "bitfield \\>> 1 ",
            "parsed": null
          }
        ]
      ], [
        "abc<<(:>>bitfield >\\> 1 <<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["vocal", "coffee"],
            "raw": "bitfield >\\> 1 ",
            "parsed": null
          }
        ]
      ], [
        "abc<<(:js>>4 + 3<<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["vocal", "js"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], [
        "abc<<(.js>>4 + 3<<)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["silent", "js"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], [
        "abc<<(:js>>4 + 3<<:js)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["vocal", "js"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], [
        "abc<<(.js>>4 + 3<<.js)>>def", "abc\u0015action0\u0013def", [
          {
            "key": "action0",
            "markup": ["silent", "js"],
            "raw": "4 + 3",
            "parsed": null
          }
        ]
      ], ["abc<<(:js>>4 + 3<<:)>>def", "abc<<(:js>>4 + 3<<:)>>def", []], ["abc<<(.js>>4 + 3<<.)>>def", "abc<<(.js>>4 + 3<<.)>>def", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_action_macros(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_command_and_value_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "some text here <<!foo>> and some there", "some text here \u0015command0\u0013 and some there", [
          {
            "key": "command0",
            "markup": "!",
            "raw": "foo",
            "parsed": "???"
          }
        ]
      ], [
        "some text here <<$foo>> and some there", "some text here \u0015value0\u0013 and some there", [
          {
            "key": "value0",
            "markup": "$",
            "raw": "foo",
            "parsed": "???"
          }
        ]
      ], ["some text here \\<<!foo>> and some there", "some text here \\<<!foo>> and some there", []], ["some text here \\<<$foo>> and some there", "some text here \\<<$foo>> and some there", []], ["some text here<!-- omit this --> and some there", "some text here<!-- omit this --> and some there", []], ["abcd<<<some raw content>>>efg", "abcd<<<some raw content>>>efg", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_command_and_value_macros(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS._ESC.escape_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [["<<(multi-column>>\nsome text here<!-- omit this --> and some there\n<<)>>\n<<!end>>\n<<!command>><<(:action>><<)>>", null, []]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS._ESC.initialize({});
      text_result = MKTS._ESC.escape_macros(S, probe);
      help(JSON.stringify([probe, text_result, S._ESC['registry']]));
      log((require('coffeenode-diff')).colorize(probe, text_result));
      T.eq(text_result, text_matcher);
      T.eq(S._ESC['registry'], registry_matcher);
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
