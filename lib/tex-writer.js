(function() {
  //###########################################################################################################
  var $, $async, ASYNC, AUX, CACHE, CND, D, HELPERS, LINEBREAKER, MACRO_ESCAPER, MACRO_INTERPRETER, MD_READER, MKTS, MKTSCRIPT_WRITER, OPTIONS, OVAL, PIPEDREAMS3B7B, SEMVER, TEXLIVEPACKAGEINFO, UNITS, XNCHR, XXX_tex_from_md_nr, YADDA, after, alert, badge, before, copy, debug, echo, help, hide, info, is_hidden, is_stamped, jr, log, njs_fs, njs_path, options_route, promisify, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper, ƒ, Σ_formatted_warning,
    splice = [].splice,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/TEX-WRITER';

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
  suspend = require('coffeenode-suspend');

  step = suspend.step;

  //...........................................................................................................
  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  // { $, $async, }            = D
  PIPEDREAMS3B7B = require('pipedreams-3b7b');

  //...........................................................................................................
  ASYNC = require('async');

  //...........................................................................................................
  ƒ = CND.format_number.bind(CND);

  HELPERS = require('./helpers');

  TEXLIVEPACKAGEINFO = require('./texlivepackageinfo');

  options_route = '../options.coffee';

  ({CACHE, OPTIONS} = require('./options-and-cache'));

  SEMVER = require('semver');

  //...........................................................................................................
  XNCHR = require('./xnchr');

  MKTS = require('./main');

  MKTSCRIPT_WRITER = require('./mktscript-writer');

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  unstamp = MD_READER.unstamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  MACRO_ESCAPER = require('./macro-escaper');

  MACRO_INTERPRETER = require('./macro-interpreter');

  LINEBREAKER = require('./linebreaker');

  this.COLUMNS = require('./tex-writer-columns');

  this.MKTS_TABLE = require('./tex-writer-mkts-table');

  AUX = require('./tex-writer-aux');

  YADDA = require('./yadda');

  OVAL = require('./object-validator');

  UNITS = require('./mkts-table-units');

  //...........................................................................................................
  Σ_formatted_warning = Symbol('formatted-warning');

  jr = JSON.stringify;

  promisify = (require('util')).promisify;

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  /* TAINT experimental, should become part of `PIPEDREAMS` to facilitate automated assembly of pipelines
  based on registered precedences using `CND.TSORT` */
  before = function(...names) {
    var method, ref;
    ref = names, [...names] = ref, [method] = splice.call(names, -1);
    return method;
  };

  //-----------------------------------------------------------------------------------------------------------
  after = function(...names) {
    var method, ref;
    ref = names, [...names] = ref, [method] = splice.call(names, -1);
    return method;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this._compile_options_fontnicks = function() {
    var d, filename, fontnick, i, len, ref, texname;
    this.options.filenames_by_fontnicks = d = {};
    ref = this.options.fonts.files;
    // debug '^8876^', @options.fonts.files
    for (i = 0, len = ref.length; i < len; i++) {
      ({texname, filename} = ref[i]);
      fontnick = (texname.replace(/^mktsFontfile/, '')).toLowerCase();
      d[fontnick] = filename;
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.compile_options = function() {
    /* TAINT this method should go to OPTIONS */
    var base, cache_locator, cache_route, has_double_slash, has_single_slash, i, len, locator, locators, options_home, options_locator, ref, route, texinputs_routes;
    options_locator = require.resolve(njs_path.resolve(__dirname, options_route));
    // debug '©zNzKn', options_locator
    options_home = njs_path.dirname(njs_path.join(njs_path.dirname(options_locator)));
    this.options = OPTIONS.from_locator(options_locator);
    this.options['home'] = options_home;
    this.options['locator'] = options_locator;
    cache_route = this.options['cache']['route'];
    this.options['cache']['locator'] = cache_locator = njs_path.resolve(options_home, cache_route);
    this.options['xelatex-command'] = njs_path.resolve(options_home, this.options['xelatex-command']);
    //.........................................................................................................
    if (!njs_fs.existsSync(cache_locator)) {
      this.options['cache']['%self'] = {};
      CACHE.save(this.options);
    }
    //.........................................................................................................
    this.options['cache']['%self'] = require(cache_locator);
    //.........................................................................................................
    if ((texinputs_routes = (ref = this.options['texinputs']) != null ? ref['routes'] : void 0) != null) {
      locators = [];
      for (i = 0, len = texinputs_routes.length; i < len; i++) {
        route = texinputs_routes[i];
        has_single_slash = /\/$/.test(route);
        has_double_slash = /\/\/$/.test(route);
        locator = njs_path.resolve(options_home, route);
        if (has_double_slash) {
          locator += '//';
        } else if (has_single_slash) {
          locator += '/';
        }
        locators.push(locator);
      }
      /* TAINT duplication: tex_inputs_home, texinputs_value */
      /* TAINT path separator depends on OS */
      this.options['texinputs']['value'] = locators.join(':');
    }
    // @options[ 'locators' ] = {}
    // for key, route of @options[ 'routes' ]
    //   @options[ 'locators' ][ key ] = njs_path.resolve options_home, route
    //.........................................................................................................
    if ((base = this.options).layout == null) {
      base.layout = {};
    }
    if (this.options.layout.lineheight != null) {
      this.options.layout.lineheight = UNITS.new_quantity(this.options.layout.lineheight);
    }
    //.........................................................................................................
    this._compile_options_fontnicks();
    return CACHE.update(this.options);
  };

  //...........................................................................................................
  this.compile_options();

  //-----------------------------------------------------------------------------------------------------------
  this.write_mkts_master = function(S, handler) {
    var base, base1, base10, base11, base2, base3, base4, base5, base6, base7, base8, base9, filename, font_settings, font_settings_txt, gkey, home, i, key, len, lines, mktsLineheight, mktsLineheight_txt, name, otf, ref, ref1, ref2, ref3, ref4, ref5, styles, subfolder, tex, texname, text, value, write;
    lines = [];
    write = lines.push.bind(lines);
    help(`writing ${S.layout_info['master-locator']}`);
    //-------------------------------------------------------------------------------------------------------
    write("");
    write(`% ${S.layout_info['master-locator']}`);
    write("% do not edit this file");
    write(`% generated from ${S.options.locator}`);
    write(`% on ${new Date()}`);
    write("");
    write("\\documentclass[a4paper,twoside]{book}");
    write("");
    //-------------------------------------------------------------------------------------------------------
    // DEFS
    //.......................................................................................................
    if (S.options.defs != null) {
      write("");
      write("% DEFS");
      ref = S.options.defs;
      for (name in ref) {
        value = ref[name];
        write(`\\def\\${name}{${value}}`);
      }
    }
    //-------------------------------------------------------------------------------------------------------
    // NEWCOMMANDS
    //.......................................................................................................
    if (S.options.newcommands != null) {
      write("");
      write("% NEWCOMMANDS");
      ref1 = S.options.newcommands;
      for (name in ref1) {
        value = ref1[name];
        warn(`implicitly converting newcommand value for ${name}`);
        value = njs_path.resolve(__dirname, '..', value);
        write(`\\newcommand{\\${name}}{%\n${value}%\n}`);
      }
    }
    //-------------------------------------------------------------------------------------------------------
    // IN-DOCUMENT CONFIGURATION
    //.......................................................................................................
    write("");
    write("% IN-DOCUMENT CONFIGURATION");
    /* TAINT use default configuration *.ptv file */
    /* TAINT make more general; ATM can only decide on boolean */
    if ((base = S.configuration)['document/geometry/show/textgrid'] == null) {
      base['document/geometry/show/textgrid'] = false;
    }
    if ((base1 = S.configuration)['document/geometry/show/papergrid'] == null) {
      base1['document/geometry/show/papergrid'] = false;
    }
    if ((base2 = S.configuration)['document/geometry/show/linebands'] == null) {
      base2['document/geometry/show/linebands'] = false;
    }
    if ((base3 = S.configuration)['document/geometry/show/columns'] == null) {
      base3['document/geometry/show/columns'] = false;
    }
    if ((base4 = S.configuration)['document/geometry/show/baselines'] == null) {
      base4['document/geometry/show/baselines'] = false;
    }
    if ((base5 = S.configuration)['document/geometry/show/ascenders'] == null) {
      base5['document/geometry/show/ascenders'] = false;
    }
    if ((base6 = S.configuration)['document/geometry/show/descenders'] == null) {
      base6['document/geometry/show/descenders'] = false;
    }
    if ((base7 = S.configuration)['document/geometry/show/medians'] == null) {
      base7['document/geometry/show/medians'] = false;
    }
    if ((base8 = S.configuration)['document/geometry/show/debug'] == null) {
      base8['document/geometry/show/debug'] = false;
    }
    if ((base9 = S.configuration)['document/geometry/show/debugorigin'] == null) {
      base9['document/geometry/show/debugorigin'] = false;
    }
    if ((base10 = S.configuration)['document/geometry/show/gutter'] == null) {
      base10['document/geometry/show/gutter'] = false;
    }
    if ((base11 = S.configuration)['document/geometry/show/linenumbers'] == null) {
      base11['document/geometry/show/linenumbers'] = false;
    }
    ref2 = S.configuration;
    for (key in ref2) {
      value = ref2[key];
      if ((key.match(/^document\/geometry\/show\//)) == null) {
        warn(`ignoring configuration key ${rpr(key)}`);
        continue;
      }
      if (!value) {
        continue;
      }
      gkey = key.replace(/^.*?([^\/]+)$/g, '$1');
      tex = `\\PassOptionsToPackage{${gkey}}{mkts-page-geometry}%`;
      info('55569', `in-document configuration -> ${tex}`);
      write(tex);
    }
    //-------------------------------------------------------------------------------------------------------
    // PACKAGES
    //.......................................................................................................
    write("");
    write("% PACKAGES");
    // write "\\usepackage{mkts2015-main}"
    // write "\\usepackage{mkts2015-fonts}"
    // write "\\usepackage{mkts2015-article}"
    write("\\usepackage{mkts2015-consolidated}");
    //-------------------------------------------------------------------------------------------------------
    // FONTS
    //......................................................................................................
    write("");
    write("% FONTS");
    write("\\usepackage{fontspec}");
    ref3 = S.options.fonts.files;
    //.......................................................................................................
    for (i = 0, len = ref3.length; i < len; i++) {
      ({texname, otf, home, subfolder, filename} = ref3[i]);
      font_settings = [];
      //.......................................................................................................
      if (home === '') {
        /* use standard settings */
        null;
      } else {
        //.......................................................................................................
        if (home == null) {
          home = S.options.fonts.home;
        }
        if (subfolder != null) {
          home = njs_path.join(home, subfolder);
        }
        if (!home.endsWith('/')) {
          home = `${home}/`;
        }
        font_settings.push([`Path=${home}`]);
      }
      if (otf != null) {
        //.......................................................................................................
        font_settings.push(otf);
      }
      font_settings_txt = font_settings.join(',');
      // debug '66733', ( jr { texname, otf, home, subfolder, filename, } ), rpr font_settings_txt
      /* TAINT should properly escape values */
      // write "\\newfontface{\\#{texname}}{#{filename}}[#{font_settings_txt}]"
      /* TAINT this is an experiment to confine font loading to what is needed in the document
      at hand. Strangely enough, calling the below commands will redefine them, although they do get
      executed; still, redefining a *font* doesn't seem to bother XeLaTeX much and indeed, only
      the needed fonts are loaded. Also, we could capture the output of the font commands and
      compile a list of all used fonts. */
      /* TAINT Mystery: redefinition doesn't work, processing time skyrockets */
      write(`\\newfontface{\\${texname}}{${filename}}[${font_settings_txt}]%`);
    }
    // write "\\newcommand{\\#{texname}}{%"
    // write "\\renewcommand{\\#{texname}}{\\#{texname}XXX}%"
    // write "\\renewcommand{\\#{texname}}{\\typeout{\\trmGreen{using #{texname}}}}%"
    // write "\\typeout{\\trmWhite{defining #{texname}}}%"
    // # write "\\newfontface{\\#{texname}XXX}{#{filename}}[#{font_settings_txt}]%"
    // # write "\\#{texname}XXX%"
    // write "}"
    write("");
    //-------------------------------------------------------------------------------------------------------
    // STYLES
    //......................................................................................................
    write("");
    write("% STYLES");
    if ((styles = S.options['styles']) != null) {
      for (name in styles) {
        value = styles[name];
        write(`\\newcommand{\\${name}}{%\n${value}%\n}`);
      }
    }
    //-------------------------------------------------------------------------------------------------------
    if ((mktsLineheight = (ref4 = (ref5 = S.options.layout) != null ? ref5.lineheight : void 0) != null ? ref4 : null) != null) {
      mktsLineheight_txt = UNITS.as_text(mktsLineheight);
      write("");
      write("% LENGTHS");
      write(`\\setlength{\\mktsLineheight}{${mktsLineheight_txt}}%`);
      write("\\setlength{\\mktsCurrentLineheight}{\\mktsLineheight}%");
    }
    //-------------------------------------------------------------------------------------------------------
    write("");
    write("% CONTENT");
    //-------------------------------------------------------------------------------------------------------
    // INCLUDES
    //.......................................................................................................
    write("");
    write(`\\input{${S.layout_info['content-locator']}}`);
    write("");
    //-------------------------------------------------------------------------------------------------------
    write("\\end{document}");
    //-------------------------------------------------------------------------------------------------------
    text = lines.join('\n');
    return njs_fs.writeFile(S.layout_info['master-locator'], text, handler);
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX = {
    TYPOFIX: require('./tex-writer-typofix'),
    SH: require('./tex-writer-sh'),
    CALL: require('./tex-writer-call'),
    PLUGINS: require('./plugins/tex-writer-plugins'),
    DOCUMENT: {},
    COMMAND: {},
    REGION: {},
    BLOCK: {},
    INLINE: {},
    MIXED: {},
    CLEANUP: {},
    API: {}
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$new_page = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      if (!select(event, ['!', '.'], 'new-page')) {
        return send(event);
      }
      send(stamp(event));
      [type, name, text, meta] = event;
      /* TAINT make insertion of `\null` (which causes invisible content to be placed onto the page to ensure
      a page break will indeed happen) conditional, so we can insert page breaks that are suppressed when
      the current page is still fresh */
      return send(['tex', "\\null\\newpage{}"]);
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$new_odd_even_page = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      if (select(event, ['!', '.'], 'new-odd-page')) {
        send(['tex', "\\newoddpage{}"]);
      } else if (select(event, ['!', '.'], 'new-even-page')) {
        send(['tex', "\\newevenpage{}"]);
      } else {
        send(event);
      }
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$blank_page = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      if (!select(event, ['!', '.'], 'blank-page')) {
        return send(event);
      }
      send(stamp(event));
      [type, name, text, meta] = event;
      return send(['tex', "\\mktsBlankPage{}"]);
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$comment = (S) => {
    var remark;
    remark = MD_READER._get_remark();
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      if (!select(event, '.', 'comment')) {
        return send(event);
      }
      [type, name, text, meta] = event;
      return send(remark('drop', `\`.comment\`: ${rpr(text)}`, copy(meta)));
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$document = (S) => {
    var bare, is_first_document_tag, ref, within_document;
    is_first_document_tag = true;
    bare = (ref = S.bare) != null ? ref : false;
    within_document = false;
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      //.......................................................................................................
      if (select(event, ['.', '('], 'document')) {
        if (!is_first_document_tag) {
          throw new Error(`encountered repeated \`<document/>\` tag (${jr(event)})`);
        }
        within_document = true;
        is_first_document_tag = false;
        [type, name, text, meta] = event;
        send(stamp(event));
        if (!bare) {
          send(['tex', "\n% begin of MD document\n"]);
          send(['tex', "\\begin{document}\\mktsStyleNormal{}"]);
          /* TAINT this should not be here, be part of style, be configurable */
          send(['tex', "\\spaceskip 0.75ex plus 0.75ex minus 0.5ex \\relax%\n"]);
        }
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        within_document = false;
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @$document = ( S ) =>
  //   buffer                  = []
  //   start_document_event    = null
  //   before_document_command = yes
  //   send_                   = null
  //   before_flush            = yes
  //   bare                    = S.bare ? no
  //   #.........................................................................................................
  //   flush_as = ( what ) =>
  //     send_ [ 'tex', "\n% begin of MD document\n", ] unless bare
  //     if what is 'preamble' and buffer.length > 0
  //       send_ [ 'tex', "% (extra preamble inserted from MD document)\n", ]
  //       send_ event for event in buffer
  //     send_ stamp start_document_event
  //     send_ [ 'tex', "\\begin{document}\\mktsStyleNormal{}", ] unless bare
  //     if what is 'document'
  //       send_ event for event in buffer
  //     buffer.length           = 0
  //     before_document_command = no
  //   #.........................................................................................................
  //   return $ ( event, send ) =>
  //     send_ = send
  //     #.......................................................................................................
  //     if before_flush
  //       send event
  //       before_flush = no if select event, '~', 'flush'
  //     #.......................................................................................................
  //     else if select event, ')', 'document'
  //       flush_as 'document' if before_document_command
  //       send [ 'tex', "\n% end of MD document\n", ] unless bare
  //       send stamp event
  //     #.......................................................................................................
  //     else if select event, '!', 'document'
  //       send stamp event
  //       flush_as 'preamble'
  //     #.......................................................................................................
  //     else if before_document_command
  //       if select event, '(', 'document'
  //         start_document_event = event
  //       else
  //         buffer.push event
  //     #.......................................................................................................
  //     else
  //       send event

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.REGION.$code = (S) => {
    /* TAINT code duplication with `REGION.$keep_lines` possible */
    var track;
    track = MD_READER.TRACKER.new_tracker('(code)');
    //.........................................................................................................
    return $((event, send) => {
      var keeplines_parameters, language, meta, name, parameters, settings, text, type, within_code;
      within_code = track.within('(code)');
      track(event);
      //.......................................................................................................
      if (select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        if (within_code) {
          text = text.replace(/\u0020/g, '\u00a0');
        }
        return send([type, name, text, meta]);
      //.......................................................................................................
      } else if (select(event, ['(', ')'], 'code')) {
        [type, name, parameters, meta] = event;
        [language, settings] = parameters;
        keeplines_parameters = settings != null ? [settings] : [];
        //.....................................................................................................
        if (type === '(') {
          send(stamp(event));
          send(['(', 'keep-lines', keeplines_parameters, copy(meta)]);
          if (language !== 'keep-lines') {
            return send(['tex', "\n\n{\\mktsStyleCode{}"]);
          }
        } else {
          if (language !== 'keep-lines') {
            send(['tex', "}\n\n"]);
          }
          send([')', 'keep-lines', keeplines_parameters, copy(meta)]);
          return send(stamp(event));
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.REGION.$keep_lines = (S) => {
    var last_was_empty, squish, track;
    track = MD_READER.TRACKER.new_tracker('(keep-lines)');
    last_was_empty = false;
    squish = false;
    //.........................................................................................................
    return $((event, send) => {
      var chunk, chunks, i, len, meta, name, parameters, ref, ref1, results, text, type, within_keep_lines;
      within_keep_lines = track.within('(keep-lines)');
      track(event);
      //.......................................................................................................
      if (within_keep_lines && select(event, '.', 'text')) {
        // send stamp event
        [type, name, text, meta] = event;
        /* TAINT other replacements possible; use API */
        /* TAINT U+00A0 (nbsp) might be too wide */
        // text = text.replace /\n\n/g, "{\\mktsTightParagraphs\\null\\par\n"
        text = text.replace(/\u0020/g, '\u00a0');
        // text    = text.replace /^\n/,     ''
        chunks = text.split(/(\n)/g);
        results = [];
        for (i = 0, len = chunks.length; i < len; i++) {
          chunk = chunks[i];
          if (chunk === '\n') {
            if (last_was_empty) {
              results.push(send(['tex', "\\null\\par\n"]));
            } else {
              results.push(send(['tex', "\\par\n"]));
            }
          } else {
            if (!(last_was_empty = chunk.length === 0)) {
              // debug `0903`, rpr chunk
              // chunk = @MKTX.TYPOFIX.fix_typography_for_tex chunk, S.options
              results.push(send(['.', 'text', chunk, copy(meta)]));
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      // send [ 'tex', chunk, ]
      //.......................................................................................................
      } else if (select(event, '(', 'keep-lines')) {
        send(stamp(event));
        [type, name, parameters, meta] = event;
        if (!(squish = (ref = parameters != null ? (ref1 = parameters[0]) != null ? ref1['squish'] : void 0 : void 0) != null ? ref : true)) {
          send(['tex', "\\null\\par"]);
        }
        return send(['tex', "{\\mktsTightParagraphs{}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'keep-lines')) {
        send(stamp(event));
        return send(['tex', "}"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  before('@MKTX.BLOCK.$heading', '@MKTX.COMMAND.$toc', this.MKTX.REGION.$toc = (S) => {
    var buffer, track;
    track = MD_READER.TRACKER.new_tracker('(toc)');
    buffer = null;
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type, within_toc;
      within_toc = track.within('(toc)');
      track(event);
      //.......................................................................................................
      if (select(event, '(', 'toc')) {
        send(stamp(event));
        [type, name, text, meta] = event;
        return buffer = ['!', name, text, meta];
      //.......................................................................................................
      } else if (select(event, ')', 'toc')) {
        send(stamp(event));
        if (buffer != null) {
          send(buffer);
          return buffer = null;
        }
      //.......................................................................................................
      } else if (within_toc && select(event, '.', 'comma')) {
        if (buffer != null) {
          send(buffer);
          return buffer = null;
        }
      //.......................................................................................................
      } else if (within_toc && select(event, ['(', ')'], 'h')) {
        [type, name, text, meta] = event;
        meta['toc'] = 'omit';
        return send(event);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  });

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$heading = (S) => {
    /* TAINT make numbering style configurable */
    /* TAINT generalize for more than 3 levels */
    var h_idx, h_nrs;
    h_nrs = [1, 1, 1, 1];
    h_idx = -1;
    //.........................................................................................................
    return $((event, send) => {
      var h_key, level, meta, name, type;
      //.......................................................................................................
      if (select(event, '(', 'h')) {
        [type, name, level, meta] = event;
        h_idx += +1;
        h_key = `h-${h_idx}`;
        if (meta.h == null) {
          meta.h = {};
        }
        meta.h.idx = h_idx;
        meta.h.key = h_key;
        //.....................................................................................................
        send(['tex', "\n"]);
        send(stamp(event));
        //.....................................................................................................
        switch (level) {
          case 1:
            send([
              '!',
              'columns',
              [1],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            send(['tex', "{\\mktsHOne{}"]);
            return send([
              'tex',
              `\\zlabel{${h_key}}`,
              {
                toc: 'omit'
              }
            ]);
          case 2:
            send([
              '!',
              'columns',
              [1],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            send(['tex', "{\\mktsHTwo{}"]);
            return send([
              'tex',
              `\\zlabel{${h_key}}`,
              {
                toc: 'omit'
              }
            ]);
          case 3:
            send([
              '!',
              'columns',
              [1],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            send(['tex', "{\\mktsHThree{}"]);
            return send([
              'tex',
              `\\zlabel{${h_key}}`,
              {
                toc: 'omit'
              }
            ]);
          case 4:
            send(['tex', "{\\mktsHFour{}"]);
            return send([
              'tex',
              `\\zlabel{${h_key}}`,
              {
                toc: 'omit'
              }
            ]);
          default:
            return send(['.', 'warning', `heading level ${level} not implemented`, copy(meta)]);
        }
      //.......................................................................................................
      } else if (select(event, ')', 'h')) {
        [type, name, level, meta] = event;
        //.....................................................................................................
        switch (level) {
          case 1:
            send(['tex', "\\mktsHOneBeg}%\n"]);
            send([
              '!',
              'columns',
              ['pop'],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            break;
          case 2:
            send(['tex', "\\mktsHTwoBeg}%\n"]);
            send([
              '!',
              'columns',
              ['pop'],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            break;
          case 3:
            send(['tex', "\\mktsHThreeBeg}%\n\n"]);
            send([
              '!',
              'columns',
              ['pop'],
              copy(meta,
              {
                toc: 'omit'
              })
            ]);
            break;
          case 4:
            send(['tex', "\\mktsHFourBeg}%\n\n"]);
            break;
          default:
            return send(['.', 'warning', `heading level ${level} not implemented`, copy(meta)]);
        }
        //.....................................................................................................
        return send(stamp(event));
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$crossrefs = (S) => {
    var crossrefs;
    crossrefs = {};
    //.........................................................................................................
    return $((event, send) => {
      var key, meta, name, text, type;
      [type, name, text, meta] = event;
      //.......................................................................................................
      if (select(event, '!', ['crossref-anchor'])) {
        // debug '33393', event
        /* count   = crossrefs[ text ] = ( crossrefs[ text ] ? 0 ) + 1 */
        /* key     = "#{text}-#{count}" */
        key = text;
        send(['tex', `\\label{${key}}`]);
        send(stamp(event));
      //.......................................................................................................
      } else if (select(event, '!', ['crossref-link'])) {
        // debug '33394', event
        /* count   = crossrefs[ text ] = ( crossrefs[ text ] ? 0 ) + 1 */
        /* key     = "#{text}-#{count}" */
        key = text;
        send(['tex', `\\mktsPagerefArrow{${key}}`]);
        send(stamp(event));
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  before('@MKTX.COMMAND.$toc', after('@MKTX.BLOCK.$heading', this.MKTX.MIXED.$collect_headings_for_toc = (S) => {
    var buffer, headings, new_heading, remark, this_heading, within_heading;
    within_heading = false;
    this_heading = null;
    headings = [];
    buffer = [];
    remark = MD_READER._get_remark();
    //.........................................................................................................
    new_heading = function(level, meta) {
      var R;
      R = {
        level: level,
        idx: meta['h']['idx'],
        key: meta['h']['key'],
        events: []
      };
      return R;
    };
    //.........................................................................................................
    return $((event, send) => {
      /* TAINT use library method to test event category */
      var i, j, len, len1, level, meta, name, sub_event, text, type;
      // debug '8624', event
      [type, name, text, meta] = event;
      //.......................................................................................................
      if (select(event, '~', ['flush', 'stop'])) {
        send(remark(name, `releasing ${buffer.length} events`, copy(meta)));
        for (i = 0, len = buffer.length; i < len; i++) {
          sub_event = buffer[i];
          send(sub_event);
        }
        buffer.length = 0;
        send(event);
      //.......................................................................................................
      } else if (select(event, '(', 'document')) {
        send(event);
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        // debug '2139', unstamp [ '.', 'toc-headings', headings, meta, ]
        send(unstamp(['.', 'toc-headings', headings, meta]));
        for (j = 0, len1 = buffer.length; j < len1; j++) {
          sub_event = buffer[j];
          send(sub_event);
        }
        buffer.length = 0;
        send(event);
      //.......................................................................................................
      } else if ((meta != null) && (meta['toc'] !== 'omit') && select(event, '(', 'h')) {
        level = text;
        within_heading = true;
        this_heading = new_heading(level, meta);
        headings.push(this_heading);
        buffer.push(event);
      //.......................................................................................................
      } else if (select(event, ')', 'h')) {
        within_heading = false;
        this_heading = null;
        buffer.push(event);
      //.......................................................................................................
      } else if (within_heading) {
        /* TAINT use library method to determine event category */
        if (event[event.length - 1]['toc'] !== 'omit') {
          if (event.length === 4) {
            this_heading['events'].push([type, name, text, copy(meta)]);
          } else {
            this_heading['events'].push(event);
          }
        }
        if (event[event.length - 1]['toc'] !== 'only') {
          buffer.push(event);
        }
      } else {
        //.......................................................................................................
        buffer.push(event);
      }
      //.......................................................................................................
      return null;
    });
  }));

  //-----------------------------------------------------------------------------------------------------------
  after('@MKTX.REGION.$toc', '@MKTX.MIXED.$collect_headings_for_toc', this.MKTX.COMMAND.$toc = (S) => {
    var headings;
    headings = null;
    //.........................................................................................................
    return $((event, send) => {
      var _, events, h_event, heading, i, idx, j, key, last_idx, len, len1, level, meta, name, text, type;
      //.......................................................................................................
      /* TAINT use library method to test event category */
      if (select(event, '.', 'toc-headings')) {
        [_, _, headings, _] = event;
        send(stamp(event));
      //.......................................................................................................
      } else if (select(event, '!', 'toc')) {
        [type, name, text, meta] = event;
        send(stamp(event));
        //.....................................................................................................
        if (headings == null) {
          return send(['.', 'warning', "expecting toc-headings event before this", copy(meta)]);
        }
        //.....................................................................................................
        send(['tex', '{\\mktsToc%\n']);
// send [ '!', 'mark', 'toc', ( copy meta ), ]
        for (i = 0, len = headings.length; i < len; i++) {
          heading = headings[i];
          ({level, events, key} = heading);
          last_idx = events.length - 1;
          for (idx = j = 0, len1 = events.length; j < len1; idx = ++j) {
            h_event = events[idx];
            if (h_event.length === 4) {
              // debug '23432', h_event
              /* TAINT use library method to determine event category */
              h_event = unstamp(h_event);
            }
            if (idx === last_idx) {
              send(['tex', `{\\mktsStyleNormal \\dotfill \\zpageref{${key}}}`]);
            }
            // send [ 'tex', " \\dotfill \\zpageref{#{key}}", ] if idx is last_idx
            send(h_event);
          }
        }
        send(['tex', '\\mktsTocBeg}%\n']);
      } else {
        // headings.length = 0
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  });

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$yadda = (S) => {
    /* TAINT in the case of Chinese (`<yadda lang=zh nr=1/>`), using the `nr` attribute will not reproduce
    the same text across runs. */
    //.........................................................................................................
    return $((event, send) => {
      var Q, i, meta, name, nr, p_count, ref, type;
      if (select(event, '.', 'yadda')) {
        send(stamp(event));
        [type, name, Q, meta] = event;
        //.....................................................................................................
        if (Q.paragraphs != null) {
          p_count = parseInt(Q.paragraphs, 10);
          for (nr = i = 1, ref = p_count; i <= ref; nr = i += +1) {
            send(['.', 'text', (YADDA.generate(Q)) + '\n\n', copy(meta)]);
          }
        } else {
          //.....................................................................................................
          send(['.', 'text', YADDA.generate(Q), copy(meta)]);
        }
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  /* experimental */
  this.MKTX.API.fncr = function(csg, srsg, cid) {
    return [['tex', `\\mktsFncr{${csg}}{${srsg}}{${cid}}`]];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$fncr = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, i, len, meta, name, ref, sub_event, type;
      //.......................................................................................................
      if (select(event, '.', 'fncr')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        ref = this.MKTX.API.fncr(Q.csg, Q.srsg, Q.cid);
        for (i = 0, len = ref.length; i < len; i++) {
          sub_event = ref[i];
          send(sub_event);
        }
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$box = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, command, meta, name, type;
      if (select(event, '(', 'box')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        command = Q.border != null ? 'framebox' : 'makebox';
        if (Q.width != null) {
          send(['tex', `\\${command}[${Q.width}]{`]);
        } else {
          send(['tex', `\\${command}{`]);
        }
      //.......................................................................................................
      } else if (select(event, ')', 'box')) {
        send(stamp(event));
        send(['tex', "}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$tabulation = (S) => {
    var within_settabs;
    within_settabs = false;
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, text, type;
      if (select(event, '.', 'tab')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        send(['tex', "\\tab{}"]);
      //.......................................................................................................
      } else if (select(event, '(', 'set-tabs')) {
        within_settabs = true;
        send(stamp(event));
      //.......................................................................................................
      } else if (select(event, ')', 'set-tabs')) {
        within_settabs = false;
        send(stamp(event));
      //.......................................................................................................
      } else if (within_settabs && (select(event, '.', 'text'))) {
        [type, name, text, meta] = event;
        send(['tex', `\\TabPositions{${text}}`]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$tiny = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '(', 'tiny')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        send(['tex', "{\\mktsTiny{}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'tiny')) {
        send(stamp(event));
        send(['tex', "}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$red = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '(', 'red')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        send(['tex', "{\\mktsRed{}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'red')) {
        send(stamp(event));
        send(['tex', "}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$readings = (S) => {
    /* TAINT can't nest reading tags */
    var within;
    within = false;
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      if (select(event, '(', 'read-ja')) {
        within = true;
        send(stamp(event));
        send(['tex', "{\\thinspace\\cjk\\mktsReadJa{}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'read-ja')) {
        within = false;
        send(stamp(event));
        send(['tex', "\\thinspace}"]);
      //.......................................................................................................
      } else if (within && select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        // send stamp event
        text = this.MKTX.TYPOFIX.escape_tex_specials(text);
        send(['tex', text]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$font = (S) => {
    var schema, validate_and_cast, within;
    within = false;
    schema = {
      postprocess: function(Q) {
        var ref;
        switch ((ref = Q.cjk) != null ? ref : null) {
          case '':
          case 'true':
            Q.cjk = true;
            break;
          case null:
          case 'false':
            Q.cjk = false;
            break;
          default:
            throw new Error(`^mkts@4453^ unexpected value for attribute \`cjk\` in ${jr(Q)}`);
        }
        return Q;
      },
      properties: {
        name: {
          type: 'string'
        },
        cjk: {
          type: ['string', 'boolean']
        }
      },
      //.......................................................................................................
      additionalProperties: false
    };
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, cjk, fontnick, meta, name, text, type;
      if (select(event, '(', 'font')) {
        within = true;
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        /* TAIT code duplication with $fontnick() */
        if (!((Q.name.length > 0) || (Q.name.toLowerCase() === Q.name))) {
          throw new Error(`^3398^ not a valid fontnick: ${rpr(Q.name)}`);
        }
        fontnick = Q.name[0].toUpperCase() + Q.name.slice(1);
        cjk = Q.cjk ? '\\cjk' : '';
        send(['tex', `{${cjk}\\mktsFontfile${fontnick}{}`]);
      //.......................................................................................................
      } else if (select(event, ')', 'font')) {
        within = false;
        send(['tex', "}"]);
      //.......................................................................................................
      } else if (within && select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        text = this.MKTX.TYPOFIX.escape_tex_specials(text);
        send(['tex', text]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$fontnick = (S) => {
    var within;
    within = false;
    //.........................................................................................................
    return $((event, send) => {
      var fontname, fontnick, meta, name, text, type;
      if (select(event, '(', 'fontnick')) {
        within = true;
        send(stamp(event));
      // send [ 'tex', "{\\mktsFontfile#{fontnick}{}", ]
      //.......................................................................................................
      } else if (select(event, ')', 'fontnick')) {
        within = false;
      // send [ 'tex', "}", ]
      //.......................................................................................................
      } else if (within && select(event, '.', 'text')) {
        [type, name, fontnick, meta] = event;
        /* TAIT code duplication with $font() */
        if (!((fontnick.length > 0) || (fontnick.toLowerCase() === fontnick))) {
          throw new Error(`^3392^ not a valid fontnick: ${rpr(fontnick)}`);
        }
        if ((fontname = this.options.filenames_by_fontnicks[fontnick]) == null) {
          throw new Error(`^mkts@3822^ unknown fontnick ${rpr(fontnick)}`);
        }
        fontnick = fontnick[0].toUpperCase() + fontnick.slice(1);
        text = this.MKTX.TYPOFIX.escape_tex_specials(fontname);
        send(['tex', '{\\mktsStyleCode{}']);
        send(['tex', text]);
        send(['tex', '}']);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$strike = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '(', 'strike')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        send(['tex', "{\\mktsStrike{}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'strike')) {
        send(stamp(event));
        send(['tex', "}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$scale = (S) => {
    var block_stack, schema, validate_and_cast;
    schema = {
      postprocess: function(Q) {
        if (Q.lines != null) {
          if (Q.lines === '') {
            Q.lines = true;
          }
        } else {
          Q.lines = false;
        }
        return Q;
      },
      //.......................................................................................................
      properties: {
        abs: {
          type: 'number'
        },
        rel: {
          type: 'number'
        },
        lines: {
          type: ['boolean', 'string']
        }
      },
      //.......................................................................................................
      additionalProperties: false,
      oneOf: [
        {
          required: ['abs']
        },
        {
          required: ['rel']
        }
      ]
    };
    //.........................................................................................................
    validate_and_cast = OVAL.new_validator(schema);
    block_stack = [];
    //.........................................................................................................
    return $((event, send) => {
      var Q, brace, command, factor, is_block, meta, name, par, ref, type;
      if (select(event, ['(', '.'], 'scale')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        //.....................................................................................................
        if (Q.abs != null) {
          factor = Q.abs;
          command = 'mktsScaleText';
        } else {
          factor = Q.rel;
          command = 'mktsScaleTextRelative';
        }
        //.....................................................................................................
        block_stack.push(Q.lines);
        brace = type === '(' ? '{' : '';
        send(['tex', `${brace}\\${command}{${factor}}`]);
      //.......................................................................................................
      } else if (select(event, ')', 'scale')) {
        send(stamp(event));
        is_block = (ref = block_stack.pop()) != null ? ref : false;
        par = is_block ? '\\par' : '';
        send(['tex', `${par}}`]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$stretch = (S) => {
    var schema, validate_and_cast;
    schema = {
      properties: {
        abs: {
          type: 'number'
        },
        rel: {
          type: 'number'
        }
      },
      //.......................................................................................................
      additionalProperties: false,
      oneOf: [
        {
          required: ['abs']
        },
        {
          required: ['rel']
        }
      ]
    };
    //.........................................................................................................
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, brace, command, factor, factor_txt, meta, name, type;
      if (select(event, ['(', '.'], 'stretch')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        //.....................................................................................................
        if (Q.abs != null) {
          factor = Q.abs;
          command = 'mktsStretchLinesAbsolute';
        } else {
          factor = Q.rel;
          command = 'mktsStretchLinesRelative';
        }
        //.....................................................................................................
        factor_txt = (factor.toFixed(6)).replace(/\.?0+$/, '');
        brace = type === '(' ? '{' : '';
        send(['tex', `${brace}\\${command}{${factor}}`]);
      //.......................................................................................................
      } else if (select(event, ')', 'stretch')) {
        send(stamp(event));
        send(['tex', "\\par}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$vspace = (S) => {
    var schema, validate_and_cast;
    schema = {
      properties: {
        abs: {
          type: 'number'
        },
        rel: {
          type: 'number'
        }
      },
      //.......................................................................................................
      additionalProperties: false,
      oneOf: [
        {
          required: ['abs']
        },
        {
          required: ['rel']
        }
      ]
    };
    //.........................................................................................................
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, command, factor, meta, name, type;
      if (select(event, '.', 'vspace')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        //.....................................................................................................
        if (Q.abs != null) {
          factor = Q.abs;
          command = 'mktsVspaceAbsolute';
        } else {
          factor = Q.rel;
          command = 'mktsVspaceRelative';
        }
        //.....................................................................................................
        send(['tex', `\\par\\${command}{${factor}}`]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$landscape = (S) => {
    var open_tag_count, schema, validate_and_cast;
    open_tag_count = 0;
    schema = {
      additionalProperties: false
    };
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, ['(', '.'], 'landscape')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        open_tag_count += +1;
        send(['tex', "\\begin{landscape}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'landscape')) {
        send(['tex', "\\end{landscape}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        while (open_tag_count > 0) {
          open_tag_count += -1;
          send(['tex', "\\end{landscape}"]);
        }
        send(event);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$samepage = (S) => {
    /* TAINT code duplication from `$landscape` */
    var open_tag_count, schema, validate_and_cast;
    open_tag_count = 0;
    schema = {
      additionalProperties: false
    };
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, ['(', '.'], 'samepage')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        open_tag_count += +1;
        send(['tex', "\\begin{mktsSamepage}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'samepage')) {
        send(['tex', "\\end{mktsSamepage}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        while (open_tag_count > 0) {
          open_tag_count += -1;
          send(['tex', "\\end{mktsSamepage}"]);
        }
        send(event);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$clearpage = (S) => {
    /* TAINT code duplication from `$landscape` */
    var schema, validate_and_cast;
    schema = {
      additionalProperties: false
    };
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '.', 'clearpage')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        send(stamp(event));
        send(['tex', "\\clearpage{}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @MKTX.BLOCK.$pre = ( S ) =>
  //   MACRO_ESCAPER.register_raw_tag 'pre'
  //   schema            =
  //     properties:           {}
  //     additionalProperties: false
  //   validate_and_cast = OVAL.new_validator schema
  //   within_pre        = false
  //   #.........................................................................................................
  //   return $ ( event, send ) =>
  //     if select event, [ '(', '.', ], 'pre'
  //       send stamp event
  //       if within_pre
  //         return send [ '.', 'warning', "can't nest <pre> within <pre>: #{rpr event}", ( copy meta ), ]
  //       [ type, name, Q, meta, ]  = event
  //       { text, attributes, }     = Q
  //       attributes                = validate_and_cast attributes
  //       within_pre                = true
  //     #.......................................................................................................
  //     else if select event, ')', 'pre'
  //       within_pre = false
  //     #.......................................................................................................
  //     else
  //       if within_pre
  //         debug '44932', 'pre', event
  //       else
  //         send event
  //     #.......................................................................................................
  //     return null

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$nudge = (S) => {
    var schema, validate_and_cast;
    schema = {
      properties: {
        push: {
          type: 'number'
        },
        raise: {
          type: 'number'
        }
      },
      //.......................................................................................................
      additionalProperties: false
    };
    // oneOf: [ { required: [ 'push', ], }, { required: [ 'raise', ], }, ]
    validate_and_cast = OVAL.new_validator(schema);
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, push, raise, ref, ref1, type;
      if (select(event, '(', 'nudge')) {
        [type, name, Q, meta] = event;
        Q = validate_and_cast(Q);
        push = (ref = Q.push) != null ? ref : 0;
        if (!CND.isa_number(push)) {
          throw new Error(`expected a number for push, got ${rpr(event)}`);
        }
        raise = (ref1 = Q.raise) != null ? ref1 : 0;
        if (!CND.isa_number(raise)) {
          throw new Error(`expected a number for raise, got ${rpr(event)}`);
        }
        send(stamp(event));
        return send(['tex', `{\\mktstfPushRaise{${push}}{${raise}}`]);
      //.......................................................................................................
      } else if (select(event, ')', 'nudge')) {
        send(stamp(event));
        return send(['tex', "}"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$turn = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, angle, meta, name, ref, type;
      if (select(event, '(', 'turn')) {
        [type, name, Q, meta] = event;
        angle = (ref = Q.angle) != null ? ref : '90';
        angle = parseFloat(angle);
        if (!CND.isa_number(angle)) {
          throw new Error(`expected a number for angle, got ${rpr(event)}`);
        }
        send(stamp(event));
        return send(['tex', `\\mktsTurn{${angle}}{`]);
      //.......................................................................................................
      } else if (select(event, ')', 'turn')) {
        send(stamp(event));
        return send(['tex', "}"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$xfsc = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '.', 'xfsc')) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        return send(['tex', `\\mktsXfsc{${Q.sc}}{${Q.symbol}}`]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$text_alignment = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, p, type;
      if (select(event, ['(', '.'], ['left', 'right', 'center', 'justify'])) {
        [type, name, Q, meta] = event;
        p = name[0].toUpperCase() + name.slice(1);
        if (type === '.') {
          send(['tex', `\\mkts${p}{}`]);
        } else {
          send(['tex', `{\\mkts${p}{}`]);
        }
        return send(stamp(event));
      //.......................................................................................................
      } else if (select(event, ')', ['left', 'right', 'center', 'justify'])) {
        [type, name, Q, meta] = event;
        send(['tex', "\\par}\n"]);
        return send(stamp(event));
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$hfill = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, type;
      if (select(event, '.', ['hfil', 'hfill'])) {
        [type, name, Q, meta] = event;
        send(stamp(event));
        return send(['tex', `\\${name}{}`]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$here_x = (S) => {
    var prv_nr;
    prv_nr = 0;
    //.........................................................................................................
    return $((event, send) => {
      var Q, meta, name, prefix, type;
      if (select(event, '.', 'here-x')) {
        send(stamp(event));
        [type, name, Q, meta] = event;
        prefix = name.slice(0, name.length - 2);
        prv_nr += +1;
        if (Q.key == null) {
          Q.key = `h${prv_nr}`;
        }
        return send(['tex', `\\${prefix}x{${Q.key}}`]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$insert = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var Q, content, meta, name, path, ref, type;
      if (select(event, '.', 'insert')) {
        send(stamp(event));
        [type, name, Q, meta] = event;
        path = HELPERS.resolve_document_relative_path(S, Q.src);
        content = njs_fs.readFileSync(path, {
          encoding: 'utf-8'
        });
        switch ((ref = Q.mode) != null ? ref : 'literal') {
          case 'literal':
            return send(['.', 'text', content, copy(meta)]);
          case 'mktscript':
            return send(['.', 'mktscript', '<document/>' + content, copy(meta)]);
          case 'raw':
            return send(['tex', content]);
          default:
            return send(['.', 'warning', `unknown mode ${rpr(Q.mode)} in ${rpr(event)}`, copy(meta)]);
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$custom_entities = (S) => {
    /* Define custom XML entities in `options.coffee` under key `entities` */
    //.........................................................................................................
    return $((event, send) => {
      var _, entry, key, meta;
      if (select(event, '.', 'entity')) {
        [_, _, key, meta] = event;
        entry = S.options.entities[key];
        if (entry == null) {
          //.....................................................................................................
          return send(event);
        }
        if (!((entry.type != null) && (entry.value != null))) {
          send(['.', 'warning', `entry for entity ${rpr(key)} needs both 'type' and 'value', got ${rpr(entry)}`, copy(meta)]);
          return null;
        }
        //.....................................................................................................
        switch (entry.type) {
          case 'text':
            send(['.', 'text', entry.value, copy(meta)]);
            send(stamp(event));
            break;
          case 'tex':
            send(['tex', entry.value]);
            send(stamp(event));
            break;
          default:
            send(event);
        }
      //.......................................................................................................
      } else if (select(event, '.', 'spurious-ampersand')) {
        [_, _, key, meta] = event;
        send(['.', 'warning', `spurious ampersand ${rpr(key)}`, copy(meta)]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$fontlist = (S) => {
    var buffer, within_fontlist;
    within_fontlist = false;
    buffer = [];
    //.........................................................................................................
    return $((event, send) => {
      var i, len, meta, name, ref, sample, shortname, tex, texname, text, type;
      //.......................................................................................................
      if (select(event, '(', 'fontlist')) {
        send(stamp(event));
        within_fontlist = true;
      //.......................................................................................................
      } else if (select(event, ')', 'fontlist')) {
        send(stamp(event));
        within_fontlist = false;
        sample = buffer.join('');
        buffer.length = 0;
        //.....................................................................................................
        send(['tex', "\\begin{tabbing}\n"]);
        send(['tex', "\\phantom{XXXXXXXXXXXXXXXXXXXXXXXXX} \\= \\phantom{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX} \\\\\n"]);
        ref = S.options['fonts']['files'];
        //.....................................................................................................
        for (i = 0, len = ref.length; i < len; i++) {
          ({texname} = ref[i]);
          shortname = texname.replace(/^mktsFontfile/, '');
          tex = `${shortname} \\> {\\${texname}{}${sample}} \\\\\n`;
          send(['tex', tex]);
        }
        //.....................................................................................................
        send(['tex', "\\end{tabbing}\n"]);
      //.......................................................................................................
      } else if (within_fontlist && select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        // send stamp event
        buffer.push(text);
      } else {
        //.......................................................................................................
        if (within_fontlist) {
          [type, name, text, meta] = event;
          send(['.', 'warning', `ignoring event ${type}`, copy(meta != null ? meta : {})]);
        } else {
          send(event);
        }
      }
      //.......................................................................................................
      return null;
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$blockquote = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      if (select(event, '(', 'blockquote')) {
        // [ type, name, parameters, meta, ] = event
        send(stamp(event));
        // send [ 'tex', "{\\setlength{\\leftskip}{5mm}\\setlength{\\rightskip}{5mm}", ]
        return send(['tex', "\\begin{mktsEnvBlockquote}"]);
      //.......................................................................................................
      } else if (select(event, ')', 'blockquote')) {
        // [ type, name, parameters, meta, ] = event
        send(stamp(event));
        // send [ 'tex', "}\n\n", ]
        return send(['tex', "\\end{mktsEnvBlockquote}\n\n"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$paragraph_1 = (S) => {
    /* TAINT should unify the two observers */
    var track;
    track = MD_READER.TRACKER.new_tracker('(code)', '(keep-lines)');
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type, within_code, within_keep_lines;
      within_code = track.within('(code)');
      within_keep_lines = track.within('(keep-lines)');
      track(event);
      //.......................................................................................................
      if (select(event, '.', 'p')) {
        [type, name, text, meta] = event;
        if (within_code || within_keep_lines) {
          send(stamp(event));
          // send [ 'tex', "\n%% PARAGRAPH ##{S.paragraph_nr})\n" ]
          return send(['tex', '\n\n']);
        } else {
          // send [ 'tex', "\n%% PARAGRAPH ##{S.paragraph_nr})\n" ]
          send(stamp(event));
          return send(this.MKTX.BLOCK._end_paragraph());
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$paragraph_2 = (S) => {
    var close_paragraph, collector, has_noindent_tag, is_first_par, seen_text_event, within_noindent, within_paragraph;
    within_paragraph = false;
    seen_text_event = false;
    collector = [];
    close_paragraph = false;
    within_noindent = false;
    is_first_par = true;
    has_noindent_tag = false;
    // is_fresh            = true
    //.........................................................................................................
    return $((event, send) => {
      var cached_event, has_indent, i, j, len, len1;
      if (select(event, '(', ['h', 'multi-columns', 'blockquote'], true)) {
        is_first_par = true;
      }
      if (select(event, ')', ['blockquote', 'ul', 'code'], true)) {
        is_first_par = true;
      }
      if (select(event, '.', ['hr', 'hr2'], true)) {
        is_first_par = true;
      }
      if (select(event, '(', ['ul', 'keep-lines'], true)) {
        within_noindent = true;
      }
      if (select(event, ')', ['ul', 'keep-lines'], true)) {
        within_noindent = false;
      }
      // if select event, '(', [ 'h',                                ],  true then is_fresh            = false
      //.......................................................................................................
      if (select(event, '.', 'noindent')) {
        send(stamp(event));
        return has_noindent_tag = true;
      //.......................................................................................................
      } else if (select(event, '~', 'start-paragraph', true)) {
        within_paragraph = true;
        seen_text_event = false;
        return S.paragraph_nr += +1;
      // send [ 'tex', "\n%% (PARAGRAPH ##{S.paragraph_nr}\n" ]
      //.......................................................................................................
      } else if (select(event, '.', 'p')) {
        has_noindent_tag = false;
        within_paragraph = false;
        seen_text_event = false;
        for (i = 0, len = collector.length; i < len; i++) {
          cached_event = collector[i];
          // send [ 'tex', "\n}\n" ]
          send(cached_event);
        }
        collector.length = 0;
        if (close_paragraph) {
          return close_paragraph = false;
        }
      // send [ 'tex', "\n}% )p\n" ]
      //.......................................................................................................
      } else if (within_paragraph) {
        if (seen_text_event) {
          /* If we're within a paragraph, but some material has aleady gone down the line, then there's
          nothing to do here: */
          return send(event);
        } else {
          /* Otherwise, we either have to cache the current event, or else—if the current event is a text
          event—we have to send all cached events, then the prefix to a new paragraph, and then the text event
          itself. */
          if (!select(event, '.', 'text')) {
            return collector.push(event);
          } else {
            seen_text_event = true;
            close_paragraph = true;
            for (j = 0, len1 = collector.length; j < len1; j++) {
              cached_event = collector[j];
              //.................................................................................................
              /* Send all the events encountered so far; typically, these will include commands to set up
              columns etc.: */
              send(cached_event);
            }
            collector.length = 0;
            //.................................................................................................
            /* Check whether we're typesetting the first text portion after a headline, the start of a
            blockquote or similar and send additional material as needed: */
            has_indent = !is_first_par;
            is_first_par = false;
            //.................................................................................................
            if (within_noindent || has_noindent_tag || (!has_indent)) { // or is_fresh
              // is_fresh = false
              null;
            } else {
              send(['tex', "\\mktsIndent{}"]);
            }
            // send [ 'tex', "¶ " ]
            //.................................................................................................
            /* Finally, send the first text portion of the paragraph itself: */
            return send(event);
          }
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK._end_paragraph = () => {
    /* TAINT use command from sty */
    /* TAINT make configurable */
    // return [ 'tex', '\\mktsShowpar\\par\n' ]
    return ['tex', '\n\n'];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$unordered_list = (S) => {
    var item_markup_tex, tex_by_md_markup;
    tex_by_md_markup = {
      '*': '$\\star$',
      'fallback': '—'
    };
    item_markup_tex = null;
    //.........................................................................................................
    return $((event, send) => {
      var markup, meta, name, ref, text, type;
      //.......................................................................................................
      if (select(event, '(', 'ul')) {
        [type, name, text, meta] = event;
        ({markup} = meta);
        item_markup_tex = (ref = tex_by_md_markup[markup]) != null ? ref : tex_by_md_markup['fallback'];
        return send(stamp(event));
      // send [ 'tex', '\\begin{itemize}' ]
      //.......................................................................................................
      } else if (select(event, '(', 'li')) {
        send(stamp(event));
        // send [ 'tex', "\\item[#{item_markup_tex}] " ]
        // send [ 'tex', "{\\mktsFontfileHanamina{}.⚫.▪.⏹.◼.⬛.}\\hspace{3mm}y" ]
        /* TAINT Horizontal space should depend on other metrics */
        // send [ 'tex', "{\\mktsFontfileHanamina{}\\mktstfPushRaise{-0.4}{-0.1}{⚫}\\hspace{-0.75mm}}" ]
        // send [ 'tex', "{\\mktsFontfileCwtexqheibold{}\\mktstfPushRaise{-0.4}{-0.1}{▷}\\hspace{-1.75mm}}" ]
        // send [ 'tex', "{\\mktsFontfileHanamina{}◼}\\hspace{3mm}L" ]
        // send [ 'tex', "{\\mktsFontfileCwtexqheibold{}\\mktstfPushRaise{-0.4}{-0.1}{▷}}" ]
        return send(['tex', S.options.entities['ulsymbol']['value']]);
      //.......................................................................................................
      } else if (select(event, ')', 'li')) {
        send(stamp(event));
        return send(['tex', '\n']);
      //.......................................................................................................
      } else if (select(event, ')', 'ul')) {
        return send(stamp(event));
      } else {
        // send [ 'tex', '\\end{itemize}' ]
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  // # before '$hr2', '@MKTX.REGION.$single_column', '@MKTX.REGION.$multi_column', \
  this.MKTX.BLOCK.$hr = (S) => {
    return $((event, send) => {
      var meta, name, parameters, text, type;
      //.........................................................................................................
      if (select(event, '.', 'hr')) {
        [type, name, text, meta] = event;
        parameters = {
          slash: false,
          above: 0,
          one: '-',
          two: null,
          three: null,
          below: 0
        };
        send(['.', 'hr2', parameters, copy(meta)]);
        return send(stamp(event));
      } else {
        //.........................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  // before '@MKTX.REGION.$single_column', '@MKTX.REGION.$multi_column', \
  this.MKTX.BLOCK.$hr2 = (S) => {
    // plain_rule  = [ 'tex', "\\mktsRulePlain{}", ]
    // swell_rule  = [ 'tex', "\\mktsRuleSwell{}", ]
    // tight_rule  = [ 'tex', "\\mktsRulePlainTight{}", ]
    /*

    / slash
    - plain (line)
    = bold (line)
    -= plain with bold (2 stacked lines)
    =- bold with plain (2 stacked lines)
    -=- plain, bold, plain (3 stacked lines)
    . dotted (line)
    * asterisks (line)
    + swole (line)
    0 compress (above & below; default)
    1 normal (spacing, one line above & below)
    2,1 custom (2 above, 1 below)
    2 splendid (2 above & below)

    // <!-- just a slash -->
    /0-------/
    0-------
    /2+++++2/
    /0--------============1/
     */
    //.........................................................................................................
    return $((event, send) => {
      var above, below, i, len, meta, mid, name, one, parameters, results, rule_command, slash, sub_event, sub_events, three, two, type;
      // #.......................................................................................................
      // ### re-interpret `<hr>`: ###
      // if select event, '(', 'hr'
      //   is_synthetic_event                        = true
      //   [ type, name, parameters, meta, ]         = event
      //   event[ 0 ]                                = '.'
      //   event[ 1 ]                                = 'hr2'
      //   event[ 2 ]                                = { slash: false, above: 0, one: '-', two: null, three: null, below: 0 }
      // #.......................................................................................................
      // if select event, ')', 'hr'
      //   return send stamp event
      //.......................................................................................................
      if (select(event, '.', 'hr2')) {
        send(stamp(event));
        [type, name, parameters, meta] = event;
        ({slash, above, one, two, three, below} = parameters);
        switch (one) {
          case '-':
            rule_command = 'mktsRulePlainTight';
            break;
          case '=':
            rule_command = 'mktsRuleBoldTight';
            break;
          case '#':
            rule_command = 'mktsRuleBlackTight';
            break;
          case '+':
            rule_command = 'mktsRuleEnglish';
            break;
          case '°':
            rule_command = 'mktsRuleZero';
            break;
          default:
            return send(['.', 'warning', `unknown hrule markup ${rpr(one)}`, copy(meta)]);
        }
        below += -1;
        sub_events = [];
        if (above !== 0) {
          sub_events.push(['tex', `\\mktsVspace{${above}}`]);
        }
        sub_events.push(['tex', `\\${rule_command}{}`]);
        if (below !== 0) {
          sub_events.push(['tex', `\\mktsVspace{${below}}`]);
        }
        sub_events.push(['tex', "\n\n"]);
        if (slash) {
          // send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{above}}%TEX-WRITER/$hr2\n", ]
          // send [ '!', 'slash', null, ( copy meta ), ]
          mid = sub_events;
          return send(['!', 'slash', {above, mid, below}, copy(meta)]);
        } else {
          results = [];
          for (i = 0, len = sub_events.length; i < len; i++) {
            sub_event = sub_events[i];
            // send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{above}}\\mktsVspace{}" ] if above > 0
            // send [ 'tex', "\\mktsRulePlainTight{}", ]
            // send [ 'tex', "\\gdef\\mktsNextVspaceCount{#{below}}\\mktsVspace{}" ] if below > 0
            // send [ 'tex', "\n\n" ]
            results.push(send(sub_event));
          }
          return results;
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$echo = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var _, meta, parameters;
      //.......................................................................................................
      if (select(event, '!', 'echo')) {
        [_, _, parameters, meta] = event;
        send(stamp(event));
        return send(['.', 'text', rpr(parameters), copy(meta)]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.BLOCK.$nl = (S) => {
    /* TAINT consider to zero-width non-breaking space */
    var nl;
    nl = ['tex', "~\\\\\n"];
    //.........................................................................................................
    return $((event, send) => {
      var _, count, i, meta, name, ref, results, type;
      //.......................................................................................................
      if (select(event, '!', 'nl')) {
        [type, name, [count], meta] = event;
        results = [];
        for (_ = i = 0, ref = count != null ? count : 1; i < ref; _ = i += +1) {
          results.push(send(nl));
        }
        return results;
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$code_span = (S) => {
    var within_code_span, within_em, within_smallcaps;
    within_smallcaps = false;
    within_em = false;
    within_code_span = false;
    //.........................................................................................................
    return $((event, send) => {
      var _, fragment, fragments, i, idx, last_idx, len, meta, results, text;
      //.......................................................................................................
      if (select(event, '(', ['smallcaps-lower'], true)) {
        send(event);
        within_smallcaps = true;
      //.......................................................................................................
      } else if (select(event, ')', ['smallcaps-lower'], true)) {
        send(event);
        within_smallcaps = false;
      }
      //.......................................................................................................
      if (select(event, '(', ['em'], true)) {
        send(event);
        return within_em = true;
      //.......................................................................................................
      } else if (select(event, ')', ['em'], true)) {
        send(event);
        return within_em = false;
      //.......................................................................................................
      } else if (select(event, '(', ['code-span', 'tt'])) {
        send(stamp(event));
        if (within_em) {
          send(['tex', '{\\mktsStyleCodeItalic{}']);
        } else if (within_smallcaps) {
          send(['tex', '{\\mktsStyleCode{}\\mktsUnderline{']);
        } else {
          send(['tex', '{\\mktsStyleCode{}']);
        }
        return within_code_span = true;
      //.......................................................................................................
      } else if (select(event, ')', ['code-span', 'tt'])) {
        send(stamp(event));
        if (within_smallcaps) {
          send(['tex', "}}"]);
        } else {
          send(['tex', "}"]);
        }
        return within_code_span = false;
      //.......................................................................................................
      } else if (select(event, '(', ['code-box', 'tt'])) {
        send(stamp(event));
        /* NOTE can dispend with `\makebox` as underline inhibits linebreaks as well */
        if (within_smallcaps) {
          send(['tex', '{\\mktsStyleCode{}\\mktsUnderline{']);
        } else {
          send(['tex', '\\makebox{{\\mktsStyleCode{}']);
        }
        return within_code_span = true;
      //.......................................................................................................
      } else if (select(event, ')', ['code-box', 'tt'])) {
        send(stamp(event));
        send(['tex', "}}"]);
        return within_code_span = false;
      //.......................................................................................................
      } else if (within_code_span && select(event, '.', 'text')) {
        [_, _, text, meta] = event;
        //.....................................................................................................
        /* TAINT sort-of code duplication with command url */
        fragments = LINEBREAKER.fragmentize(text);
        last_idx = fragments.length - 1;
//.....................................................................................................
        results = [];
        for (idx = i = 0, len = fragments.length; i < len; idx = ++i) {
          fragment = fragments[idx];
          send(['.', 'text', fragment, copy(meta)]);
          if (idx !== last_idx) {
            results.push(send(['tex', "\\allowbreak{}"]));
          } else {
            results.push(void 0);
          }
        }
        return results;
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$image = (S) => {
    var alt, alt_cache, event_cache, src, track;
    track = MD_READER.TRACKER.new_tracker('(image)');
    event_cache = [];
    alt_cache = [];
    src = null;
    alt = null;
    //.........................................................................................................
    return $((event, send) => {
      var cached_event, i, len, meta, name, text, type, within_image;
      within_image = track.within('(image)');
      track(event);
      [type, name, text, meta] = event;
      //.......................................................................................................
      if (select(event, '(', 'image')) {
        send(stamp(event));
        return src = HELPERS.resolve_document_relative_path(S, meta['src']);
      // src = njs_path.resolve S.layout_info[ 'source-home' ], meta[ 'src' ]
      //.......................................................................................................
      } else if (select(event, ')', 'image')) {
        alt = alt_cache.join('');
        send(['tex', '\\begin{figure}%\n']);
        /* TAINT escape `src`? */
        // send [ 'tex', "\\includegraphics[width=\\textwidth]{#{src}}%\n", ]
        send(['tex', `\\includegraphics[width=0.8\\linewidth]{${src}}%\n`]);
        // send [ 'tex', "\\includegraphics[width=0.5\\textwidth]{#{src}}%\n", ]
        send(['tex', `\\caption[${alt}]{%\n`]);
        for (i = 0, len = event_cache.length; i < len; i++) {
          cached_event = event_cache[i];
          send(cached_event);
        }
        send(['tex', '}%\n']);
        send(['tex', '\\end{figure}%\n']);
        src = null;
        alt_cache.length = 0;
        return send(stamp(event));
      //.......................................................................................................
      } else if (within_image) {
        event_cache.push(event);
        if (select(event, '.', 'text')) {
          return alt_cache.push(text);
        }
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED.$raw = (S) => {
    var remark;
    remark = MD_READER._get_remark();
    //.........................................................................................................
    return $((event, send) => {
      var Q, attributes, meta, name, text, type;
      //.......................................................................................................
      if (select(event, '.', 'raw')) {
        [type, name, Q, meta] = event;
        send(stamp(hide(copy(event))));
        send(remark('convert', "raw to TeX", copy(meta)));
        ({text, attributes} = Q);
        text = MACRO_ESCAPER.escape.unescape_escape_chrs(S, text);
        // debug '9382', [ 'tex', text, ]
        return send(['tex', text]);
      } else {
        // send stamp event
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED.$table = (S) => {
    var buffer, col_styles, description, remark, row_count, track;
    track = MD_READER.TRACKER.new_tracker('(table)', '(th)');
    remark = MD_READER._get_remark();
    description = null;
    row_count = null;
    col_styles = null;
    buffer = null;
    //.........................................................................................................
    return $((event, send) => {
      var alignment, d, i, idx, j, key, key2, len, len1, meta, name, ref, ref1, ref2, text, type, within_table, within_th;
      [type, name, text, meta] = event;
      key = type + name;
      within_table = track.within('(table)');
      within_th = track.within('(th)');
      track(event);
      if (!(within_table || key === '(table')) {
        //.......................................................................................................
        return send(event);
      }
      //.......................................................................................................
      if (within_th && key === '.text') {
        buffer.push([key, ['(', 'strong', null, copy(meta)]]);
        buffer.push([key, event]);
        return buffer.push([key, [')', 'strong', null, copy(meta)]]);
      //.......................................................................................................
      } else if (key === ')tr') {
        row_count += +1;
        send(stamp(hide(copy(event))));
        /* thx to http://tex.stackexchange.com/a/159260 */
        if (row_count === description['row_count']) {
          return buffer.push([key, ['tex', "\\\\\n"]]);
        } else {
          return buffer.push([key, ['tex', "\\\\\n"]]);
        }
      } else {
        //.....................................................................................................
        //.......................................................................................................
        if (key === '(table') {
          send(stamp(hide(copy(event))));
          buffer = [];
          col_styles = [];
          row_count = 0;
          description = meta['table'];
          ref = description['alignments'];
          for (i = 0, len = ref.length; i < len; i++) {
            alignment = ref[i];
            switch (alignment) {
              case 'left':
                col_styles.push('l');
                break;
              case 'center':
                col_styles.push('c');
                break;
              case 'right':
                col_styles.push('r');
                break;
              default:
                col_styles.push('l');
            }
          }
          return col_styles = '| ' + (col_styles.join(' | ')) + ' |';
        //.....................................................................................................
        } else if (key === ')table') {
          send(stamp(hide(copy(event))));
          send(['tex', `{\\setlength\\lineskiplimit{-1mm}\\relax\\mktsVspace{${row_count / 2}}`]);
          send(['tex', `\\begin{tabular}[pos]{ ${col_styles} }\n`]);
/* send buffered */
//...................................................................................................
          for (idx = j = 0, len1 = buffer.length; j < len1; idx = ++j) {
            [key2, d] = buffer[idx];
            if (d == null) {
              continue;
            }
            if (key2 === ')th' || key2 === ')td') {
              if ((ref1 = (ref2 = buffer[idx + 1]) != null ? ref2[0] : void 0) === '(th' || ref1 === '(td') {
                send(d);
              }
            } else {
              send(d);
            }
          }
          //...................................................................................................
          send(['tex', `\\hline\\end{tabular}\\mktsVspace{${row_count / 2}}}\n\n`]);
          description = null;
          row_count = null;
          col_styles = null;
          return buffer = null;
        //.....................................................................................................
        } else if (key === '(tbody' || key === ')tbody' || key === '(tr') {
          return send(stamp(hide(copy(event))));
        //.....................................................................................................
        } else if (key === '(td' || key === '(th') {
          return buffer.push([key, null]);
        //.....................................................................................................
        } else if (key === ')td' || key === ')th') {
          send(stamp(hide(copy(event))));
          return buffer.push([key, ['tex', " & "]]);
        //.....................................................................................................
        } else if (key === '(thead') {
          send(stamp(hide(copy(event))));
          return buffer.push([key, ['tex', "\\hline\n"]]);
        //.....................................................................................................
        } else if (key === ')thead') {
          send(stamp(hide(copy(event))));
          return buffer.push([key, ['tex', "\n\\hline\n"]]);
        } else {
          //.....................................................................................................
          return buffer.push([key, event]);
        }
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED.$footnote = (S) => {
    var style;
    if (S.footnotes != null) {
      /* TAINT should move this to initialization */
      throw new Error("`S.footnotes` already defined");
    }
    S.footnotes = {
      // 'style':      'classic'
      'style': 'on-demand',
      'by-idx': []
    };
    //.........................................................................................................
    switch (style = S.footnotes['style']) {
      case 'classic':
        return this.MKTX.MIXED._$footnote_classic(S);
      case 'on-demand':
        return this.MKTX.MIXED._$footnote_on_demand(S);
      default:
        throw new Error(`unknown footnote style ${rpr(style)}`);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED._$footnote_classic = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      //.......................................................................................................
      if (select(event, '(', 'footnote')) {
        send(stamp(event));
        return send(['tex', "\\footnote{"]);
      //.......................................................................................................
      } else if (select(event, ')', 'footnote')) {
        send(stamp(event));
        return send(['tex', "}"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED._$footnote_on_demand = (S) => {
    /* TAINT TeX codes used here should be made configurable */
    var cache, current_fn_cache, current_fn_idx, first_fn_idx, insert_footnotes, last_fn_idx, last_was_footnote, remark, track;
    cache = S.footnotes['by-idx'];
    current_fn_idx = -1;
    current_fn_cache = -1;
    first_fn_idx = 0;
    last_fn_idx = -1;
    track = MD_READER.TRACKER.new_tracker('(footnote)');
    remark = MD_READER._get_remark();
    last_was_footnote = false;
    //.........................................................................................................
    insert_footnotes = (send, meta) => {
      var fn_cache, fn_event, fn_idx, fn_nr, i, j, len, ref, ref1;
      if (last_fn_idx >= first_fn_idx) {
        // send [ '!', 'mark', '42', ( copy meta ), ]
        // send [ '.', 'p', null, ( copy meta ), ]
        send(['tex', "\n\n"]);
        send(['tex', "\\begin{mktsEnNotes}"]);
        for (fn_idx = i = ref = first_fn_idx, ref1 = last_fn_idx; (ref <= ref1 ? i <= ref1 : i >= ref1); fn_idx = ref <= ref1 ? ++i : --i) {
          fn_nr = fn_idx + 1;
          fn_cache = cache[fn_idx];
          cache[fn_idx] = null;
          // send [ 'tex', "(#{fn_nr})\\,", ]
          send(stamp(['(', 'footnote', null, {}]));
          send(['tex', `{\\mktsEnStyleMarkNotes\\mktsEnMarkBefore${fn_nr}\\mktsEnMarkAfter{}}`]);
          for (j = 0, len = fn_cache.length; j < len; j++) {
            fn_event = fn_cache[j];
            send(fn_event);
          }
          send(stamp([')', 'footnote', null, {}]));
        }
        send(['tex', "\\end{mktsEnNotes}\n\n"]);
        first_fn_idx = last_fn_idx + 1;
        return last_fn_idx = first_fn_idx - 1;
      }
    };
    //.........................................................................................................
    return $((event, send) => {
      var fn_nr, fn_separator, meta, name, text, type, within_footnote;
      [type, name, text, meta] = event;
      within_footnote = track.within('(footnote)');
      track(event);
      //.......................................................................................................
      if (select(event, '(', 'footnote')) {
        // send stamp event
        current_fn_cache = [];
        current_fn_idx += +1;
        last_fn_idx = current_fn_idx;
        fn_nr = current_fn_idx + 1;
        cache[current_fn_idx] = current_fn_cache;
        fn_separator = last_was_footnote ? ',' : '';
        // send [ 'tex', "\\mktsEnStyleMark{#{fn_separator}#{fn_nr}}" ]
        return send(['tex', `{\\mktsEnStyleMarkMain{}${fn_separator}${fn_nr}}`]);
      //.......................................................................................................
      } else if (select(event, ')', 'footnote')) {
        // send stamp event
        current_fn_cache = null;
        return last_was_footnote = true;
      //.......................................................................................................
      } else if (within_footnote) {
        current_fn_cache.push(event);
        return send(remark('caching', "event within footnote", event));
      //.......................................................................................................
      } else if ((select(event, '.', 'footnotes')) || (select(event, '!', 'footnotes'))) {
        /* NOTE second for legacy syntax */        send(stamp(event));
        return insert_footnotes(send, meta);
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        insert_footnotes(send, meta);
        return send(event);
      } else {
        //.......................................................................................................
        last_was_footnote = false;
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.MIXED.$footnote.$remove_extra_paragraphs = (S) => {
    var last_event;
    last_event = null;
    //.........................................................................................................
    return $((event, send, end) => {
      if (event != null) {
        //.....................................................................................................
        if (select(event, ')', 'footnote')) {
          if ((last_event != null) && !select(last_event, '.', 'p')) {
            send(last_event);
          }
          last_event = event;
        } else {
          if (last_event != null) {
            //.....................................................................................................
            send(last_event);
          }
          last_event = event;
        }
      }
      //.......................................................................................................
      if (end != null) {
        if (last_event != null) {
          send(last_event);
        }
        return end();
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$translate_i_and_b = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, new_name, text, type;
      //.......................................................................................................
      if (select(event, ['(', ')'], ['i', 'b'])) {
        [type, name, text, meta] = event;
        new_name = name === 'i' ? 'em' : 'strong';
        return send([type, new_name, text, meta]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$super_and_subscript = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, tex_style_name, text, type;
      //.......................................................................................................
      if (select(event, '(', ['sup', 'sub'])) {
        [type, name, text, meta] = event;
        send(stamp(event));
        tex_style_name = name === 'sup' ? 'mktsStyleFontSuperscript' : 'mktsStyleFontSubscript';
        return send(['tex', `{\\${tex_style_name}{}`]);
      //.......................................................................................................
      } else if (select(event, ')', ['sup', 'sub'])) {
        [type, name, text, meta] = event;
        send(stamp(event));
        return send(['tex', "}"]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$mark = (S) => {
    var mark_idx;
    mark_idx = 0;
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      //.......................................................................................................
      if (select(event, '!', 'mark')) {
        [type, name, text, meta] = event;
        send(stamp(event));
        if (text == null) {
          mark_idx += +1;
          text = `a-${mark_idx}`;
        }
        // text = @MKTX.TYPOFIX.fix_typography_for_tex text, S.options
        return send(['tex', `\\mktsMark{${text}}`]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$em_strong_and_smallcaps = (S) => {
    var code_count, em_count, sc_lower_count, sc_upper_count, strong_count, tex_events_by_keys;
    em_count = 0;
    strong_count = 0;
    sc_upper_count = 0;
    sc_lower_count = 0;
    code_count = 0;
    //.........................................................................................................
    tex_events_by_keys = {
      // ____: { start: [], stop: [], }
      ___l: {
        start: ["{\\mktsStyleSmallcapslower{}"],
        stop: ["}"]
      },
      __u_: {
        start: ["{\\mktsStyleSmallcapsupper{}"],
        stop: ["}"]
      },
      __ul: {
        start: ["{\\mktsStyleSmallcapsall{}"],
        stop: ["}"]
      },
      _s__: {
        start: ["{\\mktsStyleBold{}"],
        stop: ["}"]
      },
      _s_l: {
        start: ["{\\mktsStyleBold{}"],
        stop: ["}"]
      },
      _su_: {
        start: ["{\\mktsStyleBold{}"],
        stop: ["}"]
      },
      _sul: {
        start: ["{\\mktsStyleBold{}"],
        stop: ["}"]
      },
      e___: {
        start: ["{\\mktsStyleItalic{}"],
        stop: ["\\/", "}"]
      },
      e__l: {
        start: ["{\\mktsStyleItalicsmallcapslower{}"],
        stop: ["\\/", "}"]
      },
      e_u_: {
        start: ["{\\mktsStyleItalicsmallcapsupper{}"],
        stop: ["\\/", "}"]
      },
      e_ul: {
        start: ["{\\mktsStyleItalicsmallcapsall{}"],
        stop: ["\\/", "}"]
      },
      es__: {
        start: ["{\\mktsStyleBolditalic{}"],
        stop: ["\\/", "}"]
      },
      es_l: {
        start: ["{\\mktsStyleBolditalic{}"],
        stop: ["\\/", "}"]
      },
      esu_: {
        start: ["{\\mktsStyleBolditalic{}"],
        stop: ["\\/", "}"]
      },
      esul: {
        start: ["{\\mktsStyleBolditalic{}"],
        stop: ["\\/", "}"]
      }
    };
    // "{\\mktsStyleBold{}"
    //.........................................................................................................
    return $((event, send) => {
      var delta, i, j, key, len, len1, meta, name, results, start, stop, sub_event, text, type;
      [type, name, text, meta] = event;
      delta = type === '(' ? +1 : -1;
      //.......................................................................................................
      if (select(event, ['(', ')'], ['code', 'code-span'])) {
        code_count += delta;
        return send(event);
      //.......................................................................................................
      } else if (select(event, ['(', ')'], 'smallcaps-upper')) {
        sc_upper_count += delta;
        return send(stamp(event));
      //.......................................................................................................
      } else if (select(event, ['(', ')'], 'smallcaps-lower')) {
        sc_lower_count += delta;
        return send(stamp(event));
      //.......................................................................................................
      } else if (select(event, ['(', ')'], 'em')) {
        em_count += delta;
        return send(stamp(event));
      //.......................................................................................................
      } else if (select(event, ['(', ')'], 'strong')) {
        strong_count += delta;
        return send(stamp(event));
      //.......................................................................................................
      } else if (code_count < 1 && select(event, '.', 'text')) {
        if (/^\s*$/.test(event[2])) {
          /* skip markup when text is blank: */
          return send(event);
        }
        key = [em_count > 0 ? 'e' : '_', strong_count > 0 ? 's' : '_', sc_upper_count > 0 ? 'u' : '_', sc_lower_count > 0 ? 'l' : '_'].join('');
        if (key === '____') {
          return send(event);
        }
        ({start, stop} = tex_events_by_keys[key]);
        for (i = 0, len = start.length; i < len; i++) {
          sub_event = start[i];
          send(['tex', sub_event]);
        }
        send(event);
        results = [];
        for (j = 0, len1 = stop.length; j < len1; j++) {
          sub_event = stop[j];
          results.push(send(['tex', sub_event]));
        }
        return results;
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$link = (S) => {
    var cache, last_href, track;
    cache = [];
    last_href = null;
    track = MD_READER.TRACKER.new_tracker('(link)');
    //.........................................................................................................
    return $((event, send) => {
      var cached_event, i, j, len, len1, meta, name, text, type, within_link;
      within_link = track.within('(link)');
      track(event);
      [type, name, text, meta] = event;
      //.......................................................................................................
      if (select(event, '(', 'link')) {
        send(stamp(event));
        last_href = text;
      //.......................................................................................................
      } else if (select(event, ')', 'link')) {
        // debug '©97721', event
        // debug '©97721', cache
        send(['tex', '{\\mktsStyleLinklabel{}']);
        for (i = 0, len = cache.length; i < len; i++) {
          cached_event = cache[i];
          send(cached_event);
        }
        send(['tex', '}']);
        // send [ '(', 'footnote', null,       ( copy meta ), ]
        // send [ '(', 'url',      null,       ( copy meta ), ]
        // send [ '.', 'text',     last_href,  ( copy meta ), ]
        // send [ '.', 'p',        null,       ( copy meta ), ]
        // send [ ')', 'url',      null,       ( copy meta ), ]
        // send [ ')', 'footnote', null,       ( copy meta ), ]
        send(['(', 'footnote', null, copy(meta)]);
        send(['!', 'url', [last_href], copy(meta)]);
        send(['.', 'p', null, copy(meta)]);
        send([')', 'footnote', null, copy(meta)]);
        cache.length = 0;
        last_href = null;
        send(stamp(event));
      //.......................................................................................................
      } else if (cache.length > 0 && select(event, ')', 'document')) {
        send(['.', 'warning', "missing closing region 'link'", copy(meta)]);
        for (j = 0, len1 = cache.length; j < len1; j++) {
          cached_event = cache[j];
          send(cached_event);
        }
        send(event);
      //.......................................................................................................
      } else if (within_link) {
        cache.push(event);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.INLINE.$url = (S) => {
    var buffer, track;
    track = MD_READER.TRACKER.new_tracker('(url)');
    buffer = [];
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type, within_url;
      within_url = track.within('(url)');
      track(event);
      [type, name, text, meta] = event;
      //.......................................................................................................
      if (select(event, '(', 'url')) {
        return send(stamp(hide(copy(event))));
      //.......................................................................................................
      } else if (select(event, ')', 'url')) {
        send(['!', 'url', [buffer.join('')], copy(meta)]);
        buffer.length = 0;
        return send(stamp(hide(copy(event))));
      //.......................................................................................................
      } else if (within_url && select(event, '.', 'text')) {
        return buffer.push(text);
      //.......................................................................................................
      } else if (within_url) {
        return send(['.', 'warning', `ignoring non-text event inside \`(url)\`: ${rpr(event)}`]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.COMMAND.$url = (S) => {
    //.........................................................................................................
    return $((event, send) => {
      var fragment, fragments, i, idx, last_idx, len, meta, name, parameters, segment, slashes, type, url;
      //.......................................................................................................
      if (select(event, '!', 'url')) {
        [type, name, parameters, meta] = event;
        send(stamp(event));
        [url] = parameters;
        if (url == null) {
          return send(['.', 'warning', "missing required argument for `<<!url>>`", copy(meta)]);
        }
        //.....................................................................................................
        /* TAINT sort-of code duplication with inline code */
        fragments = LINEBREAKER.fragmentize(url);
        last_idx = fragments.length - 1;
        //.....................................................................................................
        send(['tex', "{\\mktsStyleUrl{}"]);
//.....................................................................................................
        for (idx = i = 0, len = fragments.length; i < len; idx = ++i) {
          fragment = fragments[idx];
          [segment, slashes] = fragment.split(/(\/+)$/);
          send(['.', 'text', segment, copy(meta)]);
          if (slashes != null) {
            slashes = '\\g' + (Array.from(slashes)).join('\\g');
            send(['tex', slashes]);
          }
          send(['tex', "\\allowbreak{}"]);
        }
        //.....................................................................................................
        send(['tex', "}"]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @MKTX.COMMAND.$url = ( S ) =>
  //   #.........................................................................................................
  //   return $ ( event, send ) =>
  //     #.......................................................................................................
  //     if select event, '!', 'url'
  //       [ type, name, parameters, meta, ] = event
  //       send stamp event
  //       [ url, ] = parameters
  //       unless url?
  //         return send [ '.', 'warning', "missing required argument for `<<!url>>`", ( copy meta ), ]
  //       #.....................................................................................................
  //       fragments = LINEBREAKER.fragmentize url
  //       last_idx  = fragments.length - 1
  //       for fragment, idx in fragments
  //         unless idx is last_idx
  //           if      fragment.endsWith '//' then fragment = fragment[ .. fragment.length - 3 ] + "\\g/\\g/"
  //           else if fragment.endsWith '/'  then fragment = fragment[ .. fragment.length - 2 ] + "\\g/"
  //         fragments[ idx ] = fragment
  //       url_tex = fragments.join "\\g\\allowbreak{}"
  //       send [ 'tex', "{\\mktsStyleUrl{}", ]
  //       send [ 'tex', url_tex, ]
  //       send [ 'tex', "}", ]
  //     #.......................................................................................................
  //     else
  //       send event

  //===========================================================================================================
  // CLEANUP
  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.CLEANUP.$remove_empty_texts = function(S) {
    var remark;
    remark = MD_READER._get_remark();
    return $((event, send) => {
      var meta, name, text, type;
      if (select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        if (text === '') {
          /* remain silent to make output an easier read */
          null;
          return send(remark('drop', "empty text", copy(meta)));
        } else {
          return send(event);
        }
      } else {
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.CLEANUP.$consolidate_texts = function(S) {
    var collector, first_meta;
    // remark      = MD_READER._get_remark()
    collector = [];
    first_meta = null;
    return $((event, send) => {
      var meta, name, text, type;
      if (select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        if (first_meta == null) {
          first_meta = meta;
        }
        return collector.push(text);
      } else {
        // debug '83726', collector
        if (collector.length > 0) {
          send(['.', 'text', collector.join(''), copy(first_meta)]);
          first_meta = null;
          collector.length = 0;
        }
        return send(event);
      }
    });
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @MKTX.CLEANUP.$drop_empty_p_tags = ( S ) =>
  //   ### TAINT emptyness of  `p` tags ist tested for by counting intermittend `text` events; however, a
  //   paragraph could conceivably also consist of e.g. a single image. ###
  //   text_count  = 0
  //   remark      = MD_READER._get_remark()
  //   #.........................................................................................................
  //   warn "not using `$drop_empty_p_tags` at the moment"
  //   return $ ( event, send ) =>
  //     send event
  // #.........................................................................................................
  // return $ ( event, send ) =>
  //   #.......................................................................................................
  //   ### TAINT bogus selector ###
  //   if select event, [ ')', ]
  //     text_count = 0
  //     send event
  //   #.......................................................................................................
  //   else if select event, '.', 'text'
  //     text_count += +1
  //     send event
  //   #.......................................................................................................
  //   else if select event, '.', 'p'
  //     if text_count > 0
  //       send event
  //     else
  //       [ _, _, _, meta, ] = event
  //       send remark 'drop', "empty `.p`", copy meta
  //     text_count = 0
  //   #.......................................................................................................
  //   else
  //     send event

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.REGION.$correct_p_tags_before_regions = (S) => {
    var last_was_begin_document, last_was_p, remark;
    last_was_p = false;
    last_was_begin_document = false;
    remark = MD_READER._get_remark();
    //.........................................................................................................
    return $((event, send) => {
      var meta;
      // debug '©MwBAv', event
      //.......................................................................................................
      if (select(event, 'tex')) {
        return send(event);
      //.......................................................................................................
      } else if (select(event, '(', 'document')) {
        // debug '©---1', last_was_begin_document
        // debug '©---2', last_was_p
        last_was_p = false;
        last_was_begin_document = true;
        return send(event);
      //.......................................................................................................
      } else if (select(event, '.', 'p')) {
        // debug '©---3', last_was_begin_document
        // debug '©---4', last_was_p
        last_was_p = true;
        last_was_begin_document = false;
        return send(event);
      //.......................................................................................................
      } else if (select(event, ['('])) {
        // debug '©---5', last_was_begin_document
        // debug '©---6', last_was_p
        if ((!last_was_begin_document) && (!last_was_p)) {
          [meta] = slice.call(event, -1);
          // send stamp [ '#', 'insert', my_badge, "inserting `.p` tag", ( copy meta ), ]
          send(remark('insert', "`.p` because region or block opens", copy(meta)));
          send(['.', 'p', null, copy(meta)]);
        }
        send(event);
        last_was_p = false;
        return last_was_begin_document = false;
      } else {
        //.......................................................................................................
        last_was_p = false;
        last_was_begin_document = false;
        return send(event);
      }
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$show_unhandled_tags = (S) => {
    return $((event, send) => {
      /* TAINT selection could be simpler, less repetitive */
      var event_txt, meta, name, text, type;
      [type, name, text, meta] = event;
      if ((type === 'tex') || select(event, '.', ['text', 'raw'])) {
        return send(event);
      } else if ((!is_stamped(event)) && (type !== '~') && (!select(event, '.', 'warning'))) {
        // debug '©04210', JSON.stringify event
        // if text?
        //   if ( CND.isa_pod text )
        //     if ( Object.keys text ).length is 0
        //       text = ''
        //     else
        //       text = rpr text
        // else
        //   text = ''
        // if type in [ '.', '!', ] or type in MKTS.MD_READER.FENCES.left
        //   first             = type
        //   last              = name
        // else
        //   first             = name
        //   last              = type
        // event_txt         = first + last + ' ' + text
        event_txt = `unhandled event: ${jr(event)}`;
        return send(['.', 'warning', event_txt, copy(meta)]);
      } else {
        // send stamp hide copy event
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$show_warnings = (S) => {
    var warnings;
    warnings = [];
    return $((event, send, end) => {
      /* TAINT fix location, use proper file name even for generated mktscript events */
      var col_nr, i, len, line_nr, meta, name, ref, ref1, source_locator, text, type;
      //.......................................................................................................
      if (event != null) {
        if (select(event, '.', 'warning')) {
          [type, name, text, meta] = event;
          line_nr = (ref = meta.line_nr) != null ? ref : '?';
          col_nr = (ref1 = meta.col_nr) != null ? ref1 : '?';
          source_locator = S.layout_info['source-locator'];
          if ((source_locator.match(/<STRING>/)) != null) {
            source_locator = '<STRING>';
          }
          text = `${text} (${source_locator}${line_nr}:${col_nr})`;
          warn('39833-1', text);
          warnings.push(event);
          send(event);
        } else {
          send(event);
        }
      }
      //.......................................................................................................
      if (end != null) {
        if (warnings.length > 0) {
          send(['tex', '\\newpage{}']);
          send(['tex', "{\\mktsHTwo{}\\zlabel{mktsGeneratedWarnings}Generated Warnings}\n\n"]);
          for (i = 0, len = warnings.length; i < len; i++) {
            event = warnings[i];
            [type, name, text, meta] = event;
            warn('39833-2', text);
            send(['.', 'warning', text, copy(meta)]);
            send(['tex', '\\par\n']);
          }
        }
        end();
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$format_warnings = (S) => {
    var self;
    self = this;
    return $async((event, done) => {
      var meta, name, text, type;
      /* TAINT this makes clear why we should not use '.' as type here; `warning` is a meta-event, not
      primarily a formatting instruction */
      //.......................................................................................................
      if (select(event, '.', 'warning')) {
        [type, name, text, meta] = event;
        step(function*(resume) {
          var message, message_event, message_tex;
          message = (yield self.MKTX.TYPOFIX.fix_typography_for_tex(S, text, resume));
          message_tex = `\\begin{mktsEnvWarning}${message}\\end{mktsEnvWarning}`;
          message_event = ['.', Σ_formatted_warning, message_tex, copy(meta)];
          return done(message_event);
        });
      } else {
        //.......................................................................................................
        done(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$warnings_as_tex = (S) => {
    var warnings;
    warnings = [];
    return $((event, send) => {
      var _, i, len, message_tex, meta, tex_event;
      //.......................................................................................................
      if (select(event, '.', Σ_formatted_warning)) {
        [_, _, message_tex, meta] = event;
        tex_event = ['tex', message_tex];
        warnings.push(tex_event);
        send(tex_event);
      //.......................................................................................................
      } else if (select(event, ')', 'document')) {
        if (warnings.length > 0) {
          for (i = 0, len = warnings.length; i < len; i++) {
            tex_event = warnings[i];
            send(tex_event);
            send(['tex', "\n\n"]);
          }
          send(event);
        }
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.MKTX.$consolidate_mktscript_events = function(S) {
    var collector, first_meta;
    // remark      = MD_READER._get_remark()
    collector = [];
    first_meta = null;
    return $((event, send) => {
      var meta, name, text, type;
      if (select(event, '.', 'mktscript')) {
        [type, name, text, meta] = event;
        if (first_meta == null) {
          first_meta = meta;
        }
        return collector.push(text);
      } else {
        // debug '83726', collector
        if (collector.length > 0) {
          send(['.', 'mktscript', collector.join('\n'), copy(first_meta)]);
          first_meta = null;
          collector.length = 0;
        }
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  // xxx_mktscript_nr = 0
  this.MKTX.$mktscript = (S) => {
    var collector, end, processing_mktscript, tex_from_md;
    tex_from_md = promisify(this.tex_from_md.bind(this));
    collector = [];
    processing_mktscript = false;
    end = null;
    return PIPEDREAMS3B7B.$async(async(event, send, end_) => {
      var meta, mktscript, name, tex_source, type;
      if (end_ != null) {
        end = end_;
      }
      if (end != null) {
        return end();
      }
      //.......................................................................................................
      /* Buffer all events: */
      collector.unshift(event);
      if (processing_mktscript) {
        //.......................................................................................................
        /* Postpone all further processing if we're busy:: */
        return null;
      }
      //.......................................................................................................
      while (collector.length > 0) {
        event = collector.pop();
        //.....................................................................................................
        if (event == null) {
          send.done();
          if (end != null) {
            end();
          }
          return null;
        }
        //.....................................................................................................
        if (select(event, '.', 'mktscript')) {
          processing_mktscript = true;
          [type, name, mktscript, meta] = event;
          tex_source = (await tex_from_md(mktscript, {
            bare: true
          }));
          send(['tex', tex_source]);
          send(stamp(event));
          send.done();
          processing_mktscript = false;
        } else {
          //.....................................................................................................
          send(event);
          send.done();
        }
      }
      //.......................................................................................................
      return null;
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.$filter_tex = function(S) {
    /* TAINT reduce number of event types, shapes to simplify this */
    return $((event, send) => {
      var meta, name, text, type;
      [type, name, text, meta] = event;
      if (type === 'tex') {
        return send(event[1]);
      } else if (select(event, '.', ['text', 'raw'])) {
        return send(event[2]);
      } else if ((meta != null ? meta['tex'] : void 0) === 'pass-through') {
        // debug '82341', event
        return send(event);
      } else if (!((type === '~') || (is_stamped(event)))) {
        warn(`unhandled event: ${jr(event)}`);
        return send.error(new Error(`unhandled events not allowed at this point; got ${jr(event)}`));
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$show_events = function(S) {
    return D.$observe((event) => {
      return whisper(JSON.stringify(event));
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$add_text_locators = function(S) {
    var column_stack, event, matches, stack;
    stack = [];
    event = null;
    column_stack = [1];
    matches = function(type, name) {
      return MD_READER.select(event, type, name, true);
    };
    return D.$observe((_event) => {
      var column_count, meta, name, parameter, text, type;
      event = _event;
      [type, name, text, meta] = event;
      if (matches(['~', 'tex'])) {
        return;
      }
      //.......................................................................................................
      if (matches(['(', '!'], ['multi-columns', 'columns'])) {
        if ((parameter = event[2][0]) === 'pop') {
          column_stack.pop();
        } else {
          column_stack.push(parameter);
        }
      //.......................................................................................................
      } else if (matches(['(', '!'], ['multi-columns', 'columns'])) {
        column_stack.pop();
      //.......................................................................................................
      } else if (matches('(')) {
        if (name !== 'document' && name !== 'COLUMNS/group') {
          stack.push(name);
        }
      //.......................................................................................................
      } else if (matches(')')) {
        if (name !== 'document') {
          stack.pop();
        }
      //.......................................................................................................
      } else if (matches('.', 'text')) {
        column_count = column_stack[column_stack.length - 1];
        meta.locator = ['c' + (rpr(column_count)), ...stack].join('/');
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$show_start_and_end_2 = function(S) {
    /* TAINT will buffer all texts */
    var buffer, event_count, is_first, t0, t1;
    is_first = true;
    buffer = [];
    event_count = 0;
    t0 = null;
    t1 = null;
    return $((event, send, end) => {
      var chr_count, cpe_txt, dts, eps_txt/* characters per text event */, max_chr_count, meta, name, raw_text, text, text_count, type;
      //.......................................................................................................
      if (event != null) {
        event_count += +1;
        //.....................................................................................................
        if (is_first) {
          is_first = false;
          t0 = Date.now();
        }
        //.....................................................................................................
        if (select(event, '.', 'text')) {
          [type, name, text, meta] = event;
          buffer.push(text);
        }
        //.....................................................................................................
        send(event);
      }
      //.......................................................................................................
      if (end != null) {
        t1 = Date.now();
        dts = (t1 - t0) / 1000;
        max_chr_count = 200;
        raw_text = buffer.join(' ');
        chr_count = raw_text.length/* NOTE approximate count */
        text_count = buffer.length;
        cpe_txt = (chr_count / text_count).toFixed(1);
        eps_txt = (event_count / dts).toFixed(1);
        if (/* events per second */chr_count > max_chr_count) {
          info('33442', rpr(raw_text.slice(0, max_chr_count) + ' ... ' + raw_text.slice(chr_count - max_chr_count)));
        } else {
          info('33442', rpr(raw_text));
        }
        /* TAINT compare text size with buffer length; characters per text event */
        urge('\n' + `needed ${dts}s for ${event_count} events (${eps_txt} events / s)\n(${buffer.length} text events, ${cpe_txt} chrs / text event)`);
        buffer.length = 0;
        end();
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$show_text_locators = function(S) {
    return D.$observe((event) => {
      var meta, name, ref, text, type;
      if (select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        help(CND.grey('22311'), (CND.lime((ref = meta.locator) != null ? ref : '????????????')) + ' ' + (CND.white(rpr(text))));
      }
      //.......................................................................................................
      return null;
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.create_tex_write_tee = function(S) {
    var R, pipeline, plugin, plugins_tee, readstream, settings, writestream;
    /* TAINT get state via return value of MKTS.create_mdreadstream */
    /* TAINT make execution of `$produce_mktscript` a matter of settings */
    //.......................................................................................................
    readstream = D.create_throughstream();
    writestream = D.create_throughstream();
    // mktscript_in  = D.create_throughstream()
    // mktscript_out = D.create_throughstream()
    //.......................................................................................................
    /* TAINT need a file to write MKTScript text events to; must still send on incoming events */
    // mktscript_in
    //   .pipe MKTSCRIPT_WRITER.$produce_mktscript             S
    //   .pipe mktscript_out
    // mktscript_tee = D.TEE.from_readwritestreams mktscript_in, mktscript_out
    //.......................................................................................................
    /* old plugins: */
    pipeline = (function() {
      var i, len, ref, results;
      ref = MK.TS.plugins;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        plugin = ref[i];
        results.push(plugin.$main(S));
      }
      return results;
    })();
    // plugins_tee = D.TEE.from_pipeline pipeline
    plugins_tee = D.combine(pipeline);
    //.......................................................................................................
    /* new plugins: */
    // .pipe D.$observe ( event ) -> info '23994-1', ( CND.grey '--> ' + ( jr event )[ .. 100 ] )
    // .pipe D.$observe ( event ) -> info ( CND.grey '--------->' ), ( CND.blue event[ 0 ] + event[ 1 ] )
    // .pipe MKTSCRIPT_WRITER.$show_mktsmd_events              S
    // .pipe D.$observe ( event ) -> info '23994-2', ( CND.grey '--> ' + ( jr event )[ .. 100 ] )
    //.......................................................................................................
    /* tags that produce tags */
    //.......................................................................................................
    /* stuff using new HTML-ish syntax */
    // .pipe @MKTX.BLOCK.$pre                                  S
    //.......................................................................................................
    // .pipe @MKTX.INLINE.$smallcaps                           S
    // .pipe @MKTX.INLINE.$em_and_strong                       S
    //.......................................................................................................
    // .pipe @$show_events                                     S
    // .pipe @$show_text_locators                              S
    // .pipe @$show_start_and_end_2                            S
    // .pipe D.$observe ( event ) -> info '23993', ( CND.grey '--------->' ), CND.grey jr event
    // .pipe D.$observe ( event ) -> ( info '23993', ( CND.grey '--------->' ), jr event ) unless event[ 3 ]?.stamped
    //.......................................................................................................
    readstream.pipe(this.MKTX.PLUGINS.$plugins(S)).pipe(this.MKTX.$insert(S)).pipe(this.MKTX.SH.$spawn(S)).pipe(this.MKTX.CALL.$call_await(S)).pipe(this.MKTX.CALL.$call_stream(S)).pipe(this.MKTX.$consolidate_mktscript_events(S)).pipe(this.MKTX.$mktscript(S)).pipe(this.MKTX.INLINE.$custom_entities(S)).pipe(plugins_tee).pipe(MACRO_ESCAPER.$expand.$remove_backslashes(S)).pipe(MKTSCRIPT_WRITER.$produce_mktscript(S)).pipe(this.$document(S)).pipe(this.MKTS_TABLE.$main(S)).pipe(this.MKTX.INLINE.$here_x(S)).pipe(this.MKTX.INLINE.$box(S)).pipe(this.MKTX.INLINE.$tabulation(S)).pipe(this.MKTX.INLINE.$hfill(S)).pipe(this.MKTX.INLINE.$tiny(S)).pipe(this.MKTX.INLINE.$red(S)).pipe(this.MKTX.INLINE.$strike(S)).pipe(this.MKTX.INLINE.$scale(S)).pipe(this.MKTX.INLINE.$readings(S)).pipe(this.MKTX.INLINE.$font(S)).pipe(this.MKTX.INLINE.$fontnick(S)).pipe(this.MKTX.BLOCK.$stretch(S)).pipe(this.MKTX.BLOCK.$vspace(S)).pipe(this.MKTX.BLOCK.$landscape(S)).pipe(this.MKTX.BLOCK.$samepage(S)).pipe(this.MKTX.BLOCK.$clearpage(S)).pipe(this.MKTX.INLINE.$nudge(S)).pipe(this.MKTX.INLINE.$turn(S)).pipe(this.MKTX.INLINE.$fncr(S)).pipe(this.MKTX.INLINE.$xfsc(S)).pipe(this.MKTX.BLOCK.$text_alignment(S)).pipe(this.MKTX.BLOCK.$fontlist(S)).pipe(this.MKTX.BLOCK.$blockquote(S)).pipe(this.MKTX.INLINE.$link(S)).pipe(this.MKTX.MIXED.$footnote(S)).pipe(this.MKTX.MIXED.$footnote.$remove_extra_paragraphs(S)).pipe(this.MKTX.COMMAND.$new_page(S)).pipe(this.MKTX.COMMAND.$new_odd_even_page(S)).pipe(this.MKTX.COMMAND.$blank_page(S)).pipe(this.MKTX.COMMAND.$comment(S)).pipe(this.MKTX.MIXED.$table(S)).pipe(this.MKTX.COMMAND.$echo(S)).pipe(this.MKTX.BLOCK.$hr(S)).pipe(this.MKTX.BLOCK.$hr2(S)).pipe(this.MKTX.BLOCK.$nl(S)).pipe(this.MKTX.REGION.$code(S)).pipe(this.MKTX.REGION.$keep_lines(S)).pipe(this.MKTX.REGION.$toc(S)).pipe(this.MKTX.BLOCK.$heading(S)).pipe(this.MKTX.MIXED.$collect_headings_for_toc(S)).pipe(this.MKTX.COMMAND.$toc(S)).pipe(this.MKTX.BLOCK.$unordered_list(S)).pipe(this.MKTX.INLINE.$code_span(S)).pipe(this.MKTX.INLINE.$url(S)).pipe(this.MKTX.COMMAND.$url(S)).pipe(this.MKTX.INLINE.$super_and_subscript(S)).pipe(this.MKTX.INLINE.$translate_i_and_b(S)).pipe(this.MKTX.INLINE.$em_strong_and_smallcaps(S)).pipe(this.MKTX.INLINE.$image(S)).pipe(this.MKTX.BLOCK.$yadda(S)).pipe(this.MKTX.BLOCK.$paragraph_1(S)).pipe(this.MKTX.MIXED.$raw(S)).pipe(this.COLUMNS.$main(S)).pipe(this.$add_text_locators(S)).pipe(MACRO_INTERPRETER.$capture_change_events(S)).pipe(this.MKTX.CLEANUP.$remove_empty_texts(S)).pipe(this.MKTX.CLEANUP.$consolidate_texts(S)).pipe(this.MKTX.BLOCK.$paragraph_2(S)).pipe(this.MKTX.COMMAND.$crossrefs(S)).pipe(this.MKTX.TYPOFIX.$fix_typography_for_tex(S)).pipe((() => {
      S.event_count = 0;
      return D.$observe((event) => {
        return S.event_count += +1;
      });
    // ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
    // ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
    })()).pipe(this.MKTX.INLINE.$mark(S)).pipe(this.MKTX.$show_unhandled_tags(S)).pipe(this.MKTX.$show_warnings(S)).pipe(this.MKTX.$format_warnings(S)).pipe(this.MKTX.$warnings_as_tex(S)).pipe(this.$filter_tex(S)).pipe(this.COLUMNS.$XXX_transform_pretex_to_tex(S)).pipe(MD_READER.$show_illegal_chrs(S)).pipe(writestream);
    //.......................................................................................................
    settings = {
      // inputs:
      //   mktscript:        mktscript_in
      // outputs:
      //   mktscript:        mktscript_out
      S: S
    };
    //.......................................................................................................
    R = D.TEE.from_readwritestreams(readstream, writestream, settings);
    if (S['tees'] == null) {
      S['tees'] = {};
    }
    S['tees']['tex-writer'] = R;
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._handle_error = (error) => {
    var ref, stack;
    alert(error['message']);
    stack = (ref = error['stack']) != null ? ref : "(no stacktrace available)";
    whisper('\n' + (stack.split('\n')).slice(0, 11).join('\n'));
    whisper('...');
    return process.exit(1);
  };

  //===========================================================================================================
  // PDF FROM MD
  //-----------------------------------------------------------------------------------------------------------
  this._get_on_content_output_close = function(S) {
    return async() => {
      var chr_count_txt, chrs_per_s_txt, dt_s, dt_s_txt, event_count_txt, events_per_s_txt;
      //.......................................................................................................
      await (promisify(this.write_mkts_master.bind(this)))(S);
      await (promisify(HELPERS.write_pdf.bind(HELPERS)))(S.layout_info);
      //.......................................................................................................
      S.t1 = +new Date();
      dt_s = (S.t1 - S.t0) / 1000;
      dt_s_txt = dt_s.toFixed(3);
      chrs_per_s_txt = (S.chr_count / dt_s).toFixed(3);
      events_per_s_txt = (S.event_count / dt_s).toFixed(3);
      chr_count_txt = ƒ(S.chr_count);
      event_count_txt = ƒ(S.event_count);
      help(`${chr_count_txt.padStart(10, ' ')}       chrs (approx.)`);
      help(`${event_count_txt.padStart(10, ' ')}     events (approx.)`);
      help(`${dt_s_txt.padStart(14, ' ')}          s`);
      help(`${chrs_per_s_txt.padStart(14, ' ')}   chrs / s`);
      help(`${events_per_s_txt.padStart(14, ' ')} events / s`);
      return process.exit(0);
    };
  };

  //-----------------------------------------------------------------------------------------------------------
  this._new_state = function(source_route, settings) {
    var R, ref, validate;
    validate = (ref = (settings != null ? settings : {}).validate) != null ? ref : true;
    R = {
      options: this.options,
      layout_info: HELPERS.new_layout_info(this.options, source_route, validate),
      paragraph_nr: 0,
      configuration: {}
    };
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.pdf_from_md = async function(source_route, handler) {
    var RPC_SERVER, S, content_output, md_input, md_output, md_readstream, md_source, server, tex_input, tex_output, tex_writestream;
    RPC_SERVER = require('./rpc-server');
    server = (await (promisify(RPC_SERVER.listen.bind(RPC_SERVER)))());
    process.on('exit', function() {
      help('44092', "RPC server closing");
      return server.close();
    });
    //.......................................................................................................
    S = this._new_state(source_route);
    content_output = njs_fs.createWriteStream(S.layout_info['content-locator']);
    content_output.on('close', this._get_on_content_output_close(S));
    //.......................................................................................................
    /* TAINT should read MD source stream */
    md_source = njs_fs.readFileSync(S.layout_info['source-locator'], {
      encoding: 'utf-8'
    });
    md_readstream = MD_READER.create_md_read_tee(S, md_source);
    tex_writestream = this.create_tex_write_tee(S);
    md_input = md_readstream.tee['input'];
    md_output = md_readstream.tee['output'];
    tex_input = tex_writestream.tee['input'];
    tex_output = tex_writestream.tee['output'];
    //.......................................................................................................
    // S.aux                   = yield AUX.fetch_aux_data S, resume
    S.resend = md_readstream.tee['S'].resend;
    //.......................................................................................................
    md_output.pipe(tex_input);
    tex_output.pipe(content_output);
    //.......................................................................................................
    md_input.resume();
    return null;
  };

  //===========================================================================================================
  // TEX FROM MD
  //-----------------------------------------------------------------------------------------------------------
  XXX_tex_from_md_nr = 0;

  this.tex_from_md = function(md_source, settings, handler) {
    var $collect_and_call, S, arity, layout_info, md_input, md_output, md_readstream, ref, ref1, source_route, tex_input, tex_output, tex_writestream;
    // info 'µ09090', 'tex_from_md', rpr md_source
    /* TAINT code duplication */
    switch (arity = arguments.length) {
      case 2:
        handler = settings;
        settings = {};
        break;
      case 3:
        null;
        break;
      default:
        throw new Error(`expected 2 or 3 arguments, got ${arity}`);
    }
    //.........................................................................................................
    $collect_and_call = (handler) => {
      var Z;
      Z = [];
      return $((event, send, end) => {
        if (event != null) {
          Z.push(event);
        }
        if (end != null) {
          Z = (Z.join('')).replace(/\n\n$/, '');
          handler(null, Z);
          return end();
        }
      });
    };
    //.........................................................................................................
    source_route = (ref = settings['source-route']) != null ? ref : '<STRING>';
    layout_info = HELPERS.new_layout_info(this.options, source_route, false);
    //.........................................................................................................
    /* TAINT use method to produce new state */
    S = this._new_state(source_route, {
      validate: false
    });
    S.bare = (ref1 = settings['bare']) != null ? ref1 : false;
    //.........................................................................................................
    XXX_tex_from_md_nr += +1;
    md_readstream = MD_READER.create_md_read_tee(S, md_source);
    tex_writestream = this.create_tex_write_tee(S);
    md_input = md_readstream.tee['input'];
    md_output = md_readstream.tee['output'];
    tex_input = tex_writestream.tee['input'];
    tex_output = tex_writestream.tee['output'];
    //.........................................................................................................
    // S.aux                   = yield AUX.fetch_aux_data S, resume
    S.resend = md_readstream.tee['S'].resend;
    //.........................................................................................................
    md_output.pipe(tex_input);
    // .pipe D.$show '>>>>>>>>>>>>>>>>>>'
    tex_output.pipe($collect_and_call(handler));
    //.........................................................................................................
    D.run((() => {
      return md_input.resume();
    }), this._handle_error);
    return null;
  };

  //###########################################################################################################
// unless module.parent?
//   # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
//   # @pdf_from_md 'texts/demo'
//   TW = @
//   require '../../mingkwai'
//   do ->
//     mktscript = """
//     # Headline

//     Some *important* text. <box>boxed</box>

//     """
//     # mktscript = """<box>boxed</box>"""
//     promisify = ( require 'util' ).promisify
//     tex_source  = await ( promisify TW.tex_from_md.bind TW ) mktscript, { bare: yes, }
//     debug '45532', rpr tex_source.trim()
//     debug '45532', '###'

//   # debug '©nL12s', MKTS.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
//   # debug '©nL12s', MKTS.as_tex_text 'helo さし'
//   # event = [ '(', 'single-column', ]
//   # event = [ ')', 'single-column', ]
//   # event = [ '(', 'new-page', ]
//   # debug '©Gpn1J', select event, [ '(', ')'], [ 'single-column', 'new-page', ]

}).call(this);
