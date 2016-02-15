(function() {
  var $, CND, D, MKTS, alert, badge, debug, echo, help, info, log, njs_fs, rpr, urge, warn, whisper;

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/MACRO-ESCAPER';

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

  MKTS = require('./main');

  this.cloak = (require('./cloak'))["new"]();

  this.initialize_state = (function(_this) {
    return function(state) {
      state['MACRO_ESCAPER'] = {
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
      registry = S['MACRO_ESCAPER']['registry'];
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
      if ((R = S['MACRO_ESCAPER']['registry'][id]) == null) {
        throw new Error("unknown ID " + (rpr(id)));
      }
      return R;
    };
  })(this);

  this.PATTERNS = {};

  this.html_comment_patterns = [/<!--([\s\S]*?)-->/g];

  this.action_patterns = [/<<\(([.:])((?:[^>]|>(?!>))*)>>()<<((?:\1\2)?)\)>>/g, /<<\(([.:])((?:[^>]|>(?!>))*)>>((?:[^<]|<(?!<))*)<<((?:\1\2)?)\)>>/g];

  this.region_patterns = [/<<(\()((?:[^>]|>(?!>))*)()>>/g, /<<()(|[^.:](?:[^>]|>(?!>))*)(\))>>/g];

  this.bracketed_raw_patterns = [/<<(<)((?:[^>]|>{1,2}(?!>))*)>>>/g];

  this.comma_patterns = [/<<,>>/g];

  this.command_and_value_patterns = [/<<([!$])((?:[^>]|>(?!>))*)>>/g];

  this.insert_command_patterns = [/<<([!$])insert(?=[\s>])((?:[^>]|>(?!>))*)>>/g];


  /* NB The end command macro looks like any other command except we can detect it with a much simpler
  RegEx; we want to do that so we can, as a first processing step, remove it and any material that appears
  after it, thereby inhibiting any processing of those portions.
   */

  this.end_command_patterns = [/(^|^[\s\S]+?[^\\])<<!end>>/];

  this.illegal_patterns = [/(<<|>>)/g];

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
      R = _this.escape.insert_macros(S, R);
      R = _this.escape.action_macros(S, R);
      R = _this.escape.region_macros(S, R);
      R = _this.escape.comma_macros(S, R);
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
      return _this.cloak.backslashed.hide(_this.cloak.hide(text));
    };
  })(this);

  this.escape.unescape_escape_chrs = (function(_this) {
    return function(S, text) {
      return _this.cloak.reveal(_this.cloak.backslashed.reveal(text));
    };
  })(this);

  this.escape.remove_escaping_backslashes = (function(_this) {
    return function(S, text) {
      return _this.cloak.backslashed.remove(text);
    };
  })(this);

  this.escape.sensitive_ws = (function(_this) {
    return function(S, text) {

      /* Fixes an annoying parsing problem with Markdown-it where the leading whitespace in
      ```
      <<(keep-lines>>
      　　　　　　　|𠦝韦　　　　　　韩
      ```
      is kept but deleted when the first line is blank, as in
      ```
      <<(keep-lines>>
      
      　　　　　　　|𠦝韦　　　　　　韩
      ```
       */
      var R, pattern;
      pattern = /(<<\(keep-lines>>)(\s*)/g;
      R = text;
      R = R.replace(pattern, function(_, anchor, sws) {
        var id;
        id = _this._register_content(S, 'sws', sws, sws);
        return anchor + "\x15" + id + "\x13";
      });
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
        R = R.replace(pattern, function(_, content) {
          var key;
          key = _this._register_content(S, 'comment', null, content, content.trim());
          return "\x15" + key + "\x13";
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
        R = R.replace(pattern, function(_, markup, content) {
          var id;
          id = _this._register_content(S, 'raw', markup, content);
          return "\x15" + id + "\x13";
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
        R = R.replace(pattern, function(_, markup, identifier, content, stopper) {
          var id, language, mode;
          mode = markup === '.' ? 'silent' : 'vocal';
          language = identifier;
          if (language === '') {
            language = 'coffee';
          }

          /* TAINT not using arguments peoperly */
          id = _this._register_content(S, 'action', [mode, language], content);
          return "\x15" + id + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.insert_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.insert_command_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_, markup, parameter_txt) {
          var content, error, error1, error_message, ref1, result, route;
          ref1 = MKTS.MACRO_INTERPRETER._parameters_from_text(S, 0, parameter_txt), error_message = ref1[0], result = ref1[1];

          /* TAINT need current context to resolve file route */

          /* TAINT how to return proper error message? */

          /* TAINT what kind of error handling is this? */
          if (result != null) {
            route = result[0];
            if (route != null) {
              try {
                content = njs_fs.readFileSync(route, {
                  encoding: 'utf-8'
                });
              } catch (error1) {
                error = error1;
                error_message = (error_message != null ? error_message : '') + "\n" + error['message'];
              }
            } else {
              error_message = (error_message != null ? error_message : '') + "\nneed file route for insert macro";
            }
          }
          if (error_message != null) {
            return " XXXXXXXX " + error_message + " XXXXXXXX ";
          }
          return content;
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
        R = R.replace(pattern, function(_, start_markup, identifier, stop_markup) {
          var id, markup;
          markup = start_markup.length === 0 ? stop_markup : start_markup;
          id = _this._register_content(S, 'region', markup, identifier);
          if (identifier === 'keep-lines') {
            if (start_markup === '(') {
              return "\x15" + id + "\x13\n```keep-lines";
            } else {
              return "```\n\x15" + id + "\x13";
            }
          }
          return "\x15" + id + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.escape.comma_macros = (function(_this) {
    return function(S, text) {
      var R, i, len, pattern, ref;
      R = text;
      ref = _this.comma_patterns;
      for (i = 0, len = ref.length; i < len; i++) {
        pattern = ref[i];
        R = R.replace(pattern, function(_) {
          var id;
          id = _this._register_content(S, 'comma', null, null);
          return "\x15" + id + "\x13";
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
        R = R.replace(pattern, function(_, markup, content) {
          var key, kind;
          kind = markup === '!' ? 'command' : 'value';
          key = _this._register_content(S, kind, markup, content, null);
          return "\x15" + key + "\x13";
        });
      }
      return R;
    };
  })(this);

  this.raw_id_pattern = /\x15raw([0-9]+)\x13/g;

  this.html_comment_id_pattern = /\x15comment([0-9]+)\x13/g;

  this.action_id_pattern = /\x15action([0-9]+)\x13/g;

  this.region_id_pattern = /\x15region([0-9]+)\x13/g;

  this.comma_id_pattern = /\x15comma([0-9]+)\x13/g;

  this.sws_id_pattern = /\x15sws([0-9]+)\x13/g;

  this.command_and_value_id_pattern = /\x15(?:command|value)([0-9]+)\x13/g;

  this.$expand = function(S) {
    var pipeline, settings;
    pipeline = [this.$expand.$command_and_value_macros(S), this.$expand.$comma_macros(S), this.$expand.$region_macros(S), this.$expand.$action_macros(S), this.$expand.$raw_macros(S), this.$expand.$sensitive_ws(S), this.$expand.$html_comments(S), this.$expand.$escape_chrs(S)];
    settings = {
      S: S
    };
    return D.TEE.from_pipeline(pipeline, settings);
  };

  this.$expand.$html_comments = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.html_comment_id_pattern, function(meta, entry) {
        var content;
        content = entry['raw'];
        return ['.', 'comment', content, MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$raw_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.raw_id_pattern, function(meta, entry) {
        var content;
        content = entry['raw'];
        return ['.', 'raw', content, MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$action_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.action_id_pattern, function(meta, entry) {
        var content, language, mode, ref;
        ref = entry['markup'], mode = ref[0], language = ref[1];
        content = entry['raw'];
        return [
          '.', 'action', content, MKTS.MD_READER.copy(meta, {
            mode: mode,
            language: language
          })
        ];
      });
    };
  })(this);

  this.$expand.$comma_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.comma_id_pattern, function(meta, entry) {
        return ['.', 'comma', null, MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$sensitive_ws = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.sws_id_pattern, function(meta, entry) {
        return ['.', 'text', entry['raw'], MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$region_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.region_id_pattern, function(meta, entry) {
        var markup, raw;
        raw = entry.raw, markup = entry.markup;
        return [markup, raw, null, MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$command_and_value_macros = (function(_this) {
    return function(S) {
      return _this._get_expander(S, _this.command_and_value_id_pattern, function(meta, entry) {
        var markup, raw;
        raw = entry.raw, markup = entry.markup;
        return [markup, raw, null, MKTS.MD_READER.copy(meta)];
      });
    };
  })(this);

  this.$expand.$escape_chrs = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (MKTS.MD_READER.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          return send([type, name, _this.escape.unescape_escape_chrs(S, text), meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$expand.$remove_backslashes = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (MKTS.MD_READER.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          return send([type, name, _this.escape.remove_escaping_backslashes(S, text), meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$expand.$escape_illegals = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var error_message, i, idx, is_plain, j, len, len1, line_nr, meta, name, pattern, raw_stretch, ref, ref1, results, stretch, stretches, text, type;
        if (MKTS.MD_READER.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          ref = _this.illegal_patterns;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            pattern = ref[i];
            stretches = [];
            ref1 = text.split(pattern);
            for (idx = j = 0, len1 = ref1.length; j < len1; idx = ++j) {
              raw_stretch = ref1[idx];
              if ((idx % 3) === 1) {
                stretches[stretches.length - 1] += raw_stretch;
              } else {
                stretches.push(raw_stretch);
              }
            }
            is_plain = true;
            results.push((function() {
              var k, len2, results1;
              results1 = [];
              for (k = 0, len2 = stretches.length; k < len2; k++) {
                stretch = stretches[k];
                is_plain = !is_plain;
                debug('©10012', (is_plain ? CND.green : CND.red)(rpr(stretch)));
                if (!is_plain) {
                  line_nr = meta.line_nr;
                  error_message = "illegal macro pattern on line " + line_nr + ": " + (rpr(stretch));
                  results1.push(send(['.', 'warning', error_message, MKTS.MD_READER.copy(meta)]));
                } else {
                  if (stretch.length !== 0) {
                    results1.push(send([type, name, stretch, MKTS.MD_READER.copy(meta)]));
                  } else {
                    results1.push(void 0);
                  }
                }
              }
              return results1;
            })());
          }
          return results;
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
        if (MKTS.MD_READER.select(event, '.', 'text')) {
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
                results.push(send([type, name, stretch, MKTS.MD_READER.copy(meta)]));
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

//# sourceMappingURL=../sourcemaps/macro-escaper.js.map
