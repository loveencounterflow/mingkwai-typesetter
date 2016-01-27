


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'mkts/custom-jzr'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
# ASYNC                     = require 'async'
#...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require './helpers'
# TEXLIVEPACKAGEINFO        = require './texlivepackageinfo'
# options_route             = '../options.coffee'
# { CACHE, OPTIONS, }       = require './options'
# SEMVER                    = require 'semver'
#...........................................................................................................
XNCHR                     = require './xnchr'
# MKTS                      = require './main'
# MKTSCRIPT_WRITER          = require './mktscript-writer'
MD_READER                 = require './md-reader'
hide                      = MD_READER.hide.bind        MD_READER
copy                      = MD_READER.copy.bind        MD_READER
stamp                     = MD_READER.stamp.bind       MD_READER
unstamp                   = MD_READER.unstamp.bind     MD_READER
select                    = MD_READER.select.bind      MD_READER
is_hidden                 = MD_READER.is_hidden.bind   MD_READER
is_stamped                = MD_READER.is_stamped.bind  MD_READER
# MACRO_ESCAPER             = require './macro-escaper'
# LINEBREAKER               = require './linebreaker'
HOLLERITH                 = require '../../hollerith'


#-----------------------------------------------------------------------------------------------------------
@$main = ( S ) =>
  db_route        = njs_path.resolve __dirname, '../../jizura-datasources/data/leveldb-v2'
  S.JZR          ?= {}
  if S.JZR.db?
    help "re-using DB connection to DB at #{db_route}"
  else
    warn "establishing new DB connection to DB at #{db_route}"
    S.JZR.db = HOLLERITH.new_db db_route, create: no
  debug '©52564', Object.keys S.JZR.db
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$fontlist                                    S
    #.......................................................................................................
    @$most_frequent.with_fncrs.$rewrite_events    S
    @$dump_db                                     S
    @$most_frequent.$read                         S
    @$most_frequent.$assemble                     S
    @$most_frequent.$details_from_glyphs          S
    @$most_frequent.with_fncrs.$format            S
    @$most_frequent.with_fncrs.$assemble          S
    @$dump_db.$format                             S
    #.......................................................................................................
    @$py                                          S
    ]

