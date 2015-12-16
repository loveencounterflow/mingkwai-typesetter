(function() {
  var $, CND, D, MKTS, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper,
    slice = [].slice;

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
          echo: function() {
            var P;
            P = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return macro_output.push(CND.pen.apply(CND, P));
          },
          mkts: {
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
        if (MKTS.MD_READER.select(event, '.', 'value')) {
          _ = event[0], _ = event[1], identifier = event[2], meta = event[3];
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

}).call(this);

//# sourceMappingURL=../sourcemaps/macro-interpreter.js.map
