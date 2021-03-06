// Generated by CoffeeScript 2.3.2
(function() {
  //###########################################################################################################
  var $, CND, D, MKTS, XREGEXP, alert, badge, debug, echo, help, info, log, njs_fs, njs_path, rpr, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/MACRO-ESCAPER';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  //-----------------------------------------------------------------------------------------------------------
  D = require('pipedreams');

  $ = D.remit.bind(D);

  // $async                    = D.remit_async.bind D
  //...........................................................................................................
  // Markdown_parser           = require 'markdown-it'
  // # Html_parser               = ( require 'htmlparser2' ).Parser
  // new_md_inline_plugin      = require 'markdown-it-regexp'
  //...........................................................................................................
  // HELPERS                   = require './HELPERS'
  //...........................................................................................................
  // misfit                    = Symbol 'misfit'
  MKTS = require('./main');

  this.cloak = (require('./cloak')).new();

  // hide                      = MKTS.hide.bind        MKTS
  // copy                      = MKTS.MD_READER.copy.bind        MKTS
  // stamp                     = MKTS.stamp.bind       MKTS
  // select                    = MKTS.MD_READER.select.bind      MKTS
  // is_hidden                 = MKTS.is_hidden.bind   MKTS
  // is_stamped                = MKTS.is_stamped.bind  MKTS
  XREGEXP = require('xregexp');

  this._raw_tags = [];

  //===========================================================================================================
  // HELPERS
  //-----------------------------------------------------------------------------------------------------------
  this.initialize_state = (state) => {
    state['MACRO_ESCAPER'] = {
      registry: []
    };
    return state;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._match_first = (patterns, text) => {
    var R, i, len, pattern;
    for (i = 0, len = patterns.length; i < len; i++) {
      pattern = patterns[i];
      if ((R = text.match(pattern)) != null) {
        return R;
      }
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._register_content = (S, kind, markup, raw, parsed = null) => {
    var idx, key, registry;
    registry = S['MACRO_ESCAPER']['registry'];
    idx = registry.length;
    key = `${kind}${idx}`;
    registry.push({key, markup, raw, parsed});
    return key;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._retrieve_entry = (S, id) => {
    var R;
    if ((R = S['MACRO_ESCAPER']['registry'][id]) == null) {
      throw new Error(`unknown ID ${rpr(id)}`);
    }
    return R;
  };

  //===========================================================================================================
  // PATTERNS
  //-----------------------------------------------------------------------------------------------------------
  this.PATTERNS = {};

  //-----------------------------------------------------------------------------------------------------------
  this.html_comment_patterns = [/<!--([\s\S]*?)-->/g]; // HTML comments... // (NB: end-of-comment cannot be escaped, because HTML).
  // start with less-than, exclamation mark, double hyphen;
  // then: anything, not-greedy, until we hit upon
  // a double-slash, then greater-than.

  //-----------------------------------------------------------------------------------------------------------
  this.action_patterns = [ // A silent or vocal action macro...
    // starts with two left pointy brackets, then: left round bracket,
    // then: a dot or a colon;
    // then:
    //   or: anything but a RPB
    //   or: a RPB not followed by yet another RPB
    // repeated any number of times
    // then: two RPBs...
    // (then: an empty group; see below), then: two left pointy brackets,
    // then: optionally, whatever appeared in the start tag,
    // then: right round bracket, then: two RPBs.
    
    // Start Tag
    // =========

    // Content
    // =========
    // Empty content.

    // Stop Tag
    // =========
    /<<\(([.:])((?:[^>]|>(?!>))*)>>()<<((?:\1\2)?)\)>>/g, //...........................................................................
  // Alternatively (non-empty content):
  // starts with two left pointy brackets, then: left round bracket,
  // then: a dot or a colon;
  // then:
  //   or: anything but a RPB
  //   or: a RPB not followed by yet another RPB
  // repeated any number of times
  // then: two RPBs...
  // ...followed by content, which is:
  //   or: anything but a LPB
  //   or: a LPB not followed by yet another LPB
  // repeated any number of times
  // then: two left pointy brackets,
  // then: optionally, whatever appeared in the start tag,
  // then: right round bracket, then: two RPBs.
  
  // Start Tag
  // =========

  // Content
  // =========

  // Stop Tag
  // =========
    /<<\(([.:])((?:[^>]|>(?!>))*)>>((?:[^<]|<(?!<))*)<<((?:\1\2)?)\)>>/g
  ];

  //-----------------------------------------------------------------------------------------------------------
  this.region_patterns = [ // A region macro tag...
    // starts with two left pointy brackets
    // then: left round bracket,

    // then:
    //   or: anything but a RPB
    //   or: a RPB not followed by yet another RPB
    // repeated any number of times
    // then: empty group for no markup here
    // then: two RPBs.
    
    // Start Tag
    // =========
    /<<(\()((?:[^>]|>(?!>))*)()>>/g, // Stop Tag
  // starts with two left pointy brackets
  // then: empty group for no markup here

  // then:
  //   or: anything but a RPB
  //   or: a RPB not followed by yet another RPB
  // repeated any number of times
  // a right round bracket;
  // then: two RPBs.
  // ========

    /<<()(|[^.:](?:[^>]|>(?!>))*)(\))>>/g
  ];

  // debug '234652', @action_patterns
  // debug "abc<<(:js>>4 + 3<<:js)>>def".match @action_patterns[ 0 ]
  // process.exit()

  //-----------------------------------------------------------------------------------------------------------
  this.bracketed_raw_patterns = [/<<(<)((?:[^>]|>{1,2}(?!>))*)>>>/g]; // A bracketed raw macro
  // starts with three left pointy brackets,
  // then:
  //   or: anything but a RPB
  //   or: one or two RPBs not followed by yet another RPB
  // repeated any number of times
  // then: three RPBs.

  //-----------------------------------------------------------------------------------------------------------
  this.comma_patterns = [/<<,>>/g]; // Comma macro to separate arguments within macro regions

  // #-----------------------------------------------------------------------------------------------------------
  // @raw_heredoc_pattern  = ///
  //   ( ^ | [^\\] ) <<! raw: ( [^\s>]* )>> ( .*? ) \2
  //   ///g

  //-----------------------------------------------------------------------------------------------------------
  this.command_and_value_patterns = [/<<([!@])((?:[^>]|>(?!>))*)>>/g]; // A command macro
  // starts with two left pointy brackets,
  // then: an exclamation mark or a commerical-at sign,
  // then:
  //   or: anything but a RPB
  //   or: a RPB not followed by yet another RPB
  // repeated any number of times
  // then: two RPBs.

  //-----------------------------------------------------------------------------------------------------------
  this.insert_command_patterns = [/<<(!)insert(?=[\s>])((?:[^>]|>(?!>))*)>>/g]; // An insert command macro
  // starts with two left pointy brackets,
  // then: an exclamation mark
  // then: an 'insert' literal (followed by WS or RPB)
  // then:
  //   or: anything but a RPB
  //   or: a RPB not followed by yet another RPB
  // repeated any number of times
  // then: two RPBs.

  //-----------------------------------------------------------------------------------------------------------
  /* NB The end command macro looks like any other command except we can detect it with a much simpler
  RegEx; we want to do that so we can, as a first processing step, remove it and any material that appears
  after it, thereby inhibiting any processing of those portions. */
  this.end_command_patterns = [/(^|^[\s\S]*?[^\\])<<!end>>/]; // Then end command macro // NB that this pattern is not global.
  // starts either at the first chr
  // or a minimal number of chrs whose last one is not a backslash
  // then: the `<<!end>>` literal.

  //-----------------------------------------------------------------------------------------------------------
  this.illegal_patterns = [/(<<|>>)/g]; // After applying all other macro patterns, treat as error
  // any occurrances of two left or two right pointy brackets.

  //===========================================================================================================
  // ESCAPING
  //-----------------------------------------------------------------------------------------------------------
  this.escape = (S, text) => {
    var R, discard_count;
    // debug '©II6XI', rpr text
    [R, discard_count] = this.escape.truncate_text_at_end_command_macro(S, text);
    if (discard_count > 0) {
      whisper(`detected <<!end>> macro; discarding approx. ${discard_count} characters`);
    }
    R = this.escape.insert_macros(S, R);
    R = this.escape.escape_chrs(S, R);
    R = this.escape.html_comments(S, R);
    // R = @escape.sensitive_ws              S, R
    R = this.escape.bracketed_raw_macros(S, R);
    R = this.escape.taggish_raw_macros(S, R);
    R = this.escape.action_macros(S, R);
    R = this.escape.region_macros(S, R);
    R = this.escape.comma_macros(S, R);
    R = this.escape.command_and_value_macros(S, R);
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.truncate_text_at_end_command_macro = (S, text) => {
    var R, match;
    if ((match = this._match_first(this.end_command_patterns, text)) == null) {
      return [text, 0];
    }
    R = match[1];
    // urge '©ΣΩΗΔΨ', rpr R
    return [R, text.length - R.length];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.escape_chrs = (S, text) => {
    return this.cloak.backslashed.hide(this.cloak.hide(text));
  };

  this.escape.unescape_escape_chrs = (S, text) => {
    return this.cloak.reveal(this.cloak.backslashed.reveal(text));
  };

  this.escape.remove_escaping_backslashes = (S, text) => {
    return this.cloak.backslashed.remove(text);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.sensitive_ws = (S, text) => {
    var R, pattern;
    /* Fixes an annoying parsing problem with Markdown-it where the leading whitespace in
    ```
    <<(keep-lines>>
    　　　　　　　|𠦝韦　　　　　　韩
    ```
    is kept but deleted when the first line is blank, as in
    ```
    <<(keep-lines>>

    　　　　　　　|𠦝韦　　　　　　韩
    ```
     */
    // pattern = /// (>>) (\s*) ///g
    pattern = /(<<\(keep-lines>>)(\s*)/g;
    R = text;
    //.........................................................................................................
    // for pattern in @region_patterns
    R = R.replace(pattern, (_, anchor, sws) => {
      var id;
      id = this._register_content(S, 'sws', sws, sws);
      return `${anchor}\x15${id}\x13`;
    });
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.html_comments = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.html_comment_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, content) => {
        var key;
        key = this._register_content(S, 'comment', null, content, content.trim());
        return `\x15${key}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.bracketed_raw_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.bracketed_raw_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, markup, content) => {
        var id;
        id = this._register_content(S, 'raw', markup, ['raw', content]);
        return `\x15${id}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.register_raw_tag = (tag_name) => {
    /* TAINT extend to match tag with attributes */
    var start_pattern, stop_pattern;
    start_pattern = RegExp(`<${tag_name}>|<${tag_name}\\s+(?<attributes>[^>]*)(?<!\\/)>`, "g");
    stop_pattern = RegExp(`<\\/${tag_name}>`, "g");
    return this._raw_tags.push([tag_name, start_pattern, stop_pattern]);
  };

  //...........................................................................................................
  this.register_raw_tag('raw');

  //-----------------------------------------------------------------------------------------------------------
  this.escape.taggish_raw_macros = (S, text) => {
    var error, i, id, j, len, len1, markup, match, matches, parts, ref, settings, start_pattern, stop_pattern, tag_name;
    parts = [];
    markup = null;
    //.........................................................................................................
    settings = {
      valueNames: ['between', 'left', 'match', 'right']
    };
    ref = this._raw_tags;
    for (i = 0, len = ref.length; i < len; i++) {
      [tag_name, start_pattern, stop_pattern] = ref[i];
      try {
        matches = XREGEXP.matchRecursive(text, start_pattern.source, stop_pattern.source, 'g', settings);
      } catch (error1) {
        error = error1;
        warn("when trying to parse text:");
        urge(rpr(text));
        warn(`using start pattern: ${rpr(start_pattern)}`);
        warn(`using stop  pattern: ${rpr(stop_pattern)}`);
        warn(`for tag: ${rpr(tag_name)}`);
        warn(`an error occurred: ${error.message}`);
        throw new Error(`µ49022 ${error.message}`);
      }
      //.......................................................................................................
      if (matches != null) {
        for (j = 0, len1 = matches.length; j < len1; j++) {
          match = matches[j];
          switch (match.name) {
            case 'between':
              parts.push(match.value);
              break;
            case 'left':
              markup = match.value;
              break;
            case 'match':
              id = this._register_content(S, 'raw', markup, [tag_name, match.value]);
              parts.push(`\x15${id}\x13`);
              break;
            case 'right':
              null;
          }
        }
        text = parts.join('');
        parts.length = 0;
      }
    }
    //.........................................................................................................
    return text;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.action_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.action_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, markup, identifier, content, stopper) => {
        /* TAINT not using arguments peoperly */
        var id, language, mode;
        mode = markup === '.' ? 'silent' : 'vocal';
        language = identifier;
        if (language === '') {
          language = 'coffee';
        }
        id = this._register_content(S, 'action', [mode, language], content);
        return `\x15${id}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.insert_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.insert_command_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, markup, parameter_txt) => {
        var content, error, error_message, locator, result, route;
        [error_message, result] = MKTS.MACRO_INTERPRETER._parameters_from_text(S, 0, parameter_txt);
        /* TAINT need current context to resolve file route */
        /* TAINT how to return proper error message? */
        /* TAINT what kind of error handling is this? */
        if (result != null) {
          [route] = result;
          locator = njs_path.resolve(S.layout_info['source-home'], route);
          if (route != null) {
            whisper(`resolved route: ${route} -> ${locator}`);
            try {
              content = njs_fs.readFileSync(locator, {
                encoding: 'utf-8'
              });
            } catch (error1) {
              error = error1;
              error_message = (error_message != null ? error_message : '') + "\n" + error['message'];
            }
          } else {
            error_message = (error_message != null ? error_message : '') + "\nneed file route for insert macro";
          }
        }
        if (error_message != null) {
          /* TAINT provide proper location */
          // return [ '.', 'warning', error_message, {}, ]
          return ` ███ ${error_message} ███ `;
        }
        return content;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.region_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.region_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, start_markup, identifier, stop_markup) => {
        var id, markup;
        markup = start_markup.length === 0 ? stop_markup : start_markup;
        id = this._register_content(S, 'region', markup, identifier);
        // if identifier is 'keep-lines'
        //   if start_markup is '('
        //     return """
        //       \x15#{id}\x13
        //       ```keep-lines"""
        //   else
        //     return """
        //       ```
        //       \x15#{id}\x13"""
        return `\x15${id}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.comma_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.comma_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_) => {
        var id;
        // debug '©ΛΨ regions', ( rpr text ), [ previous_chr, markup, identifier, content, stopper, ]
        id = this._register_content(S, 'comma', null, null);
        return `\x15${id}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.escape.command_and_value_macros = (S, text) => {
    var R, i, len, pattern, ref;
    R = text;
    ref = this.command_and_value_patterns;
    //.........................................................................................................
    for (i = 0, len = ref.length; i < len; i++) {
      pattern = ref[i];
      R = R.replace(pattern, (_, markup, content) => {
        var key, kind;
        kind = markup === '!' ? 'command' : 'value';
        key = this._register_content(S, kind, markup, content, null);
        return `\x15${key}\x13`;
      });
    }
    //.........................................................................................................
    return R;
  };

  //===========================================================================================================
  // EXPANDING
  //-----------------------------------------------------------------------------------------------------------
  this.raw_id_pattern = /\x15raw([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.html_comment_id_pattern = /\x15comment([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.action_id_pattern = /\x15action([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.region_id_pattern = /\x15region([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.comma_id_pattern = /\x15comma([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.sws_id_pattern = /\x15sws([0-9]+)\x13/g;

  //-----------------------------------------------------------------------------------------------------------
  this.command_and_value_id_pattern = /\x15(?:command|value)([0-9]+)\x13/g;

  //===========================================================================================================
  // EXPANDERS
  //-----------------------------------------------------------------------------------------------------------
  this.$expand = function(S) {
    var pipeline, settings;
    pipeline = [this.$expand.$command_and_value_macros(S), this.$expand.$comma_macros(S), this.$expand.$region_macros(S), this.$expand.$action_macros(S), this.$expand.$raw_macros(S), this.$expand.$sensitive_ws(S), this.$expand.$html_comments(S), this.$expand.$escape_chrs(S)];
    //.......................................................................................................
    // @$expand.$escape_illegals           S
    settings = {
      // inputs:
      //   mktscript:        mktscript_in
      // outputs:
      //   mktscript:        mktscript_out
      S: S
    };
    //.......................................................................................................
    return D.TEE.from_pipeline(pipeline, settings);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$html_comments = (S) => {
    return this._get_expander(S, this.html_comment_id_pattern, (meta, entry) => {
      var content, tag_name;
      [tag_name, content] = entry['raw'];
      return ['.', 'comment', content, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$raw_macros = (S) => {
    return this._get_expander(S, this.raw_id_pattern, (meta, entry) => {
      var Q, _, attributes, tag_name, text;
      [_, _, attributes] = MKTS.MD_READER._parse_html_open_or_lone_tag(entry.markup);
      [tag_name, text] = entry['raw'];
      Q = {attributes, text};
      return ['.', tag_name, Q, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$action_macros = (S) => {
    return this._get_expander(S, this.action_id_pattern, (meta, entry) => {
      var content, language, mode, tag_name;
      [mode, language] = entry['markup'];
      [tag_name, content] = entry['raw'];
      // debug '©19694', rpr content
      return ['.', 'action', content, MKTS.MD_READER.copy(meta, {mode, language})];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$comma_macros = (S) => {
    return this._get_expander(S, this.comma_id_pattern, (meta, entry) => {
      return ['.', 'comma', null, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$sensitive_ws = (S) => {
    return this._get_expander(S, this.sws_id_pattern, (meta, entry) => {
      var content, tag_name;
      [tag_name, content] = entry['raw'];
      return ['.', 'text', content, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$region_macros = (S) => {
    return this._get_expander(S, this.region_id_pattern, (meta, entry) => {
      var markup, raw;
      ({raw, markup} = entry);
      return [markup, raw, null, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$command_and_value_macros = (S) => {
    return this._get_expander(S, this.command_and_value_id_pattern, (meta, entry) => {
      var markup, raw;
      ({raw, markup} = entry);
      // macro_type    = if markup is '!' then 'command' else 'value'
      return [markup, raw, null, MKTS.MD_READER.copy(meta)];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$escape_chrs = (S) => {
    return $((event, send) => {
      var meta, name, text, type;
      //.......................................................................................................
      if (MKTS.MD_READER.select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        // debug '9573485', rpr text
        // debug '9573485', rpr @escape.unescape_escape_chrs S, text
        return send([type, name, this.escape.unescape_escape_chrs(S, text), meta]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$remove_backslashes = (S) => {
    return $((event, send) => {
      var meta, name, text, type;
      //.......................................................................................................
      if (MKTS.MD_READER.select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        // debug '83457', rpr text
        // debug '83457', rpr @escape.remove_escaping_backslashes S, text
        return send([type, name, this.escape.remove_escaping_backslashes(S, text), meta]);
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$expand.$escape_illegals = (S) => {
    return $((event, send) => {
      var error_message, i, idx, is_plain, j, len, len1, line_nr, meta, name, pattern, raw_stretch, ref, ref1, results, stretch, stretches, text, type;
      //.......................................................................................................
      if (MKTS.MD_READER.select(event, '.', 'text')) {
        [type, name, text, meta] = event;
        ref = this.illegal_patterns;
        // debug '©38889', rpr text
        //.....................................................................................................
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          pattern = ref[i];
          stretches = [];
          ref1 = text.split(pattern);
          //...................................................................................................
          for (idx = j = 0, len1 = ref1.length; j < len1; idx = ++j) {
            raw_stretch = ref1[idx];
            if ((idx % 3) === 1) {
              stretches[stretches.length - 1] += raw_stretch;
            } else {
              stretches.push(raw_stretch);
            }
          }
          //...................................................................................................
          is_plain = true;
          results.push((function() {
            var k, len2, results1;
            results1 = [];
            for (k = 0, len2 = stretches.length; k < len2; k++) {
              stretch = stretches[k];
              is_plain = !is_plain;
              debug('©10012', (is_plain ? CND.green : CND.red)(rpr(stretch)));
              if (!is_plain) {
                ({line_nr} = meta);
                error_message = `illegal macro pattern on line ${line_nr}: ${rpr(stretch)}`;
                results1.push(send(['.', 'warning', error_message, MKTS.MD_READER.copy(meta)]));
              } else {
                if (stretch.length !== 0) {
                  results1.push(send([type, name, stretch, MKTS.MD_READER.copy(meta)]));
                } else {
                  results1.push(void 0);
                }
              }
            }
            return results1;
          })());
        }
        return results;
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

  //===========================================================================================================
  // GENERIC EXPANDER
  //-----------------------------------------------------------------------------------------------------------
  this._get_expander = (S, pattern, method) => {
    return $((event, send) => {
      var entry, i, id, is_plain, len, meta, name, ref, results, stretch, text, type;
      //.......................................................................................................
      if (MKTS.MD_READER.select(event, '.', 'text')) {
        is_plain = false;
        [type, name, text, meta] = event;
        ref = text.split(pattern);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          stretch = ref[i];
          is_plain = !is_plain;
          if (!is_plain) {
            id = parseInt(stretch, 10);
            entry = this._retrieve_entry(S, id);
            results.push(send(method(meta, entry)));
          } else {
            if (stretch.length !== 0) {
              results.push(send([type, name, stretch, MKTS.MD_READER.copy(meta)]));
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      } else {
        //.......................................................................................................
        return send(event);
      }
    });
  };

}).call(this);

//# sourceMappingURL=macro-escaper.js.map
