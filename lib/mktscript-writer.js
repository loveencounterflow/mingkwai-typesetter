(function() {
  var $, CND, D, MD_READER, MKTS, Markdown_parser, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, misfit, new_md_inline_plugin, njs_fs, njs_path, rpr, select, stamp, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/mktscript-writer';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  D = require('pipedreams');

  $ = D.remit.bind(D);

  Markdown_parser = require('markdown-it');

  new_md_inline_plugin = require('markdown-it-regexp');

  misfit = Symbol('misfit');

  MKTS = require('./main');

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  this.$show_mktsmd_events = function(S) {
    var indentation, tag_stack, unknown_events;
    unknown_events = [];
    indentation = '';
    tag_stack = [];
    return D.$observe((function(_this) {
      return function(event, has_ended) {
        var _, color, kind, message, meta, my_badge, name, ref, ref1, text, topmost_name, topmost_type, type;
        if (event != null) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '?') {
            if (indexOf.call(unknown_events, name) < 0) {
              unknown_events.push(name);
            }
            warn(JSON.stringify(event));
          } else {
            color = CND.blue;
            if (is_hidden(event)) {
              color = CND.brown;
            } else {
              switch (type) {
                case '(':
                  color = CND.lime;
                  break;
                case ')':
                  color = CND.olive;
                  break;
                case '!':
                  color = CND.indigo;
                  break;
                case '#':
                  color = CND.plum;
                  break;
                case '.':
                  switch (name) {
                    case 'text':
                      color = CND.BLUE;
                  }
              }
            }
            text = text != null ? color(rpr(text)) : '';
            switch (type) {
              case 'text':
                log(indentation + (color(type)) + ' ' + rpr(name));
                break;
              case 'tex':
                if ((ref = S.show_tex_events) != null ? ref : false) {
                  log(indentation + (color(type)) + (color(name)) + ' ' + text);
                }
                break;
              case '#':
                _ = event[0], kind = event[1], message = event[2], _ = event[3];
                my_badge = "(" + meta['badge'] + ")";
                color = (function() {
                  switch (kind) {
                    case 'insert':
                      return 'lime';
                    case 'drop':
                      return 'orange';
                    case 'warn':
                      return 'RED';
                    case 'info':
                      return 'BLUE';
                    default:
                      return 'grey';
                  }
                })();
                log(CND[color]('#' + kind), CND.white(message), CND.grey(my_badge));
                break;
              default:
                log(indentation + (color(type)) + (color(name)) + ' ' + text);
            }
            if (!is_hidden(event)) {
              switch (type) {
                case '(':
                case ')':
                  switch (type) {
                    case '(':
                      tag_stack.push([type, name]);
                      break;
                    case ')':
                      if (tag_stack.length > 0) {
                        ref1 = tag_stack.pop(), topmost_type = ref1[0], topmost_name = ref1[1];
                        if (topmost_name !== name) {
                          warn("encountered <<" + name + type + ">> when <<" + topmost_name + ")>> was expected");
                        }
                      } else {
                        warn("level below zero");
                      }
                  }
                  indentation = (new Array(tag_stack.length)).join('  ');
              }
            }
          }
        }
        if (has_ended) {
          if (tag_stack.length > 0) {
            warn("unclosed tags: " + (tag_stack.join(', ')));
          }
          if (unknown_events.length > 0) {
            warn("unknown events: " + (unknown_events.sort().join(', ')));
          }
        }
        return null;
      };
    })(this));
  };

  this.$produce_mktscript = function(S) {
    var indentation, tag_stack;
    indentation = '';
    tag_stack = [];
    return $(function(event, send, end) {
      var anchor, line_nr, meta, name, text, text_rpr, type;
      if (event != null) {
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (type !== 'tex' && type !== 'text') {
          line_nr = meta.line_nr;
          if (line_nr != null) {
            anchor = line_nr + " █ ";
          } else {
            anchor = "";
          }
          text_rpr = '';
          if (text != null) {

            /* TAINT we have to adopt a new event format; for now, the `text` attribute is misnamed,
            as it is really a `data` attribute
             */
            if (CND.isa_text(text)) {

              /* TAINT doesn't recognize escaped backslash */
              text_rpr = ' ' + (rpr(text)).replace(/\\n/g, '\n');
            } else if ((Object.keys(text)).length > 0) {
              text_rpr = ' ' + JSON.stringify(text);
            }
          }
          send("" + anchor + type + name + text_rpr);
          send('\n');
        }
      }
      if (end != null) {
        send("# EOF");
        end();
      }
      return null;
    });
  };

  this.mkts_events_from_md = function(source, settings, handler) {
    var Z, arity, bare, input, md_readstream, output, ref, ref1;
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
    bare = (ref = settings['bare']) != null ? ref : false;
    md_readstream = MKTS.MD_READER.create_md_read_tee(source);
    ref1 = md_readstream.tee, input = ref1.input, output = ref1.output;
    Z = [];
    output.pipe($((function(_this) {
      return function(event, send) {
        if (!(bare && select(event, ['(', ')'], 'document'))) {
          return Z.push(event);
        }
      };
    })(this)));
    output.on('end', function() {
      return handler(null, Z);
    });
    input.resume();
    return null;
  };

  this.mktscript_from_md = function(md_source, settings, handler) {

    /* TAINT code duplication */
    var arity, f, input, md_readstream, output, ref, ref1, source_route;
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
    source_route = (ref = settings['source-route']) != null ? ref : '<STRING>';
    md_readstream = MKTS.MD_READER.create_md_read_tee(md_source);
    ref1 = md_readstream.tee, input = ref1.input, output = ref1.output;
    f = (function(_this) {
      return function() {
        return input.resume();
      };
    })(this);
    output.pipe(this.$produce_mktscript(md_readstream.tee['S'])).pipe((function(_this) {
      return function() {
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
    })(this)());
    D.run(f, this._handle_error);
    return null;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/mktscript-writer.js.map
