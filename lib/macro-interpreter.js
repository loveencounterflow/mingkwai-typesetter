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

  MKTS = require('./main');

  this.$process_actions = (function(_this) {
    return function(S) {
      var CS, VM, copy, hide, local_filename, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      CS = require('coffee-script');
      VM = require('vm');
      local_filename = 'XXXXXXXXXXXXX';
      (function() {
        var name, sandbox;
        sandbox = {
          'rpr': CND.rpr,
          urge: CND.get_logger('urge', local_filename),
          help: CND.get_logger('help', local_filename),
          mkts: {
            reserved_names: [],
            __filename: local_filename
          }
        };
        for (name in sandbox) {
          sandbox.mkts.reserved_names.push(name);
        }
        VM.createContext(sandbox);
        return S.sandbox = sandbox;
      })();
      return $(function(event, send) {
        var action, error, error1, error2, error_message, js_source, language, line_nr, meta, mode, source, type, value, value_rpr, warning_message;
        if (MKTS.MD_READER.select(event, '.', 'action')) {
          type = event[0], action = event[1], source = event[2], meta = event[3];
          send(stamp(hide(event)));
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          error_message = null;
          switch (language) {
            case 'js':
              js_source = source;
              break;
            case 'coffee':
              try {
                js_source = CS.compile(source, {
                  bare: true,
                  filename: local_filename
                });
              } catch (error1) {
                error = error1;
                error_message = error['message'];
              }
              break;
            default:
              error_message = "unknown language " + (rpr(language));
          }
          try {
            value = VM.runInContext(js_source, S.sandbox, {
              filename: local_filename
            });
          } catch (error2) {
            error = error2;
            error_message = error['message'];
          }
          if (error_message != null) {
            warn(error_message);

            /* TAINT should resend because error message might need escaping */

            /* TAINT should preserve stack trace of error */

            /* TAINT use method to assemble warning event */

            /* TAINT insert reference to error log */
            warning_message = "action on line " + line_nr + ": " + error_message;
            return send(['.', 'warning', warning_message, copy(meta)]);
          } else {
            debug('©Y action: source:    ', rpr(source));
            debug('©Y action: js_source: ', rpr(js_source));
            debug('©Y action: language:  ', rpr(language));
            debug('©Y action: mode:      ', rpr(mode));
            debug('©Y action: S.sandbox: ', rpr(S.sandbox));
            debug('©Y action: value:     ', rpr(value));
            switch (mode) {
              case 'silent':
                return null;
              case 'vocal':

                /* TAINT send `tex` or `text`??? */
                value_rpr = CND.isa_text(value) ? value : rpr(value);
                return send(['.', 'text', value_rpr, copy(meta)]);
            }
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/macro-interpreter.js.map
