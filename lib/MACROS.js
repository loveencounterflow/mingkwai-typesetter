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

  this.action_patterns = [/(^|[^\\])<<\(([.:])((?:\\>|[^>]|>(?!>))*)>>()<<((?:\2\3)?)\)>>/g, /(^|[^\\])<<\(([.:])((?:\\>|[^>]|>(?!>))*)>>((?:\\<|[^<]|<(?!<))*[^\\])<<((?:\2\3)?)\)>>/g];

  this.region_patterns = [/(^|[^\\])<<(\()((?:\\>|[^>]|>(?!>))*)()>>/g, /(^|[^\\])<<()(|[^.:\\](?:\\>|[^>]|>(?!>))*)(\))>>/g];

  this.bracketed_raw_patterns = [/(^|[^\\])<<(<)((?:\\>|[^>]|>{1,2}(?!>))*)>>>/g];

  this.command_and_value_patterns = [/(^|[^\\])<<([!$])((?:\\>|[^>]|>(?!>))*)>>/g];


  /* NB The end command macro looks like any other command except we can detect it with a much simpler
  RegEx; we want to do that so we can, as a first processing step, remove it and any material that appears
  after it, thereby inhibiting any processing of those portions.
   */

  this.end_command_patterns = [/(^|^[\s\S]+?[^\\])<<!end>>/];

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
        R = R.replace(pattern, function(_, previous_chr, markup, identifier, content, stopper) {
          var id, language, mode;
          mode = markup === '.' ? 'silent' : 'vocal';
          language = identifier;
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
        R = R.replace(pattern, function(_, previous_chr, start_markup, identifier, stop_markup) {
          var id, markup;
          markup = start_markup.length === 0 ? stop_markup : start_markup;
          id = _this._register_content(S, 'region', markup, identifier);
          return previous_chr + "\x15" + id + "\x13";
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
          var key, kind;
          kind = markup === '!' ? 'command' : 'value';
          key = _this._register_content(S, kind, markup, content, null);
          return previous_chr + "\x15" + key + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.raw_id_pattern = /\x15raw([0-9]+)\x13/g;

  this.html_comment_id_pattern = /\x15comment([0-9]+)\x13/g;

  this.action_id_pattern = /\x15action([0-9]+)\x13/g;

  this.region_id_pattern = /\x15region([0-9]+)\x13/g;

  this.command_and_value_id_pattern = /\x15(?:command|value)([0-9]+)\x13/g;

  this.$expand = function(S) {
    return this.$expand.create_macro_expansion_tee(S);
  };

  this.$expand.create_macro_expansion_tee = (function(_this) {
    return function(S) {
      var readstream, settings, writestream;
      readstream = D.create_throughstream();
      writestream = D.create_throughstream();
      readstream.pipe(_this.$expand_command_and_value_macros(S)).pipe(_this.$expand_region_macros(S)).pipe(_this.$expand_action_macros(S)).pipe(_this.$expand_raw_macros(S)).pipe(_this.$expand_html_comments(S)).pipe(_this.$expand_escape_chrs(S)).pipe(writestream);
      settings = {
        S: S
      };
      return D.TEE.from_readwritestreams(readstream, writestream, settings);
    };
  })(this);

  this.$expand_html_comments = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.html_comment_id_pattern, function(meta, entry) {
        var content;
        content = entry['raw'];
        return ['.', 'comment', content, MKTS.copy(meta)];
      });
    };
  })(this);

  this.$expand_raw_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.raw_id_pattern, function(meta, entry) {
        var content;
        content = entry['raw'];
        return ['.', 'raw', content, MKTS.copy(meta)];
      });
    };
  })(this);

  this.$expand_action_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.action_id_pattern, function(meta, entry) {
        var content, language, mode, ref;
        ref = entry['markup'], mode = ref[0], language = ref[1];
        content = entry['raw'];
        return [
          '.', 'action', content, MKTS.copy(meta, {
            mode: mode,
            language: language
          })
        ];
      });
    };
  })(this);

  this.$expand_region_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.region_id_pattern, function(meta, entry) {
        var markup, raw;
        raw = entry.raw, markup = entry.markup;
        return [markup, raw, null, MKTS.copy(meta)];
      });
    };
  })(this);

  this.$expand_command_and_value_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.command_and_value_id_pattern, function(meta, entry) {
        var macro_type, markup, raw;
        raw = entry.raw, markup = entry.markup;
        macro_type = markup === '!' ? 'command' : 'value';
        return ['.', macro_type, raw, MKTS.copy(meta)];
      });
    };
  })(this);

  this.$expand_escape_chrs = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (MKTS.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          return send([type, name, _this.escape.unescape_escape_chrs(S, text), meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this._get_expander = (function(_this) {
    return function(S, pattern, method) {
      return $(function(event, send) {
        var entry, i, id, is_plain, len, meta, name, ref, results, stretch, text, type;
        if (MKTS.select(event, '.', 'text')) {
          is_plain = false;
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = text.split(pattern);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            stretch = ref[i];
            is_plain = !is_plain;
            if (!is_plain) {
              id = parseInt(stretch, 10);
              entry = _this._retrieve_entry(S, id);
              results.push(send(method(meta, entry)));
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

}).call(this);

//# sourceMappingURL=../sourcemaps/MACROS.js.map
