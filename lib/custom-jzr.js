(function() {
  var $, $async, CND, D, HOLLERITH, MD_READER, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, njs_fs, njs_path, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper;

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
      return D.TEE.from_pipeline([_this.$fontlist(S), _this.$most_frequent.with_fncrs.$rewrite_events(S), _this.$most_frequent.$read(S), _this.$most_frequent.with_fncrs.$read(S), _this.$most_frequent.with_fncrs.$format(S), _this.$most_frequent.with_fncrs.$collect(S), _this.$most_frequent.with_fncrs.$assemble(S), _this.$most_frequent.$assemble(S)]);
    };
  })(this);

  this.$fontlist = (function(_this) {
    return function(S) {
      var kana_shortnames, template;
      kana_shortnames = ['Babelstonehan', 'Cwtexqfangsongmedium', 'Cwtexqheibold', 'Cwtexqkaimedium', 'Cwtexqmingmedium', 'Cwtexqyuanmedium', 'Hanamina', 'Sunexta', 'Kai', 'Nanumgothic', 'Nanummyeongjo', 'Simsun', 'Fandolfangregular', 'Fandolheibold', 'Fandolheiregular', 'Fandolkairegular', 'Fandolsongbold', 'Fandolsongregular', 'Ipaexg', 'Ipaexm', 'Ipag', 'Ipagp', 'Ipam', 'Ipamp', 'Ipaexg', 'Ipaexm', 'Ipag', 'Ipagp', 'Ipam', 'Ipamp', 'Ukai', 'Uming', 'Droidsansfallbackfull', 'Droidsansjapanese', 'Fontsjapanesegothic', 'Fontsjapanesemincho', 'Takaopgothic', 'Sourcehansansbold', 'Sourcehansansextralight', 'Sourcehansansheavy', 'Sourcehansanslight', 'Sourcehansansmedium', 'Sourcehansansnormal', 'Sourcehansansregular'];
      template = "($shortname) {\\($texname){\\cjk\\($texname){}ぁあぃいぅうぇえぉおかがきぎく\nぐけげこごさざしじすずせぜそぞた\nだちぢっつづてでとどなにぬねのは\nばぱひびぴふぶぷへべぺほぼぽまみ\nむめもゃやゅゆょよらりるれろゎわ\nゐゑをんゔゕゖァアィイゥウェエォオカガキギク\nグケゲコゴサザシジスズセゼソゾタ\nダチヂッツヅテデトドナニヌネノハ\nバパヒビピフブプヘベペホボポマミ\nムメモャヤュユョヨラリルレロヮワ\nヰヱヲンヴヵヶヷヸヹヺ\n本书使用的数字，符号一览表}\nAaBbCcDdEeFfghijklmn}";
      template = "This is {\\cjk\\($texname){}むず·かしい} so very {\\cjk\\($texname){}ムズ·カシイ} indeed.";
      template = "XXX{\\($texname){}·}XXX";
      template = "The character {\\cjk{}出} {\\($texname){}u{\\mktsFontfileEbgaramondtwelveregular{}·}cjk{\\mktsFontfileEbgaramondtwelveregular{}·}51fa} means '{\\mktsStyleItalic{}go out, send out, stand, produce}'.";
      template = "{\\($texname){}出 、出。出〃出〄出々出〆出〇出〈出〉出《出》出「出」出}\\\\\n\\> {\\($texname){}出『出』出【出】出〒出〓出〔出〕出〖出〗出〘出〙出〚出}";
      template = "{\\($texname){}abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ}";
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

  this.$most_frequent.with_fncrs.$read = (function(_this) {
    return function(S) {
      var track;
      track = MD_READER.TRACKER.new_tracker('(glyphs-with-fncrs)');
      HOLLERITH = require('../../hollerith');
      return D.remit_async_spread(function(event, send) {
        var _, glyph, meta, prefix, within_glyphs;
        within_glyphs = track.within('(glyphs-with-fncrs)');
        track(event);
        if (!(within_glyphs && select(event, '.', 'glyph'))) {
          return send.done(event);
        }
        _ = event[0], _ = event[1], glyph = event[2], meta = event[3];
        prefix = ['spo', glyph];
        return HOLLERITH.read_phrases(S.JZR.db, {
          prefix: prefix
        }, function(error, phrases) {
          var i, len, obj, phrase, prd;
          send(event);
          send(['(', 'details', glyph, copy(meta)]);
          for (i = 0, len = phrases.length; i < len; i++) {
            phrase = phrases[i];
            _ = phrase[0], _ = phrase[1], prd = phrase[2], obj = phrase[3];
            send(['*', prd, obj, copy(meta)]);
          }
          send([')', 'details', glyph, copy(meta)]);
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

  this.$most_frequent.with_fncrs.$format = (function(_this) {
    return function(S) {
      var collector, has_gloss, has_readings, reading_keys, this_glyph, track;
      track = MD_READER.TRACKER.new_tracker('(glyphs-with-fncrs)', '(details)');
      this_glyph = null;
      collector = null;
      reading_keys = ['reading/py', 'reading/hg', 'reading/ka', 'reading/hi'];
      has_readings = function(x) {
        return (CND.isa_list(x)) && (x.length > 0);
      };
      has_gloss = function(x) {
        return (CND.isa_text(x)) && (x.length > 0);
      };
      return $(function(event, send) {
        var _, i, idx, len, meta, obj, prd, reading, value, within_details, within_glyphs;
        within_glyphs = track.within('(glyphs-with-fncrs)');
        within_details = track.within('(details)');
        track(event);
        if (within_glyphs && within_details && select(event, '*', reading_keys)) {
          _ = event[0], prd = event[1], obj = event[2], meta = event[3];
          if (has_readings(obj)) {
            if (prd === 'reading/ka' || prd === 'reading/hi') {
              for (idx = i = 0, len = obj.length; i < len; idx = ++i) {
                reading = obj[idx];
                obj[idx] = reading.replace(/-/g, '⋯');
              }
            }
            value = obj.join(', ');
            return send(['*', prd, value, copy(meta)]);
          }
        } else if (within_glyphs && within_details && select(event, '*', 'reading/gloss')) {
          _ = event[0], prd = event[1], obj = event[2], meta = event[3];
          if (has_gloss(obj)) {
            value = obj.replace(/;/g, ',');
            return send(['*', prd, value, copy(meta)]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$most_frequent.with_fncrs.$collect = (function(_this) {
    return function(S) {
      var collector, this_glyph, track;
      track = MD_READER.TRACKER.new_tracker('(glyphs-with-fncrs)', '(details)');
      this_glyph = null;
      collector = null;
      return $(function(event, send) {
        var _, meta, obj, prd, within_details, within_glyphs;
        within_glyphs = track.within('(glyphs-with-fncrs)');
        within_details = track.within('(details)');
        track(event);
        if (select(event, '(', 'details')) {
          send(stamp(event));
          return collector = {};
        } else if (select(event, ')', 'details')) {
          _ = event[0], _ = event[1], _ = event[2], meta = event[3];
          send(stamp(copy(event)));
          send(['.', 'details', collector, copy(meta)]);
          return collector = null;
        } else if (within_glyphs && within_details && select(event, '*')) {
          null;
          _ = event[0], prd = event[1], obj = event[2], _ = event[3];
          return collector[prd] = obj;
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
        var _, count, details, glyph, i, key, len, meta, ref, text, value, value_txt, within_glyphs;
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
        } else if (within_glyphs && select(event, '.', 'glyph')) {
          _ = event[0], _ = event[1], glyph = event[2], meta = event[3];
          send(['tex', "\\begin{tabular}{ | @{} l @{} | @{} p{1mm} @{} | @{} p{60mm} @{} | }\n"]);
          send(['tex', "{\\mktsStyleMidashi{}\\sbSmash{"]);
          send(['.', 'text', "" + glyph, copy(meta)]);
          send(['tex', "}}"]);
          return send(['tex', " &  {\\color{white} | |} & "]);
        } else if (within_glyphs && select(event, '.', 'details')) {
          null;
          _ = event[0], _ = event[1], details = event[2], meta = event[3];
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
          send(['tex', "\\\\\n\\hline\n"]);
          send(['tex', "\\end{tabular}\n"]);
          return send(['.', 'p', null, copy(meta)]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/custom-jzr.js.map
