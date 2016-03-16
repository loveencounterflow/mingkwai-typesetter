(function() {
  var $, $async, ASYNC, CACHE, CND, D, HELPERS, LINEBREAKER, MACRO_ESCAPER, MACRO_INTERPRETER, MD_READER, MKTS, MKTSCRIPT_WRITER, OPTIONS, SEMVER, TEXLIVEPACKAGEINFO, XNCHR, after, alert, badge, before, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, njs_fs, njs_path, options_route, ref, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper, ƒ,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

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

  suspend = require('coffeenode-suspend');

  step = suspend.step;

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  ASYNC = require('async');

  ƒ = CND.format_number.bind(CND);

  HELPERS = require('./helpers');

  TEXLIVEPACKAGEINFO = require('./texlivepackageinfo');

  options_route = '../options.coffee';

  ref = require('./options'), CACHE = ref.CACHE, OPTIONS = ref.OPTIONS;

  SEMVER = require('semver');

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


  /* TAINT experimental, should become part of `PIPEDREAMS` to facilitate automated assembly of pipelines
  based on registered precedences using `CND.TSORT`
   */

  before = function() {
    var i, method, names;
    names = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), method = arguments[i++];
    return method;
  };

  after = function() {
    var i, method, names;
    names = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), method = arguments[i++];
    return method;
  };

  this.compile_options = function() {

    /* TAINT this method should go to OPTIONS */
    var cache_locator, cache_route, has_double_slash, has_single_slash, i, len, locator, locators, options_home, options_locator, ref1, route, texinputs_routes;
    options_locator = require.resolve(njs_path.resolve(__dirname, options_route));
    options_home = njs_path.dirname(options_locator);
    this.options = OPTIONS.from_locator(options_locator);
    this.options['home'] = options_home;
    this.options['locator'] = options_locator;
    cache_route = this.options['cache']['route'];
    this.options['cache']['locator'] = cache_locator = njs_path.resolve(options_home, cache_route);
    this.options['xelatex-command'] = njs_path.resolve(options_home, this.options['xelatex-command']);
    if (!njs_fs.existsSync(cache_locator)) {
      this.options['cache']['%self'] = {};
      CACHE.save(this.options);
    }
    this.options['cache']['%self'] = require(cache_locator);
    if ((texinputs_routes = (ref1 = this.options['texinputs']) != null ? ref1['routes'] : void 0) != null) {
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
    return CACHE.update(this.options);
  };

  this.compile_options();

  this.write_mkts_master = function(layout_info, handler) {
    return step((function(_this) {
      return function*(resume) {
        var content_locator, defs, filename, font_settings, font_settings_txt, fonts_home, fontspec_version, home, i, len, lines, main_font_name, master_locator, name, newcommands, otf, ref1, ref2, styles, subfolder, texname, text, use_new_syntax, value, write;
        lines = [];
        write = lines.push.bind(lines);
        master_locator = layout_info['master-locator'];
        content_locator = layout_info['content-locator'];
        help("writing " + master_locator);
        write("");
        write("% " + master_locator);
        write("% do not edit this file");
        write("% generated from " + _this.options['locator']);
        write("% on " + (new Date()));
        write("");
        write("\\documentclass[a4paper,twoside]{book}");
        write("");
        defs = _this.options['defs'];
        write("");
        write("% DEFS");
        if (defs != null) {
          for (name in defs) {
            value = defs[name];
            write("\\def\\" + name + "{" + value + "}");
          }
        }
        newcommands = _this.options['newcommands'];
        write("");
        write("% NEWCOMMANDS");
        if (newcommands != null) {
          for (name in newcommands) {
            value = newcommands[name];
            warn("implicitly converting newcommand value for " + name);
            value = njs_path.resolve(__dirname, '..', value);
            write("\\newcommand{\\" + name + "}{%\n" + value + "%\n}");
          }
        }
        write("");
        write("% PACKAGES");
        write("\\usepackage{mkts2015-consolidated}");
        fontspec_version = (yield TEXLIVEPACKAGEINFO.read_texlive_package_version(_this.options, 'fontspec', resume));
        use_new_syntax = SEMVER.satisfies(fontspec_version, '>=2.4.0');
        fonts_home = _this.options['fonts']['home'];
        write("");
        write("% FONTS");
        write("% assuming fontspec@" + fontspec_version);
        write("\\usepackage{fontspec}");
        ref1 = _this.options['fonts']['files'];
        for (i = 0, len = ref1.length; i < len; i++) {
          ref2 = ref1[i], texname = ref2.texname, otf = ref2.otf, home = ref2.home, subfolder = ref2.subfolder, filename = ref2.filename;
          if (home == null) {
            home = fonts_home;
          }
          if (subfolder != null) {
            home = njs_path.join(home, subfolder);
          }
          if (!home.endsWith('/')) {
            home = home + "/";
          }
          font_settings = ["Path=" + home];
          if (otf != null) {
            font_settings.push(otf);
          }
          font_settings_txt = font_settings.join(',');
          if (use_new_syntax) {

            /* TAINT should properly escape values */
            write("\\newfontface{\\" + texname + "}{" + filename + "}[" + font_settings_txt + "]");
          } else {
            write("\\newfontface\\" + texname + "[" + font_settings_txt + "]{" + filename + "}");
          }
        }
        write("");
        write("");
        write("% STYLES");
        if ((styles = _this.options['styles']) != null) {
          for (name in styles) {
            value = styles[name];
            write("\\newcommand{\\" + name + "}{%\n" + value + "%\n}");
          }
        }
        main_font_name = _this.options['fonts']['main'];
        if (main_font_name == null) {
          throw new Error("need entry options/fonts/name");
        }
        write("");
        write("% CONTENT");
        write("\\begin{document}\\mktsStyleNormal");
        write("");
        write("\\input{" + content_locator + "}");
        write("");
        write("\\end{document}");
        text = lines.join('\n');
        return njs_fs.writeFile(master_locator, text, handler);
      };
    })(this));
  };

  this.MKTX = {
    TEX: require('./tex-writer-typofix'),
    DOCUMENT: {},
    COMMAND: {},
    REGION: {},
    BLOCK: {},
    INLINE: {},
    MIXED: {},
    CLEANUP: {}
  };

  this.MKTX.COMMAND.$new_page = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (!select(event, '!', 'new-page')) {
          return send(event);
        }
        send(stamp(event));
        type = event[0], name = event[1], text = event[2], meta = event[3];
        return send(['tex', "\\null\\newpage{}"]);
      });
    };
  })(this);

  this.MKTX.COMMAND.$comment = (function(_this) {
    return function(S) {
      var remark;
      remark = MD_READER._get_remark();
      return $(function(event, send) {
        var meta, name, text, type;
        if (!select(event, '.', 'comment')) {
          return send(event);
        }
        type = event[0], name = event[1], text = event[2], meta = event[3];
        return send(remark('drop', "`.comment`: " + (rpr(text)), copy(meta)));
      });
    };
  })(this);

  this.$document = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        if (select(event, '(', 'document')) {
          send(stamp(event));
          return send(['tex', "\n% begin of MD document\n"]);
        } else if (select(event, ')', 'document')) {
          send(['tex', "\n% end of MD document\n"]);
          return send(stamp(event));
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.REGION.$code = (function(_this) {
    return function(S) {

      /* TAINT code duplication with `REGION.$keep_lines` possible */
      var track;
      track = MD_READER.TRACKER.new_tracker('(code)');
      return $(function(event, send) {
        var keeplines_parameters, language, meta, name, parameters, settings, text, type, within_code;
        within_code = track.within('(code)');
        track(event);
        if (select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (within_code) {
            text = text.replace(/\u0020/g, '\u00a0');
          }
          return send([type, name, text, meta]);
        } else if (select(event, ['(', ')'], 'code')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          language = parameters[0], settings = parameters[1];
          keeplines_parameters = settings != null ? [settings] : [];
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
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.REGION.$keep_lines = (function(_this) {
    return function(S) {
      var last_was_empty, squish, track;
      track = MD_READER.TRACKER.new_tracker('(keep-lines)');
      last_was_empty = false;
      squish = false;
      return $(function(event, send) {
        var chunk, chunks, i, len, meta, name, parameters, ref1, ref2, results, text, type, within_keep_lines;
        within_keep_lines = track.within('(keep-lines)');
        track(event);
        if (within_keep_lines && select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];

          /* TAINT other replacements possible; use API */

          /* TAINT U+00A0 (nbsp) might be too wide */
          text = text.replace(/\u0020/g, '\u00a0');
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
                results.push(send(['.', 'text', chunk, copy(meta)]));
              } else {
                results.push(void 0);
              }
            }
          }
          return results;
        } else if (select(event, '(', 'keep-lines')) {
          send(stamp(event));
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          if (!(squish = (ref1 = parameters != null ? (ref2 = parameters[0]) != null ? ref2['squish'] : void 0 : void 0) != null ? ref1 : false)) {
            send(['tex', "\\null\\par"]);
          }
          return send(['tex', "{\\mktsTightParagraphs{}"]);
        } else if (select(event, ')', 'keep-lines')) {
          send(stamp(event));
          return send(['tex', "}"]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  before('@MKTX.BLOCK.$heading', '@MKTX.COMMAND.$toc', this.MKTX.REGION.$toc = (function(_this) {
    return function(S) {
      var buffer, track;
      track = MD_READER.TRACKER.new_tracker('(toc)');
      buffer = null;
      return $(function(event, send) {
        var meta, name, text, type, within_toc;
        within_toc = track.within('(toc)');
        track(event);
        if (select(event, '(', 'toc')) {
          send(stamp(event));
          type = event[0], name = event[1], text = event[2], meta = event[3];
          return buffer = ['!', name, text, meta];
        } else if (select(event, ')', 'toc')) {
          send(stamp(event));
          if (buffer != null) {
            send(buffer);
            return buffer = null;
          }
        } else if (within_toc && select(event, '.', 'comma')) {
          if (buffer != null) {
            send(buffer);
            return buffer = null;
          }
        } else if (within_toc && select(event, ['(', ')'], 'h')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          meta['toc'] = 'omit';
          return send(event);
        } else {
          return send(event);
        }
      });
    };
  })(this));

  this.MKTX.BLOCK.$heading = (function(_this) {
    return function(S) {

      /* TAINT make numbering style configurable */

      /* TAINT generalize for more than 3 levels */
      var h_idx, h_nrs;
      h_nrs = [1, 1, 1];
      h_idx = -1;
      return $(function(event, send) {
        var h_key, level, meta, name, type;
        if (select(event, '(', 'h')) {
          type = event[0], name = event[1], level = event[2], meta = event[3];
          h_idx += +1;
          h_key = "h-" + h_idx;
          if (meta['h'] == null) {
            meta['h'] = {};
          }
          meta['h']['idx'] = h_idx;
          meta['h']['key'] = h_key;
          send(['tex', "\n"]);
          send(stamp(event));
          switch (level) {
            case 1:
              send([
                '!', 'columns', [1], copy(meta, {
                  toc: 'omit'
                })
              ]);
              send(['tex', "{\\mktsHOne{}"]);
              return send([
                'tex', "\\zlabel{" + h_key + "}", {
                  toc: 'omit'
                }
              ]);
            case 2:
              send([
                '!', 'columns', [1], copy(meta, {
                  toc: 'omit'
                })
              ]);
              send(['tex', "{\\mktsHTwo{}"]);
              return send([
                'tex', "\\zlabel{" + h_key + "}", {
                  toc: 'omit'
                }
              ]);
            case 3:
              send([
                '!', 'columns', [1], copy(meta, {
                  toc: 'omit'
                })
              ]);
              send(['tex', "{\\mktsHThree{}"]);
              return send([
                'tex', "\\zlabel{" + h_key + "}", {
                  toc: 'omit'
                }
              ]);
            default:
              return send(['.', 'warning', "heading level " + level + " not implemented", copy(meta)]);
          }
        } else if (select(event, ')', 'h')) {
          type = event[0], name = event[1], level = event[2], meta = event[3];
          switch (level) {
            case 1:
              send(['tex', "\\mktsHOneBeg}%\n"]);
              send([
                '!', 'columns', ['pop'], copy(meta, {
                  toc: 'omit'
                })
              ]);
              break;
            case 2:
              send(['tex', "\\mktsHTwoBeg}%\n"]);
              send([
                '!', 'columns', ['pop'], copy(meta, {
                  toc: 'omit'
                })
              ]);
              break;
            case 3:
              send(['tex', "\\mktsHThreeBeg}%\n\n"]);
              send([
                '!', 'columns', ['pop'], copy(meta, {
                  toc: 'omit'
                })
              ]);
              break;
            default:
              return send(['.', 'warning', "heading level " + level + " not implemented", copy(meta)]);
          }
          return send(stamp(event));
        } else {
          return send(event);
        }
      });
    };
  })(this);

  before('@MKTX.COMMAND.$toc', after('@MKTX.BLOCK.$heading', this.MKTX.MIXED.$collect_headings_for_toc = (function(_this) {
    return function(S) {
      var buffer, headings, new_heading, remark, this_heading, within_heading;
      within_heading = false;
      this_heading = null;
      headings = [];
      buffer = [];
      remark = MD_READER._get_remark();
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
      return $(function(event, send) {
        var i, j, len, len1, level, meta, name, sub_event, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (select(event, '~', ['flush', 'stop'])) {
          send(remark(name, "releasing " + buffer.length + " events", copy(meta)));
          for (i = 0, len = buffer.length; i < len; i++) {
            sub_event = buffer[i];
            send(sub_event);
          }
          buffer.length = 0;
          return send(event);
        } else if (select(event, '(', 'document')) {
          return send(event);
        } else if (select(event, ')', 'document')) {
          send(unstamp(['.', 'toc-headings', headings, meta]));
          for (j = 0, len1 = buffer.length; j < len1; j++) {
            sub_event = buffer[j];
            send(sub_event);
          }
          buffer.length = 0;
          return send(event);
        } else if ((meta != null) && (meta['toc'] !== 'omit') && select(event, '(', 'h')) {

          /* TAINT use library method to test event category */
          level = text;
          within_heading = true;
          this_heading = new_heading(level, meta);
          headings.push(this_heading);
          return buffer.push(event);
        } else if (select(event, ')', 'h')) {
          within_heading = false;
          this_heading = null;
          return buffer.push(event);
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
            return buffer.push(event);
          }
        } else {
          return buffer.push(event);
        }
      });
    };
  })(this)));

  after('@MKTX.REGION.$toc', '@MKTX.MIXED.$collect_headings_for_toc', this.MKTX.COMMAND.$toc = (function(_this) {
    return function(S) {
      var headings;
      headings = null;
      return $(function(event, send) {

        /* TAINT use library method to test event category */
        var _, events, h_event, heading, i, idx, j, key, last_idx, len, len1, level, meta, name, text, type;
        if (select(event, '.', 'toc-headings')) {
          _ = event[0], _ = event[1], headings = event[2], _ = event[3];
          return send(stamp(event));
        } else if (select(event, '!', 'toc')) {
          send(stamp(event));
          if (headings == null) {
            return send(['.', 'warning', "expecting toc-headings event before this", copy(meta)]);
          }
          type = event[0], name = event[1], text = event[2], meta = event[3];
          send(['tex', '{\\mktsToc%\n']);
          for (i = 0, len = headings.length; i < len; i++) {
            heading = headings[i];
            level = heading.level, events = heading.events, key = heading.key;
            last_idx = events.length - 1;
            for (idx = j = 0, len1 = events.length; j < len1; idx = ++j) {
              h_event = events[idx];

              /* TAINT use library method to determine event category */
              if (h_event.length === 4) {
                h_event = unstamp(h_event);
              }
              if (idx === last_idx) {
                send(['tex', "{\\mktsStyleNormal \\dotfill \\zpageref{" + key + "}}"]);
              }
              send(h_event);
            }
          }
          return send(['tex', '\\mktsTocBeg}%\n']);
        } else {
          return send(event);
        }
      });
    };
  })(this));

  this.MKTX.BLOCK.$yadda = (function(_this) {
    return function(S) {
      var cache, generate_yadda, settings;
      generate_yadda = require('lorem-ipsum');
      cache = [];
      settings = {
        count: 1,
        units: 'paragraphs',
        sentenceLowerBound: 5,
        sentenceUpperBound: 15,
        paragraphLowerBound: 3,
        paragraphUpperBound: 7,
        format: 'plain',
        random: CND.get_rnd(42, 3),
        suffix: '\n'
      };
      return $(function(event, send) {
        var meta, name, parameters, type, yadda, yadda_idx;
        if (select(event, '!', 'yadda')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          yadda_idx = parameters[0];
          if (yadda_idx == null) {
            yadda_idx = cache.length;
          }
          while (cache.length - 1 < yadda_idx) {
            cache.push(generate_yadda(settings));
          }
          yadda = cache[yadda_idx];
          send(stamp(event));
          return send(['tex', yadda]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$paragraph = (function(_this) {
    return function(S) {

      /* TAINT should unify the two observers */
      var track;
      track = MD_READER.TRACKER.new_tracker('(code)', '(keep-lines)');
      return $(function(event, send) {
        var meta, name, text, type, within_code, within_keep_lines;
        within_code = track.within('(code)');
        within_keep_lines = track.within('(keep-lines)');
        track(event);
        if (select(event, '.', 'p')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (within_code || within_keep_lines) {
            send(stamp(event));
            return send(['tex', '\n\n']);
          } else {
            send(stamp(event));
            return send(_this.MKTX.BLOCK._end_paragraph());
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK._end_paragraph = (function(_this) {
    return function() {

      /* TAINT use command from sty */

      /* TAINT make configurable */
      return ['tex', '\n\n'];
    };
  })(this);

  this.MKTX.BLOCK.$unordered_list = (function(_this) {
    return function(S) {
      var item_markup_tex, tex_by_md_markup;
      tex_by_md_markup = {
        '*': '$\\star$',
        'fallback': '—'
      };
      item_markup_tex = null;
      return $(function(event, send) {
        var markup, meta, name, ref1, text, type;
        if (select(event, '(', 'ul')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          markup = meta.markup;

          /* TAINT won't work in nested lists */

          /* TAINT make configurable */
          item_markup_tex = (ref1 = tex_by_md_markup[markup]) != null ? ref1 : tex_by_md_markup['fallback'];
          send(stamp(event));
          return send(['tex', '\\begin{itemize}']);
        } else if (select(event, '(', 'li')) {
          send(stamp(event));
          return send(['tex', "\\item[" + item_markup_tex + "] "]);
        } else if (select(event, ')', 'li')) {
          send(stamp(event));
          return send(['tex', '\n']);
        } else if (select(event, ')', 'ul')) {
          send(stamp(event));
          return send(['tex', '\\end{itemize}']);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$hr = (function(_this) {
    return function(S) {
      var plain_rule, swell_rule;
      plain_rule = ['tex', "\\mktsRulePlain{}"];
      swell_rule = ['tex', "\\mktsRuleSwell{}"];
      return $(function(event, send) {
        var chr, meta, name, text, type;
        if (select(event, '.', 'hr')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          switch (chr = text[0]) {
            case '-':
              send(stamp(copy(event)));
              return send(plain_rule);
            case '*':
              send(stamp(copy(event)));
              return send(swell_rule);
            case '=':
              send(stamp(hide(copy(event))));
              return send(['!', 'slash', [], copy(meta)]);
            case '#':
              send(stamp(hide(copy(event))));
              return send(['!', 'slash', [swell_rule], copy(meta)]);
            default:
              send(stamp(hide(copy(event))));
              return send(remark('drop', "`[hr] because markup unknown " + (rpr(text)), copy(meta)));
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$nl = (function(_this) {
    return function(S) {

      /* TAINT consider to zero-width non-breaking space */
      var nl;
      nl = ['tex', "~\\\\\n"];
      return $(function(event, send) {
        var _, count, i, meta, name, ref1, ref2, results, type;
        if (select(event, '!', 'nl')) {
          type = event[0], name = event[1], (ref1 = event[2], count = ref1[0]), meta = event[3];
          results = [];
          for (_ = i = 0, ref2 = count != null ? count : 1; i < ref2; _ = i += +1) {
            results.push(send(nl));
          }
          return results;
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$code_span = (function(_this) {
    return function(S) {
      var track;
      track = MD_READER.TRACKER.new_tracker('(code-span)');
      return $(function(event, send) {
        var _, fragment, fragments, i, idx, last_idx, len, meta, results, text, within_code_span;
        within_code_span = track.within('(code-span)');
        track(event);
        if (select(event, '(', 'code-span')) {
          send(stamp(event));
          return send(['tex', '{\\mktsStyleCode{}']);
        } else if (select(event, ')', 'code-span')) {
          return send(['tex', "}"]);
        } else if (within_code_span && select(event, '.', 'text')) {
          _ = event[0], _ = event[1], text = event[2], meta = event[3];

          /* TAINT sort-of code duplication with command url */
          fragments = LINEBREAKER.fragmentize(text);
          last_idx = fragments.length - 1;
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
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$image = (function(_this) {
    return function(S) {
      var alt, alt_cache, event_cache, src, track;
      track = MD_READER.TRACKER.new_tracker('(image)');
      event_cache = [];
      alt_cache = [];
      src = null;
      alt = null;
      return $(function(event, send) {
        var cached_event, i, len, meta, name, text, type, within_image;
        within_image = track.within('(image)');
        track(event);
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (select(event, '(', 'image')) {
          send(stamp(event));
          return src = njs_path.resolve(S.layout_info['source-home'], meta['src']);
        } else if (select(event, ')', 'image')) {
          alt = alt_cache.join('');
          send(['tex', '\\begin{figure}%\n']);

          /* TAINT escape `src`? */
          send(['tex', "\\includegraphics[width=0.5\\textwidth]{" + src + "}%\n"]);
          send(['tex', "\\caption[" + alt + "]{%\n"]);
          for (i = 0, len = event_cache.length; i < len; i++) {
            cached_event = event_cache[i];
            send(cached_event);
          }
          send(['tex', '}%\n']);
          send(['tex', '\\end{figure}%\n']);
          src = null;
          return alt_cache.length = 0;
        } else if (within_image) {
          event_cache.push(event);
          if (select(event, '.', 'text')) {
            return alt_cache.push(text);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.MIXED.$raw = (function(_this) {
    return function(S) {
      var remark;
      remark = MD_READER._get_remark();
      return $(function(event, send) {
        var meta, name, text, type;
        if (select(event, '.', 'raw')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          send(stamp(hide(copy(event))));
          send(remark('convert', "raw to TeX", copy(meta)));
          text = MACRO_ESCAPER.escape.unescape_escape_chrs(S, text);
          return send(['tex', text]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.MIXED.$table = (function(_this) {
    return function(S) {
      var buffer, remark, track;
      track = MD_READER.TRACKER.new_tracker('(table)', '(th)');
      remark = MD_READER._get_remark();
      buffer = null;
      return $(function(event, send) {
        var alignment, col_styles, i, len, meta, name, ref1, text, type, within_table, within_th;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        within_table = track.within('(table)');
        within_th = track.within('(th)');
        track(event);
        if (within_th && select(event, '.', 'text')) {
          send(['(', 'strong', null, copy(meta)]);
          send(stamp(event));
          return send([')', 'strong', null, copy(meta)]);
        } else if (select(event, ')', 'tr')) {
          buffer = null;
          send(stamp(hide(copy(event))));
          return send(['tex', "\\\\\n"]);
        } else {
          if (buffer) {
            send(buffer);
          }
          buffer = null;
          if (select(event, '(', 'table')) {
            send(stamp(hide(copy(event))));
            col_styles = [];
            ref1 = meta['table']['alignments'];
            for (i = 0, len = ref1.length; i < len; i++) {
              alignment = ref1[i];
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
            col_styles = '| ' + (col_styles.join(' | ')) + ' |';
            return send(['tex', "\n\n\\begin{tabular}[pos]{ " + col_styles + " }\n"]);
          } else if (select(event, ')', 'table')) {
            send(stamp(hide(copy(event))));
            return send(['tex', "\\end{tabular}\n\n"]);
          } else if (select(event, '(', 'tbody')) {
            return send(stamp(hide(copy(event))));
          } else if (select(event, ')', 'tbody')) {
            send(['tex', "\\hline\n"]);
            return send(stamp(hide(copy(event))));
          } else if (select(event, '(', 'td')) {
            return send(stamp(hide(copy(event))));
          } else if (select(event, ')', 'td')) {
            send(stamp(hide(copy(event))));
            return buffer = ['tex', " & "];
          } else if (select(event, '(', 'th')) {
            return send(stamp(hide(copy(event))));
          } else if (select(event, ')', 'th')) {
            send(stamp(hide(copy(event))));
            return buffer = ['tex', " & "];
          } else if (select(event, '(', 'thead')) {
            send(['tex', "\\hline\n"]);
            return send(stamp(hide(copy(event))));
          } else if (select(event, ')', 'thead')) {
            send(stamp(hide(copy(event))));
            return send(['tex', "\n\\hline\n"]);
          } else if (select(event, '(', 'tr')) {
            return send(stamp(hide(copy(event))));
          } else {
            return send(event);
          }
        }
      });
    };
  })(this);

  this.MKTX.MIXED.$footnote = (function(_this) {
    return function(S) {

      /* TAINT should move this to initialization */
      var style;
      if (S.footnotes != null) {
        throw new Error("`S.footnotes` already defined");
      }
      S.footnotes = {
        'style': 'on-demand',
        'by-idx': []
      };
      switch (style = S.footnotes['style']) {
        case 'classic':
          return _this.MKTX.MIXED._$footnote_classic(S);
        case 'on-demand':
          return _this.MKTX.MIXED._$footnote_on_demand(S);
        default:
          throw new Error("unknown footnote style " + (rpr(style)));
      }
    };
  })(this);

  this.MKTX.MIXED._$footnote_classic = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        if (select(event, '(', 'footnote')) {
          send(stamp(event));
          return send(['tex', "\\footnote{"]);
        } else if (select(event, ')', 'footnote')) {
          send(stamp(event));
          return send(['tex', "}"]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.MIXED._$footnote_on_demand = (function(_this) {
    return function(S) {

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
      insert_footnotes = function(send, meta) {
        var fn_cache, fn_event, fn_idx, fn_nr, i, j, len, ref1, ref2;
        if (last_fn_idx >= first_fn_idx) {
          send(['tex', "\n\n"]);
          send(['tex', "\\begin{mktsEnNotes}"]);
          for (fn_idx = i = ref1 = first_fn_idx, ref2 = last_fn_idx; ref1 <= ref2 ? i <= ref2 : i >= ref2; fn_idx = ref1 <= ref2 ? ++i : --i) {
            fn_nr = fn_idx + 1;
            fn_cache = cache[fn_idx];
            cache[fn_idx] = null;
            send(['tex', "{\\mktsEnStyleMarkNotes\\mktsEnMarkBefore" + fn_nr + "\\mktsEnMarkAfter{}}"]);
            for (j = 0, len = fn_cache.length; j < len; j++) {
              fn_event = fn_cache[j];
              send(fn_event);
            }
          }
          send(['tex', "\\end{mktsEnNotes}\n\n"]);
          first_fn_idx = last_fn_idx + 1;
          return last_fn_idx = first_fn_idx - 1;
        }
      };
      return $(function(event, send) {
        var fn_nr, fn_separator, meta, name, text, type, within_footnote;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        within_footnote = track.within('(footnote)');
        track(event);
        if (select(event, '(', 'footnote')) {
          send(stamp(event));
          current_fn_cache = [];
          current_fn_idx += +1;
          last_fn_idx = current_fn_idx;
          fn_nr = current_fn_idx + 1;
          cache[current_fn_idx] = current_fn_cache;
          fn_separator = last_was_footnote ? ',' : '';
          return send(['tex', "{\\mktsEnStyleMarkMain{}" + fn_separator + fn_nr + "}"]);
        } else if (select(event, ')', 'footnote')) {
          send(stamp(event));
          current_fn_cache = null;
          return last_was_footnote = true;
        } else if (within_footnote) {
          current_fn_cache.push(event);
          return send(remark('caching', "event within footnote", event));
        } else if (select(event, '!', 'footnotes')) {
          send(stamp(event));
          return insert_footnotes(send, meta);
        } else if (select(event, ')', 'document')) {
          insert_footnotes(send, meta);
          return send(event);
        } else {
          last_was_footnote = false;
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.MIXED.$footnote.$remove_extra_paragraphs = (function(_this) {
    return function(S) {
      var last_event;
      last_event = null;
      return $(function(event, send, end) {
        if (event != null) {
          if (select(event, ')', 'footnote')) {
            if ((last_event != null) && !select(last_event, '.', 'p')) {
              send(last_event);
            }
            last_event = event;
          } else {
            if (last_event != null) {
              send(last_event);
            }
            last_event = event;
          }
        }
        if (end != null) {
          if (last_event != null) {
            send(last_event);
          }
          return end();
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$translate_i_and_b = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, new_name, text, type;
        if (select(event, ['(', ')'], ['i', 'b'])) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          new_name = name === 'i' ? 'em' : 'strong';
          return send([type, new_name, text, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$mark = (function(_this) {
    return function(S) {
      var mark_idx;
      mark_idx = 0;
      return $(function(event, send) {
        var meta, name, text, type;
        if (select(event, '!', 'mark')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          send(stamp(event));
          if (text == null) {
            mark_idx += +1;
            text = "a-" + mark_idx;
          }
          return send(['tex', "\\mktsMark{" + text + "}"]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$em_and_strong = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (select(event, ['(', ')'], ['em', 'strong'])) {
          send(stamp(event));
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '(') {
            if (name === 'em') {
              return send(['tex', '{\\mktsStyleItalic{}']);

              /* TAINT must not be sent when in vertical mode */
            } else {
              return send(['tex', '{\\mktsStyleBold{}']);
            }
          } else {
            if (name === 'em') {
              send(['tex', '\\/']);
            }
            return send(['tex', "}"]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$link = (function(_this) {
    return function(S) {
      var cache, last_href, track;
      cache = [];
      last_href = null;
      track = MD_READER.TRACKER.new_tracker('(link)');
      return $(function(event, send) {
        var cached_event, i, j, len, len1, meta, name, text, type, within_link;
        within_link = track.within('(link)');
        track(event);
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (select(event, '(', 'link')) {
          send(stamp(event));
          last_href = text;
        } else if (select(event, ')', 'link')) {
          send(['tex', '{\\mktsStyleLinklabel{}']);
          for (i = 0, len = cache.length; i < len; i++) {
            cached_event = cache[i];
            send(cached_event);
          }
          send(['tex', '}']);
          send(['(', 'footnote', null, copy(meta)]);
          send(['!', 'url', [last_href], copy(meta)]);
          send(['.', 'p', null, copy(meta)]);
          send([')', 'footnote', null, copy(meta)]);
          cache.length = 0;
          last_href = null;
          send(stamp(event));
        } else if (cache.length > 0 && select(event, ')', 'document')) {
          send(['.', 'warning', "missing closing region 'link'", copy(meta)]);
          for (j = 0, len1 = cache.length; j < len1; j++) {
            cached_event = cache[j];
            send(cached_event);
          }
          send(event);
        } else if (within_link) {
          cache.push(event);
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.MKTX.INLINE.$url = (function(_this) {
    return function(S) {
      var buffer, track;
      track = MD_READER.TRACKER.new_tracker('(url)');
      buffer = [];
      return $(function(event, send) {
        var meta, name, text, type, within_url;
        within_url = track.within('(url)');
        track(event);
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (select(event, '(', 'url')) {
          return send(stamp(hide(copy(event))));
        } else if (select(event, ')', 'url')) {
          send(['!', 'url', [buffer.join('')], copy(meta)]);
          buffer.length = 0;
          return send(stamp(hide(copy(event))));
        } else if (within_url && select(event, '.', 'text')) {
          return buffer.push(text);
        } else if (within_url) {
          return send(['.', 'warning', "ignoring non-text event inside `(url)`: " + (rpr(event))]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.COMMAND.$url = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var fragment, fragments, i, idx, last_idx, len, meta, name, parameters, ref1, segment, slashes, type, url;
        if (select(event, '!', 'url')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          send(stamp(event));
          url = parameters[0];
          if (url == null) {
            return send(['.', 'warning', "missing required argument for `<<!url>>`", copy(meta)]);
          }

          /* TAINT sort-of code duplication with inline code */
          fragments = LINEBREAKER.fragmentize(url);
          last_idx = fragments.length - 1;
          send(['tex', "{\\mktsStyleUrl{}"]);
          for (idx = i = 0, len = fragments.length; i < len; idx = ++i) {
            fragment = fragments[idx];
            ref1 = fragment.split(/(\/+)$/), segment = ref1[0], slashes = ref1[1];
            send(['.', 'text', segment, copy(meta)]);
            if (slashes != null) {
              slashes = '\\g' + (Array.from(slashes)).join('\\g');
              send(['tex', slashes]);
            }
            send(['tex', "\\allowbreak{}"]);
          }
          send(['tex', "}"]);
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.MKTX.CLEANUP.$remove_empty_texts = function(S) {
    var remark;
    remark = MD_READER._get_remark();
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
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
      };
    })(this));
  };

  this.MKTX.CLEANUP.$consolidate_texts = function(S) {
    var collector, first_meta;
    collector = [];
    first_meta = null;
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (first_meta == null) {
            first_meta = meta;
          }
          return collector.push(text);
        } else {
          if (collector.length > 0) {
            send(['.', 'text', collector.join(''), copy(first_meta)]);
            first_meta = null;
            collector.length = 0;
          }
          return send(event);
        }
      };
    })(this));
  };

  this.MKTX.REGION.$correct_p_tags_before_regions = (function(_this) {
    return function(S) {
      var last_was_begin_document, last_was_p, remark;
      last_was_p = false;
      last_was_begin_document = false;
      remark = MD_READER._get_remark();
      return $(function(event, send) {
        var meta;
        if (select(event, 'tex')) {
          return send(event);
        } else if (select(event, '(', 'document')) {
          last_was_p = false;
          last_was_begin_document = true;
          return send(event);
        } else if (select(event, '.', 'p')) {
          last_was_p = true;
          last_was_begin_document = false;
          return send(event);
        } else if (select(event, ['('])) {
          if ((!last_was_begin_document) && (!last_was_p)) {
            meta = event[event.length - 1];
            send(remark('insert', "`.p` because region or block opens", copy(meta)));
            send(['.', 'p', null, copy(meta)]);
          }
          send(event);
          last_was_p = false;
          return last_was_begin_document = false;
        } else {
          last_was_p = false;
          last_was_begin_document = false;
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.$show_unhandled_tags = (function(_this) {
    return function(S) {
      return $(function(event, send) {

        /* TAINT selection could be simpler, less repetitive */
        var event_txt, meta, name, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if ((type === 'tex') || select(event, '.', ['text', 'raw'])) {
          return send(event);
        } else if ((!is_stamped(event)) && (type !== '~') && (!select(event, '.', 'warning'))) {
          event_txt = "unhandled event: " + (JSON.stringify(event, null, ' '));
          warn(event_txt);
          return send(['.', 'warning', event_txt, copy(meta)]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.$show_warnings = (function(_this) {
    return function(S) {
      return $(function(event, send) {

        /* TAINT this makes clear why we should not use '.' as type here; `warning` is a meta-event, not
        primarily a formatting instruction
         */
        var message, meta, name, text, type;
        if (select(event, '.', 'warning')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          message = _this.MKTX.TEX.fix_typography_for_tex(text, S.options);

          /* TAINT use location data */
          return send(['tex', "\\begin{mktsEnvWarning}" + message + "\\end{mktsEnvWarning}"]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$filter_tex = function(S) {

    /* TAINT reduce number of event types, shapes to simplify this */
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (type === 'tex') {
          return send(event[1]);
        } else if (select(event, '.', ['text', 'raw'])) {
          return send(event[2]);
        } else if ((meta != null ? meta['tex'] : void 0) === 'pass-through') {
          return send(event);
        } else if (!((type === '~') || (is_stamped(event)))) {
          warn("unhandled event: " + (JSON.stringify(event)));
          return send.error(new Error("unhandled events not allowed at this point; got " + (JSON.stringify(event))));
        }
      };
    })(this));
  };

  this.create_tex_write_tee = function(S) {

    /* TAINT get state via return value of MKTS.create_mdreadstream */

    /* TAINT make execution of `$produce_mktscript` a matter of settings */
    var R, mktscript_in, mktscript_out, pipeline, plugin, plugins_tee, readstream, settings, writestream;
    readstream = D.create_throughstream();
    writestream = D.create_throughstream();
    mktscript_in = D.create_throughstream();
    mktscript_out = D.create_throughstream();

    /* TAINT need a file to write MKTScript text events to; must still send on incoming events */
    pipeline = (function() {
      var i, len, ref1, results;
      ref1 = MK.TS.plugins;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        plugin = ref1[i];
        results.push(plugin.$main(S));
      }
      return results;
    })();
    plugins_tee = D.combine(pipeline);
    readstream.pipe(plugins_tee).pipe(MACRO_ESCAPER.$expand.$remove_backslashes(S)).pipe(this.$document(S)).pipe(this.MKTX.INLINE.$link(S)).pipe(this.MKTX.MIXED.$footnote(S)).pipe(this.MKTX.MIXED.$footnote.$remove_extra_paragraphs(S)).pipe(this.MKTX.COMMAND.$new_page(S)).pipe(this.MKTX.COMMAND.$comment(S)).pipe(this.MKTX.MIXED.$table(S)).pipe(this.MKTX.BLOCK.$hr(S)).pipe(this.MKTX.BLOCK.$nl(S)).pipe(this.MKTX.REGION.$code(S)).pipe(this.MKTX.REGION.$keep_lines(S)).pipe(this.MKTX.REGION.$toc(S)).pipe(this.MKTX.BLOCK.$heading(S)).pipe(this.MKTX.MIXED.$collect_headings_for_toc(S)).pipe(this.MKTX.COMMAND.$toc(S)).pipe(this.MKTX.BLOCK.$unordered_list(S)).pipe(this.MKTX.INLINE.$code_span(S)).pipe(this.MKTX.INLINE.$url(S)).pipe(this.MKTX.COMMAND.$url(S)).pipe(this.MKTX.INLINE.$translate_i_and_b(S)).pipe(this.MKTX.INLINE.$em_and_strong(S)).pipe(this.MKTX.INLINE.$image(S)).pipe(this.MKTX.BLOCK.$yadda(S)).pipe(this.MKTX.BLOCK.$paragraph(S)).pipe(this.MKTX.MIXED.$raw(S)).pipe(this.COLUMNS.$main(S)).pipe(MACRO_INTERPRETER.$capture_change_events(S)).pipe(this.MKTX.CLEANUP.$remove_empty_texts(S)).pipe(this.MKTX.CLEANUP.$consolidate_texts(S)).pipe(this.MKTX.TEX.$fix_typography_for_tex(S)).pipe(this.MKTX.INLINE.$mark(S)).pipe(this.MKTX.$show_unhandled_tags(S)).pipe(this.MKTX.$show_warnings(S)).pipe(this.$filter_tex(S)).pipe(this.COLUMNS.$XXX_transform_pretex_to_tex(S)).pipe(MD_READER.$show_illegal_chrs(S)).pipe(writestream);
    settings = {
      S: S
    };
    R = D.TEE.from_readwritestreams(readstream, writestream, settings);
    if (S['tees'] == null) {
      S['tees'] = {};
    }
    S['tees']['tex-writer'] = R;
    return R;
  };

  this._handle_error = (function(_this) {
    return function(error) {
      var ref1, stack;
      alert(error['message']);
      stack = (ref1 = error['stack']) != null ? ref1 : "(no stacktrace available)";
      whisper('\n' + (stack.split('\n')).slice(0, 11).join('\n'));
      whisper('...');
      return process.exit(1);
    };
  })(this);

  this.pdf_from_md = function(source_route, handler) {

    /* TAINT code duplication */

    /* TAIN only works with docs in the filesystem, not with literal texts */
    var f;
    f = (function(_this) {
      return function() {
        return step(function*(resume) {
          var S, content_locator, file_output, layout_info, md_input, md_output, md_readstream, md_source, mkscript_locator, mkscript_output, source_locator, tex_input, tex_output, tex_writestream;
          layout_info = HELPERS.new_layout_info(_this.options, source_route);
          (yield _this.write_mkts_master(layout_info, resume));
          source_locator = layout_info['source-locator'];
          content_locator = layout_info['content-locator'];
          file_output = njs_fs.createWriteStream(content_locator);
          mkscript_locator = layout_info['mkscript-locator'];
          mkscript_output = njs_fs.createWriteStream(mkscript_locator);
          file_output.on('close', function() {
            return HELPERS.write_pdf(layout_info, function(error) {
              if (error != null) {
                throw error;
              }
              if (handler != null) {
                return handler(null);
              }
            });
          });
          S = {
            options: _this.options,
            layout_info: layout_info
          };

          /* TAINT should read MD source stream */
          md_source = njs_fs.readFileSync(source_locator, {
            encoding: 'utf-8'
          });
          md_readstream = MD_READER.create_md_read_tee(S, md_source);
          tex_writestream = _this.create_tex_write_tee(S);
          md_input = md_readstream.tee['input'];
          md_output = md_readstream.tee['output'];
          tex_input = tex_writestream.tee['input'];
          tex_output = tex_writestream.tee['output'];
          S.resend = md_readstream.tee['S'].resend;
          md_output.pipe(tex_input);
          tex_output.pipe(file_output);
          return md_input.resume();
        });
      };
    })(this);
    return D.run(f, this._handle_error);
  };

  this.tex_from_md = function(md_source, settings, handler) {

    /* TAINT code duplication */
    var $collect_and_call, S, arity, layout_info, md_input, md_output, md_readstream, ref1, source_route, tex_input, tex_output, tex_writestream;
    switch (arity = arguments.length) {
      case 2:
        handler = settings;
        settings = {};
        break;
      case 3:
        null;
        break;
      default:
        throw new Error("expected 2 or 3 arguments, got " + arity);
    }
    $collect_and_call = (function(_this) {
      return function(handler) {
        var Z;
        Z = [];
        return $(function(event, send, end) {
          if (event != null) {
            Z.push(event);
          }
          if (end != null) {
            handler(null, Z.join(''));
            return end();
          }
        });
      };
    })(this);
    source_route = (ref1 = settings['source-route']) != null ? ref1 : '<STRING>';
    layout_info = HELPERS.new_layout_info(this.options, source_route, false);
    S = {
      options: this.options,
      layout_info: layout_info
    };
    md_readstream = MD_READER.create_md_read_tee(md_source);
    tex_writestream = this.create_tex_write_tee(S);
    md_input = md_readstream.tee['input'];
    md_output = md_readstream.tee['output'];
    tex_input = tex_writestream.tee['input'];
    tex_output = tex_writestream.tee['output'];
    S.resend = md_readstream.tee['S'].resend;
    md_output.pipe(tex_input);
    tex_output.pipe($collect_and_call(handler));
    D.run(((function(_this) {
      return function() {
        return md_input.resume();
      };
    })(this)), this._handle_error);
    return null;
  };

  if (module.parent == null) {
    this.pdf_from_md('texts/demo');
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/tex-writer.js.map
