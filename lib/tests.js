(function() {
  var $, $async, CND, D, MKTS, after, alert, badge, copy_regex_non_global, debug, echo, help, info, join, later, list_from_match, log, match_first, nice_text_rpr, njs_path, rpr, show_events, step, suspend, test, urge, warn, whisper;

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

  MKTS = require('./main');

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

  this["_TEX_WRITER_TYPOFIX.fix_typography_for_tex"] = function(T, done) {
    var CACHE, OPTIONS, S, TEX_WRITER_TYPOFIX, i, len, matcher, options_home, options_locator, options_route, probe, probes_and_matchers, ref, ref1, result;
    S = {};
    ref = require('./options'), CACHE = ref.CACHE, OPTIONS = ref.OPTIONS;
    TEX_WRITER_TYPOFIX = require('./tex-writer-typofix');
    options_route = '../options.coffee';
    options_locator = require.resolve(njs_path.resolve(__dirname, options_route));
    options_home = njs_path.dirname(options_locator);
    S.options = OPTIONS.from_locator(options_locator);
    probes_and_matchers = [["a 國 b", "a \\cjkgGlue{\\cjk{}國\\cjkgGlue} b"], ["a 𠇋 b", "a \\cjkgGlue{\\cjk{}{\\cnxb{}𠇋\\cjkgGlue}} b"]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref1 = probes_and_matchers[i], probe = ref1[0], matcher = ref1[1];
      result = TEX_WRITER_TYPOFIX.fix_typography_for_tex(probe, S.options);
      echo('    ' + JSON.stringify([probe, result]));
      T.eq(matcher.trim().replace(/\x20/g, '█'), result.trim().replace(/\x20/g, '█'));
    }
    return done();
  };

  this["TEX_WRITER_TYPOFIX.fix_typography_for_tex_2"] = function(T, done) {
    var CACHE, OPTIONS, S, TEX_WRITER_TYPOFIX, i, len, matcher, options_home, options_locator, options_route, probe, probes_and_matchers, ref, ref1, result;
    S = {};
    ref = require('./options'), CACHE = ref.CACHE, OPTIONS = ref.OPTIONS;
    TEX_WRITER_TYPOFIX = require('./tex-writer-typofix');
    options_route = '../options.coffee';
    options_locator = require.resolve(njs_path.resolve(__dirname, options_route));
    options_home = njs_path.dirname(options_locator);
    S.options = OPTIONS.from_locator(options_locator);
    probes_and_matchers = [["國", "\\cjkgGlue{\\cjk{}國\\cjkgGlue}"]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref1 = probes_and_matchers[i], probe = ref1[0], matcher = ref1[1];
      result = TEX_WRITER_TYPOFIX.fix_typography_for_tex_2(probe, S.options);
      echo('    ' + JSON.stringify([probe, result]));
      T.eq(matcher.trim().replace(/\x20/g, '█'), result.trim().replace(/\x20/g, '█'));
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
