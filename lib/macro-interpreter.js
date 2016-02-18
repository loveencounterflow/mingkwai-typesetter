(function() {
  var $, CND, D, MKTS, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper,
    slice = [].slice;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/MACRO-INTERPRETER';

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

  this.$process_actions = (function(_this) {
    return function(S) {

      /* TAINT this is an essentially synchronous solution that will not work for async code */
      var CS, VM, copy, hide, local_filename, macro_output, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      CS = require('coffee-script');
      VM = require('vm');
      local_filename = 'XXXXXXXXXXXXX';
      macro_output = [];
      (function() {
        var name;
        S.compiled = {};
        S.compiled.coffee = {};
        S.sandbox = {
          'rpr': CND.rpr,
          urge: CND.get_logger('urge', local_filename),
          help: CND.get_logger('help', local_filename),
          setImmediate: setImmediate,
          S: S,
          echo: function() {
            var P;
            P = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return macro_output.push(CND.pen.apply(CND, P));
          },
          mkts: {
            signature_reader: function() {
              var P;
              P = 1 <= arguments.length ? slice.call(arguments, 0) : [];
              return P;
            },
            output: macro_output,
            reserved_names: [],
            __filename: local_filename
          }
        };
        S.sandbox['here'] = S.sandbox;
        for (name in S.sandbox) {
          S.sandbox.mkts.reserved_names.push(name);
        }
        return VM.createContext(S.sandbox);
      })();
      return $(function(event, send) {
        var _, action_value, action_value_rpr, error, error1, error2, error_message, js_source, language, line_nr, macro_output_rpr, meta, mode, raw_source, ref, ref1, wrapped_source;
        if (MKTS.MD_READER.select(event, '.', 'action')) {
          _ = event[0], _ = event[1], raw_source = event[2], meta = event[3];
          send(stamp(hide(event)));
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          error_message = null;
          switch (language) {
            case 'js':
              js_source = raw_source;
              break;
            case 'coffee':
              if ((js_source = S.compiled.coffee[raw_source]) == null) {
                wrapped_source = "do =>\n  " + raw_source.replace(/\n/g, "\n  ");
                try {
                  js_source = CS.compile(wrapped_source, {
                    bare: true,
                    filename: local_filename
                  });
                } catch (error1) {
                  error = error1;
                  error_message = (ref = error['message']) != null ? ref : rpr(error);
                }
                if (error_message == null) {
                  S.compiled.coffee[raw_source] = js_source;
                }
              }
              break;
            default:
              error_message = "unknown language " + (rpr(language));
          }
          try {
            action_value = VM.runInContext(js_source, S.sandbox, {
              filename: local_filename
            });
          } catch (error2) {
            error = error2;
            error_message = (ref1 = error['message']) != null ? ref1 : rpr(error);
          }
          if (error_message != null) {
            warn(error_message);

            /* TAINT should preserve stack trace of error */

            /* TAINT use method to assemble warning event */

            /* TAINT write error log with full trace, insert reference (error nr) */
            error_message = "action on line " + line_nr + ": " + error_message;
            return send(['.', 'warning', error_message, copy(meta)]);
          } else {

            /* TAINT join using empty string? spaces? newlines? */
            if (macro_output.length > 0) {
              macro_output_rpr = macro_output.join('');
              macro_output.length = 0;
              send(['.', 'text', macro_output_rpr, copy(meta)]);
            }
            switch (mode) {
              case 'silent':
                return null;
              case 'vocal':

                /* TAINT send `tex` or `text`??? */
                action_value_rpr = CND.isa_text(action_value) ? action_value : rpr(action_value);
                return send(['.', 'text', action_value_rpr, copy(meta)]);
            }
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$process_values = (function(_this) {
    return function(S) {
      var copy, hide, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      return $(function(event, send) {
        var _, action_value, action_value_rpr, error_message, identifier, line_nr, meta;
        if (MKTS.MD_READER.select(event, '$')) {
          _ = event[0], identifier = event[1], _ = event[2], meta = event[3];
          action_value = S.sandbox[identifier];
          if (action_value !== void 0) {
            if (!CND.isa_text(action_value)) {
              action_value_rpr = rpr(action_value);
            }
            return send(['.', 'text', action_value_rpr, copy(meta)]);
          } else {

            /* TAINT should preserve stack trace of error */

            /* TAINT use method to assemble warning event */

            /* TAINT write error log with full trace, insert reference (error nr) */
            line_nr = meta.line_nr;
            error_message = "value on line " + line_nr + ": unknown identifier " + (rpr(identifier));
            return send(['.', 'warning', error_message, copy(meta)]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$process_commands = (function(_this) {
    return function(S) {
      var copy, hide, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      return $(function(event, send) {
        var _, call_signature, error_message, identifier, language, line_nr, meta, mode, parameters, parameters_txt, ref, ref1;
        if (MKTS.MD_READER.select(event, '!')) {
          _ = event[0], call_signature = event[1], _ = event[2], meta = event[3];
          ref = call_signature.match(/^\s*([^\s]*)\s*(.*)$/), _ = ref[0], identifier = ref[1], parameters_txt = ref[2];
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          ref1 = _this._parameters_from_text(S, line_nr, parameters_txt), error_message = ref1[0], parameters = ref1[1];
          if (error_message != null) {
            return send(['.', 'warning', error_message, meta]);
          }
          return send(['!', identifier, parameters, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$process_regions = (function(_this) {
    return function(S) {
      var copy, hide, select, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      select = MKTS.MD_READER.select.bind(MKTS.MD_READER);
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      return $(function(event, send) {

        /* TAINT code duplication */
        var _, call_signature, error_message, extra, identifier, language, line_nr, meta, mode, parameters, parameters_txt, ref, ref1;
        if (select(event, '(')) {
          _ = event[0], call_signature = event[1], extra = event[2], meta = event[3];
          ref = call_signature.match(/^\s*([^\s]*)\s*(.*)$/), _ = ref[0], identifier = ref[1], parameters_txt = ref[2];

          /* Refuse to overwrite 3rd event parameter when already set. This is a makeshift solution that will
          be removed when we implement a simplified and more unified event syntax.
           */
          if (extra != null) {
            if (parameters_txt.length > 0) {
              warn("encountered start region event with parameters and extra");
            }
            return send(event);
          }
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          ref1 = _this._parameters_from_text(S, line_nr, parameters_txt), error_message = ref1[0], parameters = ref1[1];
          if (error_message != null) {
            send(['.', 'warning', error_message, meta]);
          }
          return send(['(', identifier, parameters, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$consolidate_regions = (function(_this) {
    return function(S) {
      var copy, hide, select, stamp, tag_stack;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      select = MKTS.MD_READER.select.bind(MKTS.MD_READER);
      tag_stack = [];
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      return $(function(event, send) {

        /* TAINT code duplication */
        var _, call_signature, error_message, expected, extra, identifier, language, line_nr, message, meta, mode, parameters, parameters_txt, ref, ref1;
        debug('©18567', event);
        if (select(event, '(')) {
          _ = event[0], call_signature = event[1], extra = event[2], meta = event[3];
          ref = call_signature.match(/^\s*([^\s]*)\s*(.*)$/), _ = ref[0], identifier = ref[1], parameters_txt = ref[2];

          /* Refuse to overwrite 3rd event parameter when already set. This is a makeshift solution that will
          be removed when we implement a simplified and more unified event syntax.
           */
          if (extra != null) {
            if (parameters_txt.length > 0) {
              warn("encountered start region event with parameters and extra");
            }
            return send(event);
          }
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          ref1 = _this._parameters_from_text(S, line_nr, parameters_txt), error_message = ref1[0], parameters = ref1[1];
          if (error_message != null) {
            send(['.', 'warning', error_message, meta]);
          }
          send(['(', identifier, parameters, meta]);
          return tag_stack.push(identifier);
        } else if (select(event, ')')) {
          _ = event[0], identifier = event[1], extra = event[2], meta = event[3];
          if (tag_stack.length < 1) {
            warn('34-1', ['.', 'warning', "too many closing regions", copy(meta)]);
            return send(['.', 'warning', "too many closing regions", copy(meta)]);
          }
          expected = tag_stack.pop();
          if ((identifier.length > 0) && (expected !== identifier)) {
            message = "expected closing region " + (rpr(expected)) + ", got " + (rpr(identifier));
            warn('34-2', ['.', 'warning', message, copy(meta)]);
            send(['.', 'warning', message, copy(meta)]);
            if (identifier === 'document') {
              send(event);
            }
          }
          identifier = expected;
          send([')', identifier, extra, copy(meta)]);
          return urge('443', [')', identifier, extra, copy(meta)]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$process_code_blocks = (function(_this) {
    return function(S) {
      var copy, hide, select, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      select = MKTS.MD_READER.select.bind(MKTS.MD_READER);
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      return $(function(event, send) {

        /* TAINT code duplication */
        var _, call_signature, error_message, identifier, line_nr, meta, parameters, parameters_txt, ref, ref1, type;
        if (select(event, ['(', ')'], 'code')) {
          type = event[0], _ = event[1], call_signature = event[2], meta = event[3];
          line_nr = meta.line_nr;
          ref = call_signature.match(/^\s*([^\s]*)\s*(.*)$/), _ = ref[0], identifier = ref[1], parameters_txt = ref[2];
          ref1 = _this._parameters_from_text(S, line_nr, parameters_txt), error_message = ref1[0], parameters = ref1[1];
          parameters.unshift(identifier);
          if (error_message != null) {
            send(['.', 'warning', error_message, meta]);
          }
          return send([type, 'code', parameters, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this._parameters_from_text = (function(_this) {
    return function(S, line_nr, text) {
      var CS, R, VM, error, error1, error2, error_message, js_source, ref, ref1, source;
      if (/^\s*$/.test(text)) {
        return [null, []];
      }

      /* TAINT replicates some code from MACRO_INTERPRETER.process_actions */

      /* TAINT move to CND? COFFEESCRIPT? */
      CS = require('coffee-script');
      VM = require('vm');
      source = "@mkts.signature_reader " + text;
      error_message = null;
      if (S.sandbox == null) {
        throw new Error("internal error: need S.sandbox, must use `$process_actions`");
      }
      try {
        js_source = CS.compile(source, {
          bare: true,
          filename: 'parameter resolution'
        });
      } catch (error1) {
        error = error1;
        error_message = (ref = error['message']) != null ? ref : rpr(error);
      }
      if (error_message == null) {
        try {
          R = VM.runInContext(js_source, S.sandbox, {
            filename: 'parameter resolution'
          });
        } catch (error2) {
          error = error2;
          error_message = (ref1 = error['message']) != null ? ref1 : rpr(error);
        }
      }
      if (error_message != null) {
        warn(error_message);

        /* TAINT should preserve stack trace of error */

        /* TAINT use method to assemble warning event */

        /* TAINT write error log with full trace, insert reference (error nr) */
        return ["action on line " + line_nr + ": " + error_message, null];
      }
      return [null, R];
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/macro-interpreter.js.map
