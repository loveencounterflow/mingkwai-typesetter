(function() {
  var $, CND, D, MKTS, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/MACROS';

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

  MKTS = require('./MKTS');

  this.initialize_state = (function(_this) {
    return function(state) {
      state['MACROS'] = {
        registry: []
      };
      return state;
    };
  })(this);

  this._match_first = (function(_this) {
    return function(patterns, text) {
      var R, i, len, pattern;
      for (i = 0, len = patterns.length; i < len; i++) {
        pattern = patterns[i];
        if ((R = text.match(pattern)) != null) {
          return R;
        }
      }
      return null;
    };
  })(this);

  this._register_content = (function(_this) {
    return function(S, kind, markup, raw, parsed) {
      var idx, key, registry;
      if (parsed == null) {
        parsed = null;
      }
      registry = S['MACROS']['registry'];
      idx = registry.length;
      key = "" + kind + idx;
      registry.push({
        key: key,
        markup: markup,
        raw: raw,
        parsed: parsed
      });
      return key;
    };
  })(this);

  this._retrieve_entry = (function(_this) {
    return function(S, id) {
      var R;
      if ((R = S['MACROS']['registry'][id]) == null) {
        throw new Error("unknown ID " + (rpr(id)));
      }
      return R;
    };
  })(this);

  this.PATTERNS = {};

  this.html_comment_patterns = [/(^|[^\\])<!--([\s\S]*?)-->/g];

  this.action_patterns = [/(^|[^\\])<<\(([.:](?:\\>|[^>]|>(?!>))*)>>((?:\\<|[^<]|<(?!<))*)<<(\2?)\)>>/g];

  this.region_patterns = [/(^|[^\\])<<\(((?:\\>|[^>]|>(?!>))*)>>((?:\\<|[^<]|<(?!<))*)<<(\2?)\)>>/g];

  this.bracketed_raw_patterns = [/(^|[^\\])<<(<)((?:\\>|[^>]|>{1,2}(?!>))*)>>>/g];

  this.command_and_value_patterns = [/(^|[^\\])<<([!$])((?:\\>|[^>]|>(?!>))*)>>/g];


  /* NB The end command macro looks like any other command except we can detect it with a much simpler
  RegEx; we want to do that so we can, as a first processing step, remove it and any material that appears
  after it, thereby inhibiting any processing of those portions.
   */

  this.end_command_patterns = [/(^|^[\s\S]+[^\\])<<!end>>/];

  this.illegal_patterns = [/(^|[^\\])(<<|>>)([\s\S]{0,10})/g];

  this.escape = (function(_this) {
    return function(S, text) {
      var R, discard_count, ref;
      ref = _this.escape.truncate_text_at_end_command_macro(S, text), R = ref[0], discard_count = ref[1];
      if (discard_count > 0) {
        whisper("detected <<!end>> macro; discarding approx. " + discard_count + " characters");
      }
      R = _this.escape.escape_chrs(S, R);
      R = _this.escape.html_comments(S, R);
      R = _this.escape.bracketed_raw_macros(S, R);
      R = _this.escape.action_macros(S, R);
      R = _this.escape.region_macros(S, R);
      R = _this.escape.command_and_value_macros(S, R);
      return R;
    };
  })(this);

  this.escape.truncate_text_at_end_command_macro = (function(_this) {
    return function(S, text) {
      var R, match;
      if ((match = _this._match_first(_this.end_command_patterns, text)) == null) {
        return [text, 0];
      }
      R = match[1];
      return [R, text.length - R.length];
    };
  })(this);

  this.escape.escape_chrs = (function(_this) {
    return function(S, text) {
      var R;
      R = text;
      R = R.replace(/\x10/g, '\x10A');
      R = R.replace(/\x15/g, '\x10X');
      return R;
    };
  })(this);

  this.escape.unescape_escape_chrs = (function(_this) {
    return function(S, text) {
      var R;
      R = text;
      R = R.replace(/\x10X/g, '\x15');
      R = R.replace(/\x10A/g, '\x10');
      return R;
    };
  })(this);

  this.escape.html_comments = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.html_comment_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, previous_chr, content) {
          var key;
          key = _this._register_content(S, 'comment', null, content, content.trim());
          return previous_chr + "\x15" + key + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.bracketed_raw_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.bracketed_raw_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, previous_chr, markup, content) {
          var id;
          id = _this._register_content(S, 'raw', markup, content);
          return previous_chr + "\x15" + id + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.action_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.action_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, previous_chr, starter, content, stopper) {
          var id, language, mode;
          mode = starter[0];
          mode = mode === '.' ? 'silent' : 'vocal';
          language = starter.slice(1);
          if (language === '') {
            language = 'coffee';
          }

          /* TAINT not using arguments peoperly */
          id = _this._register_content(S, 'action', [mode, language], content);
          return previous_chr + "\x15" + id + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.region_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.region_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, previous_chr, starter, content, stopper) {

          /* TAINT not using arguments peoperly */
          var starter_id, starter_rpr, stopper_id, stopper_rpr;
          starter_rpr = "<<(" + starter + ">>";
          stopper_rpr = "<<" + stopper + ")>>";
          starter_id = _this._register_content(S, 'region', starter, starter_rpr);
          stopper_id = _this._register_content(S, 'region', starter, stopper_rpr);
          return previous_chr + "\x15" + starter_id + "\x13" + content + "\x15" + stopper_id + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.command_and_value_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.command_and_value_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, previous_chr, markup, content) {
          var key, kind, parsed_content;
          kind = markup === '!' ? 'command' : 'value';
          parsed_content = '???';
          key = _this._register_content(S, kind, markup, content, parsed_content);
          return previous_chr + "\x15" + key + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.raw_id_pattern = /\x15raw([0-9]+)\x13/g;

  this.html_comment_id_pattern = /\x15comment([0-9]+)\x13/g;

  this.do_id_pattern = /\x15do([0-9]+)\x13/g;

  this.action_id_pattern = /\x15action([0-9]+)\x13/g;

  this.$expand_html_comments = (function(_this) {
    return function(S) {

      /* TAINT code duplication */
      return $(function(event, send) {

        /* TAINT wrong selector */
        var content, entry, i, id, is_comment, len, meta, name, ref, results, stretch, text, type;
        if (MKTS.select(event, '.', ['text', 'code'])) {
          is_comment = true;
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = text.split(_this.html_comment_id_pattern);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            stretch = ref[i];
            is_comment = !is_comment;
            if (is_comment) {
              id = parseInt(stretch, 10);
              entry = _this._retrieve_entry(S, id);
              content = entry['raw'];
              results.push(send(['.', 'comment', content, MKTS.copy(meta)]));
            } else {
              if (stretch.length !== 0) {
                results.push(send([type, name, stretch, MKTS.copy(meta)]));
              } else {
                results.push(void 0);
              }
            }
          }
          return results;
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$expand_actions = (function(_this) {
    return function(S) {

      /* TAINT code duplication */
      var track;
      track = MKTS.TRACKER.new_tracker('(code)', '{code}');
      return $(function(event, send) {
        var action_name, content, entry, fence, i, id, is_command, left_fence, len, meta, name, ref, results, right_fence, stretch, text, type, within_code;
        within_code = track.within('(code)', '{code}');
        track(event);

        /* TAINT wrong selector */
        if (MKTS.select(event, '.', ['text', 'code', 'comment'])) {
          is_command = true;
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = text.split(_this.action_id_pattern);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            stretch = ref[i];
            is_command = !is_command;
            if (is_command) {
              id = parseInt(stretch, 10);
              entry = _this._retrieve_entry(S, id);
              if (within_code) {
                content = entry['raw'];
                results.push(send(['.', 'text', content, MKTS.copy(meta)]));
              } else {
                content = entry['parsed'];

                /* should never happen: */
                debug('©ΘΔΩΕΥ', rpr(content));
                debug('©ΘΔΩΕΥ', rpr(stretch));
                if (!CND.isa_list(content)) {
                  throw new Error("not registered correctly: " + (rpr(stretch)));
                }
                left_fence = content[0], action_name = content[1], right_fence = content[2];
                fence = left_fence != null ? left_fence : right_fence;
                results.push(send([fence, action_name, null, MKTS.copy(meta)]));
              }
            } else {
              if (stretch.length !== 0) {
                results.push(send([type, name, stretch, MKTS.copy(meta)]));
              } else {
                results.push(void 0);
              }
            }
          }
          return results;
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$expand_raw_spans = (function(_this) {
    return function(S) {

      /* TAINT code duplication */
      return $(function(event, send) {

        /* TAINT wrong selector */
        var content, entry, i, id, is_raw, len, meta, name, ref, results, stretch, text, type;
        if (MKTS.select(event, '.', ['text', 'code', 'comment'])) {
          is_raw = true;
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = text.split(_this.raw_id_pattern);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            stretch = ref[i];
            is_raw = !is_raw;
            if (is_raw) {
              id = parseInt(stretch, 10);
              entry = _this._retrieve_entry(S, id);
              content = entry['raw'];
              results.push(send(['.', 'raw', content, MKTS.copy(meta)]));
            } else {
              results.push(send([type, name, stretch, MKTS.copy(meta)]));
            }
          }
          return results;
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$expand_do_spans = (function(_this) {
    return function(S) {

      /* TAINT code duplication */
      return $(function(event, send) {

        /* TAINT wrong selector */
        var content, entry, i, id, is_do, len, meta, name, ref, results, stretch, text, type;
        if (MKTS.select(event, '.', ['text', 'code', 'comment'])) {
          is_do = true;
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = text.split(_this.do_id_pattern);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            stretch = ref[i];
            is_do = !is_do;
            if (is_do) {
              id = parseInt(stretch, 10);
              entry = _this._retrieve_entry(S, id);
              content = entry['raw'];
              results.push(send(['!', 'do', content, MKTS.copy(meta)]));
            } else {
              results.push(send([type, name, stretch, MKTS.copy(meta)]));
            }
          }
          return results;
        } else {
          return send(event);
        }
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/MACROS.js.map