#-----------------------------------------------------------------------------------------------------------
@$fontlist = ( S ) =>
  kaishu_shortnames = [
    'Fandolkairegular'
    'Kai'
    'Ukai'
    'Epkaisho'
    'Cwtexqkaimedium'
    'Biaukai'
    ]
  kana_shortnames = [
    'Babelstonehan'
    'Cwtexqfangsongmedium'
    'Cwtexqheibold'
    'Cwtexqkaimedium'
    'Cwtexqmingmedium'
    'Cwtexqyuanmedium'
    'Hanamina'
    'Sunexta'
    'Kai'
    'Nanumgothic'
    'Nanummyeongjo'
    'Simsun'
    'Fandolfangregular'
    'Fandolheibold'
    'Fandolheiregular'
    'Fandolkairegular'
    'Fandolsongbold'
    'Fandolsongregular'
    'Ipaexg'
    'Ipaexm'
    'Ipag'
    'Ipagp'
    'Ipam'
    'Ipamp'
    'Ipaexg'
    'Ipaexm'
    'Ipag'
    'Ipagp'
    'Ipam'
    'Ipamp'
    'Ukai'
    'Uming'
    'Droidsansfallbackfull'
    'Droidsansjapanese'
    'Fontsjapanesegothic'
    'Fontsjapanesemincho'
    'Takaopgothic'
    'Sourcehansansbold'
    'Sourcehansansextralight'
    'Sourcehansansheavy'
    'Sourcehansanslight'
    'Sourcehansansmedium'
    'Sourcehansansnormal'
    'Sourcehansansregular'
    ]
  #.........................................................................................................
  template = """
    ($shortname) {\\($texname){\\cjk\\($texname){}ぁあぃいぅうぇえぉおかがきぎく
    ぐけげこごさざしじすずせぜそぞた
    だちぢっつづてでとどなにぬねのは
    ばぱひびぴふぶぷへべぺほぼぽまみ
    むめもゃやゅゆょよらりるれろゎわ
    ゐゑをんゔゕゖァアィイゥウェエォオカガキギク
    グケゲコゴサザシジスズセゼソゾタ
    ダチヂッツヅテデトドナニヌネノハ
    バパヒビピフブプヘベペホボポマミ
    ムメモャヤュユョヨラリルレロヮワ
    ヰヱヲンヴヵヶヷヸヹヺ
    本书使用的数字，符号一览表}
    AaBbCcDdEeFfghijklmn}
    """
  #.........................................................................................................
  template = """
    This is {\\cjk\\($texname){}むず·かしい} so very {\\cjk\\($texname){}ムズ·カシイ} indeed.
    """
  #.........................................................................................................
  template = """
    XXX{\\($texname){}·}XXX
    """
  #.........................................................................................................
  template = """
    The character {\\cjk{}出} {\\($texname){}u{\\mktsFontfileEbgaramondtwelveregular{}·}cjk{\\mktsFontfileEbgaramondtwelveregular{}·}51fa} means '{\\mktsStyleItalic{}go out, send out, stand, produce}'.
    """
  #.........................................................................................................
  template = """
    {\\($texname){}出 、出。出〃出〄出々出〆出〇出〈出〉出《出》出「出」出}\\\\
    \\> {\\($texname){}出『出』出【出】出〒出〓出〔出〕出〖出〗出〘出〙出〚出}
    """
  #.........................................................................................................
  template = """
    {\\($texname){}abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ}
    """
  #.........................................................................................................
  template = """
    {\\($texname){\\cjk\\($texname){}本书使用的数字，符号一览表書覽} AaBbCcDdEeFfghijklmnopqrstuvwxyz}
    """
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if select event, '!', 'JZR.fontlist'
      send stamp event
      #.....................................................................................................
      send [ 'tex', "\\begin{tabbing}\n" ]
      send [ 'tex', "\\phantom{XXXXXXXXXXXXXXXXXXXXXXXXX} \\= \\phantom{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX} \\\\\n" ]
      #.....................................................................................................
      for { texname, } in S.options[ 'fonts' ][ 'files' ]
        shortname = texname.replace /^mktsFontfile/, ''
        # continue unless shortname in kana_shortnames
        raw       = template
        raw       = raw.replace /\(\$texname\)/g,    texname
        raw       = raw.replace /\(\$shortname\)/g,  shortname
        # send [ '.', 'text', "#{shortname}\\\\\n", ]
        send [ 'tex', "#{shortname} \\> #{raw} \\\\\n", ]
      #.....................................................................................................
      send [ 'tex', "\\end{tabbing}\n" ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent             = {}
@$most_frequent.with_fncrs  = {}

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$rewrite_events = ( S ) =>
  return $ ( event, send ) =>
    if select event, '!', 'JZR.most_frequent.with_fncrs'
      [ _, _, parameters, meta ]    = event
      meta[ 'jzr' ]?=                 {}
      meta[ 'jzr' ][ 'group-name' ] = 'glyphs-with-fncrs'
      send [ '!', 'JZR.most_frequent', parameters, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.$read = ( S ) =>
  HOLLERITH_DEMO  = require '../../hollerith/lib/demo'
  defaults        =
    n:            100
    group_name:   'glyphs'
  #.........................................................................................................
  return D.remit_async_spread ( event, send ) =>
    return send.done event unless select event, '!', 'JZR.most_frequent'
    [ type, name, [ n ], meta, ]  = event
    n                            ?= defaults.n
    group_name                    = meta[ 'jzr' ]?[ 'group-name' ] ? defaults.group_name
    #.......................................................................................................
    step ( resume ) =>
      #.....................................................................................................
      try
        glyphs = yield HOLLERITH_DEMO.read_sample S.JZR.db, n, resume
      #.....................................................................................................
      catch error
        warn error
        return send.error error
      #.....................................................................................................
      send stamp event
      glyphs = Object.keys glyphs
      send [ '(', group_name, null, ( copy meta ), ]
      for glyph in glyphs
        send [ '.', 'glyph', glyph, ( copy meta ), ]
      send [ ')', group_name, null, ( copy meta ), ]
      send.done()

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.$assemble = ( S ) =>
  track = MD_READER.TRACKER.new_tracker '(glyphs)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs = track.within '(glyphs)'
    track event
    #.......................................................................................................
    if select event, '(', 'glyphs'
      send stamp event
    #.......................................................................................................
    else if within_glyphs and select event, '.', 'glyph'
      # glyphs = ( ( if idx % 40 is 0 then "#{glyph}\n" else glyph ) for glyph, idx in glyphs )
      # glyphs = glyphs. join ''
      [ _, _, glyph, meta, ] = event
      send [ '.', 'text', glyph, ( copy meta ), ]
    #.......................................................................................................
    else if select event, ')', 'glyphs'
      send stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.$details_from_glyphs = ( S ) =>
  # track     = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)'
  HOLLERITH = require '../../hollerith'
  #.........................................................................................................
  return D.remit_async_spread ( event, send ) =>
    # within_glyphs = track.within '(glyphs-with-fncrs)'
    # track event
    #.......................................................................................................
    if select event, '.', 'glyph'
      [ _, _, glyph, meta, ]  = event
      prefix                  = [ 'spo', glyph, ] # 'cp/sfncr'
      HOLLERITH.read_phrases S.JZR.db, { prefix, }, ( error, phrases ) =>
        details = { glyph, }
        for phrase in phrases
          [ _, _, prd, obj, ] = phrase
          details[ prd ] = obj
        send [ '.', 'details', details, ( copy meta ), ]
        send.done()
    #.......................................................................................................
    else
      send.done event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$format = ( S ) =>
  track         = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)'
  this_glyph    = null
  reading_keys  = [ 'reading/py', 'reading/hg', 'reading/ka', 'reading/hi', ]
  has_readings  = ( x ) -> ( CND.isa_list x ) and ( x.length > 0 )
  has_gloss     = ( x ) -> ( CND.isa_text x ) and ( x.length > 0 )
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs   = track.within '(glyphs-with-fncrs)'
    track event
    #.......................................................................................................
    if within_glyphs and select event, '.', 'details'
      [ _, _, details, meta, ]  = event
      #.....................................................................................................
      for prd in reading_keys
        #...................................................................................................
        if has_readings ( readings = details[ prd ] )
          if prd in [ 'reading/ka', 'reading/hi', ]
            readings = ( reading.replace /-/g, '⋯' for reading in readings )
          details[ prd ] = readings.join ', \n'
      #.....................................................................................................
      if has_gloss ( gloss = details[ 'reading/gloss' ] )
        details[ 'reading/gloss' ]  = gloss.replace /;/g, ','
      #.....................................................................................................
      send event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$assemble = ( S ) =>
  track       = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)'
  this_glyph  = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs   = track.within '(glyphs-with-fncrs)'
    track event
    #.......................................................................................................
    if select event, '(', 'glyphs-with-fncrs'
      [ _, _, this_glyph, _, ] = event
      send stamp event
      send [ 'tex', '{\\setlength\\parskip{0mm}\n', ]
    #.......................................................................................................
    else if select event, ')', 'glyphs-with-fncrs'
      this_glyph = null
      send stamp event
      send [ 'tex', '}\n\n']
    #.......................................................................................................
    else if within_glyphs and select event, '.', 'details'
      [ _, _, details, meta, ] = event
      send [ 'tex', "\\begin{tabular}{ | @{} p{20mm} @{} | @{} l @{} | @{} p{1mm} @{} | @{} p{60mm} @{} | }\n", ]
      # send [ 'tex', "\\begin{tabular}{ | @{} l @{} | @{} p{1mm} @{} | @{} p{60mm} @{} | }\n", ]
      #.....................................................................................................
      # GUIDES
      #.....................................................................................................
      value = details[ 'guide/kwic/v3/sortcode' ]
      # if value? and value.length > 0
      value = value[ 0 ]
      # [ [ '1293f---', '1217f---', null ], '女', [ '子' ], [] ]
      [ _, infix, suffix, prefix, ] = value
      unless prefix.length is 0
        throw new Error "expected empty prefix, got #{glyph} #{rpr value}"
      # send [ 'tex', "{\\mktsStyleGuides{}", ]
      value = infix + suffix.join ''
      send [ '.', 'text', value, ( copy meta ), ]
      # send [ 'tex', "}", ]
      #.....................................................................................................
      send [ 'tex', " & ", ]
      #.....................................................................................................
      # MIDASHI
      #.....................................................................................................
      glyph = details[ 'glyph' ]
      send [ 'tex', "{\\mktsStyleMidashi{}\\sbSmash{", ]
      send [ '.', 'text', "#{glyph}", ( copy meta ), ]
      send [ 'tex', "}}", ]
      #.....................................................................................................
      send [ 'tex', " & ", ]
      #.....................................................................................................
      # STRUT
      #.....................................................................................................
      send [ 'tex', "{\\color{white} | |}", ]
      #.....................................................................................................
      send [ 'tex', " & ", ]
      #.....................................................................................................
      value = details[ 'formula' ]
      if value? and value.length > 0
        value = value[ 0 ]
        # send [ 'tex', "{\\mktsStyleFormula{}", ]
        send [ '.', 'text', value, ( copy meta ), ]
        # send [ 'tex', "} ", ]
      #.....................................................................................................
      value = details[ 'cp/fncr' ]
      value = value.replace /-/g, '·'
      send [ 'tex', "{\\mktsStyleFncr{}", ]
      send [ '.', 'text', value, ( copy meta ), ]
      send [ 'tex', "}\n", ]
      #.....................................................................................................
      count = 0
      for key in [ 'reading/py', 'reading/hg', 'reading/ka', 'reading/hi', 'reading/gloss', ]
        value     = details[ key ]
        continue unless value?
        value_txt = if CND.isa_text value then value else rpr value
        text      = "#{value_txt}"
        send [ '.', 'text', '; \n', ( copy meta ), ] unless count is 0
        send [ 'tex', "{\\mktsStyleGloss{}", ]  if key is 'reading/gloss'
        send [ '.', 'text', text, ( copy meta ), ]
        send [ 'tex', "}", ]                    if key is 'reading/gloss'
        count += +1
      send [ '.', 'text', '.', ( copy meta ), ] unless count is 0
      #.....................................................................................................
      if ( value = details[ 'variant' ] )?
        value = value.join ''
        send [ '.', 'text', " #{value}", ( copy meta ), ]
      #.....................................................................................................
      send [ 'tex', "\\\\\n\\hline\n", ]
      send [ 'tex', "\\end{tabular}\n", ]
      send [ '.', 'p', null, ( copy meta ), ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$dump_db = ( S ) =>
  return $ ( event, send ) =>
    if select event, '!', 'JZR.dump_db'
      [ _, _, parameters, meta ]    = event
      [ settings ] = parameters
      # send [ '.', 'text', ( rpr settings ), ( copy meta ), ]
      if ( glyphs = settings[ 'glyphs' ] )?
        glyphs  = XNCHR.chrs_from_text glyphs if CND.isa_text glyphs
        tasks   = []
        send [ '(', 'dump-db', glyphs, ( copy meta ), ]
        send [ '.', 'glyph', glyph, ( copy meta ), ] for glyph in glyphs
        send [ ')', 'dump-db', glyphs, ( copy meta ), ]
      else
        send [ '.', 'warning', "expected setting 'glyphs' in call to `JZR.dump_db`", ( copy meta ), ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$dump_db.$format = ( S ) =>
  track     = MD_READER.TRACKER.new_tracker '(dump-db)'
  excludes  = [
    'guide/kwic/v1/lineup/wrapped/infix'
    'guide/kwic/v1/lineup/wrapped/prefix'
    'guide/kwic/v1/lineup/wrapped/single'
    'guide/kwic/v1/lineup/wrapped/suffix'
    'guide/kwic/v1/sortcode'
    'guide/kwic/v2/lineup/wrapped/single'
    'guide/kwic/v2/sortcode'
    ]
  #.........................................................................................................
  return $ ( event, send ) =>
    within_dumpdb = track.within '(dump-db)'
    track event
    #.......................................................................................................
    if within_dumpdb and select event, '.', 'details'
      [ _, _, details, meta, ]  = event
      send stamp event
      { glyph } = details
      delete details[ 'glyph' ]
      last_idx  = ( Object.keys details ).length - 1
      idx       = -1
      #.....................................................................................................
      # send [ '(', 'h', 3, ( copy meta ), ]
      send [ '.', 'p', null, ( copy meta ), ]
      send [ '.', 'text', "Details for Glyph #{glyph} #{details[ 'cp/fncr' ]}", ( copy meta ), ]
      send [ '.', 'p', null, ( copy meta ), ]
      #.....................................................................................................
      for predicate, value of details
        idx += +1
        continue if predicate in excludes
        value_txt = JSON.stringify value, null, ' '
        send [ 'tex', "\\begin{tabular}{ | p{30mm} | p{129mm} | }\n", ]
        send [ 'tex', "\\hline\n", ] if idx is 0
        send [ 'tex', "{\\mktsStyleFontUrl{}", ]
        send [ '.', 'text', "#{predicate}", ( copy meta ), ]
        send [ 'tex', "}", ]
        send [ 'tex', " & ", ( copy meta ), ]
        send [ '.', 'text', "#{value_txt}", ( copy meta, 'typofix': 'escape-ncrs' ), ]
        send [ 'tex', "\\\\\n", ( copy meta ), ]
        send [ 'tex', "\\hline\n", ] if idx is last_idx
        send [ 'tex', "\\end{tabular}\n", ]
      #.....................................................................................................
      send [ '.', 'p', null, ( copy meta ), ]
    #.......................................................................................................
    else if select event, '(', 'dump-db'
      send stamp event
    #.......................................................................................................
    else if select event, ')', 'dump-db'
      send stamp event
    #.......................................................................................................
    else
      send event



#===========================================================================================================
# PINYIN (EXPERIMENTAL, INCOMPLETE)
#-----------------------------------------------------------------------------------------------------------
@$py = ( S ) =>
  ### TAINT should translate special syntax to ordinary commands, then translate to TeX ###
  # track   = MD_READER.TRACKER.new_tracker '(py)'
  # remark  = MD_READER._get_remark()
  ### TAINT make RegEx more specific, don't include punctuation ###
  py_pattern = /// !py!([^\s]+) ///
  compile_pinyin = ( text ) =>
    return text.replace py_pattern, ( $0, $1 ) =>
      ### TAINT translate digits to accents ###
      ### TAINT consider to use fix_typography_for_tex ###
      return "{\\py{}#{$1}}"
  #.........................................................................................................
  return $ ( event, send ) =>
    # within_py = track.within '(py)'
    # track event
    [ type, name, text, meta, ] = event
    #.......................................................................................................
    # if within_py and text?
    if select event, '(', 'py'
      send stamp event
      send [ 'tex', "{\\py{}", ]
    #.......................................................................................................
    else if select event, ')', 'py'
      send stamp event
      send [ 'tex', "}", ]
    #.......................................................................................................
    else if select event, '.', 'text'
      send [ '.', 'text', ( compile_pinyin text ), ( copy meta ), ]
    #.......................................................................................................
    else
      send event









