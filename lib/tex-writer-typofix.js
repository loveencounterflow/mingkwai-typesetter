(function() {
  var $, CND, D, MD_READER, XNCHR, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, rpr, select, stamp, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'mkts/tex-writer-typofix';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  XNCHR = require('./xnchr');

  D = require('pipedreams');

  $ = D.remit.bind(D);

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  this._tex_escape_replacements = [[/\x01/g, '\x01\x02'], [/\x5c/g, '\x01\x01'], [/\{/g, '\\{'], [/\}/g, '\\}'], [/\$/g, '\\$'], [/\#/g, '\\#'], [/%/g, '\\%'], [/_/g, '\\_'], [/\^/g, '\\textasciicircum{}'], [/~/g, '\\textasciitilde{}'], [/&/g, '\\&'], [/\x01\x01/g, '\\textbackslash{}'], [/\x01\x02/g, '\x01']];

  this.escape_for_tex = (function(_this) {
    return function(text) {
      var R, i, idx, len, pattern, ref, ref1, replacement;
      R = text;
      ref = _this._tex_escape_replacements;
      for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
        ref1 = ref[idx], pattern = ref1[0], replacement = ref1[1];
        R = R.replace(pattern, replacement);
      }
      return R;
    };
  })(this);

  this.$fix_typography_for_tex = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, ref, style, text, type;
        if (select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          meta['raw'] = text;
          style = (ref = meta['typofix']) != null ? ref : 'basic';
          text = _this.fix_typography_for_tex(text, S.options, null, style);
          return send([type, name, text, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.is_cjk_rsg = (function(_this) {
    return function(rsg, options) {
      return indexOf.call(options['tex']['cjk-rsgs'], rsg) >= 0;
    };
  })(this);

  this._analyze_chr = function(S, chr, style, is_last) {
    var R, ref;
    R = XNCHR.CHR.analyze(chr, {
      input: style === 'escape-ncrs' ? 'plain' : 'xncr'
    });
    switch (R.rsg) {
      case 'jzr-fig':
        R.chr = R.uchr;
        break;
      case 'u-pua':
        R.rsg = 'jzr-fig';
        break;
      case 'u-latn':
        R.chr = this.escape_for_tex(chr);
    }

    /* OBS `chr` has still the value this method was called with, so styling should work even for `u-latn`
    characters
     */
    R.is_whitespace = indexOf.call(S.whitespace, chr) >= 0;
    R.is_cjk = (ref = R.rsg, indexOf.call(S.cjk_rsgs, ref) >= 0);
    R.styled_chr = this._style_chr(S, R, chr, is_last);
    return R;
  };

  this._style_chr = function(S, chr_info, chr, is_last) {
    var R, csg, fncr, is_cjk, message, ref, ref1, ref2, ref3, ref4, rpl_chr, rpl_cmd, rpl_push, rpl_raise, rsg, rsg_command, style;
    csg = chr_info.csg, rsg = chr_info.rsg, fncr = chr_info.fncr, is_cjk = chr_info.is_cjk;
    rsg_command = S.tex_command_by_rsgs[rsg];
    if (csg !== 'u' && csg !== 'jzr') {

      /* TAINT won't capture styling for `&`, `#` and so on */
      return this.escape_for_tex(chr_info.chr);
    }
    if (rsg_command == null) {
      rsg_command = (ref = S.tex_command_by_rsgs['fallback']) != null ? ref : null;
      message = "unknown RSG " + (rpr(rsg)) + ": " + fncr + " " + chr + " (using fallback " + (rpr(rsg_command)) + ")";
      if (S.send != null) {
        S.send(remark('warn', message, {}));
      } else {
        warn(message);
      }
    }
    if (rsg_command === 'latin') {
      rsg_command = null;
    }
    style = S.glyph_styles[chr];
    if (style != null) {

      /* TAINT use `cjkgGlue` only if `is_cjk` */
      R = [];
      R.push("{");
      if (is_cjk) {
        R.push("\\cn{}");
      }
      rpl_push = (ref1 = style['push']) != null ? ref1 : null;
      rpl_raise = (ref2 = style['raise']) != null ? ref2 : null;
      rpl_chr = (ref3 = style['glyph']) != null ? ref3 : chr_info['uchr'];
      rpl_cmd = (ref4 = style['cmd']) != null ? ref4 : rsg_command;
      if (rpl_cmd === 'cn') {
        rpl_cmd = null;
      }
      if ((rpl_push != null) && (rpl_raise != null)) {
        R.push("\\tfPushRaise{" + rpl_push + "}{" + rpl_raise + "}");
      } else if (rpl_push != null) {
        R.push("\\tfPush{" + rpl_push + "}");
      } else if (rpl_raise != null) {
        R.push("\\tfRaise{" + rpl_raise + "}");
      }
      if (rpl_cmd != null) {
        R.push("\\" + rpl_cmd + "{}");
      }
      R.push(rpl_chr);
      R.push("}");
      R = R.join('');
    } else if (rsg_command != null) {

      /* TAINT does not collect glyphs with same RSG */
      R = "{\\" + rsg_command + "{}" + chr_info['uchr'] + "}";
    } else {
      R = null;
    }
    S.last_rsg_command = rsg_command;
    return R;
  };

  this._move_whitespace = function(S) {
    var ref;
    (ref = S.collector).splice.apply(ref, [S.collector.length, 0].concat(slice.call(S.ws_collector)));
    S.ws_collector.length = 0;
    return null;
  };

  this._push = function(S, chr, postpone_ws) {
    if (postpone_ws == null) {
      postpone_ws = false;
    }
    if (!postpone_ws) {
      this._move_whitespace(S);
    }
    if (chr != null) {
      S.collector.push(chr);
    }
    if (postpone_ws) {
      this._move_whitespace(S);
    }
    S.has_cjk_glue = false;
    return null;
  };

  this._push_whitespace = function(S, chr) {
    S.ws_collector.push(chr);
    return null;
  };

  this._split_dangling_ws = function(text) {
    var _, head, ref, tail;
    ref = text.match(this._split_dangling_ws.pattern), _ = ref[0], head = ref[1], tail = ref[2];
    return [head, tail];
  };

  this._split_dangling_ws.pattern = /^([\s\S]*?)([\x20\t\n]*)$/;

  this.fix_typography_for_tex = (function(_this) {
    return function(text, options, send, style) {
      var A, S, chr, chrs, dangling_ws, i, idx, last_idx, len, ref, ref1, ref2, ref3, ref4, ref5;
      if (send == null) {
        send = null;
      }
      S = {
        cjk_rsgs: (ref = (ref1 = options['tex']) != null ? ref1['cjk-rsgs'] : void 0) != null ? ref : null,
        glyph_styles: (ref2 = (ref3 = options['tex']) != null ? ref3['glyph-styles'] : void 0) != null ? ref2 : {},
        tex_command_by_rsgs: (ref4 = options['tex']) != null ? ref4['tex-command-by-rsgs'] : void 0,
        ws_collector: [],
        collector: [],
        whitespace: '\x20\n\r\t',
        this_is_cjk: false,
        last_was_cjk: false,
        last_rsg_command: null,
        R: null
      };
      if (S.tex_command_by_rsgs == null) {
        throw new Error("need setting 'tex-command-by-rsgs'");
      }
      if (S.cjk_rsgs == null) {
        throw new Error("need setting 'cjk-rsgs'");
      }
      ref5 = _this._split_dangling_ws(text), text = ref5[0], dangling_ws = ref5[1];
      chrs = XNCHR.chrs_from_text(text);
      last_idx = chrs.length - 1;
      for (idx = i = 0, len = chrs.length; i < len; idx = ++i) {
        chr = chrs[idx];
        A = _this._analyze_chr(S, chr, style, idx === last_idx);

        /* Whitespace is ambiguous; it is treated as CJK when coming between two unambiguous CJK characters and
        as non-CJK otherwise; to decide between these cases, we have to wait for the next non-whitespace
        character:
         */
        if (A.is_whitespace) {
          _this._push_whitespace(S, chr);
          continue;
        }
        S.last_was_cjk = S.this_is_cjk;
        S.this_is_cjk = A.is_cjk;

        /* In case we're entering a region of CJK characters, we have to start a group and issue a `\cjk`
        command; before we do that, any cached whitespace will be moved into the result. If we're leaving a
        CJK region, the group must be closed first and followed by any cached whitespace:
         */
        if ((!S.last_was_cjk) && S.this_is_cjk) {
          _this._push(S, "{\\cjk{}");
        } else if (S.last_was_cjk && (!S.this_is_cjk)) {
          _this._push(S, "}", true);
        }
        if (A.styled_chr != null) {
          _this._push(S, A.styled_chr);
        } else {
          _this._push(S, A.chr);
        }
      }

      /* TAINT here we should keep state across text chunks to decide on cases like
      `國 **b** 國` vs `國 **國** 國`
       */
      _this._push(S);
      if (S.this_is_cjk) {
        _this._push(S, '}');
      }
      _this._push(S, dangling_ws);
      return S.collector.join('');
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/tex-writer-typofix.js.map
