// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var $, $async, CND, FS, L, PATH, PS, alert, assign, badge, copy, debug, echo, help, info, jr, log, new_pushable, rpr, rprx, urge, warn, whisper,
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
    var ref, ref1;
    return `${d.sigil} ${d.key}:: ${jr((ref = d.value) != null ? ref : null)} ${jr((ref1 = d.stamped) != null ? ref1 : false)}`;
  };

  /*

  Pipestream Events v2
  ====================

  d         := { sigil,          key, value, ... }    # implicit global namespace
            := { sigil, prefix,  key, value, ... }    # explicit namespace

   * `d.sigil` indicates 'regionality':

  sigil     := '.' # proper singleton
            := '~' # system singleton
            := '(' # start-of-region (SOR)    # '<'
            := ')' # end-of-region   (EOR)    # '>'

   * `prefix` indicates the namespace; where missing on an event or is `null`, `undefined` or `'global'`,
   * it indicates the global namespace:

  prefix    := null | undefined | 'global' | non-empty text

  key       := non-empty text         # typename

  value     := any                    # payload

   */
  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.stamp = function(d) {
    /* Set the `stamped` attribute on event to sigil it as processed. Stamped events will not be selected
    by the `select` method, only by the `select_all` method. */
    d.stamped = true;
    return d;
  };

  //===========================================================================================================
  // RECYCLING
  //-----------------------------------------------------------------------------------------------------------
  this.unwrap_recycled = function(d) {
    /* Given an event, return its value if its a `~recycle` event; otherwise, return the event itself. */
    if (this.is_recycling(d)) {
      return d.value;
    } else {
      return d;
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$unwrap_recycled = function() {
    return $((d, send) => {
      return send(this.unwrap_recycled(d));
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.$recycle = function(sender) {
    return PS.$watch((d) => {
      if (this.is_recycling(d)) {
        return sender(d);
      }
    });
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.select = function(d, prefix, sigils, keys) {
    /* TAINT avoid to test twice for arity */
    var arity;
    if (this.is_stamped(d)) {
      /* Reject all stamped and recycle events: */
      return false;
    }
    if (this.is_recycling(d)) {
      return false;
    }
    switch (arity = arguments.length) {
      case 3:
        return this.select_all(d, prefix, sigils);
      case /* d, sigils, keys */4:
        return this.select_all(d, prefix, sigils, keys);
      default:
        throw new Error("expected 3 to 4 arguments, got arity");
    }
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @select_system = ( d, prefix, keys ) ->
  //   ### TAINT avoid to test twice for arity ###
  //   switch arity = arguments.length
  //     when 2 then return @select_all d, prefix, sigils ### d, sigils, keys ###
  //     when 3 then return @select_all d, prefix, sigils, keys
  //     else throw new Error "expected 3 to 4 arguments, got arity"

  //-----------------------------------------------------------------------------------------------------------
  this.select_all = function(d, prefix, sigils, keys) {
    /* accepts 3 or 4 arguments; when 4, then second must be prefix (only one prefix allowed);
    `sigils` and `keys` may be text or list of texts. */
    var _type, arity, ref, ref1;
    switch (arity = arguments.length) {
      // when 2 then [ prefix, sigils, keys, ] = [ null, prefix, sigils, ]
      case 3:
        [prefix, sigils, keys] = [null, prefix, sigils];
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
    if (sigils == null) {
      sigils = null;
    }
    if (keys == null) {
      keys = null;
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
    switch (_type = CND.type_of(sigils)) {
      case 'null':
        null;
        break;
      case 'text':
        if (d.sigil !== sigils) {
          return false;
        }
        break;
      case 'list':
        if (ref = d.sigil, indexOf.call(sigils, ref) < 0) {
          return false;
        }
        break;
      default:
        throw new Error(`expected a text or a list, got a ${_type}`);
    }
    switch (_type = CND.type_of(keys)) {
      case 'null':
        null;
        break;
      case 'text':
        if (d.key !== keys) {
          return false;
        }
        break;
      case 'list':
        if (ref1 = d.key, indexOf.call(keys, ref1) < 0) {
          return false;
        }
        break;
      default:
        throw new Error(`expected a text or a list, got a ${_type}`);
    }
    return true;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.is_system = function(d) {
    /* Return whether event is a system event (i.e. whether its `sigil` equals `'~'`). */
    return d.sigil === '~';
  };

  //-----------------------------------------------------------------------------------------------------------
  this.is_recycling = function(d) {
    /* Return whether event is a recycling wrapper event. */
    return (d.sigil === '~') && (d.key === 'recycle');
  };

  //-----------------------------------------------------------------------------------------------------------
  this.is_stamped = function(d) {
    var ref;
    /* Return whether event is stamped (i.e. already processed). */
    return (ref = d.stamped) != null ? ref : false;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.new_event = function(sigil, key, value, ...other) {
    if (value != null) {
      return assign({sigil, key, value}, ...other);
    }
    return assign({sigil, key}, ...other);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.new_single_event = function(key, value, ...other) {
    return this.new_event('.', key, value, ...other);
  };

  this.new_start_event = function(key, value, ...other) {
    return this.new_event('(', key, value, ...other);
  };

  this.new_stop_event = function(key, value, ...other) {
    return this.new_event(')', key, value, ...other);
  };

  this.new_system_event = function(key, value, ...other) {
    return this.new_event('~', key, value, ...other);
  };

  this.new_end_event = function() {
    return this.new_system_event('end');
  };

  this.recycling = function(d) {
    return this.new_system_event('recycle', d);
  };

  //###########################################################################################################
  L = this;

  (function() {
    var key, value;
    for (key in L) {
      value = L[key];
      if (!CND.isa_function(value)) {
        continue;
      }
      L[key] = value.bind(L);
    }
    return null;
  })();

}).call(this);

//# sourceMappingURL=recycle.js.map