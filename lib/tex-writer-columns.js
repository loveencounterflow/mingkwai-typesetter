(function() {
  var $, $async, CND, D, MD_READER, MKTS, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, njs_fs, njs_path, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MK/TS/TEX-WRITER/COLUMNS';

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

  MKTS = require('./main');

  MD_READER = require('./md-reader');

  hide = MD_READER.hide.bind(MD_READER);

  copy = MD_READER.copy.bind(MD_READER);

  stamp = MD_READER.stamp.bind(MD_READER);

  unstamp = MD_READER.unstamp.bind(MD_READER);

  select = MD_READER.select.bind(MD_READER);

  is_hidden = MD_READER.is_hidden.bind(MD_READER);

  is_stamped = MD_READER.is_stamped.bind(MD_READER);

  this.$main = function(S) {
    return D.TEE.from_pipeline([this.$initialize_state(S), this.$end_columns_with_document(S), this.$slash(S), this.$columns(S), this.$transform_to_tex(S)]);
  };

  this.$initialize_state = function(S) {
    var sandbox;
    sandbox = {};
    return $((function(_this) {
      return function(event, send) {
        var _, changeset, meta, sandbox_backup;
        if (select(event, '~', 'change')) {
          _ = event[0], _ = event[1], changeset = event[2], _ = event[3];
          sandbox = MK.TS.DIFFPATCH.patch(changeset, sandbox);
          send(event);
        } else if (select(event, '(', 'document')) {
          meta = event[event.length - 1];
          sandbox_backup = MK.TS.DIFFPATCH.snapshot(sandbox);
          if (sandbox['COLUMNS'] != null) {
            throw new Error("namespace collision: `S.sandbox.COLUMNS` already defined");
          }
          sandbox['COLUMNS'] = {
            count: 2,
            stack: [_this._new_setting()]
          };
          send(event);
          changeset = MKTS.DIFFPATCH.diff({}, sandbox);
          debug('©47846', 'changeset', changeset);
          if (changeset.length > 0) {
            send(stamp(['~', 'change', changeset, copy(meta)]));
          }
          send(['!', 'columns', [1], copy(meta)]);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.$end_columns_with_document = function(S) {
    var remark;
    remark = MK.TS.MD_READER._get_remark();
    return $((function(_this) {
      return function(event, send) {
        var meta;
        if (select(event, ')', 'document')) {
          meta = event[event.length - 1];
          send(['!', 'columns', [1], copy(meta)]);
          send(event);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.$slash = function(S) {
    return $((function(_this) {
      return function(event, send) {
        var i, len, meta, name, parameters, type, x;
        if (select(event, '!', 'slash')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          send(stamp(hide(copy(event))));
          send(['!', 'columns', [1], copy(meta)]);
          if (CND.isa_list(parameters)) {
            for (i = 0, len = parameters.length; i < len; i++) {
              x = parameters[i];

              /* TAINT should formally check for `event`ness of value */
              if (CND.isa_list(x)) {
                send(x);
              } else {
                send(['.', 'warning', "ignoring argument to <<!slash>>: " + (rpr(x)), copy(meta)]);
              }
            }
          }
          send(['!', 'columns', ['pop'], copy(meta)]);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.$columns = function(S) {
    var remark, sandbox;
    remark = MK.TS.MD_READER._get_remark();
    sandbox = {};
    return $((function(_this) {
      return function(event, send) {
        var _, changeset, message, meta, name, parameter, parameters, type;
        if (select(event, '~', 'change')) {
          _ = event[0], _ = event[1], changeset = event[2], _ = event[3];
          sandbox = MK.TS.DIFFPATCH.patch(changeset, sandbox);
          send(event);
        } else if (select(event, '!', 'columns')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          if (parameters.length === 0) {
            parameters.push(sandbox.COLUMNS.count);
          }
          parameter = parameters[0];
          switch (type = CND.type_of(parameter)) {
            case 'text':
              switch (parameter) {
                case 'pop':
                  send(stamp(hide(copy(event))));
                  _this._restore_column_count(sandbox, event, send);
                  break;
                default:
                  send(stamp(hide(copy(event))));
                  message = "unknown text argument " + (rpr(parameter));
                  send(['.', 'warning', message, copy(meta)]);
              }
              break;
            case 'number':
              if (!((parameter > 0) && ((Math.floor(parameter)) === parameter))) {
                send(stamp(hide(copy(event))));
                message = "expected non-zero positive integer, got " + (rpr(parameter));
                return send(['.', 'warning', message, copy(meta)]);
              }
              send(stamp(hide(copy(event))));
              _this._change_column_count(sandbox, event, send, parameter);
              break;
            default:
              send(stamp(hide(copy(event))));
              message = "expected a text or a number, got a " + parameter_type;
              send(['.', 'warning', message, copy(meta)]);
          }
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this._new_setting = function() {
    var P, R;
    P = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    R = {
      count: 1
    };
    return Object.assign.apply(Object, [R].concat(slice.call(P)));
  };

  this._push = function(sandbox, setting) {
    return sandbox.COLUMNS.stack.push(setting);
  };

  this._pop = function(sandbox) {
    return sandbox.COLUMNS.stack.pop();
  };

  this._get_column_count = function(sandbox) {
    return sandbox.COLUMNS.stack[this._get_stack_idx(sandbox)]['count'];
  };

  this._get_stack_idx = function(sandbox) {
    return sandbox.COLUMNS.stack.length - 1;
  };

  this._change_column_count = function(sandbox, event, send, column_count) {
    this._stop_column_region(sandbox, event, send);
    return this._start_column_region(sandbox, event, send, column_count);
  };

  this._restore_column_count = function(sandbox, event, send) {
    var column_count;
    this._stop_column_region(sandbox, event, send);
    this._pop(sandbox);
    column_count = this._get_column_count(sandbox);
    return this._start_column_region(sandbox, event, send, column_count);
  };

  this._start_column_region = function(sandbox, event, send, column_count) {
    var meta;
    this._push(sandbox, this._new_setting({
      count: column_count
    }));
    if (column_count !== 1) {
      meta = event[event.length - 1];

      /* TAINT this event should be namespaced and handled only right before output */
      send(['(', 'multi-columns', [column_count], copy(meta)]);
    }
    return null;
  };

  this._stop_column_region = function(sandbox, event, send) {

    /* No-op in case we're in base ('ambient', 'document') state */
    var column_count, meta;
    if ((this._get_stack_idx(sandbox)) === 0) {
      return;
    }
    column_count = this._get_column_count(sandbox);

    /* No-op in case we're already in single-column state */
    if (column_count === 1) {
      return;
    }
    meta = event[event.length - 1];

    /* TAINT this event should be namespaced and handled only right before output */
    return send([')', 'multi-columns', [column_count], copy(meta)]);
  };

  this.$transform_to_tex = function(S) {
    return $((function(_this) {
      return function(event, send) {
        var column_count, meta, name, parameters, type;
        type = event[0], name = event[1], parameters = event[2], meta = event[3];
        if (select(event, '(', 'multi-columns')) {
          send(stamp(event));
          column_count = parameters[0];
          send(['tex', "\n\n\\vspace{\\mktsLineheight}\\begin{multicols}{" + column_count + "}\\raggedcolumns{}"]);
        } else if (select(event, ')', 'multi-columns')) {
          send(stamp(event));
          column_count = parameters[0];
          send(['tex', "\\end{multicols}\n\n"]);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };


  /*
  
  <<(.>>@document.column_count = 3<<)>>
  
  
  <<!columns 1>>                            (single-column
  <<!columns 1>>                            (multi-column 1
  <<!columns>>                              (multi-column
  
  <<!columns 'push'>>
  <<!columns 'pop'>>
   */

}).call(this);

//# sourceMappingURL=../sourcemaps/tex-writer-columns.js.map
