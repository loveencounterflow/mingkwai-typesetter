(function() {
  var CHR, CND, alert, badge, debug, echo, help, info, log, rpr, settings, warn, whisper;

  CHR = require('coffeenode-chr');

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'XNCR_CHR';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  whisper = CND.get_logger('whisper', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);


  /* TAINT there should be a unified way to obtain copies of libraries with certain settings that
    differ from that library's default options. Interface could maybe sth like this:
    ```
    settings              = _.deep_copy CHR.options
    settings[ 'input' ]   = 'xncr'
    XNCR_CHR              = OPTIONS.new_library CHR, settings
    ```
   */


  /* TAINT additional settings silently ignored */

  settings = {
    input: 'xncr'
  };

  this.analyze = function(glyph) {
    return CHR.analyze(glyph, settings);
  };

  this.as_csg = function(glyph) {
    return CHR.as_csg(glyph, settings);
  };

  this.as_chr = function(glyph) {
    return CHR.as_chr(glyph, settings);
  };

  this.as_uchr = function(glyph) {
    return CHR.as_uchr(glyph, settings);
  };

  this.as_cid = function(glyph) {
    return CHR.as_cid(glyph, settings);
  };

  this.as_rsg = function(glyph) {
    return CHR.as_rsg(glyph, settings);
  };

  this.as_sfncr = function(glyph) {
    return CHR.as_sfncr(glyph, settings);
  };

  this.as_fncr = function(glyph) {
    return CHR.as_fncr(glyph, settings);
  };

  this.chrs_from_text = function(text) {
    return CHR.chrs_from_text(text, settings);
  };

  this.is_inner_glyph = function(glyph) {
    var ref;
    return (ref = this.as_csg(glyph)) === 'u' || ref === 'jzr';
  };

  this.chr_from_cid_and_csg = function(cid, csg) {
    return CHR.as_chr(cid, {
      csg: csg
    });
  };

  this.cid_range_from_rsg = function(rsg) {
    return CHR.cid_range_from_rsg(rsg);
  };

  this.normalize = function(glyph) {
    var cid, csg, rsg;
    rsg = this.as_rsg(glyph);
    cid = this.as_cid(glyph);
    csg = rsg === 'u-pua' ? 'jzr' : 'u';
    return this.chr_from_cid_and_csg(cid, csg);
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/XNCHR.js.map
