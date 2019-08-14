(function() {
  //###########################################################################################################
  // njs_path                  = require 'path'
  // njs_fs                    = require 'fs'
  //...........................................................................................................
  var CND, MKNCR, NUCW, alert, badge, debug, echo, get_cid, help, info, jr, log, rpr, urge, warn, whisper,
    indexOf = [].indexOf;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'mkts/collect-glyph-descriptions';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  MKNCR = require('../../../../mingkwai-ncr');

  NUCW = require('../../../../ncr-unicode-cache-writer');

  jr = JSON.stringify;

  get_cid = function(x) {
    return x.codePointAt(0);
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.main = function() {
    var cid, cid_range, cid_ranges, description, first_cid, fncr, glyph, has_tex, i, is_cjk, is_ideograph, j, last_cid, len, ref, ref1, ref2, ref3, rsg, tag, tex, tex_block, tex_cp, uchr;
    NUCW.read_intervals((error, intervals) => {
      if (error != null) {
        return handler(error);
      }
      return debug('µ44322', intervals);
    });
    return;
    // [ 0x0000, 0x4e10, ]
    cid_ranges = [[0x4da0, 0x4e10], [get_cid('🉠'), get_cid('🉥')], [get_cid('。'), get_cid('。')]];
    for (i = 0, len = cid_ranges.length; i < len; i++) {
      cid_range = cid_ranges[i];
      [first_cid, last_cid] = cid_range;
      for (cid = j = ref = first_cid, ref1 = last_cid; (ref <= ref1 ? j <= ref1 : j >= ref1); cid = ref <= ref1 ? ++j : --j) {
        glyph = String.fromCodePoint(cid);
        description = MKNCR.describe(glyph);
        ({uchr, fncr, rsg, tag, tex} = description);
        is_cjk = indexOf.call(tag, 'cjk') >= 0;
        is_ideograph = is_cjk && indexOf.call(tag, 'ideograph') >= 0;
        tex_block = (ref2 = tex != null ? tex.block : void 0) != null ? ref2 : null;
        tex_cp = (ref3 = tex != null ? tex.codepoint : void 0) != null ? ref3 : null;
        has_tex = (tex_block != null) && tex_block !== '\\mktsRsgFb{}';
        if (!(is_cjk || has_tex)) {
          continue;
        }
        // continue unless is_ideograph
        // debug 'µ55663', jr description
        debug('µ55663', jr([glyph, fncr, tex_block, tex_cp]));
      }
    }
    // { block: tex_block, codepoint: tex_cp, }  = tex
    //.......................................................................................................
    return null;
  };

  //###########################################################################################################
  if (module.parent == null) {
    this.main();
  }

}).call(this);
