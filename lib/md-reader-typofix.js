(function() {
  var CND, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/MD-READER/TYPOFIX';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  this.replacements = {
    'copyright': [/\(c\)/gi, '©'],
    'ellipsis': [/(^|[^.])[.]{3}($|[^.])/gi, '$1…$2']
  };

  this.rewrite = function(S, text) {
    var R, i, len, matcher, matchers, name, ref, ref1, replacement;
    R = text;
    ref = this.replacements;
    for (name in ref) {
      ref1 = ref[name], matchers = ref1[0], replacement = ref1[1];
      if (!CND.isa_list(matchers)) {
        matchers = [matchers];
      }
      for (i = 0, len = matchers.length; i < len; i++) {
        matcher = matchers[i];
        R = R.replace(matcher, replacement);
      }
    }
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/md-reader-typofix.js.map
