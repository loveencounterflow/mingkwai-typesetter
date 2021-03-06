(function() {
  /*

  {\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}{\latin{} }{\cjk{}{\cn{}{\mktstfRaise{-0.2}\cnxBabel{}癶}}}{\cjk{}{\cn{}里}}{\cjk{}{\cnxb{}{\cnxJzr{}}}}{\latin{} }{\cjk{}{\cn{}里}}{\cjk{}{\cnxa{}䊷}}{\mktsRsgFb{}இ}{\latin{} }{\latin{}a}{\latin{}g}{\latin{}f}{\latin{}i}

  agfi {\cjk{}\cn{}{\mktstfRaise{-0.2}\cnxBabel{}癶}里{\cnxb{}\cnxJzr{}} 里{\cnxa{}䊷}}{\mktsRsgFb{}இ} agfi

  agfi {\cjk{}\cn{}{\mktstfRaise{-0.2}\cnxBabel{}癶}里\cnxb{}\cnxJzr{}\cn 里\cnxa{}䊷}{\mktsRsgFb{}இ} agfi

  */
  var $, CND, MD_READER, MKNCR, PIPEDREAMS3B7B, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, jr, log, rpr, select, stamp, urge, warn, whisper, Σ_glyph_description,
    indexOf = [].indexOf;

  /*

  typofix v1:
  {\cjk{}{\cn{}里}{\cn{}里}{\cn\cnxa{}䊷}{\cn\cnxa{}䊷}{\cn{}里}{\cn{}里}{\cn{}里}{\cn{}里}{\cn{}里}}\\

  typofix v2:
  {\cjk{}{\cn{}里里}{\cnxa{}䊷䊷}{\cn{}里里里里里}}

  typofix v2 intermediate:
  {\CJK{}{\CN{}里里}{\CNXA{}䊷䊷}{\CN{}里里里里里}}
  */
  //###########################################################################################################
  // njs_path                  = require 'path'
  // njs_fs                    = require 'fs'
  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'mkts/tex-writer-typofix';

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
  PIPEDREAMS3B7B = require('pipedreams-3b7b');

  ({$} = PIPEDREAMS3B7B);

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  //...........................................................................................................
  MKNCR = require('../../mingkwai-ncr');

  Σ_glyph_description = Symbol('glyph-description');

  jr = JSON.stringify;

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.$format_tex_specials = function(S) {
    /* TAINT should preserve raw text from before replacements */
    return $((event, send) => {
      var description, meta, name, rsg, type, uchr;
      if (!select(event, '.', Σ_glyph_description)) {
        return send(event);
      }
      [type, name, description, meta] = event;
      ({uchr, rsg} = description);
      if (rsg !== 'u-latn') {
        return send(event);
      }
      switch (uchr) {
        case '\\':
          return send(['tex', '\\textbackslash{}']);
        case '{':
          return send(['tex', '\\{']);
        case '}':
          return send(['tex', '\\}']);
        case '$':
          return send(['tex', '\\$']);
        case '#':
          return send(['tex', '\\#']);
        case '%':
          return send(['tex', '\\%']);
        case '_':
          return send(['tex', '\\_']);
        case '^':
          return send(['tex', '\\textasciicircum{}']);
        case '~':
          return send(['tex', '\\textasciitilde{}']);
        case '&':
          return send(['tex', '\\&']);
      }
      return send(event);
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape_tex_specials = function(text) {
    var R;
    R = text;
    R = R.replace(/\\/g, '\\textbackslash{}');
    R = R.replace(/\{/g, '\\{');
    R = R.replace(/\}/g, '\\}');
    R = R.replace(/\$/g, '\\$');
    R = R.replace(/#/g, '\\#');
    R = R.replace(/%/g, '\\%');
    R = R.replace(/_/g, '\\_');
    R = R.replace(/\^/g, '\\textasciicircum{}');
    R = R.replace(/~/g, '\\textasciitilde{}');
    R = R.replace(/&/g, '\\&');
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$format_cjk = function(S) {
    /* NOTE same pattern as in `$consolidate_tex_events` */
    /* TAINT should preserve raw text from before replacements */
    /* TAINT use piped streams for logic? */
    /* TAINT unify with `$format_non_cjk` */
    /* TAINT do not use a collector, may potentially store text of entire document in memory */
    var cjk_collector, event, flush_and_send_event, last_texcmd_block, send;
    cjk_collector = [];
    send = null;
    event = null;
    last_texcmd_block = null;
    //.........................................................................................................
    flush_and_send_event = () => {
      var tex;
      if (cjk_collector.length > 0) {
        if (last_texcmd_block != null) {
          cjk_collector.push("}");
        }
        cjk_collector.push("}");
        tex = "{\\cjk{}" + cjk_collector.join('');
        last_texcmd_block = null;
        cjk_collector.length = 0;
        send(['tex', tex]);
      }
      if (event != null) {
        send(event);
      }
      return null;
    };
    //.........................................................................................................
    return $('null', (_event, _send) => {
      var description, is_cjk, meta, name, rsg, tag, tex, texcmd, texcmd_block, texcmd_cp, type, uchr;
      send = _send;
      event = _event;
      if (event == null) {
        //.......................................................................................................
        return flush_and_send_event();
      }
      if (!select(event, '.', Σ_glyph_description)) {
        return flush_and_send_event();
      }
      //.......................................................................................................
      [type, name, description, meta] = event;
      ({
        uchr,
        rsg,
        tag,
        tex: texcmd
      } = description);
      is_cjk = indexOf.call(tag, 'cjk') >= 0;
      if (!is_cjk) {
        return flush_and_send_event();
      }
      //.......................................................................................................
      if (texcmd != null) {
        ({
          block: texcmd_block,
          codepoint: texcmd_cp
        } = texcmd);
      } else {
        send(['.', 'warning', `missing TeX command in description for codepoint: ${description}`, copy(meta)]);
        texcmd_block = "\\cn{}";
        texcmd_cp = null;
      }
      //.......................................................................................................
      if (last_texcmd_block !== texcmd_block) {
        if (last_texcmd_block != null) {
          /* close previous open TeX block command, if any: */
          cjk_collector.push('}');
        }
        cjk_collector.push('{');
        cjk_collector.push(texcmd_block);
        last_texcmd_block = texcmd_block;
      }
      //.......................................................................................................
      tex = texcmd_cp;
      if (tex == null) {
        tex = uchr;
      }
      cjk_collector.push(tex);
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$format_non_cjk = function(S) {
    /* TAINT code duplication */
    /* TAINT unify with `$format_cjk` */
    var ignore_texcmd_blocks;
    ignore_texcmd_blocks = ['\\latin{}', '\\mktsRsgFb{}'];
    // ignore_texcmd_blocks  = [ '\\latin{}', ]
    //.........................................................................................................
    return $((_event, _send) => {
      var collector, description, event, meta, name, rsg, send, tag, tex, texcmd, texcmd_block, texcmd_cp, type, uchr;
      send = _send;
      event = _event;
      if (!select(event, '.', Σ_glyph_description)) {
        //.......................................................................................................
        return send(event);
      }
      //.......................................................................................................
      [type, name, description, meta] = event;
      ({
        uchr,
        rsg,
        tag,
        tex: texcmd
      } = description);
      if (indexOf.call(tag, 'cjk') >= 0) {
        return send(event);
      }
      if (texcmd == null) {
        return send(event);
      }
      ({
        //.......................................................................................................
        block: texcmd_block,
        codepoint: texcmd_cp
      } = texcmd);
      if (indexOf.call(ignore_texcmd_blocks, texcmd_block) >= 0) {
        // debug '79876', texcmd, texcmd in ignore_texcmd_blocks
        // return send event if texcmd_block in ignore_texcmd_blocks
        texcmd_block = null;
      }
      if ((texcmd_block == null) && (texcmd_cp == null)) {
        return send(event);
      }
      //.......................................................................................................
      collector = [];
      if (texcmd_block != null) {
        collector.push(`{${texcmd_block}`);
      }
      collector.push(texcmd_cp != null ? texcmd_cp : uchr);
      if (texcmd_block != null) {
        collector.push("}");
      }
      tex = collector.join('');
      send(['tex', tex]);
      //.......................................................................................................
      return null;
    });
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @$format_cjk = ( S ) ->
  //   ### NOTE same pattern as in `$consolidate_tex_events` ###
  //   ### TAINT should preserve raw text from before replacements ###
  //   ### TAINT use piped streams for logic? ###
  //   cjk_collector         = []
  //   send                  = null
  //   event                 = null
  //   last_texcmd_block     = null
  //   script                = 'latin'
  //   last_script           = script
  //   ignore_texcmd_blocks  = [ '\\latin{}', ]
  //   must_close_group      = no
  //   #.........................................................................................................
  //   flush_and_send_event = =>
  //     if cjk_collector.length > 0
  //       cjk_collector.push "}" if last_texcmd_block?
  //       cjk_collector.push "}"
  //       tex                   = "{\\cjk{}" + cjk_collector.join ''
  //       last_texcmd_block     = null
  //       cjk_collector.length  = 0
  //       send [ 'tex', tex, ]
  //     send event if event?
  //     return null
  //   #.........................................................................................................
  //   return $ 'null', ( _event, _send ) =>
  //     send  = _send
  //     event = _event
  //     #.......................................................................................................
  //     return flush_and_send_event() unless event?
  //     return flush_and_send_event() unless select event, '.', Σ_glyph_description
  //     #.......................................................................................................
  //     [ type, name, description, meta, ]  = event
  //     { uchr, rsg, tag, tex: texcmd, }    = description
  //     script                              = if ( 'cjk' in tag ) then 'cjk' else 'latin'
  //     flush_and_send_event() if script isnt last_script
  //     last_script                         = script
  //     #.......................................................................................................
  //     if texcmd?
  //       { block: texcmd_block, codepoint: texcmd_cp, }  = texcmd
  //     else
  //       send [ '.', 'warning', "missing TeX command in description for codepoint: #{description}", ( copy meta ), ]
  //       texcmd_block  = null
  //       texcmd_cp     = null
  //     #.......................................................................................................
  //     if last_texcmd_block isnt texcmd_block
  //       ### close previous open TeX block command, if any: ###
  //       if must_close_group
  //         cjk_collector.push '}' if cjk_collector?
  //         must_close_group = no
  //       debug "30222", rpr texcmd_block, texcmd_block in ignore_texcmd_blocks
  //       if texcmd_block in ignore_texcmd_blocks
  //         must_close_group  = no
  //       else
  //         must_close_group  = yes
  //         cjk_collector.push '{'
  //         cjk_collector.push texcmd_block
  //       last_texcmd_block = texcmd_block
  //     #.......................................................................................................
  //     tex   = texcmd_cp
  //     tex  ?= uchr
  //     cjk_collector.push tex
  //     #.......................................................................................................
  //     return null

  //===========================================================================================================
  // SPLITTING, WRAPPING, UNWRAPPING
  //-----------------------------------------------------------------------------------------------------------
  this.$split = function(S) {
    return $((event, send) => {
      var glyph, i, len, meta, name, ref, text, type;
      if (!select(event, '.', 'text')) {
        return send(event);
      }
      [type, name, text, meta] = event;
      ref = MKNCR.chrs_from_text(text);
      for (i = 0, len = ref.length; i < len; i++) {
        glyph = ref[i];
        send(['.', Σ_glyph_description, glyph, meta]);
      }
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$wrap_as_glyph_description = function(S) {
    return $((event, send) => {
      var csg, description, glyph, i, len, meta, name, ref, sub_glyph, type;
      if (!select(event, '.', Σ_glyph_description)) {
        return send(event);
      }
      [type, name, glyph, meta] = event;
      description = MKNCR.describe(glyph);
      ({csg} = description);
      if (csg === 'u' || csg === 'jzr') {
        send([type, name, description, meta]);
      } else {
        ref = Array.from(glyph);
        /* NOTE In case the CSG is not an 'inner' one (either Unicode or Jizura), the glyph can only
        have been represented as an extended NCR (a string like `&morohashi#x12ab;`). In that case,
        we send all the constituent US-ASCII glyphs separately so the NCR will be rendered literally. */
        for (i = 0, len = ref.length; i < len; i++) {
          sub_glyph = ref[i];
          send([type, name, MKNCR.describe(sub_glyph), meta]);
        }
      }
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$consolidate_tex_events = function(S) {
    /* NOTE same pattern as in `$format_cjk` */
    var collector, event, flush_and_send_event, send;
    collector = [];
    send = null;
    event = null;
    //.........................................................................................................
    flush_and_send_event = () => {
      var tex;
      if (collector.length > 0) {
        tex = collector.join('');
        collector.length = 0;
        send(['tex', tex]);
      }
      if (event != null) {
        //.......................................................................................................
        send(event);
      }
      return null;
    };
    //.........................................................................................................
    return $('null', (_event, _send) => {
      var _, tex;
      send = _send;
      event = _event;
      if (event == null) {
        //.......................................................................................................
        return flush_and_send_event();
      }
      if (!select(event, 'tex')) {
        return flush_and_send_event();
      }
      //.......................................................................................................
      [_, tex] = event;
      collector.push(tex);
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$unwrap_glyph_description = function(S) {
    return $((event, send) => {
      var description, glyph, meta, name, type;
      if (!select(event, '.', Σ_glyph_description)) {
        return send(event);
      }
      [type, name, description, meta] = event;
      // debug '70333', description
      glyph = description['uchr'];
      /* TAINT send `tex` or `text` event? */
      send(['tex', glyph]);
      return null;
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.$fix_typography_for_tex = function(S) {
    var pipeline;
    pipeline = [this.$split(S), this.$wrap_as_glyph_description(S), this.$format_cjk(S), this.$format_non_cjk(S), this.$format_tex_specials(S), this.$unwrap_glyph_description(S), this.$consolidate_tex_events(S)];
    // $ ( event ) -> help '65099', rpr event[ 1 ] if select event, 'tex'
    return PIPEDREAMS3B7B.new_stream({pipeline});
  };

  //-----------------------------------------------------------------------------------------------------------
  this.fix_typography_for_tex = function(S, text, handler) {
    var collector, input;
    collector = [];
    input = PIPEDREAMS3B7B.new_stream();
    input.pipe(this.$fix_typography_for_tex(S)).pipe($((event) => {
      var _, tex;
      if (!select(event, 'tex')) {
        return;
      }
      [_, tex] = event;
      return collector.push(tex);
    })).pipe($('finish', () => {
      return handler(null, collector.join(''));
    }));
    //.........................................................................................................
    PIPEDREAMS3B7B.send(input, ['.', 'text', text, {}]);
    PIPEDREAMS3B7B.end(input);
    //.........................................................................................................
    return null;
  };

  // ############################################################################################################
// unless module.parent?
//   debug '83744', MKNCR.describe '&#x3000;'

}).call(this);
