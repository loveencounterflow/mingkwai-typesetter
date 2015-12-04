(function() {
  "use strict";
  var CLOAK, CND, DIFF, alert, badge, cloak, cloaked_text, debug, echo, esc_re, help, info, log, rainbow, rpr, text, uncloaked_text, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'CLOAK';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  rainbow = CND.rainbow.bind(CND);


  /*
  
  Cloaking characters by chained replacements:
  
  Assuming an alphabet `/[0-9]/`, cloaking characters starting from `0`.
  
  To cloak only `0`, we have to free the string of all occurrences of that
  character. In order to do so, we choose a primary escapement character, '1',
  and a secondary escapement character, conveniently also `1`. With those, we
  can replace all occurrences of `0` as `11`. However, that alone would produce
  ambiguous sequences. For example,  the string `011` results in `1111`, but so
  does the string `1111` itself (because it does not contain a `0`, it remains
  unchanged when replacing `0`). Therefore, we have to escape the  secondary
  escapement character itself, too; we choose the secondary replacement `1 ->
  12`  which has to come *first* when cloaking and *second* when uncloaking.
  This results in the following cloaking chain:
  
  CLOAK.new '012'
  
           0123456789
  1 -> 12: 01223456789
  0 -> 11: 111223456789
  
  The resulting string is free of `0`s. Because all original `0`s and `1`s have
  been preserved in disguise, we are now free to insert additional data into the
  string.
  
  Let's assume we have a text transformer `f`, say, `f ( x ) -> x.replace
  /456/g, '15'`, and a more comprehensive text transformer `g` which includes
  calls to `f` and other elementary transforms. Now, we would like to apply `g`
  to our text `0123456789`, but specifically omit the transformation performed
  by `f` (which would turn `0123456789` into `012315789`). We can do so by
  choosing a cloaking character—`0` in this example—and one or more signal
  characters that will pass unmodified through `g`. Assuming we cloak `456` as
  `01`, we first escape `0123456789` to `111223456789` so that all `0`s are
  removed. Then, we symbolize all occurrances of `456` as `01`, leading to
  `11122301789`. This string may be fed to `g` and will pass through `f`
  untouched. We can then reverse our steps: `11122301789` ... `111223456789` ...
  `01223456789` ... `0123456789`—which is indeed the string we're started with.
  Of course, this could not have worked if `g` had somehow transformed any of
  our cloaking devices; therefore, it is important to choose codepoints that are
  certain to be transparent to the intended text transformation.
  
  In case more primary escapement characters are needed, the chain may be
  expanded to include more replacement steps. In particular, it is interesting
  to use exactly two primary escapements; that way, we can define cloaked
  sequences of arbitrary lengths, using the two escapements—`0` and `1` in this
  example—as start and stop brackets:
  
  CLOAK.new '01234'
  
           0123456789
  2 -> 24: 01243456789
  1 -> 23: 023243456789
  0 -> 22: 2223243456789
  
  Using more than two primary escapements is possible:
  
  CLOAK.new '0123456'
  
           0123456789
  3 -> 36: 01236456789
  2 -> 35: 013536456789
  1 -> 34: 0343536456789
  0 -> 33: 33343536456789
  
  CLOAK.new '012345678'
  
           0123456789
  4 -> 48: 01234856789
  3 -> 47: 012474856789
  2 -> 46: 0146474856789
  1 -> 45: 04546474856789
  0 -> 44: 444546474856789
   */


  /* from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions */

  esc_re = function(text) {
    return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  };

  this.new_cloak = function(chrs, base) {
    var R, chr_count, cloaked, delta, hide, idx, master, meta_chr_patterns, reveal, target_seq_chrs, target_seq_patterns;
    if (base == null) {
      base = 16;
    }
    if (chrs == null) {
      chrs = ['\x10', '\x11', '\x12', '\x13', '\x14'];
    } else if (CND.isa_text(chrs)) {
      chrs = Array.from(chrs);
    } else if (!CND.isa_list(chrs)) {
      throw new Error("expected a text or a list, got a " + (CND.type_of(chrs)));
    }
    if (!((chr_count = chrs.length) >= 3)) {
      throw new Error("expected at least 3 characters, got " + chr_count);
    }
    if (chr_count % 2 === 0) {
      throw new Error("expected an odd number of characters, got " + chr_count);
    }
    delta = (chr_count + 1) / 2 - 1;
    master = chrs[chr_count - delta - 1];
    meta_chr_patterns = (function() {
      var i, ref, results;
      results = [];
      for (idx = i = 0, ref = delta; 0 <= ref ? i <= ref : i >= ref; idx = 0 <= ref ? ++i : --i) {
        results.push(RegExp("" + (esc_re(chrs[idx])), "g"));
      }
      return results;
    })();
    target_seq_chrs = (function() {
      var i, ref, results;
      results = [];
      for (idx = i = 0, ref = delta; 0 <= ref ? i <= ref : i >= ref; idx = 0 <= ref ? ++i : --i) {
        results.push("" + master + chrs[idx + delta]);
      }
      return results;
    })();
    target_seq_patterns = (function() {
      var i, ref, results;
      results = [];
      for (idx = i = 0, ref = delta; 0 <= ref ? i <= ref : i >= ref; idx = 0 <= ref ? ++i : --i) {
        results.push(RegExp("" + (esc_re(target_seq_chrs[idx])), "g"));
      }
      return results;
    })();
    cloaked = chrs.slice(0, delta);
    hide = (function(_this) {
      return function(text) {
        var R_, i, ref;
        R_ = text;
        for (idx = i = ref = delta; i >= 0; idx = i += -1) {
          R_ = R_.replace(meta_chr_patterns[idx], target_seq_chrs[idx]);
        }
        return R_;
      };
    })(this);
    reveal = (function(_this) {
      return function(text) {
        var R_, i, ref;
        R_ = text;
        for (idx = i = 0, ref = delta; 0 <= ref ? i <= ref : i >= ref; idx = 0 <= ref ? ++i : --i) {
          R_ = R_.replace(target_seq_patterns[idx], chrs[idx]);
        }
        return R_;
      };
    })(this);
    R = {
      '~isa': 'CLOAK/cloak',
      hide: hide,
      reveal: reveal,
      cloaked: cloaked,
      master: master
    };
    this._mixin_backslashed(R, base);
    return R;
  };

  this._mixin_backslashed = function(cloak, base) {
    var _mcp_backslash, _oc_backslash, _oce_backslash, _rm_backslash, _tsp_backslash, cloaked, hide, remove, reveal, start_chr, stop_chr;
    if (base == null) {
      base = 16;
    }
    cloaked = cloak.cloaked;
    if (cloaked.length < 2) {
      start_chr = stop_chr = cloaked[0];
    } else {
      start_chr = cloaked[0], stop_chr = cloaked[1];
    }

    /* `oc`: 'original character' */
    _oc_backslash = '\\';

    /* `op`: 'original pattern' */
    _oce_backslash = esc_re(_oc_backslash);
    _mcp_backslash = RegExp((esc_re(_oc_backslash)) + "((?:[\\ud800-\\udbff][\\udc00-\\udfff])|.)", "g");
    _tsp_backslash = RegExp((esc_re(start_chr)) + "([0-9a-z]+)" + (esc_re(stop_chr)), "g");

    /* `rm`: 'remove' */
    _rm_backslash = RegExp((esc_re(_oc_backslash)) + "(.)", "g");
    hide = (function(_this) {
      return function(text) {
        var R;
        R = text;
        R = R.replace(_mcp_backslash, function(_, $1) {
          var cid_hex;
          cid_hex = ($1.codePointAt(0)).toString(base);
          return "" + start_chr + cid_hex + stop_chr;
        });
        return R;
      };
    })(this);
    reveal = (function(_this) {
      return function(text) {
        var R;
        R = text;
        R = R.replace(_tsp_backslash, function(_, $1) {
          var chr;
          chr = String.fromCodePoint(parseInt($1, base));
          return "" + _oc_backslash + chr;
        });
        return R;
      };
    })(this);
    remove = (function(_this) {
      return function(text) {
        return text.replace(_rm_backslash, '$1');
      };
    })(this);
    cloak['backslashed'] = {
      hide: hide,
      reveal: reveal,
      remove: remove
    };
    return null;
  };

  if (module.parent == null) {
    CLOAK = this;
    DIFF = require('coffeenode-diff');
    cloak = CLOAK.new_cloak('()LTX');
    cloak = CLOAK.new_cloak('*+?^$');
    help(cloak);
    text = "% & ! ;\nsome <<unlicensed>> (stuff here). \\𠄨 *20128+? &%!%A&123;\nsome more \\\\<<unlicensed\\\\>> (stuff here).\nsome \\<<licensed\\>> stuff here, and <\\<\nThe <<<\\LaTeX{}>>> Logo: `<<<\\LaTeX{}>>>`";
    log('(1) -', CND.rainbow(text));
    cloaked_text = text;
    log('(2) -', CND.rainbow((cloaked_text = cloak.hide(cloaked_text))));
    log('(3) -', CND.rainbow((cloaked_text = cloak.backslashed.hide(cloaked_text))));
    uncloaked_text = cloaked_text;
    log('(4) -', CND.rainbow((uncloaked_text = cloak.backslashed.reveal(uncloaked_text))));
    log('(5) -', CND.rainbow((uncloaked_text = cloak.reveal(uncloaked_text))));
    log('(7) -', CND.rainbow('©79011', cloak.backslashed.remove(uncloaked_text)));
    if (uncloaked_text !== text) {
      log(DIFF.colorize(text, uncloaked_text));
    }
    log(CND.steel('########################################################################'));
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/cloak.js.map
