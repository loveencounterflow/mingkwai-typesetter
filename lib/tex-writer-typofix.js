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
        var meta, name, text, type;
        if (select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          meta['raw'] = text;
          text = _this.fix_typography_for_tex(text, S.options);
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

  this.fix_typography_for_tex = (function(_this) {
    return function(text, options, send) {
      var R, advance, advance_each_chr, advance_whitespace, chr, chunk, command, fncr, glyph_styles, glyph_styles_v2, has_cjk_glue, i, last_command, last_rsg, last_was_cjk, last_was_whitespace, len, message, ref, ref1, ref10, ref11, ref12, ref13, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9, remark, replacement, rpl, rpl_chr, rpl_cmd, rpl_push, rpl_raise, rsg, tex_command_by_rsgs, this_is_cjk, this_is_whitespace, uchr, whitespace_cache;
      if (send == null) {
        send = null;
      }

      /* An improved version of `XELATEX.tag_from_chr` */

      /* TAINT should accept settings, fall back to `require`d `options.coffee` */
      glyph_styles = (ref = (ref1 = options['tex']) != null ? ref1['glyph-styles'] : void 0) != null ? ref : {};
      glyph_styles_v2 = (ref2 = (ref3 = options['tex']) != null ? ref3['glyph-styles-v2'] : void 0) != null ? ref2 : {};

      /* Legacy mode: force one command per non-latin character. This is OK for Chinese texts,
      but a bad idea for all other scripts; in the future, MKTS's TeX formatting commands like
      `\cn{}` will be rewritten to make this setting superfluous.
       */
      advance_each_chr = (ref4 = (ref5 = options['tex']) != null ? ref5['advance-each-chr'] : void 0) != null ? ref4 : false;
      tex_command_by_rsgs = (ref6 = options['tex']) != null ? ref6['tex-command-by-rsgs'] : void 0;
      last_command = null;
      R = [];
      chunk = [];
      last_rsg = null;
      remark = send != null ? _this._get_remark() : null;
      this_is_cjk = false;
      last_was_cjk = false;
      this_is_whitespace = false;
      last_was_whitespace = false;
      whitespace_cache = [];
      replacement = null;
      has_cjk_glue = false;
      if (tex_command_by_rsgs == null) {
        throw new Error("need setting 'tex-command-by-rsgs'");
      }
      advance_whitespace = function() {
        chunk.splice.apply(chunk, [chunk.length, 0].concat(slice.call(whitespace_cache)));
        return whitespace_cache.length = 0;
      };
      advance = function() {
        if (chunk.length > 0) {
          R.push(chunk.join(''));
          if (last_command !== null && last_command !== 'latin' && last_command !== 'cn') {
            R.push("}");
          }
        }
        chunk.length = 0;
        return null;
      };
      ref7 = XNCHR.chrs_from_text(text);
      for (i = 0, len = ref7.length; i < len; i++) {
        chr = ref7[i];

        /* Treat whitespace specially */
        if ((this_is_whitespace = chr === '\x20' || chr === '\n' || chr === '\r' || chr === '\t')) {
          whitespace_cache.push(chr);
          continue;
        }
        ref8 = XNCHR.analyze(chr), chr = ref8.chr, uchr = ref8.uchr, fncr = ref8.fncr, rsg = ref8.rsg;
        switch (rsg) {
          case 'jzr-fig':
            chr = uchr;
            break;
          case 'u-pua':
            rsg = 'jzr-fig';
            break;
          case 'u-latn':
            chr = _this.escape_for_tex(chr);
        }
        this_is_cjk = _this.is_cjk_rsg(rsg, options);
        if ((!last_was_cjk) && this_is_cjk) {
          advance_whitespace();
          chunk.push("{\\cjk{}");
        } else if (last_was_cjk && (!this_is_cjk)) {
          chunk.push("}");
          advance_whitespace();
        } else if (whitespace_cache.length > 0) {
          advance_whitespace();
        }
        last_was_cjk = this_is_cjk;

        /* TAINT if chr is a TeX active ASCII chr like `$`, `#`, then it will be escaped at this point
        and no more match entries in `glyph_styles`
         */
        if ((replacement = glyph_styles_v2[chr]) != null) {
          advance();
          rpl = [];
          if (!has_cjk_glue) {
            rpl.push('\\cjkgGlue');
          }
          rpl.push('{');
          rpl_push = (ref9 = replacement['push']) != null ? ref9 : null;
          rpl_raise = (ref10 = replacement['raise']) != null ? ref10 : null;
          rpl_chr = (ref11 = replacement['glyph']) != null ? ref11 : chr;
          rpl_cmd = (ref12 = replacement['cmd']) != null ? ref12 : null;
          if (rpl_cmd === 'cn') {
            rpl_cmd = null;
          }
          if ((rpl_push != null) && (rpl_raise != null)) {
            rpl.push("\\tfPushRaise{" + rpl_push + "}{" + rpl_raise + "}");
          } else if (rpl_push != null) {
            rpl.push("\\tfPush{" + rpl_push + "}");
          } else if (rpl_raise != null) {
            rpl.push("\\tfRaise{" + rpl_raise + "}");
          }
          if (rpl_cmd != null) {
            rpl.push("\\" + rpl_cmd + "{}");
          }
          rpl.push(rpl_chr);
          rpl.push('\\cjkgGlue}');
          R.push(rpl.join(''));
          has_cjk_glue = true;
          last_command = null;
          continue;
        } else if ((replacement = glyph_styles[chr]) != null) {

          /* TAINT this is the legacy branch; new stuff uses glyph_styles_v2, above */
          advance();
          R.push(replacement);
          last_command = null;
          has_cjk_glue = false;
          continue;
        } else {
          has_cjk_glue = false;
        }
        if ((command = tex_command_by_rsgs[rsg]) == null) {
          command = (ref13 = tex_command_by_rsgs['fallback']) != null ? ref13 : null;
          message = "unknown RSG " + (rpr(rsg)) + ": " + fncr + " " + chr + " (using fallback " + (rpr(command)) + ")";
          if (send != null) {
            send(remark('warn', message, {}));
          } else {
            warn(message);
          }
        }
        if (command == null) {
          advance();
          chunk.push(chr);
          continue;
        }
        if (advance_each_chr || last_command !== command) {
          advance();
          last_command = command;

          /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
          if (command !== 'latin' && command !== 'cn') {
            chunk.push("{\\" + command + "{}");
          }

          /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
        }
        chunk.push(chr);
      }
      if (this_is_cjk) {
        chunk.push("}");
      }
      if (whitespace_cache.length > 0) {
        advance_whitespace();
      }
      advance();
      return R.join('');
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/tex-writer-typofix.js.map
