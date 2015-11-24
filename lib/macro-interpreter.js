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
      var CS, VM, copy, hide, local_filename, sandbox, stamp;
      copy = MKTS.MD_READER.copy.bind(MKTS.MD_READER);
      stamp = MKTS.MD_READER.stamp.bind(MKTS.MD_READER);
      hide = MKTS.MD_READER.hide.bind(MKTS.MD_READER);
      CS = require('coffee-script');
      VM = require('vm');
      local_filename = 'XXXXXXXXXXXXX';
      S.local = {
        definitions: new Map()
      };
      sandbox = {
        urge: CND.get_logger('urge', local_filename),
        help: CND.get_logger('help', local_filename),
        __filename: local_filename,
        define: function(pod) {
          var key, results, value;
          results = [];
          for (key in pod) {
            value = pod[key];
            results.push(S.local.definitions.set(key, value));
          }
          return results;
        }
      };
      VM.createContext(sandbox);
      return $(function(event, send) {
        var action, js_source, language, line_nr, meta, mode, source, type, value, value_rpr;
        if (MKTS.MD_READER.select(event, '.', 'action')) {
          send(stamp(hide(event)));
          type = event[0], action = event[1], source = event[2], meta = event[3];
          mode = meta.mode, language = meta.language, line_nr = meta.line_nr;
          switch (language) {
            case 'js':
              js_source = source;
              break;
            case 'coffee':
              js_source = CS.compile(source, {
                bare: true,
                filename: local_filename
              });
              break;
            default:
              return send.error(new Error("unknown language " + (rpr(language)) + " in action on line #" + line_nr));
          }
          value = VM.runInContext(js_source, sandbox, {
            filename: local_filename
          });
          urge('4742', js_source);
          urge('4742', rpr(value));
          debug('©YMF7F', sandbox);
          debug('©YMF7F', S.local.definitions);
          switch (mode) {
            case 'silent':
              return null;
            case 'vocal':

              /* TAINT must resend to allow for TeX-escaping (or MD-escaping?) */

              /* TAINT send `tex` or `text`??? */
              value_rpr = CND.isa_text(value) ? value : rpr(value);
              return send(['.', 'text', value_rpr, copy(meta)]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/macro-interpreter.js.map
