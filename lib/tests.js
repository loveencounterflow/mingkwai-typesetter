(function() {
  var $, $async, CND, D, MKTS, MKTS_XXX, after, alert, badge, copy_regex_non_global, debug, echo, help, info, join, later, list_from_match, log, match_first, nice_text_rpr, njs_path, rpr, show_events, step, suspend, test, urge, warn, whisper;

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

  nice_text_rpr = function(text) {

    /* Ad-hoc method to print out text in a readable, CoffeeScript-compatible, triple-quoted way. Line breaks
    (`\\n`) will be shown as line breaks, so texts should not be as spaghettified as they appear with
    JSON.stringify (the last line break of a string is, however, always shown in its symbolic form so it
    won't get swallowed by the CoffeeScript parser). Code points below U+0020 (space) are shown as
    `\\x00`-style escapes, taken up less space than `\u0000` escapes while keeping things explicit. All
    double quotes will be prepended with a backslash.
     */
    var R;
    R = text;
    R = R.replace(/[\x00-\x09\x0b-\x19]/g, function($0) {
      var cid_hex;
      cid_hex = ($0.codePointAt(0)).toString(16);
      if (cid_hex.length === 1) {
        cid_hex = '0' + cid_hex;
      }
      return "\\x" + cid_hex;
    });
    R = R.replace(/"/g, '\\"');
    R = R.replace(/\n$/g, '\\n');
    R = '\n"""' + R + '"""';
    return R;
  };

  this["MKTS.MACROS.action_patterns[ 0 ] matches action macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<(.>><<)>>", ["", ".", "", ""]], ["<<(.>>xxx<<)>>", ["", ".", "xxx", ""]], ["<<(.>>some code<<)>>", ["", ".", "some code", ""]], ["abc<<(.>>4 + 3<<)>>def", ["c", ".", "4 + 3", ""]], ["<<(:>><<)>>", ["", ":", "", ""]], ["<<(:>>xxx<<)>>", ["", ":", "xxx", ""]], ["<<(:>>some code<<)>>", ["", ":", "some code", ""]], ["abc<<(:>>4 + 3<<)>>def", ["c", ":", "4 + 3", ""]], ["abc<<(:>>bitfield \\>> 1 <<)>>def", ["c", ":", "bitfield \\>> 1 ", ""]], ["abc<<(:>>bitfield >\\> 1 <<)>>def", ["c", ":", "bitfield >\\> 1 ", ""]], ["abc<<(:js>>4 + 3<<)>>def", ["c", ":js", "4 + 3", ""]], ["abc<<(.js>>4 + 3<<)>>def", ["c", ".js", "4 + 3", ""]], ["abc<<(:js>>4 + 3<<:js)>>def", ["c", ":js", "4 + 3", ":js"]], ["abc<<(.js>>4 + 3<<.js)>>def", ["c", ".js", "4 + 3", ".js"]], ["abc<<(:js>>4 + 3<<:)>>def", null], ["abc<<(.js>>4 + 3<<.)>>def", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS.MACROS.action_patterns;
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

  this["MKTS.MACROS.bracketed_raw_patterns matches raw macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<<...raw material...>>>", ["", "<", "...raw material..."]], ["<<(.>>some code<<)>>", null], ["<<<>>>", ["", "<", ""]], ["abcdef<<<\\XeLaTeX{}>>>ghijklm", ["f", "<", "\\XeLaTeX{}"]], ["abcdef<<<123\\>>>0>>>ghijklm", ["f", "<", "123\\>>>0"]], ["abcdef\\<<<123>>>ghijklm", null], ["abcdef<\\<<123>>>ghijklm", null], ["abcdef<<\\<123>>>ghijklm", null], ["abcdef<<<123>>\\>ghijklm", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS.MACROS.bracketed_raw_patterns;
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

  this["MKTS.MACROS.command_and_value_patterns matches command macro"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["<<!>>", ["", "!", ""]], ["<<!name>>", ["", "!", "name"]], ["abc<<!name>>def", ["c", "!", "name"]], ["abc<<!n>me>>def", ["c", "!", "n>me"]], ["abc<<!n>\\>me>>def", ["c", "!", "n>\\>me"]], ["abc<<!n\\>me>>def", ["c", "!", "n\\>me"]], ["abc\\<<!nme>>def", null], ["<<$>>", ["", "$", ""]], ["<<$name>>", ["", "$", "name"]], ["abc<<$name>>def", ["c", "$", "name"]], ["abc<<$n>me>>def", ["c", "$", "n>me"]], ["abc<<$n>\\>me>>def", ["c", "$", "n>\\>me"]], ["abc<<$n\\>me>>def", ["c", "$", "n\\>me"]], ["abc\\<<$nme>>def", null]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS.MACROS.command_and_value_patterns;
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

  this["MKTS.MACROS.illegal_patterns matches consecutive unescaped LPBs"] = function(T, done) {
    var i, len, matcher, pattern, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["helo world", null], ["helo \\<< world", null], ["helo <\\< world", null], ["helo << world", [" ", "<<", " world"]]];
    patterns = (function() {
      var i, len, ref, results;
      ref = MKTS.MACROS.illegal_patterns;
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

  this["MKTS.MACROS.end_command_patterns matches end command macro"] = function(T, done) {
    var i, len, matcher, patterns, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["some text here <<!end>> and some there", ["some text here "]], ["some text here <<!end>>", ["some text here "]], ["<<!end>>", [""]], ["", null], ["<<!end>> and some there", [""]], ["\\<<!end>> and some there", null], ["some text here \\<<!end>> and some there", null], ["some text here <<!end>\\> and some there", null]];
    patterns = MKTS.MACROS.end_command_patterns;
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = list_from_match(match_first(patterns, probe));
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.truncate_text_at_end_command_macro"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref, result;
    probes_and_matchers = [["some text here <<!end>> and some there", ["some text here ", 23]], ["some text here <<!end>>", ["some text here ", 8]], ["<<!end>>", ["", 8]], ["", ["", 0]], ["<<!end>> and some there", ["", 23]], ["\\<<!end>> and some there", ["\\<<!end>> and some there", 0]], ["some text here \\<<!end>> and some there", ["some text here \\<<!end>> and some there", 0]], ["some text here <<!end>\\> and some there", ["some text here <<!end>\\> and some there", 0]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      result = MKTS.MACROS.escape.truncate_text_at_end_command_macro(null, probe);
      help(JSON.stringify([probe, result]));
      T.eq(result, matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.html_comments"] = function(T, done) {
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
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape.html_comments(S, probe);
      help(JSON.stringify([probe, text_result, S.MACROS['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.bracketed_raw_macros"] = function(T, done) {
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
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape.bracketed_raw_macros(S, probe);
      help(JSON.stringify([probe, text_result, S.MACROS['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.region_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "some text here <<(em>>and some there<<em)>>", "some text here \u0015region0\u0013and some there\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "(",
            "raw": "em",
            "parsed": null
          }, {
            "key": "region1",
            "markup": ")",
            "raw": "em",
            "parsed": null
          }
        ]
      ], ["some text here \\<<(em>>and some there<<em)>>", "some text here \\<<(em>>and some there<<em)>>", []], [
        "some text here <<(em>>and some there\\<<em)>>", "some text here \u0015region0\u0013and some there\\\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "(",
            "raw": "em",
            "parsed": null
          }, {
            "key": "region1",
            "markup": ")",
            "raw": "em",
            "parsed": null
          }
        ]
      ], [
        "some text here <<(em>>and some there<<)>>", "some text here \u0015region0\u0013and some there\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "(",
            "raw": "em",
            "parsed": null
          }, {
            "key": "region1",
            "markup": ")",
            "raw": "em",
            "parsed": null
          }
        ]
      ], ["some text here \\<<(em>>and some there<<)>>", "some text here \\<<(em>>and some there<<)>>", []], [
        "some text here <<(em>>and some there\\<<)>>", "some text here \u0015region0\u0013and some there\\\u0015region1\u0013", [
          {
            "key": "region0",
            "markup": "(",
            "raw": "em",
            "parsed": null
          }, {
            "key": "region1",
            "markup": ")",
            "raw": "em",
            "parsed": null
          }
        ]
      ], ["some text here <<(em>>and some there<<foo)>>", "some text here <<(em>>and some there<<foo)>>", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape.region_macros(S, probe);
      help(JSON.stringify([probe, text_result, S.MACROS['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.action_macros"] = function(T, done) {
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
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape.action_macros(S, probe);
      help(JSON.stringify([probe, text_result, S.MACROS['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape.command_and_value_macros"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "some text here <<!foo>> and some there", "some text here \u0015command0\u0013 and some there", [
          {
            "key": "command0",
            "markup": "!",
            "raw": "foo",
            "parsed": null
          }
        ]
      ], [
        "some text here <<$foo>> and some there", "some text here \u0015value0\u0013 and some there", [
          {
            "key": "value0",
            "markup": "$",
            "raw": "foo",
            "parsed": null
          }
        ]
      ], ["some text here \\<<!foo>> and some there", "some text here \\<<!foo>> and some there", []], ["some text here \\<<$foo>> and some there", "some text here \\<<$foo>> and some there", []], ["some text here<!-- omit this --> and some there", "some text here<!-- omit this --> and some there", []], ["abcd<<<some raw content>>>efg", "abcd<<<some raw content>>>efg", []]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape.command_and_value_macros(S, probe);
      help(JSON.stringify([probe, text_result, S.MACROS['registry']]));
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.escape 2"] = function(T, done) {
    var S, i, len, probe, probes_and_matchers, ref, registry_matcher, text_matcher, text_result;
    probes_and_matchers = [
      [
        "<<(multi-column 3>>\nsome text here<!-- omit this --> and some there\n<<)>>\n<<(multi-column 2>>\nThis text will appear in two-column<!-- omit this --> layout.\n<!--some code-->\n<<(:>>some code<<)>>\n<<)>>\n<<!end>>\n<<!command>><<(:action>><<)>>", "\x15region4\x13\nsome text here\x15comment0\x13 and some there\n\x15region5\x13\n\x15region6\x13\nThis text will appear in two-column\x15comment1\x13 layout.\n\x15comment2\x13\n\x15action3\x13\n\x15region7\x13\n", [
          {
            "key": "comment0",
            "markup": null,
            "raw": " omit this ",
            "parsed": "omit this"
          }, {
            "key": "comment1",
            "markup": null,
            "raw": " omit this ",
            "parsed": "omit this"
          }, {
            "key": "comment2",
            "markup": null,
            "raw": "some code",
            "parsed": "some code"
          }, {
            "key": "action3",
            "markup": ["vocal", "coffee"],
            "raw": "some code",
            "parsed": null
          }, {
            "key": "region4",
            "markup": "(",
            "raw": "multi-column 3",
            "parsed": null
          }, {
            "key": "region5",
            "markup": ")",
            "raw": "multi-column 3",
            "parsed": null
          }, {
            "key": "region6",
            "markup": "(",
            "raw": "multi-column 2",
            "parsed": null
          }, {
            "key": "region7",
            "markup": ")",
            "raw": "multi-column 2",
            "parsed": null
          }
        ]
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], text_matcher = ref[1], registry_matcher = ref[2];
      S = MKTS.MACROS.initialize_state({});
      text_result = MKTS.MACROS.escape(S, probe);
      T.eq(text_result, text_matcher);
      T.eq(S.MACROS['registry'], registry_matcher);
    }
    return done();
  };

  this["MKTS.MACROS.$expand_html_comments"] = function(T, done) {
    var S, i, input, len, matcher, pre_probe, probe, probes_and_matchers, ref, results, stream;
    probes_and_matchers = [["<<(multi-column 3>>\nsome text here<!-- omit this 1 --> and some there\n<<)>>\n<<(multi-column 2>>\nThis text will appear in two-column<!-- omit this 2 --> layout.\n<!--some code-->\n<<(:>>some code<<)>>\n<<)>>\n<<!end>>\n<<!command>><<(:action>><<)>>", [[".", "text", "\u0015region4\u0013\nsome text here", {}], [".", "comment", " omit this 1 ", {}], [".", "text", " and some there\n\u0015region5\u0013\n\u0015region6\u0013\nThis text will appear in two-column", {}], [".", "comment", " omit this 2 ", {}], [".", "text", " layout.\n", {}], [".", "comment", "some code", {}], [".", "text", "\n\u0015action3\u0013\n\u0015region7\u0013\n", {}]]]];
    results = [];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], pre_probe = ref[0], matcher = ref[1];
      S = MKTS.MACROS.initialize_state({});
      probe = MKTS.MACROS.escape(S, pre_probe);
      input = D.stream_from_text(probe);
      stream = input.pipe($((function(_this) {
        return function(text, send) {
          return send(['.', 'text', text, {}]);
        };
      })(this)));
      D.call_transform(stream, ((function(_this) {
        return function() {
          return MKTS.MACROS.$expand_html_comments(S);
        };
      })(this)), (function(_this) {
        return function(error, result) {
          var event, j, len1;
          for (j = 0, len1 = result.length; j < len1; j++) {
            event = result[j];
            log(CND.white(JSON.stringify(event)));
          }
          T.eq(result, matcher);
          return done();
        };
      })(this));
      results.push(input.resume());
    }
    return results;
  };

  this["MKTS.MACROS.$expand_action_macros"] = function(T, done) {
    var S, i, input, len, matcher, pre_probe, probe, probes_and_matchers, ref, results, stream;
    probes_and_matchers = [
      [
        "<<(multi-column 3>>\nsome text with <<(:>>vocal action<<)>>.\n<<(.js>>and( \"a silent action\" )<<.js)>>", [
          [".", "text", "<<(multi-column 3>>\nsome text with ", {}], [
            ".", "action", "vocal action", {
              "mode": "vocal",
              "language": "coffee"
            }
          ], [".", "text", ".\n", {}], [
            ".", "action", "and( \"a silent action\" )", {
              "mode": "silent",
              "language": "js"
            }
          ]
        ]
      ]
    ];
    results = [];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], pre_probe = ref[0], matcher = ref[1];
      S = MKTS.MACROS.initialize_state({});
      probe = MKTS.MACROS.escape(S, pre_probe);
      input = D.stream_from_text(probe);
      stream = input.pipe($((function(_this) {
        return function(text, send) {
          return send(['.', 'text', text, {}]);
        };
      })(this)));
      D.call_transform(stream, ((function(_this) {
        return function() {
          return MKTS.MACROS.$expand_action_macros(S);
        };
      })(this)), (function(_this) {
        return function(error, result) {
          var event, j, len1;
          for (j = 0, len1 = result.length; j < len1; j++) {
            event = result[j];
            log(CND.white(JSON.stringify(event)));
          }
          T.eq(result, matcher);
          return done();
        };
      })(this));
      results.push(input.resume());
    }
    return results;
  };

  this["MKTS.MACROS.$expand_raw_macros"] = function(T, done) {
    var S, i, input, len, matcher, pre_probe, probe, probes_and_matchers, ref, results, stream;
    probes_and_matchers = [["<<(multi-column 3>>\nsome text here<<<\\LaTeX{}>>> and some there\n<<)>>", [[".", "text", "\u0015region1\u0013\nsome text here", {}], [".", "raw", "\\LaTeX{}", {}], [".", "text", " and some there\n\u0015region2\u0013", {}]]]];
    results = [];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], pre_probe = ref[0], matcher = ref[1];
      S = MKTS.MACROS.initialize_state({});
      probe = MKTS.MACROS.escape(S, pre_probe);
      input = D.stream_from_text(probe);
      stream = input.pipe($((function(_this) {
        return function(text, send) {
          return send(['.', 'text', text, {}]);
        };
      })(this)));
      D.call_transform(stream, ((function(_this) {
        return function() {
          return MKTS.MACROS.$expand_raw_macros(S);
        };
      })(this)), (function(_this) {
        return function(error, result) {
          var event, j, len1;
          for (j = 0, len1 = result.length; j < len1; j++) {
            event = result[j];
            log(CND.white(JSON.stringify(event)));
          }
          T.eq(result, matcher);
          return done();
        };
      })(this));
      results.push(input.resume());
    }
    return results;
  };

  this["MKTS.MACROS.$expand_command_and_value_macros"] = function(T, done) {
    var S, i, input, len, matcher, pre_probe, probe, probes_and_matchers, ref, results, stream;
    probes_and_matchers = [["<<(multi-column 3>>\nsome text here <<!LATEX>> and some there\n<<)>>", [[".", "text", "<<(multi-column 3>>\nsome text here ", {}], ["!", "LATEX", null, {}], [".", "text", " and some there\n<<)>>", {}]]]];
    results = [];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], pre_probe = ref[0], matcher = ref[1];
      S = MKTS.MACROS.initialize_state({});
      probe = MKTS.MACROS.escape(S, pre_probe);
      input = D.stream_from_text(probe);
      stream = input.pipe($((function(_this) {
        return function(text, send) {
          return send(['.', 'text', text, {}]);
        };
      })(this)));
      D.call_transform(stream, ((function(_this) {
        return function() {
          return MKTS.MACROS.$expand_command_and_value_macros(S);
        };
      })(this)), (function(_this) {
        return function(error, result) {
          var event, j, len1;
          for (j = 0, len1 = result.length; j < len1; j++) {
            event = result[j];
            log(CND.white(JSON.stringify(event)));
          }
          T.eq(result, matcher);
          return done();
        };
      })(this));
      results.push(input.resume());
    }
    return results;
  };

  this["MKTS.MACROS.$expand_region_macros"] = function(T, done) {
    var S, i, input, len, matcher, pre_probe, probe, probes_and_matchers, ref, results, stream;
    probes_and_matchers = [["<<(multi-column 3>>\nsome text here<!-- omit this --> and some there\n<<)>>\n<<(multi-column 2>>\nThis text will appear in two-column<!-- omit this --> layout.\n<!--some code-->\n<<(:>>some code<<)>>\n<<)>>\n<<!end>>\n<<!command>><<(:action>><<)>>", [["(", "multi-column 3", null, {}], [".", "text", "\nsome text here\u0015comment0\u0013 and some there\n", {}], [")", "multi-column 3", null, {}], [".", "text", "\n", {}], ["(", "multi-column 2", null, {}], [".", "text", "\nThis text will appear in two-column\u0015comment1\u0013 layout.\n\u0015comment2\u0013\n\u0015action3\u0013\n", {}], [")", "multi-column 2", null, {}], [".", "text", "\n", {}]]]];
    results = [];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], pre_probe = ref[0], matcher = ref[1];
      S = MKTS.MACROS.initialize_state({});
      probe = MKTS.MACROS.escape(S, pre_probe);
      input = D.stream_from_text(probe);
      stream = input.pipe($((function(_this) {
        return function(text, send) {
          return send(['.', 'text', text, {}]);
        };
      })(this)));
      D.call_transform(stream, ((function(_this) {
        return function() {
          return MKTS.MACROS.$expand_region_macros(S);
        };
      })(this)), (function(_this) {
        return function(error, result) {
          var event, j, len1;
          for (j = 0, len1 = result.length; j < len1; j++) {
            event = result[j];
            log(CND.white(JSON.stringify(event)));
          }
          T.eq(result, matcher);
          return done();
        };
      })(this));
      results.push(input.resume());
    }
    return results;
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
