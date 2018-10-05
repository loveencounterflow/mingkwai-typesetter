// Generated by CoffeeScript 2.3.2
(function() {
  //###########################################################################################################
  var CND, YADDA, badge, caches, debug, lorem_settings, rpr;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/YADDA';

  debug = CND.get_logger('debug', badge);

  //...........................................................................................................
  caches = {};

  //...........................................................................................................
  lorem_settings = {
    la: {
      count: 1, // Number of words, sentences, or paragraphs to generate.
      // units:                'sentences'             # Generate words, sentences, or paragraphs.
      units: 'paragraphs', // Generate words, sentences, or paragraphs.
      sentenceLowerBound: 5, // Minimum words per sentence.
      sentenceUpperBound: 15, // Maximum words per sentence.
      paragraphLowerBound: 3, // Minimum sentences per paragraph.
      paragraphUpperBound: 7, // Maximum sentences per paragraph.
      format: 'plain', // Plain text or html
      // words:                ['ad', 'dolor', ... ]   # Custom word dictionary. Uses dictionary.words (in lib/dictionary.js) by default.
      random: CND.get_rnd(42, 3), // A PRNG function. Uses Math.random by default
      suffix: '\n' // The character to insert between paragraphs. Defaults to default EOL for your OS.
    },
    ja: {
      count: 1, // Number of words, sentences, or paragraphs to generate.
      // units:                'sentences'             # Generate words, sentences, or paragraphs.
      units: 'paragraphs', // Generate words, sentences, or paragraphs.
      sentenceLowerBound: 5, // Minimum words per sentence.
      sentenceUpperBound: 15, // Maximum words per sentence.
      paragraphLowerBound: 3, // Minimum sentences per paragraph.
      paragraphUpperBound: 7, // Maximum sentences per paragraph.
      format: 'plain', // Plain text or html
      // words:                ['ad', 'dolor', ... ]   # Custom word dictionary. Uses dictionary.words (in lib/dictionary.js) by default.
      random: CND.get_rnd(42, 3), // A PRNG function. Uses Math.random by default
      suffix: '\n' // The character to insert between paragraphs. Defaults to default EOL for your OS.
    },
    zh: '20c'
  };

  //-----------------------------------------------------------------------------------------------------------
  this.generate_zh = function() {
    var chinesegen;
    chinesegen = require('chinesegen');
    return (chinesegen({
      count: 50,
      freq: true
    })).text.replace(/[？！]/g, '。');
  };

  //-----------------------------------------------------------------------------------------------------------
  this.generators = {
    la: require('lorem-ipsum'),
    ja: require('lorem-ipsum-japanese'),
    zh: this.generate_zh.bind(this)
  };

  //-----------------------------------------------------------------------------------------------------------
  this.generate = function(Q) {
    var cache, name;
    if (Q.lang == null) {
      Q.lang = 'la';
    }
    cache = caches[name = Q.lang] != null ? caches[name] : caches[name] = [];
    if (Q.nr == null) {
      Q.nr = cache.length + 1;
    }
    while (cache.length < Q.nr) {
      cache.push(this.generators[Q.lang](lorem_settings[Q.lang]));
    }
    return cache[Q.nr - 1];
  };

  //###########################################################################################################
  if (module.parent == null) {
    YADDA = this;
    debug('la', YADDA.generate({
      lang: 'la'
    }));
    debug('ja', YADDA.generate({
      lang: 'ja',
      nr: 1
    }));
    debug('zh', YADDA.generate({
      lang: 'zh',
      nr: 1
    }));
  }

}).call(this);

//# sourceMappingURL=yadda.js.map