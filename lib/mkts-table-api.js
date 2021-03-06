// Generated by CoffeeScript 2.3.2
(function() {
  'use strict';
  var CND, IG, MKTS, MKTS_TABLE, UNITS, alert, badge, debug, echo, help, info, jr, log, rpr, urge, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MKTS/TABLE/API';

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
  MKTS = require('./main');

  MKTS_TABLE = require('./mkts-table');

  //...........................................................................................................
  jr = JSON.stringify;

  IG = require('intergrid');

  UNITS = require('./mkts-table-units');

  //===========================================================================================================
  // PUBLIC API
  //-----------------------------------------------------------------------------------------------------------
  this.create_layout = function(S, meta, id) {
    var R;
    R = MKTS_TABLE._new_description(S);
    R.meta = meta;
    R.name = id;
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_grid = function(me, size) {
    if (me.grid != null) {
      throw new Error("µ1234 unable to re-define grid");
    }
    switch (size.type) {
      case 'cellkey':
        me.grid = IG.GRID.new_grid_from_cellkey(size.value);
        break;
      default:
        throw new Error(`µ1235 unknown type for grid size ${rpr(size)}`);
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_debug = function(me, toggle) {
    switch (toggle) {
      case true:
        me.debug = true;
        break;
      case false:
        me.debug = false;
        break;
      default:
        throw new Error(`µ1236 expected \`true\` or \`false\` for mkts-table/debug, got ${rpr(toggle)}`);
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.create_field = function(me, id, selector) {
    var base, base1, fieldcell, fieldnr, first, name, rangekey, rangeref, ref, second;
    switch (selector.type) {
      case 'cellkey':
        rangekey = `${selector.value}..${selector.value}`;
        break;
      case 'rangekey':
        first = selector.first;
        second = selector.second;
        if (first.type !== 'cellkey') {
          throw new Error(`(MKTS/TABLE µ1237) expected a cellkey, got a ${rpr(first.type)}`);
        }
        if (second.type !== 'cellkey') {
          throw new Error(`(MKTS/TABLE µ1238) expected a cellkey, got a ${rpr(second.type)}`);
        }
        rangekey = `${first.value}..${second.value}`;
    }
    //.........................................................................................................
    /* TAINT should support using variables etc. */
    /* aliases     = @_parse_aliases me, aliases */
    rangeref = IG.GRID.parse_rangekey(me.grid, rangekey);
    fieldnr = (me._tmp.prv_fieldnr += +1);
    if (me.fieldcells[fieldnr] != null) {
      throw new /* should never happen */Error(`(MKTS/TABLE µ1239) unable to redefine field ${fieldnr}: ${rpr(source)}`);
    }
    //.........................................................................................................
    me.fieldcells[fieldnr] = rangeref;
    ref = IG.GRID.walk_cells_from_rangeref(me.grid, rangeref);
    for (fieldcell of ref) {
      ((base = me.cellfields)[name = fieldcell.cellkey] != null ? base[name] : base[name] = []).push(fieldnr);
    }
    //.........................................................................................................
    /* TAINT should support using variables etc.
      for alias in aliases
    ( me.fieldnrs_by_aliases[ alias ]?= [] ).push fieldnr */
    if (id != null) {
      ((base1 = me.fieldnrs_by_aliases)[id] != null ? base1[id] : base1[id] = []).push(fieldnr);
    }
    //.........................................................................................................
    this._set_default_gaps(me, fieldnr);
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_borders = function(me, selectors, edges, style) {
    var base, edge, fieldnr, i, len, ref, ref1, target;
    ref = this.walk_fieldnrs_from_selectors(me, selectors);
    for (fieldnr of ref) {
      target = (base = me.fieldborders)[fieldnr] != null ? base[fieldnr] : base[fieldnr] = {};
      ref1 = this._expand_edges(me, edges);
      for (i = 0, len = ref1.length; i < len; i++) {
        edge = ref1[i];
        if (style === 'none') {
          delete target[edge];
        } else {
          target[edge] = style;
        }
      }
    }
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._expand_edges = function(me, edges) {
    var edge, i, len;
    for (i = 0, len = edges.length; i < len; i++) {
      edge = edges[i];
      if (edge !== 'left' && edge !== 'right' && edge !== 'top' && edge !== 'bottom' && edge !== 'all') {
        throw new Error(`µ1240 unknown edge ${rpr(edge)}`);
      }
    }
    if (indexOf.call(edges, 'all') < 0) {
      return [...edges];
    }
    return ['left', 'right', 'top', 'bottom'];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_unit_lengths = function(me, value, unit) {
    this._set_unit_length(me, 'width', value, unit);
    this._set_unit_length(me, 'height', value, unit);
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._set_unit_length = function(me, direction, value, unit) {
    var p;
    if (direction !== 'width' && direction !== 'height') {
      throw new Error(`µ1247 expected 'width' or 'height', got ${rpr(direction)}`);
    }
    p = `unit${direction}`;
    //.........................................................................................................
    /* Do nothing if dimension already defined: */
    if (me[p] != null) {
      throw new Error(`µ1247 unable to re-define unit for ${rpr(direction)}`);
    }
    //.........................................................................................................
    me[p] = UNITS.new_quantity(value, unit);
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_background = function(me, selectors, style) {
    var fieldnr, ref;
    ref = this.walk_fieldnrs_from_selectors(me, selectors);
    for (fieldnr of ref) {
      me.fieldbackgrounds[fieldnr] = style;
    }
    // target = me.fieldbackgrounds[ fieldnr ]?= {}
    // target.background = style
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_alignment = function(me, selectors, direction, alignment) {
    var fieldnr, ref, target;
    switch (direction) {
      //.......................................................................................................
      case 'horizontal':
        if (alignment !== 'left' && alignment !== 'right' && alignment !== 'center' && alignment !== 'justified') {
          throw new Error(`(MKTS/TABLE µ1241) unknown horizontal alignment ${rpr(alignment)}`);
        }
        target = me.haligns;
        break;
      //.......................................................................................................
      case 'vertical':
        if (alignment !== 'top' && alignment !== 'bottom' && alignment !== 'center' && alignment !== 'spread') {
          throw new Error(`(MKTS/TABLE µ1242) unknown vertical alignment ${rpr(alignment)}`);
        }
        target = me.valigns;
        break;
      default:
        throw new Error(`µ1243 unknown direction ${rpr(direction)}`);
    }
    ref = this.walk_fieldnrs_from_selectors(me, selectors);
    //.........................................................................................................
    for (fieldnr of ref) {
      target[fieldnr] = alignment;
    }
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_lane_sizes = function(me, direction, value) {
    var i, lane_count, nr, p, ps, ref;
    if (direction !== 'width' && direction !== 'height') {
      throw new Error(`µ1249 expected 'width' or 'height', got ${rpr(direction)}`);
    }
    //.........................................................................................................
    p = direction === 'width' ? 'colwidth' : 'rowheight';
    ps = direction === 'width' ? 'colwidths' : 'rowheights';
    //.........................................................................................................
    this._ensure_grid(me);
    lane_count = me.grid[direction];
    // #.........................................................................................................
    // if selector?
    //   me[ ps ][  0 ]  ?= me.default[ p ] ### set default ###
    //   me[ ps ][ nr ]  ?= me.default[ p ] for nr in [ 1 .. lane_count ] ### set defaults where missing ###
    //   for [ fail, lanenr, ] from @_walk_fails_and_lanenrs_from_direction_and_selector me, direction, selector
    //     if fail? then _record me, fail
    //     else          me[ ps ][ lanenr ] = length
    // else
    me[ps][0] = value/* set default */
    for (nr = i = 1, ref = lane_count; (1 <= ref ? i <= ref : i >= ref); nr = 1 <= ref ? ++i : --i) {
      me[ps][nr] = value;
    }
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._set_default_gaps = function(me, fieldnr) {
    var base, edge, gap, i, j, len, len1, ref, ref1;
    ref = ['background', 'margins', 'paddings'];
    for (i = 0, len = ref.length; i < len; i++) {
      gap = ref[i];
      ref1 = ['left', 'right', 'top', 'bottom'];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        edge = ref1[j];
        ((base = me.gaps[gap])[fieldnr] != null ? base[fieldnr] : base[fieldnr] = {})[edge] = me.default.gaps[gap];
      }
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_default_gaps = function(me, feature, value) {
    if (feature !== 'border' && feature !== 'text' && feature !== 'background') {
      throw new Error(`µ1290 expected one of 'border', 'text', 'background', got ${rpr(feature)}`);
    }
    switch (feature) {
      case 'border':
        me.default.gaps.margins = value;
        break;
      case 'text':
        me.default.gaps.paddings = value;
        break;
      case 'background':
        me.default.gaps.background = value;
    }
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set_field_gaps = function(me, selectors, edges, feature, value) {
    var edge, fieldnr, i, len, ref, ref1, sub_target, target;
    switch (feature) {
      case 'border':
        target = me.gaps.margins;
        break;
      case 'text':
        target = me.gaps.paddings;
        break;
      case 'background':
        target = me.gaps.background;
        break;
      default:
        throw new Error(`µ1290 expected one of 'border', 'text', 'background', got ${rpr(feature)}`);
    }
    ref = this.walk_fieldnrs_from_selectors(me, selectors);
    for (fieldnr of ref) {
      sub_target = target[fieldnr] != null ? target[fieldnr] : target[fieldnr] = {};
      ref1 = this._expand_edges(me, edges);
      for (i = 0, len = ref1.length; i < len; i++) {
        edge = ref1[i];
        sub_target[edge] = value;
      }
    }
    //.........................................................................................................
    return null;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.walk_fieldnrs_from_selectors = function*(me, selectors) {
    var cellref, fieldnr, i, j, k, l, len, len1, len2, len3, rangekey, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, seen_fieldnrs, selector;
    seen_fieldnrs = new Set();
//.........................................................................................................
    for (i = 0, len = selectors.length; i < len; i++) {
      selector = selectors[i];
      switch (selector.type) {
        case 'rangekey':
          rangekey = selector.first.value + '..' + selector.second.value;
          ref = IG.GRID.walk_cells_from_rangekey(me.grid, rangekey);
          for (cellref of ref) {
            ref2 = (ref1 = me.cellfields[cellref.cellkey]) != null ? ref1 : [];
            for (j = 0, len1 = ref2.length; j < len1; j++) {
              fieldnr = ref2[j];
              if (seen_fieldnrs.has(fieldnr)) {
                continue;
              }
              seen_fieldnrs.add(fieldnr);
              yield fieldnr;
            }
          }
          break;
        case 'cellkey':
          ref3 = IG.GRID.walk_cells_from_key(me.grid, selector.value);
          for (cellref of ref3) {
            ref5 = (ref4 = me.cellfields[cellref.cellkey]) != null ? ref4 : [];
            for (k = 0, len2 = ref5.length; k < len2; k++) {
              fieldnr = ref5[k];
              if (seen_fieldnrs.has(fieldnr)) {
                continue;
              }
              seen_fieldnrs.add(fieldnr);
              yield fieldnr;
            }
          }
          break;
        case 'id':
          ref7 = (ref6 = me.fieldnrs_by_aliases[selector.id]) != null ? ref6 : [];
          for (l = 0, len3 = ref7.length; l < len3; l++) {
            fieldnr = ref7[l];
            if (seen_fieldnrs.has(fieldnr)) {
              continue;
            }
            seen_fieldnrs.add(fieldnr);
            yield fieldnr;
          }
          break;
        default:
          throw new Error(`µ1245 ignoring selector type ${selector.type}`);
      }
    }
    //.........................................................................................................
    if (seen_fieldnrs.size === 0) {
      throw new Error(`µ1244 selectors ${rpr(selectors)} do not match any field`);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  //.........................................................................................................
  this.walk_cellrefs_from_selectors = function*(me, selectors) {
    var cellref, count, fieldnr, i, j, len, len1, ref, ref1, ref2, ref3, seen_cellkeys, selector;
    count = 0;
    seen_cellkeys = new Set();
//.........................................................................................................
    for (i = 0, len = selectors.length; i < len; i++) {
      selector = selectors[i];
      switch (selector.type) {
        case 'cellkey':
          ref = IG.GRID.walk_cells_from_key(me.grid, selector.value);
          for (cellref of ref) {
            if (seen_cellkeys.has(cellref.cellkey)) {
              continue;
            }
            seen_cellkeys.add(cellref.cellkey);
            count += +1;
            yield cellref;
          }
          break;
        case 'id':
          ref2 = (ref1 = me.fieldnrs_by_aliases[selector.id]) != null ? ref1 : [];
          for (j = 0, len1 = ref2.length; j < len1; j++) {
            fieldnr = ref2[j];
            ref3 = this.walk_cellrefs_from_fieldnr(me, fieldnr);
            for (cellref of ref3) {
              if (seen_cellkeys.has(cellref.cellkey)) {
                continue;
              }
              seen_cellkeys.add(cellref.cellkey);
              count += +1;
              yield cellref;
            }
          }
          break;
        default:
          warn('µ1245', `ignoring selector type ${selector.type}`);
      }
    }
    //.........................................................................................................
    if (count === 0) {
      throw new Error(`µ1246 selectors ${rpr(selectors)} do not match any cell`);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  //.........................................................................................................
  this.walk_cellrefs_from_fieldnr = function*(me, fieldnr) {
    var cellref, rangeref, ref;
    if ((rangeref = me.fieldcells[fieldnr]) == null) {
      throw new Error(`µ1246 unknown fieldnr ${rpr(fieldnr)}`);
    }
    ref = IG.GRID.walk_cells_from_rangeref(me.grid, rangeref);
    for (cellref of ref) {
      yield cellref;
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  //.........................................................................................................
  this._ensure_grid = function(me) {
    if (me.grid != null) {
      return null;
    }
    throw new Error("(MKTS/TABLE µ5307) grid must be set");
  };

}).call(this);

//# sourceMappingURL=mkts-table-api.js.map
