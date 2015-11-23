(function() {
  var $, CND, D, HELPERS, Markdown_parser, alert, badge, debug, echo, get_parse_html_methods, help, info, log, misfit, new_md_inline_plugin, njs_fs, njs_path, parse_methods, rpr, tracker_pattern, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/MKTS';

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

  HELPERS = require('./HELPERS');

  this.MACROS = require('./MACROS');

  misfit = Symbol('misfit');

  this._get_badge = function(delta) {
    var caller_info, method_name, ref;
    if (delta == null) {
      delta = 0;
    }

    /* Experimental, to be used with remarks when things got omitted or inserted. */
    caller_info = CND.get_caller_info(delta + 2);
    method_name = (ref = caller_info['function-name']) != null ? ref : caller_info['method-name'];
    method_name = method_name.replace(/^__dirname\./, '');
    return method_name;
  };

  this._get_remark = function(delta) {
    var my_badge;
    if (delta == null) {
      delta = 0;
    }
    my_badge = this._get_badge(delta + 1);
    return (function(_this) {
      return function(kind, message, meta) {
        return _this.stamp([
          '#', kind, message, _this.copy(meta, {
            badge: my_badge
          })
        ]);
      };
    })(this);
  };

  this._new_markdown_parser = function() {

    /* https://markdown-it.github.io/markdown-it/#MarkdownIt.new */
    var R, feature_set, settings;
    feature_set = 'zero';
    settings = {
      html: true,
      xhtmlOut: false,
      breaks: false,
      langPrefix: 'language-',
      linkify: true,
      typographer: true,
      quotes: '“”‘’'
    };
    R = new Markdown_parser(feature_set, settings);
    R.enable('text').enable('escape').enable('backticks').enable('strikethrough').enable('emphasis').enable('link').enable('image').enable('autolink').enable('html_inline').enable('entity').enable('fence').enable('blockquote').enable('hr').enable('list').enable('reference').enable('heading').enable('lheading').enable('html_block').enable('table').enable('paragraph').enable('normalize').enable('block').enable('inline').enable('linkify').enable('replacements').enable('smartquotes');
    R.use(require('markdown-it-footnote'));
    return R;
  };

  get_parse_html_methods = function() {
    var Parser, R, get_message, parser;
    Parser = (require('parse5')).Parser;
    parser = new Parser();
    get_message = function(source) {
      return "expected single opening node, got " + (rpr(source));
    };
    R = {};
    R['_parse_html_open_tag'] = function(source) {
      var cn, cns, ref, ref1, tree;
      tree = parser.parseFragment(source);
      if ((cns = tree['childNodes']).length !== 1) {
        throw new Error(get_message(source));
      }
      cn = cns[0];
      if (((ref = cn['childNodes']) != null ? ref.length : void 0) !== 0) {
        throw new Error(get_message(source));
      }
      return ['begin', cn['tagName'], (ref1 = cn['attrs'][0]) != null ? ref1 : {}];
    };
    R['_parse_html_block'] = function(source) {
      var tree;
      tree = parser.parseFragment(source);
      debug('@88817', tree);
      return null;
    };
    return R;
  };

  parse_methods = get_parse_html_methods();

  this._parse_html_open_tag = parse_methods['_parse_html_open_tag'];

  this._parse_html_block = parse_methods['_parse_html_block'];

  this._parse_html_tag = function(source) {
    var match;
    if ((match = source.match(this._parse_html_tag.close_tag_pattern)) != null) {
      return ['end', match[1]];
    }
    if ((match = source.match(this._parse_html_tag.comment_pattern)) != null) {
      return ['comment', 'comment', match[1]];
    }
    return this._parse_html_open_tag(source);
  };

  this._parse_html_tag.close_tag_pattern = /^<\/([^>]+)>$/;

  this._parse_html_tag.comment_pattern = /^<!--([\s\S]*)-->$/;

  this.FENCES = {};


  /* TAINT moving to parentheses-only syntax; note that most of the `FENCES` submodule can then go */

  this.FENCES.left = ['('];

  this.FENCES.right = [')'];

  this.FENCES.pairs = {
    '(': ')',
    ')': '('
  };

  this.FENCES._get_opposite = (function(_this) {
    return function(fence, fallback) {
      var R;
      if ((R = _this.FENCES.pairs[fence]) == null) {
        if (fallback !== void 0) {
          return fallback;
        }
        throw new Error("unknown fence: " + (rpr(fence)));
      }
      return R;
    };
  })(this);

  this.TRACKER = {};

  tracker_pattern = /^([.!$(]?)([^\s.!$()]*)([)]?)$/;

  this.FENCES.parse = (function(_this) {
    return function(pattern, settings) {
      var _, left_fence, match, name, ref, right_fence, symmetric;
      left_fence = null;
      name = null;
      right_fence = null;
      symmetric = (ref = settings != null ? settings['symmetric'] : void 0) != null ? ref : true;
      if ((pattern == null) || pattern.length === 0) {
        throw new Error("pattern must be non-empty, got " + (rpr(pattern)));
      }
      match = pattern.match(_this.TRACKER._tracker_pattern);
      if (match == null) {
        throw new Error("not a valid pattern: " + (rpr(pattern)));
      }
      _ = match[0], left_fence = match[1], name = match[2], right_fence = match[3];
      if (left_fence.length === 0) {
        left_fence = null;
      }
      if (name.length === 0) {
        name = null;
      }
      if (right_fence.length === 0) {
        right_fence = null;
      }
      if (left_fence === '.') {

        /* Can not have a right fence if left fence is a dot */
        if (right_fence != null) {
          throw new Error("fence '.' can not have right fence, got " + (rpr(pattern)));
        }
      } else {

        /* Except for dot fence, must always have no fence or both fences in case `symmetric` is set */
        if (symmetric) {
          if (((left_fence != null) && (right_fence == null)) || ((right_fence != null) && (left_fence == null))) {
            throw new Error("unmatched fence in " + (rpr(pattern)));
          }
        }
      }
      if ((left_fence != null) && left_fence !== '.') {

        /* Complain about unknown left fences */
        if (indexOf.call(_this.FENCES.left, left_fence) < 0) {
          throw new Error("illegal left_fence in pattern " + (rpr(pattern)));
        }
        if (right_fence != null) {

          /* Complain about non-matching fences */
          if ((_this.FENCES._get_opposite(left_fence, null)) !== right_fence) {
            throw new Error("fences don't match in pattern " + (rpr(pattern)));
          }
        }
      }
      if (right_fence != null) {

        /* Complain about unknown right fences */
        if (indexOf.call(_this.FENCES.right, right_fence) < 0) {
          throw new Error("illegal right_fence in pattern " + (rpr(pattern)));
        }
      }
      return [left_fence, name, right_fence];
    };
  })(this);

  this.TRACKER._tracker_pattern = tracker_pattern;

  this.TRACKER.new_tracker = (function(_this) {
    return function() {
      var _MKTS, patterns, self;
      patterns = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      _MKTS = _this;
      self = function(event) {
        var event_name, left_fence, parts, pattern, pattern_name, ref, ref1, right_fence, state, type;
        ref = self._states;
        for (pattern in ref) {
          state = ref[pattern];
          parts = state.parts;
          if (!_MKTS.select.apply(_MKTS, [event].concat(slice.call(parts)))) {
            continue;
          }
          (ref1 = parts[0], left_fence = ref1[0], right_fence = ref1[1]), pattern_name = parts[1];
          type = event[0], event_name = event[1];
          if (type === left_fence) {
            self._enter(state);
          } else {
            self._leave(state);

            /* TAINT shouldn't throw error but issue warning remark */
            if (state['count'] < 0) {
              throw new Error("too many right fences: " + (rpr(event)));
            }
          }
        }
        return event;
      };
      self._states = {};
      self._get_state = function(pattern) {
        var R;
        if ((R = self._states[pattern]) == null) {
          throw new Error("untracked pattern " + (rpr(pattern)));
        }
        return R;
      };
      self.within = function() {
        var i, len, pattern, patterns;
        patterns = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        for (i = 0, len = patterns.length; i < len; i++) {
          pattern = patterns[i];
          if (self._within(pattern)) {
            return true;
          }
        }
        return false;
      };
      self._within = function(pattern) {
        return (self._get_state(pattern))['count'] > 0;
      };
      self.enter = function(pattern) {
        return self._enter(self._get_state(pattern));
      };
      self.leave = function(pattern) {
        return self._leave(self._get_state(pattern));
      };
      self._enter = function(state) {
        return state['count'] += +1;
      };

      /* TAINT should validate count when leaving */
      self._leave = function(state) {
        return state['count'] += -1;
      };
      (function() {
        var i, left_fence, len, pattern, pattern_name, ref, results, right_fence, state;
        results = [];
        for (i = 0, len = patterns.length; i < len; i++) {
          pattern = patterns[i];
          ref = _MKTS.FENCES.parse(pattern), left_fence = ref[0], pattern_name = ref[1], right_fence = ref[2];
          state = {
            parts: [[left_fence, right_fence], pattern_name],
            count: 0
          };
          results.push(self._states[pattern] = state);
        }
        return results;
      })();
      return self;
    };
  })(this);

  this._PRE = {};

  this._PRE.$flatten_tokens = (function(_this) {
    return function(S) {
      return $(function(token, send) {
        var i, len, ref, results, sub_token, type;
        switch ((type = token['type'])) {
          case 'inline':
            ref = token['children'];
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              sub_token = ref[i];
              results.push(send(sub_token));
            }
            return results;
            break;
          default:
            return send(token);
        }
      });
    };
  })(this);

  this._PRE.$reinject_html_blocks = (function(_this) {
    return function(S) {

      /* re-inject HTML blocks */
      var md_parser;
      md_parser = _this._new_markdown_parser();
      return $(function(token, send) {
        var XXX_source, environment, i, len, map, ref, ref1, ref2, removed, results, tokens, type;
        type = token.type, map = token.map;
        if (type === 'html_block') {

          /* TAINT `map` location data is borked with this method */

          /* add extraneous text content; this causes the parser to parse the HTML block as a paragraph
          with some inline HTML:
           */
          XXX_source = "XXX" + token['content'];

          /* for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse */

          /* TAINT what to do with useful data appearing in `environment`? */
          environment = {};
          tokens = md_parser.parse(XXX_source, environment);

          /* remove extraneous text content: */
          removed = (ref = tokens[1]) != null ? (ref1 = ref['children']) != null ? ref1.splice(0, 1) : void 0 : void 0;
          if (((ref2 = removed[0]) != null ? ref2['content'] : void 0) !== "XXX") {
            throw new Error("should never happen");
          }
          results = [];
          for (i = 0, len = tokens.length; i < len; i++) {
            token = tokens[i];
            results.push(S.confluence.write(token));
          }
          return results;
        } else {
          return send(token);
        }
      });
    };
  })(this);

  this._PRE.$rewrite_markdownit_tokens = (function(_this) {
    return function(S) {
      var _send, end_token, is_first, last_map, remark, send_unknown, unknown_tokens, within_footnote_block;
      unknown_tokens = [];
      is_first = true;
      last_map = [0, 0];
      _send = null;
      remark = _this._get_remark();
      within_footnote_block = false;
      end_token = Symbol["for"]('end');
      send_unknown = function(token, meta) {
        var type;
        type = token.type;
        _send(['?', type, token['content'], meta]);
        if (indexOf.call(unknown_tokens, type) < 0) {
          return unknown_tokens.push(type);
        }
      };
      return $(function(token, send) {
        var col_nr, extra, id, language_name, line_nr, map, markup, meta, name, position, ref, ref1, ref2, text_meta, type;
        _send = send;
        if (token === end_token) {
          if (unknown_tokens.length > 0) {
            send(remark('warn', "unknown tokens: " + (unknown_tokens.sort().join(', ')), {}));
          }
          if (is_first) {
            is_first = false;
            send(['(', 'document', null, {}]);
            send(['.', 'action', 'empty-document', {}]);
          }
          send([')', 'document', null, {}]);
          setImmediate(function() {
            whisper("ending input stream");
            return send.end();
          });
        } else if (CND.isa_list(token)) {

          /* TAINT this clause shouldn't be here; we should target resends (which could be source texts
          or MKTS events) to appropriate insertion points in the stream
           */

          /* pass through re-injected MKTS events */
          send(token);
        } else {
          type = token.type, map = token.map, markup = token.markup;
          if (map == null) {
            map = last_map;
          }
          line_nr = ((ref = map[0]) != null ? ref : 0) + 1;
          col_nr = ((ref1 = map[1]) != null ? ref1 : 0) + 1;
          meta = {
            line_nr: line_nr,
            col_nr: col_nr,
            markup: markup
          };
          if (is_first) {
            is_first = false;
            send(['(', 'document', null, meta]);
          }
          if (type === 'footnote_block_open') {
            within_footnote_block = true;
          }
          if (within_footnote_block || !S.has_ended) {
            switch (type) {
              case 'heading_open':
                send(['(', token['tag'], null, meta]);
                break;
              case 'heading_close':
                send([')', token['tag'], null, meta]);
                break;
              case 'paragraph_open':
                null;
                break;
              case 'paragraph_close':
                send(['.', 'p', null, meta]);
                break;
              case 'bullet_list_open':
                send(['(', 'ul', null, meta]);
                break;
              case 'bullet_list_close':
                send([')', 'ul', null, meta]);
                break;
              case 'list_item_open':
                send(['(', 'li', null, meta]);
                break;
              case 'list_item_close':
                send([')', 'li', null, meta]);
                break;
              case 'strong_open':
                send(['(', 'strong', null, meta]);
                break;
              case 'strong_close':
                send([')', 'strong', null, meta]);
                break;
              case 'em_open':
                send(['(', 'em', null, meta]);
                break;
              case 'em_close':
                send([')', 'em', null, meta]);
                break;
              case 'text':
                send(['.', 'text', token['content'], meta]);
                break;
              case 'hr':
                send(['.', 'hr', token['markup'], meta]);
                break;
              case 'code_inline':
                text_meta = _this.copy(meta);
                text_meta['markup'] = '';
                send(['(', 'code-span', null, meta]);
                send(['.', 'text', token['content'], text_meta]);
                send([')', 'code-span', null, _this.copy(meta)]);
                break;
              case 'footnote_ref':
                id = token['meta']['id'];
                send(['.', 'footnote-ref', id, meta]);
                break;
              case 'footnote_open':
                id = token['meta']['id'];
                send(['(', 'footnote-def', id, meta]);
                break;
              case 'footnote_close':
                send([')', 'footnote-def', null, meta]);
                break;
              case 'footnote_anchor':
                null;
                break;
              case 'footnote_block_open':
              case 'footnote_block_close':
                null;
                break;
              case 'html_block':
                throw new Error("should never happen");
                break;
              case 'fence':
                switch (token['tag']) {
                  case 'code':
                    language_name = token['info'];
                    if (language_name.length === 0) {
                      language_name = 'text';
                    }
                    send(['(', 'code', language_name, meta]);
                    send(['.', 'text', token['content'], _this.copy(meta)]);
                    send([')', 'code', language_name, _this.copy(meta)]);
                    break;
                  default:
                    send_unknown(token, meta);
                }
                break;
              case 'html_inline':
                ref2 = _this._parse_html_tag(token['content']), position = ref2[0], name = ref2[1], extra = ref2[2];
                switch (position) {
                  case 'comment':
                    send(['.', 'comment', extra.trim(), meta]);
                    break;
                  case 'begin':
                    if (name !== 'p') {
                      send(['(', name, extra, meta]);
                    }
                    break;
                  case 'end':
                    if (name === 'p') {
                      send(['.', name, null, meta]);
                    } else {
                      send([')', name, null, meta]);
                    }
                    break;
                  default:
                    throw new Error("unknown HTML tag position " + (rpr(position)));
                }
                break;
              default:
                debug('@26.05', token);
                send_unknown(token, meta);
            }
            last_map = map;
          }
          if (type === 'footnote_block_close') {
            within_footnote_block = false;
          }
        }
        return null;
      });
    };
  })(this);

  this._PRE.$process_end_command = (function(_this) {
    return function(S) {
      var remark;
      S.has_ended = false;
      remark = _this._get_remark();
      return $(function(event, send) {
        var _, line_nr, meta;
        if (_this.select(event, '!', 'end')) {
          if (!S.has_ended) {
            _ = event[0], _ = event[1], _ = event[2], meta = event[3];
            line_nr = meta.line_nr;

            /* TAINT consider to re-send `document>` */
            send(_this.stamp(event));
            send(remark('info', "encountered `<<!end>>` on line #" + line_nr, _this.copy(meta)));
            S.has_ended = true;
          }
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this._PRE.$consolidate_footnotes = (function(_this) {
    return function(S) {
      var collector, current_footnote_events, current_footnote_id, idx_by_ids, track, within_footnote_def;
      track = _this.TRACKER.new_tracker('(footnote-def)');
      collector = [];
      idx_by_ids = new Map();
      current_footnote_events = [];
      current_footnote_id = null;
      within_footnote_def = false;
      return $(function(event, send, end) {
        var events, i, id, j, len, len1, meta, name, target_idx, type;
        if (event != null) {
          within_footnote_def = track.within('(footnote-def)');
          track(event);
          if (_this.select(event, '.', 'footnote-ref')) {
            type = event[0], name = event[1], id = event[2], meta = event[3];
            collector.push([['(', 'footnote', id, _this.copy(meta)]]);
            idx_by_ids.set(id, collector.length);
            collector.push([]);
            collector.push([[')', 'footnote', id, _this.copy(meta)]]);
          } else if (_this.select(event, '(', 'footnote-def')) {
            type = event[0], name = event[1], id = event[2], meta = event[3];
            current_footnote_id = id;
          } else if (_this.select(event, ')', 'footnote-def')) {
            current_footnote_id = null;
          } else {
            if (within_footnote_def) {
              target_idx = idx_by_ids.get(current_footnote_id);
              if (!target_idx) {
                send.error(new Error("unknown footnote ID " + (rpr(current_footnote_id))));
              } else {
                collector[target_idx].push(event);
              }
            } else {
              collector.push([event]);
            }
          }
        }
        if (end != null) {
          for (i = 0, len = collector.length; i < len; i++) {
            events = collector[i];
            for (j = 0, len1 = events.length; j < len1; j++) {
              event = events[j];
              send(event);
            }
          }
          return end();
        }
      });
    };
  })(this);

  this._PRE.$close_dangling_open_tags = (function(_this) {
    return function(S) {
      var remark, tag_stack;
      tag_stack = [];
      remark = _this._get_remark();
      return $(function(event, send) {
        var meta, name, sub_event, sub_meta, sub_name, sub_text, sub_type, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (name === 'document') {
          if (type === ')') {
            while (tag_stack.length > 0) {
              sub_event = tag_stack.pop();
              sub_type = sub_event[0], sub_name = sub_event[1], sub_text = sub_event[2], sub_meta = sub_event[3];
              switch (sub_type) {
                case '(':
                  sub_type = ')';
                  break;
                case '(':
                  sub_type = ')';
                  break;
                case '(':
                  sub_type = ')';
              }
              send(remark('resend', "`" + sub_name + sub_type + "`", _this.copy(meta)));
              S.resend([sub_type, sub_name, sub_text, _this.copy(sub_meta)]);
            }
          }
        } else if (_this.select(event, '(')) {
          tag_stack.push([type, name, null, meta]);
        } else if (_this.select(event, ')')) {

          /* TAINT should check matching pairs */
          tag_stack.pop();
        }
        send(event);
        return null;
      });
    };
  })(this);

  this.select = function(event, type, name) {

    /* TAINT should use the same syntax as accepted by `FENCES.parse` */

    /* check for arity as it's easy to write `select event, '(', ')', 'latex'` when what you meant
    was `select event, [ '(', ')', ], 'latex'`
     */
    var arity, ref, ref1, type_of_name, type_of_type;
    if (this.is_hidden(event)) {
      return false;
    }
    if ((arity = arguments.length) > 3) {
      throw new Error("expected at most 3 arguments, got " + arity);
    }
    if (type != null) {
      switch (type_of_type = CND.type_of(type)) {
        case 'text':
          if (event[0] !== type) {
            return false;
          }
          break;
        case 'list':
          if (ref = event[0], indexOf.call(type, ref) < 0) {
            return false;
          }
          break;
        default:
          throw new Error("expected text or list, got a " + type_of_type);
      }
    }
    if (name != null) {
      switch (type_of_name = CND.type_of(name)) {
        case 'text':
          if (event[1] !== name) {
            return false;
          }
          break;
        case 'list':
          if (ref1 = event[1], indexOf.call(name, ref1) < 0) {
            return false;
          }
          break;
        default:
          throw new Error("expected text or list, got a " + type_of_name);
      }
    }
    return true;
  };

  this.stamp = function(event) {

    /* 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
    ignore events that have already been marked upstream, or, inversely choose to look out for events
    that have not yet found a representation in the target document.
     */
    event[3]['stamped'] = true;
    return event;
  };

  this.is_stamped = function(event) {
    var ref;
    return ((ref = event[3]) != null ? ref['stamped'] : void 0) === true;
  };

  this.is_unstamped = function(event) {
    return !this.is_stamped(event);
  };

  this.hide = function(event) {

    /* 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
    ignore events that have already been marked upstream, or, inversely choose to look out for events
    that have not yet found a representation in the target document.
     */
    event[3]['hidden'] = true;
    return event;
  };

  this.is_hidden = function(event) {
    var ref;
    return ((ref = event[3]) != null ? ref['hidden'] : void 0) === true;
  };

  this.copy = function() {
    var R, isa_list, meta, updates, x;
    x = arguments[0], updates = 2 <= arguments.length ? slice.call(arguments, 1) : [];

    /* (Hopefully) fast semi-deep copying for events (i.e. lists with a possible `meta` object on
    index 3) and plain objects. The value returned will be a shallow copy in the case of objects and
    lists, but if a list has a value at index 3, that object will also be copied. Not guaranteed to
    work for general values.
     */
    if ((isa_list = CND.isa_list(x))) {
      R = [];
    } else if (CND.isa_pod(x)) {
      R = {};
    } else {
      throw new Error("unable to copy a " + (CND.type_of(x)));
    }
    R = Object.assign.apply(Object, [R, x].concat(slice.call(updates)));
    if (isa_list && ((meta = R[3]) != null)) {
      R[3] = Object.assign({}, meta);
    }
    return R;
  };

  this._split_lines_with_nl = function(text) {
    var i, len, line, ref, results;
    ref = text.split(/(.*\n)/);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      if (line.length > 0) {
        results.push(line);
      }
    }
    return results;
  };

  this._flush_text_collector = function(send, collector, meta) {
    if (collector.length > 0) {
      send(['.', 'text', collector.join(''), meta]);
      collector.length = 0;
    }
    return null;
  };

  this.$show_illegal_chrs = function(S) {
    return $(function(old_text, send) {
      var new_text;
      new_text = old_text.replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f\ufffd-\uffff]/g, function($0) {
        var cid_hex, post, pre;
        cid_hex = ($0.codePointAt(0)).toString(16);
        pre = '█';
        post = '█';

        /* TAINT use mkts command */
        warn("detected illegal character U+" + cid_hex);
        return "{\\mktsStyleBold\\color{red}{%\n\\mktsStyleSymbol" + pre + "}U+" + cid_hex + "{\\mktsStyleSymbol" + post + "}}";
      });
      return send(new_text);
    });
  };

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
            if (_this.is_hidden(event)) {
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
            if (!_this.is_hidden(event)) {
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

  this.new_resender = function(S, stream) {

    /* TAINT re-parsing new source text should be handled by regular stream transform at an appropriate
    stream entry point
     */

    /* TAINT new parser not needed, can reuse 'main' parser */
    var md_parser;
    md_parser = this._new_markdown_parser();
    return (function(_this) {
      return function(md_source) {

        /* TAINT must handle data in environment */
        var environment, first_idx, i, idx, keys, last_idx, ref, ref1, results, tokens;
        if (CND.isa_text(md_source)) {
          md_source = _this.MACROS.escape(S, md_source);
          environment = {};
          tokens = md_parser.parse(md_source, environment);

          /* TAINT intermediate solution */
          if ((keys = Object.keys(environment)).length > 0) {
            warn("ignoring keys from sub-parsing environment: " + (rpr(keys)));
          }
          if (tokens.length > 0) {

            /* Omit `paragraph_open` as first and `paragraph_close` as last token: */
            first_idx = 0;
            last_idx = tokens.length - 1;
            first_idx = tokens[first_idx]['type'] === 'paragraph_open' ? first_idx + 1 : first_idx;
            last_idx = tokens[last_idx]['type'] === 'paragraph_close' ? last_idx - 1 : last_idx;
            results = [];
            for (idx = i = ref = first_idx, ref1 = last_idx; ref <= ref1 ? i <= ref1 : i >= ref1; idx = ref <= ref1 ? ++i : --i) {
              results.push(stream.write(tokens[idx]));
            }
            return results;
          }
        } else {
          return stream.write(md_source);
        }
      };
    })(this);
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
    md_readstream = this.create_md_read_tee(source);
    ref1 = md_readstream.tee, input = ref1.input, output = ref1.output;
    Z = [];
    output.pipe($((function(_this) {
      return function(event, send) {
        if (!(bare && _this.select(event, ['(', ')'], 'document'))) {
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
    md_readstream = this.create_md_read_tee(md_source);
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

  this.create_md_read_tee = function(md_source, settings) {
    var R, S, input, readstream, writestream;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }

    /* for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse */
    S = {
      environment: {}
    };

    /* TAINT `settings`, `S` and fitting should be the same object */
    settings = {
      S: S
    };

    /* TAINT rewrite to use D.TEE.from_pipeline, don't use readstream, writestream */
    readstream = D.create_throughstream();
    writestream = D.create_throughstream();
    R = D.TEE.from_readwritestreams(readstream, writestream, settings);
    input = R.tee.input;
    input.pause();
    S.resend = this.new_resender(S, readstream);
    S.confluence = readstream;
    readstream.pipe(this._PRE.$flatten_tokens(S)).pipe(this._PRE.$reinject_html_blocks(S)).pipe(this._PRE.$rewrite_markdownit_tokens(S)).pipe(this.MACROS.$expand(S)).pipe(this._PRE.$process_end_command(S)).pipe(this._PRE.$close_dangling_open_tags(S)).pipe(this._PRE.$consolidate_footnotes(S)).pipe(writestream);
    input.on('resume', (function(_this) {
      return function() {
        var i, len, md_parser, token, tokens;
        md_parser = _this._new_markdown_parser();
        _this.MACROS.initialize_state(S);
        md_source = _this.MACROS.escape(S, md_source);
        tokens = md_parser.parse(md_source, S.environment);
        for (i = 0, len = tokens.length; i < len; i++) {
          token = tokens[i];
          input.write(token);
        }
        return input.write(Symbol["for"]('end'));
      };
    })(this));
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/MKTS.js.map
