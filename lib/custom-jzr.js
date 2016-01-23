(function() {
  var $, $async, ASYNC, CND, D, HOLLERITH, MD_READER, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, njs_fs, njs_path, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'mkts/custom-jzr';

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

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  unstamp = MD_READER.unstamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  HOLLERITH = require('../../hollerith');

  this.$main = (function(_this) {
    return function(S) {
      var base, db_route;
      db_route = njs_path.resolve(__dirname, '../../jizura-datasources/data/leveldb-v2');
      if (S.JZR == null) {
        S.JZR = {};
      }
      if ((base = S.JZR).db == null) {
        base.db = HOLLERITH.new_db(db_route, {
          create: false
        });
      }
      return D.TEE.from_pipeline([_this.$fontlist(S), _this.$most_frequent.with_fncrs.$rewrite_events(S), _this.$most_frequent.$read(S), _this.$most_frequent.$assemble(S), _this.$most_frequent.$details_from_glyphs(S), _this.$most_frequent.with_fncrs.$format(S), _this.$most_frequent.with_fncrs.$assemble(S), _this.$dump_db(S)]);
    };
  })(this);

  this.$fontlist = (function(_this) {
    return function(S) {
      var kaishu_shortnames, kana_shortnames, template;
      kaishu_shortnames = ['Fandolkairegular', 'Kai', 'Ukai', 'Epkaisho', 'Cwtexqkaimedium', 'Biaukai'];
      kana_shortnames = ['Babelstonehan', 'Cwtexqfangsongmedium', 'Cwtexqheibold', 'Cwtexqkaimedium', 'Cwtexqmingmedium', 'Cwtexqyuanmedium', 'Hanamina', 'Sunexta', 'Kai', 'Nanumgothic', 'Nanummyeongjo', 'Simsun', 'Fandolfangregular', 'Fandolheibold', 'Fandolheiregular', 'Fandolkairegular', 'Fandolsongbold', 'Fandolsongregular', 'Ipaexg', 'Ipaexm', 'Ipag', 'Ipagp', 'Ipam', 'Ipamp', 'Ipaexg', 'Ipaexm', 'Ipag', 'Ipagp', 'Ipam', 'Ipamp', 'Ukai', 'Uming', 'Droidsansfallbackfull', 'Droidsansjapanese', 'Fontsjapanesegothic', 'Fontsjapanesemincho', 'Takaopgothic', 'Sourcehansansbold', 'Sourcehansansextralight', 'Sourcehansansheavy', 'Sourcehansanslight', 'Sourcehansansmedium', 'Sourcehansansnormal', 'Sourcehansansregular'];
      template = "($shortname) {\\($texname){\\cjk\\($texname){}ぁあぃいぅうぇえぉおかがきぎく\nぐけげこごさざしじすずせぜそぞた\nだちぢっつづてでとどなにぬねのは\nばぱひびぴふぶぷへべぺほぼぽまみ\nむめもゃやゅゆょよらりるれろゎわ\nゐゑをんゔゕゖァアィイゥウェエォオカガキギク\nグケゲコゴサザシジスズセゼソゾタ\nダチヂッツヅテデトドナニヌネノハ\nバパヒビピフブプヘベペホボポマミ\nムメモャヤュユョヨラリルレロヮワ\nヰヱヲンヴヵヶヷヸヹヺ\n本书使用的数字，符号一览表}\nAaBbCcDdEeFfghijklmn}";
      template = "This is {\\cjk\\($texname){}むず·かしい} so very {\\cjk\\($texname){}ムズ·カシイ} indeed.";
      template = "XXX{\\($texname){}·}XXX";
      template = "The character {\\cjk{}出} {\\($texname){}u{\\mktsFontfileEbgaramondtwelveregular{}·}cjk{\\mktsFontfileEbgaramondtwelveregular{}·}51fa} means '{\\mktsStyleItalic{}go out, send out, stand, produce}'.";
      template = "{\\($texname){}出 、出。出〃出〄出々出〆出〇出〈出〉出《出》出「出」出}\\\\\n\\> {\\($texname){}出『出』出【出】出〒出〓出〔出〕出〖出〗出〘出〙出〚出}";
      template = "{\\($texname){}abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ}";
      template = "{\\($texname){\\cjk\\($texname){}本书使用的数字，符号一览表書覽} AaBbCcDdEeFfghijklmnopqrstuvwxyz}";
      return $(function(event, send) {
        var i, len, raw, ref, shortname, texname;
        if (select(event, '!', 'JZR.fontlist')) {
          send(stamp(event));
          send(['tex', "\\begin{tabbing}\n"]);
          send(['tex', "\\phantom{XXXXXXXXXXXXXXXXXXXXXXXXX} \\= \\phantom{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX} \\\\\n"]);
          ref = S.options['fonts']['files'];
          for (i = 0, len = ref.length; i < len; i++) {
            texname = ref[i].texname;
            shortname = texname.replace(/^mktsFontfile/, '');
            raw = template;
            raw = raw.replace(/\(\$texname\)/g, texname);
            raw = raw.replace(/\(\$shortname\)/g, shortname);
            send(['tex', shortname + " \\> " + raw + " \\\\\n"]);
          }
          return send(['tex', "\\end{tabbing}\n"]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$most_frequent = {};

  this.$most_frequent.with_fncrs = {};

  this.$most_frequent.with_fncrs.$rewrite_events = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var _, meta, parameters;
        if (select(event, '!', 'JZR.most_frequent.with_fncrs')) {
          _ = event[0], _ = event[1], parameters = event[2], meta = event[3];
          if (meta['jzr'] == null) {
            meta['jzr'] = {};
          }
          meta['jzr']['group-name'] = 'glyphs-with-fncrs';
          return send(['!', 'JZR.most_frequent', parameters, meta]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$most_frequent.$read = (function(_this) {
    return function(S) {
      var HOLLERITH_DEMO, defaults;
      HOLLERITH_DEMO = require('../../hollerith/lib/demo');
      defaults = {
        n: 100,
        group_name: 'glyphs'
      };
      return D.remit_async_spread(function(event, send) {
        var group_name, meta, n, name, ref, ref1, ref2, type;
        if (!select(event, '!', 'JZR.most_frequent')) {
          return send.done(event);
        }
        type = event[0], name = event[1], (ref = event[2], n = ref[0]), meta = event[3];
        if (n == null) {
          n = defaults.n;
        }
        group_name = (ref1 = (ref2 = meta['jzr']) != null ? ref2['group-name'] : void 0) != null ? ref1 : defaults.group_name;
        return step(function*(resume) {
          var error, error1, glyph, glyphs, i, len;
          try {
            glyphs = (yield HOLLERITH_DEMO.read_sample(S.JZR.db, n, resume));
          } catch (error1) {
            error = error1;
            warn(error);
            return send.error(error);
          }
          send(stamp(event));
          glyphs = Object.keys(glyphs);
          send(['(', group_name, null, copy(meta)]);
          for (i = 0, len = glyphs.length; i < len; i++) {
            glyph = glyphs[i];
            send(['.', 'glyph', glyph, copy(meta)]);
          }
          send([')', group_name, null, copy(meta)]);
          return send.done();
        });
      });
    };
  })(this);

  this.$most_frequent.$assemble = (function(_this) {
    return function(S) {
      var track;
      track = MD_READER.TRACKER.new_tracker('(glyphs)');
      return $(function(event, send) {
        var _, glyph, meta, within_glyphs;
        within_glyphs = track.within('(glyphs)');
        track(event);
        if (select(event, '(', 'glyphs')) {
          return send(stamp(event));
        } else if (within_glyphs && select(event, '.', 'glyph')) {
          _ = event[0], _ = event[1], glyph = event[2], meta = event[3];
          return send(['.', 'text', glyph, copy(meta)]);
        } else if (select(event, ')', 'glyphs')) {
          return send(stamp(event));
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$most_frequent.$details_from_glyphs = (function(_this) {
    return function(S) {
      HOLLERITH = require('../../hollerith');
      return D.remit_async_spread(function(event, send) {
        var _, glyph, meta, prefix;
        if (select(event, '.', 'glyph')) {
          _ = event[0], _ = event[1], glyph = event[2], meta = event[3];
          prefix = ['spo', glyph];
          return HOLLERITH.read_phrases(S.JZR.db, {
            prefix: prefix
          }, function(error, phrases) {
            var details, i, len, obj, phrase, prd;
            details = {
              glyph: glyph
            };
            for (i = 0, len = phrases.length; i < len; i++) {
              phrase = phrases[i];
              _ = phrase[0], _ = phrase[1], prd = phrase[2], obj = phrase[3];
              details[prd] = obj;
            }
            send(['.', 'details', details, copy(meta)]);
            return send.done();
          });
        } else {
          return send.done(event);
        }
      });
    };
  })(this);

  this.$most_frequent.with_fncrs.$format = (function(_this) {
    return function(S) {
      var has_gloss, has_readings, reading_keys, this_glyph, track;
      track = MD_READER.TRACKER.new_tracker('(glyphs-with-fncrs)');
      this_glyph = null;
      reading_keys = ['reading/py', 'reading/hg', 'reading/ka', 'reading/hi'];
      has_readings = function(x) {
        return (CND.isa_list(x)) && (x.length > 0);
      };
      has_gloss = function(x) {
        return (CND.isa_text(x)) && (x.length > 0);
      };
      return $(function(event, send) {
        var _, details, gloss, i, len, meta, prd, reading, readings, within_glyphs;
        within_glyphs = track.within('(glyphs-with-fncrs)');
        track(event);
        if (within_glyphs && select(event, '.', 'details')) {
          _ = event[0], _ = event[1], details = event[2], meta = event[3];
          for (i = 0, len = reading_keys.length; i < len; i++) {
            prd = reading_keys[i];
            if (has_readings((readings = details[prd]))) {
              if (prd === 'reading/ka' || prd === 'reading/hi') {
                readings = (function() {
                  var j, len1, results;
                  results = [];
                  for (j = 0, len1 = readings.length; j < len1; j++) {
                    reading = readings[j];
                    results.push(reading.replace(/-/g, '⋯'));
                  }
                  return results;
                })();
              }
              details[prd] = readings.join(', ');
            }
          }
          if (has_gloss((gloss = details['reading/gloss']))) {
            details['reading/gloss'] = gloss.replace(/;/g, ',');
          }
          return send(event);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$most_frequent.with_fncrs.$assemble = (function(_this) {
    return function(S) {
      var this_glyph, track;
      track = MD_READER.TRACKER.new_tracker('(glyphs-with-fncrs)');
      this_glyph = null;
      return $(function(event, send) {
        var _, count, details, glyph, i, infix, key, len, meta, prefix, ref, suffix, text, value, value_txt, within_glyphs;
        within_glyphs = track.within('(glyphs-with-fncrs)');
        track(event);
        if (select(event, '(', 'glyphs-with-fncrs')) {
          _ = event[0], _ = event[1], this_glyph = event[2], _ = event[3];
          send(stamp(event));
          return send(['tex', '{\\setlength\\parskip{0mm}\n']);
        } else if (select(event, ')', 'glyphs-with-fncrs')) {
          this_glyph = null;
          send(stamp(event));
          return send(['tex', '}\n\n']);
        } else if (within_glyphs && select(event, '.', 'details')) {
          _ = event[0], _ = event[1], details = event[2], meta = event[3];
          send(['tex', "\\begin{tabular}{ | @{} p{20mm} @{} | @{} l @{} | @{} p{1mm} @{} | @{} p{60mm} @{} | }\n"]);
          value = details['guide/kwic/v3/sortcode'];
          value = value[0];
          _ = value[0], infix = value[1], suffix = value[2], prefix = value[3];
          if (prefix.length !== 0) {
            throw new Error("expected empty prefix, got " + glyph + " " + (rpr(value)));
          }
          value = infix + suffix.join('');
          send(['.', 'text', value, copy(meta)]);
          send(['tex', " & "]);
          glyph = details['glyph'];
          send(['tex', "{\\mktsStyleMidashi{}\\sbSmash{"]);
          send(['.', 'text', "" + glyph, copy(meta)]);
          send(['tex', "}}"]);
          send(['tex', " & "]);
          send(['tex', "{\\color{white} | |}"]);
          send(['tex', " & "]);
          value = details['formula'];
          if ((value != null) && value.length > 0) {
            value = value[0];
            send(['.', 'text', value, copy(meta)]);
          }
          value = details['cp/fncr'];
          value = value.replace(/-/g, '·');
          send(['tex', "{\\mktsStyleFncr{}"]);
          send(['.', 'text', value, copy(meta)]);
          send(['tex', "} "]);
          count = 0;
          ref = ['reading/py', 'reading/hg', 'reading/ka', 'reading/hi', 'reading/gloss'];
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            value = details[key];
            if (value == null) {
              continue;
            }
            value_txt = CND.isa_text(value) ? value : rpr(value);
            text = "" + value_txt;
            if (count !== 0) {
              send(['.', 'text', '; ', copy(meta)]);
            }
            if (key === 'reading/gloss') {
              send(['tex', "{\\mktsStyleGloss{}"]);
            }
            send(['.', 'text', text, copy(meta)]);
            if (key === 'reading/gloss') {
              send(['tex', "}"]);
            }
            count += +1;
          }
          if (count !== 0) {
            send(['.', 'text', '.', copy(meta)]);
          }
          if ((value = details['variant']) != null) {
            value = value.join('');
            send(['.', 'text', " " + value, copy(meta)]);
          }
          send(['tex', "\\\\\n\\hline\n"]);
          send(['tex', "\\end{tabular}\n"]);
          return send(['.', 'p', null, copy(meta)]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$dump_db = (function(_this) {
    return function(S) {
      HOLLERITH = require('../../hollerith');
      return $(function(event, send) {
        var _, glyph, glyphs, i, len, meta, parameters, results, settings, tasks;
        if (select(event, '!', 'JZR.dump_db')) {
          _ = event[0], _ = event[1], parameters = event[2], meta = event[3];
          settings = parameters[0];
          send(['.', 'text', rpr(settings), copy(meta)]);
          if ((glyphs = settings['glyphs']) != null) {
            if (CND.isa_text(glyphs)) {
              glyphs = XNCHR.chrs_from_text(glyphs);
            }
            tasks = [];
            results = [];
            for (i = 0, len = glyphs.length; i < len; i++) {
              glyph = glyphs[i];
              results.push(tasks.push);
            }
            return results;
          } else {
            return send(['.', 'warning', "expected setting 'glyphs' in call to `JZR.dump_db`", copy(meta)]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/custom-jzr.js.map
