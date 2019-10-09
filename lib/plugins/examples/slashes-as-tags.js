(function() {
  'use strict';
  var $, $async, CND, FS, MD_READER, PATH, PS, TYPOFIX, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, jr, log, rpr, select, stamp, unstamp, urge, warn, whisper;

  //###########################################################################################################
  PATH = require('path');

  FS = require('fs');

  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/TEX-WRITER/PLUGINS/SLASHES-AS-TAGS';

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
  MD_READER = require('../../md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  unstamp = MD_READER.unstamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  jr = JSON.stringify;

  //...........................................................................................................
  /* plugins must use pipestreams */
  PS = require('pipestreams');

  ({$, $async} = PS);

  TYPOFIX = require('../../tex-writer-typofix');

  //-----------------------------------------------------------------------------------------------------------
  this.$tag_tag = function(S, settings) {
    /* TAINT can't nest tags */
    var tagname, within;
    tagname = `${settings.prefix}-tag`;
    within = false;
    //.........................................................................................................
    return $((event, send) => {
      var meta, name, text, type;
      if (select(event, '(', tagname)) {
        within = true;
        send(stamp(event));
        send(['tex', '{\\mktsStyleCode{}']);
      //.......................................................................................................
      } else if (select(event, ')', tagname)) {
        within = false;
        send(stamp(event));
        send(['tex', '}']);
      //.......................................................................................................
      } else if (within && select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        // send stamp event
        send(['tex', '{\\mktsFontfileAsanamath{}⟪}']);
        // send [ 'tex', '{\\mktsFontfileHanamina{}☰}', ]
        // text = TYPOFIX.escape_tex_specials "[#{text}]"
        text = TYPOFIX.escape_tex_specials(`${text}`);
        send(['tex', text]);
        send(['tex', '{\\mktsFontfileAsanamath{}⟫}']);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$tagsample = function(S, settings) {
    var tag_name, tagsample_name, within;
    tagsample_name = `${settings.prefix}-tagsample`;
    tag_name = `${settings.prefix}-tag`;
    within = false;
    //.........................................................................................................
    return $((event, send) => {
      var fontnick, glyphs, meta, mktscript, name, parts, tag, text, type;
      if (select(event, '(', tagsample_name)) {
        within = true;
        send(stamp(event));
      // send [ 'tex', '{\\mktsStyleCode{}', ]
      //.......................................................................................................
      } else if (select(event, ')', tagsample_name)) {
        within = false;
        send(stamp(event));
      // send [ 'tex', '}', ]
      //.......................................................................................................
      } else if (within && select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        parts = text.split('::');
        //.....................................................................................................
        if (!((parts.length === 3) && (parts.every(function(x) {
          return x.length > 0;
        })))) {
          throw new Error(`^slashes_as_tags@3338^ not a valid tagsample line: ${rpr(text)}`);
        }
        [tag, fontnick, glyphs] = parts;
        //.....................................................................................................
        tag = tag.trim();
        fontnick = fontnick.trim();
        glyphs = glyphs.trim();
        //.....................................................................................................
        mktscript = '';
        mktscript += "<noindent/>";
        mktscript += `<${tag_name}>${tag}</${tag_name}><tab/>`;
        mktscript += `\`${fontnick}\`<tab/>`;
        mktscript += `<fontnick>${fontnick}</fontnick><tab/>`;
        mktscript += `<font name=${fontnick}>音言主文馬</font>&nl;`;
        // mktscript  += "<noindent/><#{tag_name}>#{tag}</#{tag_name}><tab/>`#{fontnick}`<tab/>`#{fontnick}`<tab/><font name=#{fontnick}>音言主文馬</font>&nl;"
        send(['.', 'mktscript', mktscript, copy(meta)]);
      } else {
        //.......................................................................................................
        send(event);
      }
      //.......................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$slashes_as_tags = function(S, settings) {
    var pattern;
    pattern = /\[\/(?<tag>\S+)\/\]/g;
    return $((event, send) => {
      var i, is_tag, len, meta, name, part, ref, text, type;
      if (select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        is_tag = true;
        ref = text.split(pattern);
        for (i = 0, len = ref.length; i < len; i++) {
          part = ref[i];
          is_tag = !is_tag;
          //...................................................................................................
          if (!is_tag) {
            send(['.', 'text', part, copy(meta)]);
            continue;
          }
          send(['tex', '{\\mktsStyleCode{}']);
          send(['.', 'text', part, copy(meta)]);
          send(['tex', '}']);
        }
      } else {
        send(event);
      }
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.main = function(S, settings) {
    var pipeline;
    pipeline = [];
    pipeline.push(this.$tag_tag(S, settings));
    pipeline.push(this.$tagsample(S, settings));
    // pipeline.push @$slashes_as_tags    S, settings
    return PS.pull(...pipeline);
  };

}).call(this);
