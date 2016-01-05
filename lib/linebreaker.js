(function() {
  var CND, HOTMETAL, badge, rpr;

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'MKTS/LINEBREAKER';

  HOTMETAL = require('..');

  this.fragmentize = function(text, settings) {
    var R, breakpoint, chrs, extended, i, incremental, last_position, len, line_breaker, matcher, part, position, ref, ref1, ref2, ref3, ref4, required, shred, shreds, subpart, whitespace;
    text = text.replace(/\n/g, ' ');
    last_position = null;
    incremental = (ref = settings != null ? settings['incremental'] : void 0) != null ? ref : true;
    chrs = (ref1 = settings != null ? settings['chrs'] : void 0) != null ? ref1 : false;
    extended = (ref2 = settings != null ? settings['extended'] : void 0) != null ? ref2 : false;
    if (extended) {
      throw new Error("setting `extended` not supported");
    }
    whitespace = (ref3 = settings != null ? settings['whitespace'] : void 0) != null ? ref3 : false;
    matcher = whitespace ? /(\s+)/ : null;
    if (chrs) {
      shreds = text.split(/((?:[\ud800-\udbff][\udc00-\udfff])|.)/);
      R = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = shreds.length; i < len; i++) {
          shred = shreds[i];
          if (shred !== '') {
            results.push(shred);
          }
        }
        return results;
      })();
    } else {
      line_breaker = new (require('linebreak'))(text);
      R = [];
      while (breakpoint = line_breaker.nextBreak()) {
        position = breakpoint.position, required = breakpoint.required;
        if (incremental && (last_position != null)) {
          part = text.slice(last_position, breakpoint.position);
        } else {
          part = text.slice(0, breakpoint.position);
        }
        last_position = position;
        if (whitespace) {
          ref4 = part.split(matcher);
          for (i = 0, len = ref4.length; i < len; i++) {
            subpart = ref4[i];
            if (subpart.length > 0) {
              R.push(subpart);
            }
          }
        } else {
          R.push(part);
        }
      }
    }
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/linebreaker.js.map
