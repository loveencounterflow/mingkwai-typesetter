(function() {
  var $, CND, D, HOTMETAL, badge, rpr;

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'MKTS/HYPHENATOR';

  HOTMETAL = require('..');

  D = require('pipedreams');

  $ = D.remit.bind(D);

  this.new_hyphenate = function(hyphenation, min_length) {
    var HYPHER, Hypher;
    if (hyphenation == null) {
      hyphenation = null;
    }
    if (min_length == null) {
      min_length = 2;
    }

    /* https://github.com/bramstein/hypher */
    Hypher = require('hypher');
    if (hyphenation == null) {
      hyphenation = require('hyphenation.en-us');
    }
    HYPHER = new Hypher(hyphenation);
    return HYPHER.hyphenateText.bind(HYPHER);
  };

  this.$hyphenate = function(hyphenation, min_length) {
    var hyphenate;
    if (hyphenation == null) {
      hyphenation = null;
    }
    if (min_length == null) {
      min_length = 4;
    }
    hyphenate = this.new_hyphenate(hyphenation, min_length);
    return $((function(_this) {
      return function(text, send) {
        return send(hyphenate(text, min_length));
      };
    })(this));
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/hyphenator.js.map
