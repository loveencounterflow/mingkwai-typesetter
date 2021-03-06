// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var CND, HP2, alert, assign, badge, close_tag_pattern, debug, echo, eq, handlers, head, help, i, info, join, jr, len, log, lone_tag_idx, match, provide_handlers, rpr, settings, source, sources, tail, test, urge, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'HTML-TAGS/TESTS';

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
  test = require('guy-test');

  eq = CND.equals;

  jr = JSON.stringify;

  //...........................................................................................................
  join = function(x, joiner = '') {
    return x.join(joiner);
  };

  assign = Object.assign;

  // XREGEXP                   = require 'xregexp'
  HP2 = require('htmlparser2');

  close_tag_pattern = /^(?<all><\/(?<name>[^>\s]+?)>)/;

  //-----------------------------------------------------------------------------------------------------------
  settings = {
    lowerCaseTags: false,
    lowerCaseAttributeNames: false,
    decodeEntities: false,
    xmlMode: false,
    recognizeSelfClosing: true,
    recognizeCDATA: false
  };

  //-----------------------------------------------------------------------------------------------------------
  provide_handlers = function(handler) {
    //---------------------------------------------------------------------------------------------------------
    this.onopentag = function(name, attributes) {
      var end, start;
      start = this.parser.startIndex;
      end = this.parser.endIndex;
      return handler(null, {
        mark: '(',
        name,
        attributes,
        start,
        end
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.ontext = function(text) {
      var end, start;
      start = this.parser.startIndex;
      end = this.parser.endIndex;
      return handler(null, {
        mark: '.',
        name: 'text',
        value: text,
        start,
        end
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.onclosetag = function(name) {
      var end, start;
      start = this.parser.startIndex;
      end = this.parser.endIndex;
      return handler(null, {
        mark: ')',
        name,
        start,
        end
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.onprocessinginstruction = function(name, data) {
      return handler(new Error(`encounter illegal XML processing instruction: ${rp({name, data})}`));
    };
    //---------------------------------------------------------------------------------------------------------
    this.onerror = function(error) {
      return handler(error);
    };
    //---------------------------------------------------------------------------------------------------------
    this.oncomment = function(data) {
      return whisper('comment', rpr({data}));
    };
    this.oncommentend = function() {
      return whisper('commentend');
    };
    // onopentag:                ( name,  attributes ) -> whisper 'opentag'
    // onopentagname:            ( name              ) -> whisper 'opentagname', rpr name
    // onattribute:              ( name,  value      ) -> whisper 'attribute', rpr { name: value }
    // ontext:                   ( text              ) -> whisper 'text'
    // onclosetag:               ( name              ) -> whisper 'closetag'
    // onprocessinginstruction:  ( name,  data       ) -> whisper 'processinginstruction', rpr { name, data, }
    // oncdatastart:             ()                    -> whisper 'cdatastart'
    // oncdataend:               ()                    -> whisper 'cdataend'
    // onreset:                  ()                    -> whisper 'reset'
    // onend:                    ()                    -> whisper 'end'
    return this;
  };

  //###########################################################################################################
  if (module.parent == null) {
    sources = ["helo <x:tag>world", "helo <x:tag></x:tag>world", "helo <x:tag> </x:tag>world", "helo <tag> </ignored>world", "helo <x:tag/>world", "helo <いきましょうか/>world", "<div>just a </div> that is closed", "just a </div> that is closed", "some < lonely > brackets", "some < lonely brackets", "some lonely > brackets"];
    // """<?xml-stylesheet type="text/xsl" href="style.xsl"?>foobar"""
    // "helo <x:b>world</x:b>"
    // "helo <b><i>world"
    // "helo <tag foo/>world"
    // "helo <tag foo>world</tag>"
    // "helo <tag foo=bar/>world"
    // "helo <TAG FOO=BAR/>world"
    // "helo <tag foo='bar'/>world"
    // "helo <TAG FOO='BAR'/>world"
    handlers = provide_handlers.call({}, function(error, d) {
      var color;
      if (error != null) {
        throw error;
      }
      color = (function() {
        switch (d.mark) {
          case '.':
            return CND.white;
          case '(':
            return CND.lime;
          case ')':
            return CND.orange;
          default:
            return CND.red;
        }
      })();
      return urge(color(jr(d)));
    });
    handlers.parser = new HP2.Parser(handlers, settings);
    for (i = 0, len = sources.length; i < len; i++) {
      source = sources[i];
      info(rpr(source));
      lone_tag_idx = source.indexOf('</');
      if ((lone_tag_idx = source.indexOf('</')) > -1 && lone_tag_idx <= (source.indexOf('<'))) {
        head = source.slice(0, lone_tag_idx);
        tail = source.slice(lone_tag_idx);
        urge(rpr(head));
        if ((match = tail.match(close_tag_pattern)) == null) {
          throw new Error(`illegal HTML markup at #${lone_tag_idx}: ${rpr(source)}`);
        }
        urge('close tag:', match.groups.name);
        // debug match.groups.all.length
        source = tail.slice(match.groups.all.length);
      }
      handlers.parser.write(source);
      handlers.parser.reset();
    }
  }

  // parser.end()
// parser.parseComplete()

}).call(this);

//# sourceMappingURL=parse-htmlish-tags.js.map
