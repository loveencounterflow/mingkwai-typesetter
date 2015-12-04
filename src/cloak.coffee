


"use strict"

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'CLOAK'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
rainbow                   = CND.rainbow.bind CND

###

Cloaking characters by chained replacements:

Assuming an alphabet `/[0-9]/`, cloaking characters starting from `0`.

To cloak only `0`, we have to free the string of all occurrences of that
character. In order to do so, we choose a primary escapement character, '1',
and a secondary escapement character, conveniently also `1`. With those, we
can replace all occurrences of `0` as `11`. However, that alone would produce
ambiguous sequences. For example,  the string `011` results in `1111`, but so
does the string `1111` itself (because it does not contain a `0`, it remains
unchanged when replacing `0`). Therefore, we have to escape the  secondary
escapement character itself, too; we choose the secondary replacement `1 ->
12`  which has to come *first* when cloaking and *second* when uncloaking.
This results in the following cloaking chain:

CLOAK.new '012'

         0123456789
1 -> 12: 01223456789
0 -> 11: 111223456789

The resulting string is free of `0`s. Because all original `0`s and `1`s have
been preserved in disguise, we are now free to insert additional data into the
string.

Let's assume we have a text transformer `f`, say, `f ( x ) -> x.replace
/456/g, '15'`, and a more comprehensive text transformer `g` which includes
calls to `f` and other elementary transforms. Now, we would like to apply `g`
to our text `0123456789`, but specifically omit the transformation performed
by `f` (which would turn `0123456789` into `012315789`). We can do so by
choosing a cloaking character—`0` in this example—and one or more signal
characters that will pass unmodified through `g`. Assuming we cloak `456` as
`01`, we first escape `0123456789` to `111223456789` so that all `0`s are
removed. Then, we symbolize all occurrances of `456` as `01`, leading to
`11122301789`. This string may be fed to `g` and will pass through `f`
untouched. We can then reverse our steps: `11122301789` ... `111223456789` ...
`01223456789` ... `0123456789`—which is indeed the string we're started with.
Of course, this could not have worked if `g` had somehow transformed any of
our cloaking devices; therefore, it is important to choose codepoints that are
certain to be transparent to the intended text transformation.

In case more primary escapement characters are needed, the chain may be
expanded to include more replacement steps. In particular, it is interesting
to use exactly two primary escapements; that way, we can define cloaked
sequences of arbitrary lengths, using the two escapements—`0` and `1` in this
example—as start and stop brackets:

CLOAK.new '01234'

         0123456789
2 -> 24: 01243456789
1 -> 23: 023243456789
0 -> 22: 2223243456789

Using more than two primary escapements is possible:

CLOAK.new '0123456'

         0123456789
3 -> 36: 01236456789
2 -> 35: 013536456789
1 -> 34: 0343536456789
0 -> 33: 33343536456789

CLOAK.new '012345678'

         0123456789
4 -> 48: 01234856789
3 -> 47: 012474856789
2 -> 46: 0146474856789
1 -> 45: 04546474856789
0 -> 44: 444546474856789


###

#-----------------------------------------------------------------------------------------------------------
### from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions ###
esc_re = ( text ) -> text.replace /[.*+?^${}()|[\]\\]/g, "\\$&"

#-----------------------------------------------------------------------------------------------------------
@new_cloak = ( chrs, base = 16 ) ->
  #.........................................................................................................
  unless chrs?
    chrs = [ '\x10', '\x11', '\x12', '\x13', '\x14', ]
  #.........................................................................................................
  else if CND.isa_text chrs
    chrs = Array.from chrs
  #.........................................................................................................
  else unless CND.isa_list chrs
    throw new Error "expected a text or a list, got a #{CND.type_of chrs}"
  #.........................................................................................................
  unless ( chr_count = chrs.length ) >= 3
    throw new Error "expected at least 3 characters, got #{chr_count}"
  #.........................................................................................................
  if chr_count % 2 is 0
    throw new Error "expected an odd number of characters, got #{chr_count}"
  #.........................................................................................................
  delta               = ( chr_count + 1 ) / 2 - 1
  master              = chrs[ chr_count - delta - 1 ]
  meta_chr_patterns   = ( /// #{esc_re chrs[ idx ]} ///g            for idx in [ 0 .. delta ] )
  target_seq_chrs     = ( "#{master}#{chrs[ idx + delta ]}"         for idx in [ 0 .. delta ] )
  target_seq_patterns = ( /// #{esc_re target_seq_chrs[ idx ]} ///g for idx in [ 0 .. delta ] )
  cloaked             = chrs[ 0 ... delta ]
  #---------------------------------------------------------------------------------------------------------
  hide = ( text ) =>
    R_ = text
    R_ = R_.replace meta_chr_patterns[ idx ], target_seq_chrs[ idx ] for idx in [ delta .. 0 ] by -1
    return R_
  #.........................................................................................................
  reveal = ( text ) =>
    R_ = text
    R_ = R_.replace target_seq_patterns[ idx ], chrs[ idx ] for idx in [ 0 .. delta ]
    return R_
  #---------------------------------------------------------------------------------------------------------
  R = { '~isa': 'CLOAK/cloak', hide, reveal, cloaked, master, }
  @_mixin_backslashed R, base
  return R

#-----------------------------------------------------------------------------------------------------------
@_mixin_backslashed = ( cloak, base = 16 ) ->
  { cloaked } = cloak
  if cloaked.length < 2 then    start_chr = stop_chr    = cloaked[ 0 ]
  else                        [ start_chr,  stop_chr, ] = cloaked
  ### `oc`: 'original character' ###
  _oc_backslash      = '\\'
  ### `op`: 'original pattern' ###
  _oce_backslash     = esc_re _oc_backslash
  _mcp_backslash     = ///
    #{esc_re _oc_backslash}
    ( (?: [  \ud800-\udbff ] [ \udc00-\udfff ] ) | . ) ///g
  _tsp_backslash     = /// #{esc_re start_chr} ( [ 0-9 a-f ]+ ) #{esc_re stop_chr} ///g
  ### `rm`: 'remove' ###
  _rm_backslash      = /// #{esc_re _oc_backslash} ( . ) ///g
  #---------------------------------------------------------------------------------------------------------
  hide = ( text ) =>
    R = text
    R = R.replace _mcp_backslash, ( _, $1 ) ->
      cid_hex = ( $1.codePointAt 0 ).toString base
      return "#{start_chr}#{cid_hex}#{stop_chr}"
    return R
  #.........................................................................................................
  reveal = ( text ) =>
    R = text
    R = R.replace _tsp_backslash, ( _, $1 ) ->
      chr = String.fromCodePoint parseInt $1, base
      return "#{_oc_backslash}#{chr}"
    return R
  #.........................................................................................................
  remove = ( text ) =>
    return text.replace _rm_backslash, '$1'
  #---------------------------------------------------------------------------------------------------------
  cloak[ 'backslashed' ] = { hide, reveal, remove, }
  return null


############################################################################################################
unless module.parent?
  CLOAK           = @
  DIFF            = require 'coffeenode-diff'
  cloak           = CLOAK.new_cloak '()LTX', 2
  cloak           = CLOAK.new_cloak '*+?^$', 2
  # { cloak
  #   reveal
  #   cloaked
  #   master
  #   esc_re }      = cloak
  help cloak
  [ start_chr
    stop_chr  ] = cloak[ 'cloaked' ]


  text = """
    % & ! ;
    some <<unlicensed>> (stuff here). \\𠄨 &%!%A&123;
    some more \\\\<<unlicensed\\\\>> (stuff here).
    some \\<<licensed\\>> stuff here, and <\\<
    The <<<\\LaTeX{}>>> Logo: `<<<\\LaTeX{}>>>`
    """
  # debug '©94643', @_mcp_backslash
  # text = "% ; 2 3 \\ \\\\ \\𠄨"
  # text = "0 1 2 3 4 5 6 7 8"
  # text = "<<"
  log '(1) -', CND.rainbow ( text )
  cloaked_text = text
  log '(2) -', CND.rainbow ( cloaked_text   = cloak.hide cloaked_text )
  log '(3) -', CND.rainbow ( cloaked_text   = cloak.backslashed.hide    cloaked_text )
  uncloaked_text = cloaked_text
  log '(4) -', CND.rainbow ( uncloaked_text = cloak.backslashed.reveal  uncloaked_text )
  log '(5) -', CND.rainbow ( uncloaked_text = cloak.reveal uncloaked_text )
  log '(7) -', CND.rainbow '©79011', cloak.backslashed.remove           uncloaked_text
  if uncloaked_text isnt text
    log DIFF.colorize text, uncloaked_text

  log CND.steel '########################################################################'
