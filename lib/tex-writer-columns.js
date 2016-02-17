(function() {
  var $, $async, CND, D, alert, badge, copy, debug, echo, help, hide, info, is_hidden, is_stamped, log, njs_fs, njs_path, rpr, select, stamp, step, suspend, unstamp, urge, warn, whisper;

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

  debug('9387', MK);

  hide = MK.TS.MD_READER.hide.bind(MK.TS.MD_READER);

  copy = MK.TS.MD_READER.copy.bind(MK.TS.MD_READER);

  stamp = MK.TS.MD_READER.stamp.bind(MK.TS.MD_READER);

  unstamp = MK.TS.MD_READER.unstamp.bind(MK.TS.MD_READER);

  select = MK.TS.MD_READER.select.bind(MK.TS.MD_READER);

  is_hidden = MK.TS.MD_READER.is_hidden.bind(MK.TS.MD_READER);

  is_stamped = MK.TS.MD_READER.is_stamped.bind(MK.TS.MD_READER);

  this.$main = (function(_this) {
    return function(S) {
      if (S.COLUMNS == null) {
        S.COLUMNS = {};
      }
      return D.TEE.from_pipeline([_this.$regions_from_commands(S), _this.$consolidate_columns(S), _this.$slash(S), _this.$multi_column(S), _this.$single_column(S)]);
    };
  })(this);

  this._begin_multi_column = (function(_this) {
    return function(S, column_count) {
      if (column_count == null) {
        column_count = 2;
      }

      /* TAINT Column count must come from layout / options / MKTS-MD command */

      /* TAINT make `\raggedcolumns` optional? */
      if (column_count == null) {
        column_count = S.document.column_count;
      }
      return ['tex', "\n\n\\vspace{\\mktsLineheight}\\begin{multicols}{" + column_count + "}\\raggedcolumns{}"];
    };
  })(this);

  this._end_multi_column = (function(_this) {
    return function(S, column_count) {
      if (column_count == null) {
        column_count = 2;
      }
      return ['tex', "\\end{multicols}\n\n"];
    };
  })(this);

  this.$regions_from_commands = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, parameters, type;
        if (select(event, '!', 'multi-column')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          send(stamp(hide(copy(event))));
          send(['(', 'multi-column', parameters, copy(meta)]);
        } else if (select(event, '!', 'single-column')) {
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          send(stamp(hide(copy(event))));
          send(['(', 'single-column', parameters, copy(meta)]);
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.$consolidate_columns = (function(_this) {
    return function(S) {
      var stack, within_multi_column, within_single_column;
      within_multi_column = false;
      within_single_column = false;
      stack = [];
      return $(function(event, send) {
        var extra_event, meta, name, parameters, type;
        type = event[0], name = event[1], parameters = event[2], meta = event[3];
        if (select(event, '(', ['single-column', 'multi-column'])) {
          if (within_single_column) {
            extra_event = stack.pop();
            send(copy([')', 'single-column', extra_event[2], meta]));
            within_single_column = false;
          } else if (within_multi_column) {
            extra_event = stack.pop();
            send(copy([')', 'multi-column', extra_event[2], meta]));
            within_multi_column = false;
          }
        }
        if (select(event, '(', 'multi-column')) {
          send(event);
          stack.push(event);
          within_multi_column = true;
        } else if (select(event, '(', 'single-column')) {
          send(event);
          stack.push(event);
          within_single_column = true;
        } else if (select(event, ')', 'multi-column')) {
          send(event);
          within_multi_column = false;
        } else if (select(event, ')', 'single-column')) {
          send(event);
          within_single_column = false;
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.$slash = (function(_this) {
    return function(S) {
      var remark, track;
      track = MK.TS.MD_READER.TRACKER.new_tracker('(multi-column)');
      remark = MK.TS.MD_READER._get_remark();
      return $(function(event, send) {
        var meta, name, text, type, within_multi_column;
        within_multi_column = track.within('(multi-column)');
        track(event);
        if (select(event, '!', 'slash')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          send(stamp(event));
          if (within_multi_column) {
            send([')', 'multi-column', null, copy(meta)]);

            /* TAINT consider to send MKTS macro */
            send(['tex', "\\mktsEmptyLine\n"]);
            send(['(', 'multi-column', null, copy(meta)]);
          } else {
            send(remark('drop', "`!slash` because not within `(multi-column)`", copy(meta)));
          }
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.$multi_column = (function(_this) {
    return function(S) {
      var column_count, remark, track;
      track = MK.TS.MD_READER.TRACKER.new_tracker('(multi-column)');
      remark = MK.TS.MD_READER._get_remark();
      column_count = 1;
      return $(function(event, send) {
        var meta, name, parameters, ref, type, within_multi_column;
        within_multi_column = track.within('(multi-column)');
        track(event);
        if (select(event, ['(', ')'], 'multi-column')) {
          send(stamp(event));
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          column_count = (ref = parameters != null ? parameters[0] : void 0) != null ? ref : S.document.column_count;
          if (type === '(') {
            if (within_multi_column) {
              send(remark('drop', "`(multi-column` because already within `(multi-column)`", copy(meta)));
            } else {
              send(track(_this._begin_multi_column(S, column_count)));
            }
          } else {
            if (within_multi_column) {
              send(track(_this._end_multi_column(S, column_count)));
            } else {
              send(remark('drop', "`multi-column)` because not within `(multi-column)`", copy(meta)));
            }
          }
        } else if (select(event, ')', 'document')) {
          if (within_multi_column) {
            send(track(_this._end_multi_column(S, column_count)));
          }
          send(event);
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

  this.$single_column = (function(_this) {
    return function(S) {

      /* TAINT consider to implement command `change_column_count = ( send, n )` */
      var column_count, remark, track;
      track = MK.TS.MD_READER.TRACKER.new_tracker('(multi-column)');
      remark = MK.TS.MD_READER._get_remark();
      column_count = 1;
      return $(function(event, send) {
        var meta, name, parameters, ref, text, type, within_multi_column;
        within_multi_column = track.within('(multi-column)');
        track(event);
        if (select(event, ['(', ')'], 'multi-column')) {
          send(event);
          type = event[0], name = event[1], parameters = event[2], meta = event[3];
          column_count = (ref = parameters != null ? parameters[0] : void 0) != null ? ref : S.document.column_count;
        } else if (select(event, ['(', ')'], 'single-column')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '(') {
            if (within_multi_column) {
              send(remark('insert', "`multi-column)`", copy(meta)));
              send(track(_this._end_multi_column(S, column_count)));
              send(stamp(event));
            } else {
              send(remark('drop', "`single-column` because not within `(multi-column)`", copy(meta)));
            }
          } else {
            if (within_multi_column) {
              send(stamp(event));
              send(remark('insert', "`(multi-column`", copy(meta)));
              send(track(_this._begin_multi_column(S, column_count)));
            } else {
              send(remark('drop', "`single-column` because not within `(multi-column)`", copy(meta)));
            }
          }
        } else {
          send(event);
        }
        return null;
      });
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/tex-writer-columns.js.map
