(function() {
  var $, $async, CND, D, MKTS, MKTS_XXX, after, alert, badge, debug, echo, help, info, join, later, log, njs_path, rpr, show_events, step, suspend, test, urge, warn, whisper;

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

  this["MKTS.FENCES.parse accepts dot patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['.', ['.', null, null]], ['.p', ['.', 'p', null]], ['.text', ['.', 'text', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts empty fenced patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<>', ['<', null, '>']], ['{}', ['{', null, '}']], ['[]', ['[', null, ']']], ['()', ['(', null, ')']]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts unfenced named patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['document', [null, 'document', null]], ['singlecolumn', [null, 'singlecolumn', null]], ['code', [null, 'code', null]], ['blockquote', [null, 'blockquote', null]], ['em', [null, 'em', null]], ['xxx', [null, 'xxx', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts fenced named patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<document>', ['<', 'document', '>']], ['{singlecolumn}', ['{', 'singlecolumn', '}']], ['{code}', ['{', 'code', '}']], ['[blockquote]', ['[', 'blockquote', ']']], ['(em)', ['(', 'em', ')']]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse rejects empty string"] = function(T, done) {
    T.throws("pattern must be non-empty, got ''", (function() {
      return MKTS.FENCES.parse('');
    }));
    return done();
  };

  this["MKTS.FENCES.parse rejects non-matching fences etc"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['(xxx}', 'fences don\'t match in pattern \'(xxx}\''], ['.)', 'fence \'.\' can not have right fence, got \'.)\''], ['.p)', 'fence \'.\' can not have right fence, got \'.p)\''], ['.[', 'fence \'.\' can not have right fence, got \'.[\''], ['<', 'unmatched fence in \'<\''], ['{', 'unmatched fence in \'{\''], ['[', 'unmatched fence in \'[\''], ['(', 'unmatched fence in \'(\'']];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.throws(matcher, (function() {
        return MKTS.FENCES.parse(probe);
      }));
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts non-matching fences when so configured"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<document>', ['<', 'document', '>']], ['{singlecolumn}', ['{', 'singlecolumn', '}']], ['{code}', ['{', 'code', '}']], ['[blockquote]', ['[', 'blockquote', ']']], ['(em)', ['(', 'em', ')']], ['document>', [null, 'document', '>']], ['singlecolumn}', [null, 'singlecolumn', '}']], ['code}', [null, 'code', '}']], ['blockquote]', [null, 'blockquote', ']']], ['em)', [null, 'em', ')']], ['<document', ['<', 'document', null]], ['{singlecolumn', ['{', 'singlecolumn', null]], ['{code', ['{', 'code', null]], ['[blockquote', ['[', 'blockquote', null]], ['(em', ['(', 'em', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe, {
        symmetric: false
      }), matcher);
    }
    return done();
  };

  this["MKTS.TRACKER.new_tracker (short comprehensive test)"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref, track;
    track = MKTS.TRACKER.new_tracker('(code)', '{multi-column}');
    probes_and_matchers = [[['<', 'document'], [false, false]], [['{', 'multi-column'], [false, true]], [['(', 'code'], [true, true]], [['{', 'multi-column'], [true, true]], [['.', 'text'], [true, true]], [['}', 'multi-column'], [true, true]], [[')', 'code'], [false, true]], [['}', 'multi-column'], [false, false]], [['>', 'document'], [false, false]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      track(probe);
      whisper(probe);
      help('(code):', track.within('(code)'), '{multi-column}:', track.within('{multi-column}'));
      T.eq(track.within('(code)'), matcher[0]);
      T.eq(track.within('{multi-column}'), matcher[1]);
    }
    return done();
  };

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

  this["MKTS.mkts_events_from_md (1)"] = function(T, done) {
    var matcher, probe;
    probe = "`<<($>>eval block<<$)>>`";
    warn("should merge texts");
    matcher = [
      [
        "<", "document", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        "(", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<($>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "eval block", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<$)>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ")", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [">", "document", null, {}]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (2)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "`<<($>>eval block<<$)>>`";
    warn("should merge texts");
    matcher = [
      [
        "(", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<($>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "eval block", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<$)>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ")", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (3)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "`<<(\\$>>eval block<<\\$)>>`";
    warn("should merge texts");
    matcher = [
      [
        "(", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<(\\$>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "eval block", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "text", "<<\\$)>>", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ")", "code", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "`"
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (4)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "<<!end>>";
    warn("match remark?");
    matcher = [
      [
        "!", "end", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "",
          "stamped": true
        }
      ], [
        "#", "info", "encountered `<<!end>>` on line #1", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "",
          "stamped": true,
          "badge": "$process_end_command"
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (5)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "<<!multi-column>>";
    warn("should not contain `.p`");
    matcher = [
      [
        "!", "multi-column", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (6)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "aaa\n<<(multi-column>>\nbbb\n<<multi-column)>>\nccc";
    warn("missing `.p` inside `(multi-column)`");
    matcher = [
      [
        ".", "text", "aaa\n", {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ], [
        "(", "multi-column", null, {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ], [
        ".", "text", "\nbbb\n", {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ], [
        ")", "multi-column", null, {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ], [
        ".", "text", "\nccc", {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 6,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (7)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "她說：「你好。」";
    matcher = [
      [
        ".", "text", "她說：「你好。」", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md (8)"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "A paragraph with *emphasis*.\n\nA paragraph with **bold text**.";
    matcher = [
      [
        ".", "text", "A paragraph with ", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        "(", "em", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "*"
        }
      ], [
        ".", "text", "emphasis", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        ")", "em", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": "*"
        }
      ], [
        ".", "text", ".", {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 2,
          "markup": ""
        }
      ], [
        ".", "text", "A paragraph with ", {
          "line_nr": 3,
          "col_nr": 4,
          "markup": ""
        }
      ], [
        "(", "strong", null, {
          "line_nr": 3,
          "col_nr": 4,
          "markup": "**"
        }
      ], [
        ".", "text", "bold text", {
          "line_nr": 3,
          "col_nr": 4,
          "markup": ""
        }
      ], [
        ")", "strong", null, {
          "line_nr": 3,
          "col_nr": 4,
          "markup": "**"
        }
      ], [
        ".", "text", ".", {
          "line_nr": 3,
          "col_nr": 4,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 3,
          "col_nr": 4,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

  this["MKTS.mkts_events_from_md: footnotes"] = function(T, done) {
    var matcher, probe, settings;
    settings = {
      bare: true
    };
    probe = "Here is an inline footnote^[whose text appears at the point of insertion],\nfollowed by a referenced footnote[^1].\n\n[^1]: Referenced footnotes must use matching references.";
    matcher = [
      [
        ".", "text", "Here is an inline footnote", {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        "(", "footnote", 0, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "text", "whose text appears at the point of insertion", {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ")", "footnote", 0, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "text", ",\nfollowed by a referenced footnote", {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        "(", "footnote", 1, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "text", "Referenced footnotes must use matching references.", {
          "line_nr": 4,
          "col_nr": 5,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 4,
          "col_nr": 5,
          "markup": ""
        }
      ], [
        ")", "footnote", 1, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "text", ".", {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ], [
        ".", "p", null, {
          "line_nr": 1,
          "col_nr": 3,
          "markup": ""
        }
      ]
    ];
    return step((function(_this) {
      return function*(resume) {
        var result;
        result = (yield MKTS.mkts_events_from_md(probe, settings, resume));
        T.eq(matcher, result);
        return done();
      };
    })(this));
  };

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
