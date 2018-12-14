// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var $, $async, $try_to_recycle, $uncycle, CND, EFILE, FS, PATH, PS, alert, assign, badge, copy, debug, echo, help, info, is_meta, jr, log, new_event, new_number_event, new_pushable, provide_xxx, recycle, rpr, rprx, select, select_all, stamp, try_to_recycle, uncycle, urge, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  PATH = require('path');

  FS = require('fs');

  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'SCRATCH/CIRCULAR-PIPELINES';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  // #...........................................................................................................
  // suspend                   = require 'coffeenode-suspend'
  // step                      = suspend.step
  //...........................................................................................................
  // D                         = require 'pipedreams'
  // $                         = D.remit.bind D
  // $async                    = D.remit_async.bind D
  PS = require('pipestreams');

  ({$, $async} = PS);

  new_pushable = require('pull-pushable');

  assign = Object.assign;

  jr = JSON.stringify;

  copy = function(...P) {
    return assign({}, ...P);
  };

  rprx = function(d) {
    var ref;
    return `${d.mark} ${d.type}:: ${jr(d.value)} ${jr((ref = d.stamped) != null ? ref : false)}`;
  };

  /*

  Pipestream Events v2
  ====================

  d         := { mark,          type, value, ... }    # implicit global namespace
            := { mark, prefix,  type, value, ... }    # explicit namespace

   * `d.mark` indicates 'regionality':

  mark      := '.' # proper singleton
  mark      := '~' # meta singleton
            := '(' # start-of-region (SOR)    # '<'
            := ')' # end-of-region   (EOR)    # '>'

   * `prefix` indicates the namespace; where missing on an event or is `null`, `undefined` or `'global'`,
   * it indicates the global namespace:

  prefix    := null | undefined | 'global' | non-empty text

  type      := non-empty text         # typename

  value     := any                    # payload

   */
  //-----------------------------------------------------------------------------------------------------------
  stamp = function(d) {
    d.stamped = true;
    return d;
  };

  //-----------------------------------------------------------------------------------------------------------
  recycle = function(d) {
    return new_event('~', 'recycle', d);
  };

  uncycle = function(d) {
    if (select_all(d, '~', 'recycle')) {
      return d.value;
    } else {
      return d;
    }
  };

  $uncycle = function() {
    return $(function(d, send) {
      return send(uncycle(d));
    });
  };

  try_to_recycle = function(d) {
    if (select(d, '~', 'recycle')) {
      return d.value;
    } else {
      return null;
    }
  };

  $try_to_recycle = function(resend) {
    return PS.$watch(function(d) {
      var e;
      if ((e = try_to_recycle(d)) != null) {
        return resend(d);
      }
    });
  };

  is_meta = function(d) {
    return select_all(d, '~', null);
  };

  //-----------------------------------------------------------------------------------------------------------
  select = function(d, prefix, marks, types) {
    /* TAINT avoid to test twice for arity */
    var arity;
    /* Reject all stamped events: */
    if (d.stamped === true) {
      return false;
    }
    if (d.recycle === true) {
      return false;
    }
    switch (arity = arguments.length) {
      case 3:
        return select_all(d, prefix, marks);
      case /* d, marks, types */4:
        return select_all(d, prefix, marks, types);
      default:
        throw new Error("expected 3 to 4 arguments, got arity");
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  select_all = function(d, prefix, marks, types) {
    /* accepts 3 or 4 arguments; when 4, then second must be prefix (only one prefix allowed);
    `marks` and `types` may be text or list of texts. */
    var _type, arity, ref, ref1;
    switch (arity = arguments.length) {
      // when 2 then [ prefix, marks, types, ] = [ null, prefix, marks, ]
      case 3:
        [prefix, marks, types] = [null, prefix, marks];
        break;
      case 4:
        null;
        break;
      default:
        throw new Error("expected 3 to 4 arguments, got arity");
    }
    if ((prefix == null) || (prefix === 'global')) {
      //.........................................................................................................
      prefix = null;
    }
    if (marks == null) {
      marks = null;
    }
    if (types == null) {
      types = null;
    }
    switch (_type = CND.type_of(prefix)) {
      case 'null':
        null;
        break;
      case 'text':
        if (d.prefix !== prefix) {
          return false;
        }
        break;
      default:
        throw new Error(`expected a text or a list, got a ${_type}`);
    }
    switch (_type = CND.type_of(marks)) {
      case 'null':
        null;
        break;
      case 'text':
        if (d.mark !== marks) {
          return false;
        }
        break;
      case 'list':
        if (ref = d.mark, indexOf.call(marks, ref) < 0) {
          return false;
        }
        break;
      default:
        throw new Error(`expected a text or a list, got a ${_type}`);
    }
    switch (_type = CND.type_of(types)) {
      case 'null':
        null;
        break;
      case 'text':
        if (d.type !== types) {
          return false;
        }
        break;
      case 'list':
        if (ref1 = d.type, indexOf.call(types, ref1) < 0) {
          return false;
        }
        break;
      default:
        throw new Error(`expected a text or a list, got a ${_type}`);
    }
    return true;
  };

  //-----------------------------------------------------------------------------------------------------------
  new_event = function(mark, type, value, ...other) {
    if (value == null) {
      value = null;
    }
    return assign({mark, type, value}, ...other);
  };

  //-----------------------------------------------------------------------------------------------------------
  new_number_event = function(value, ...other) {
    return new_event('.', 'number', value, ...other);
  };

  provide_xxx = function() {
    //-----------------------------------------------------------------------------------------------------------
    return this;
  };

  // COLLATZ = provide_collatz.apply {}

  //-----------------------------------------------------------------------------------------------------------
  this.new_sender = function(S) {
    var R, on_stop, pipeline;
    S.source = new_pushable();
    //.........................................................................................................
    on_stop = PS.new_event_collector('stop', function() {
      return help('ok');
    });
    pipeline = [];
    //.........................................................................................................
    pipeline.push(S.source);
    pipeline.push($uncycle());
    // pipeline.push COLLATZ.$main S
    pipeline.push(PS.$watch(function(d) {
      if (!is_meta(d)) {
        return help('> sink  ', rprx(d));
      }
    }));
    //.........................................................................................................
    pipeline.push(PS.$watch(function(d) {
      if (select(d, '~', 'end')) {
        return S.source.end();
      }
    }));
    pipeline.push($try_to_recycle(S.source.push.bind(S.source)));
    //.........................................................................................................
    pipeline.push(on_stop.add(PS.$drain()));
    PS.pull(...pipeline);
    //.........................................................................................................
    R = function(value) {
      return S.source.push(new_event('.', 'number', value));
    };
    R.end = function() {
      return S.source.end();
    };
    return R;
  };

  //###########################################################################################################
  if (module.parent == null) {
    // S = {}
    // send = @new_sender S
    // urge '-----------'
    // send 42
    // urge '-----------'
    // for n in [ 1 .. 5 ]
    //   send -n
    //   urge '-----------'
    // # # send.end()
    EFILE = require('./embedded-file');
    EFILE.read_embedded_file(__filename);
  }

  /*<embedded-file>

</embedded-file>*/

}).call(this);

//# sourceMappingURL=circular-pipelines-plus-db.js.map