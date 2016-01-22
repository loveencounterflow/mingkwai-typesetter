


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
# #...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require './helpers'
# TEXLIVEPACKAGEINFO        = require './texlivepackageinfo'
# options_route             = '../options.coffee'
# { CACHE, OPTIONS, }       = require './options'
# SEMVER                    = require 'semver'
#...........................................................................................................
# XNCHR                     = require './xnchr'
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
  S.JZR.db       ?= HOLLERITH.new_db db_route, create: no
  #.........................................................................................................
  return D.TEE.from_pipeline [
    @$fontlist                                    S
    #.......................................................................................................
    @$most_frequent.with_fncrs.$rewrite_events    S
    @$most_frequent.$read                         S
    @$most_frequent.with_fncrs.$read              S
    @$most_frequent.with_fncrs.$format            S
    @$most_frequent.with_fncrs.$collect           S
    @$most_frequent.with_fncrs.$assemble          S
    @$most_frequent.$assemble                     S
    ]

#-----------------------------------------------------------------------------------------------------------
@$fontlist = ( S ) =>
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
@$most_frequent.with_fncrs.$read = ( S ) =>
  track     = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)'
  HOLLERITH = require '../../hollerith'
  #.........................................................................................................
  return D.remit_async_spread ( event, send ) =>
    within_glyphs = track.within '(glyphs-with-fncrs)'
    track event
    return send.done event unless within_glyphs and select event, '.', 'glyph'
    [ _, _, glyph, meta, ]  = event
    prefix                  = [ 'spo', glyph, ] # 'cp/sfncr'
    HOLLERITH.read_phrases S.JZR.db, { prefix, }, ( error, phrases ) =>
      send event
      send [ '(', 'details', glyph, ( copy meta ), ]
      for phrase in phrases
        [ _, _, prd, obj, ] = phrase
        send [ '*', prd, obj, ( copy meta ), ]
      send [ ')', 'details', glyph, ( copy meta ), ]
      send.done()

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$format = ( S ) =>
  track         = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)', '(details)'
  this_glyph    = null
  reading_keys  = [ 'reading/py', 'reading/hg', 'reading/ka', 'reading/hi', ]
  has_readings  = ( x ) -> ( CND.isa_list x ) and ( x.length > 0 )
  has_gloss     = ( x ) -> ( CND.isa_text x ) and ( x.length > 0 )
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs   = track.within '(glyphs-with-fncrs)'
    within_details  = track.within '(details)'
    track event
    # #.......................................................................................................
    # if within_glyphs and within_details and select event, '*'
    #   [ _, prd, obj, meta, ]  = event
    #   urge '77336', this_glyph, prd, obj
    #.......................................................................................................
    if within_glyphs and within_details and select event, '*', reading_keys
      [ _, prd, obj, meta, ]  = event
      #.....................................................................................................
      if has_readings obj
        #...................................................................................................
        if prd in [ 'reading/ka', 'reading/hi', ]
          for reading, idx in obj
            obj[ idx ] = reading.replace /-/g, '⋯'
        #...................................................................................................
        value = obj.join ', '
        send [ '*', prd, value, ( copy meta ), ]
    #.......................................................................................................
    else if within_glyphs and within_details and select event, '*', 'reading/gloss'
      [ _, prd, obj, meta, ]  = event
      if has_gloss obj
        value = obj.replace /;/g, ','
        send [ '*', prd, value, ( copy meta ), ]
    # #.......................................................................................................
    # else if within_glyphs and select event, ')', 'details'
    #   send event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$collect = ( S ) =>
  track       = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)', '(details)'
  this_glyph  = null
  collector   = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs   = track.within '(glyphs-with-fncrs)'
    within_details  = track.within '(details)'
    track event
    #.......................................................................................................
    if select event,  '(', 'details'
      send stamp event
      collector = {}
    #.......................................................................................................
    else if select event, ')', 'details'
      [ _, _, _, meta, ] = event
      send stamp copy event
      send [ '.', 'details', collector, ( copy meta ), ]
      collector = null
    #.......................................................................................................
    else if within_glyphs and within_details and select event, '*'
      null # send hide stamp event
      [ _, prd, obj, _, ]     = event
      collector[ prd ]        = obj
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$most_frequent.with_fncrs.$assemble = ( S ) =>
  track       = MD_READER.TRACKER.new_tracker '(glyphs-with-fncrs)'
  this_glyph  = null
  #.........................................................................................................
  return $ ( event, send ) =>
    within_glyphs = track.within '(glyphs-with-fncrs)'
    track event
    #.......................................................................................................
    if select event, '(', 'glyphs-with-fncrs'
      [ _, _, this_glyph, _, ] = event
      send stamp event
      # send [ 'tex', '\\begin{flushleft}', ]
      # send [ 'tex', '{\\RaggedRight', ]
      send [ 'tex', '{\\setlength\\parskip{0mm}\n', ]
    #.......................................................................................................
    else if select event, ')', 'glyphs-with-fncrs'
      this_glyph = null
      send stamp event
      # send [ 'tex', '\\end{flushleft}']
      send [ 'tex', '}\n\n']
    #.......................................................................................................
    else if within_glyphs and select event, '.', 'glyph'
      [ _, _, glyph, meta, ] = event
      send [ 'tex', "\\begin{tabular}{ | @{} l @{} | @{} p{1mm} @{} | @{} p{60mm} @{} | }\n", ]
      # send [ 'tex', "\\hline\n", ]
      send [ 'tex', "{\\mktsStyleMidashi{}\\sbSmash{", ]
      send [ '.', 'text', "#{glyph}", ( copy meta ), ]
      send [ 'tex', "}}", ]
      send [ 'tex', " &  {\\color{white} | |} & ", ]
    #.......................................................................................................
    else if within_glyphs and select event, '.', 'details'
      null # send hide stamp copy event
      [ _, _, details, meta, ] = event
      urge details
      # send [ 'tex', "\\begin{minipage}{0.8\\linewidth}", ]
      #.....................................................................................................
      value = details[ 'cp/fncr' ]
      value = value.replace /-/g, '·'
      send [ 'tex', "{\\mktsStyleFncr{}", ]
      send [ '.', 'text', value, ( copy meta ), ]
      send [ 'tex', "} ", ]
      #.....................................................................................................
      count = 0
      for key in [ 'reading/py', 'reading/hg', 'reading/ka', 'reading/hi', 'reading/gloss', ]
        value     = details[ key ]
        continue unless value?
        value_txt = if CND.isa_text value then value else rpr value
        text      = "#{value_txt}"
        send [ '.', 'text', '; ', ( copy meta ), ] unless count is 0
        send [ 'tex', "{\\mktsStyleGloss{}", ]  if key is 'reading/gloss'
        send [ '.', 'text', text, ( copy meta ), ]
        send [ 'tex', "}", ]                    if key is 'reading/gloss'
        count += +1
      send [ '.', 'text', '.', ( copy meta ), ] unless count is 0
      #.....................................................................................................
      if ( value = details[ 'variant' ] )?
        debug '23423', value
        value = value.join ''
        send [ '.', 'text', " #{value}", ( copy meta ), ]
      #.....................................................................................................
      send [ 'tex', "\\\\\n\\hline\n", ]
      send [ 'tex', "\\end{tabular}\n", ]
      #.....................................................................................................
      # send [ 'tex', "\\end{minipage}", ]
      send [ '.', 'p', null, ( copy meta ), ]
    #.......................................................................................................
    else
      send event













