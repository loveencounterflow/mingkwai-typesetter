// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var $, $async, $recycle, $unwrap_recycled, CND, COLLATZ, FS, PATH, PS, S, alert, assign, badge, copy, debug, echo, help, i, info, is_recycling, is_stamped, is_system, jr, log, n, name, new_end_event, new_event, new_pushable, new_single_event, new_start_event, new_stop_event, new_system_event, provide_collatz, recycling, rpr, rprx, select, select_all, send, stamp, unwrap_recycled, urge, warn, whisper,
    modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

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
    var ref, ref1;
    return `${d.sigil} ${d.key}:: ${jr((ref = d.value) != null ? ref : null)} ${jr((ref1 = d.stamped) != null ? ref1 : false)}`;
  };

  echo('{ ' + (((function() {
    var results;
    results = [];
    for (name in require('./recycle')) {
      results.push(name);
    }
    return results;
  })()).sort().join('\n  ')) + " } = require './recycle'");

  ({$recycle, $unwrap_recycled, is_recycling, is_stamped, is_system, new_end_event, new_event, new_single_event, new_start_event, new_stop_event, new_system_event, recycling, select, select_all, stamp, unwrap_recycled} = require('./recycle'));

  //-----------------------------------------------------------------------------------------------------------
  provide_collatz = function() {
    //-----------------------------------------------------------------------------------------------------------
    this.new_number_event = function(value, ...other) {
      return new_single_event('number', value, ...other);
    };
    //-----------------------------------------------------------------------------------------------------------
    this.is_one = function(n) {
      return n === 1;
    };
    this.is_odd = function(n) {
      return modulo(n, 2) !== 0;
    };
    this.is_even = function(n) {
      return modulo(n, 2) === 0;
    };
    //-----------------------------------------------------------------------------------------------------------
    this.$even_numbers = function(S) {
      return $((d, send) => {
        if ((select(d, '.', 'number')) && (this.is_even(d.value))) {
          send(stamp(d));
          send(recycling(this.new_number_event(d.value / 2)));
        } else {
          send(d);
        }
        return null;
      });
    };
    //-----------------------------------------------------------------------------------------------------------
    this.$odd_numbers = function(S) {
      return $((d, send) => {
        if ((select(d, '.', 'number')) && (!this.is_one(d.value)) && (this.is_odd(d.value))) {
          // if ( select d, sigil: '.', key: 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
          // if ( select_single d, null, 'number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
          // if ( select_single d, 'kwic:number' ) and ( not @is_one d.value ) and ( @is_odd d.value )
          send(stamp(d));
          send(recycling(this.new_number_event(d.value * 3 + 1)));
        } else {
          send(d);
        }
        return null;
      });
    };
    //-----------------------------------------------------------------------------------------------------------
    this.$skip_known = function(S) {
      var known;
      known = new Set();
      return $((d, send) => {
        if (select(d, '.', 'number')) {
          if (!known.has(d.value)) {
            send(d);
            known.add(d.value);
          } else {
            urge('->', d.value);
          }
        } else {
          send(d);
        }
        return null;
      });
    };
    //-----------------------------------------------------------------------------------------------------------
    this.$terminate = function(S) {
      return $((d, send) => {
        if ((select_all(d, '.', 'number')) && (is_one(d.value))) {
          send(stamp(d));
          send(new_end_event());
        } else {
          send(d);
        }
        return null;
      });
    };
    //-----------------------------------------------------------------------------------------------------------
    this.$main = function(S) {
      var pipeline;
      pipeline = [];
      pipeline.push(COLLATZ.$skip_known(S));
      pipeline.push(COLLATZ.$even_numbers(S));
      pipeline.push(COLLATZ.$odd_numbers(S));
      // pipeline.push COLLATZ.$terminate            S
      return PS.pull(...pipeline);
    };
    //-----------------------------------------------------------------------------------------------------------
    return this;
  };

  COLLATZ = provide_collatz.apply({});

  //-----------------------------------------------------------------------------------------------------------
  this.new_sender = function(S) {
    var R, on_stop, pipeline, resend;
    S.source = new_pushable();
    resend = S.source.push.bind(S.source);
    on_stop = PS.new_event_collector('stop', function() {
      return help('ok');
    });
    pipeline = [];
    //.........................................................................................................
    pipeline.push(S.source);
    pipeline.push($unwrap_recycled());
    pipeline.push(COLLATZ.$main(S));
    pipeline.push(PS.$watch(function(d) {
      return help(jr(d));
    }));
    // pipeline.push PS.$watch ( d ) -> help '> sink  ', rprx d unless is_meta d
    pipeline.push(PS.$watch(function(d) {
      if (select(d, '~', 'end')) {
        return S.source.end();
      }
    }));
    pipeline.push($recycle(resend));
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
    S = {};
    send = this.new_sender(S);
    urge('-----------');
    send(42);
    urge('-----------');
    for (n = i = 1; i <= 5; n = ++i) {
      send(-n);
      urge('-----------');
    }
  }

  // # send.end()

}).call(this);

//# sourceMappingURL=circular-pipelines.js.map