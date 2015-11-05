<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# A Permuted Index of Chinese Characters

# A Permuted Index of Chinese Character Components

![](../unicode-cjk-chrs-by-regions/euler-venn-diagram-cjk-usage-by-region.png)


## Data Collections

```
meaning/meanings.txt
shape/extra-shapeclasses.txt
shape/shape-breakdown-formula-naive.txt
shape/shape-breakdown-formula.txt
shape/shape-factor-hierarchy.txt
shape/shape-figural-themes.txt
shape/shape-guides-similarity.txt
shape/shape-similarity-identity.txt
shape/shape-strokeorder-zhaziwubifa.txt
usage/IRGN1067R2_IICore22_MappingTable.txt
usage/usage-missing-chrs.txt
usage/usage-rank-ja-chubu-2050chrs-2050ranks.txt
usage/usage-rank-ja-jouyoujinmeiyou-3140chrs-8ranks.txt
usage/usage-rank-ja-kanjicards-2500chrs-2500ranks.txt
usage/usage-rank-ja-koohii-9920chrs-3250ranks.txt
usage/usage-rank-ja-leedscorpus-words-2300chrs-1700ranks.txt
usage/usage-rank-ja-touyou-1850chrs-1rank.txt
usage/usage-rank-zh-zeinse-3650chrs-2700ranks.txt
usage/usage-rank-zhcn-junda-3500chrs-3300ranks.txt
usage/usage-rank-zhcn-leedscorpus-chrs-6800chrs-3500ranks.txt
usage/usage-rank-zhcn-leedscorpus-words-1950chrs-490ranks.txt
usage/usage-rank-zhcn-moecn-3500chrs-2ranks.txt
usage/usage-rank-zhcn-upennldc-words-4550chrs-1100ranks.txt
usage/usage-rank-zhtw-chtsai-13000chrs-3700ranks.txt
variants/harigaya-variants.txt
variants/reform-japan-1949.txt
variants/reform-japan-asahi.txt
variants/reform-japan-update.txt
variants/reform-prc-1964.txt
variants/reform-singapore.txt
variants/Unihan_Variants.txt
variants/variants-corrections.varcor
variantusage/variants-and-usage.txt
```

### Coverage



### Binary and N-Ary Character Decompositions

Geometric (or graphic) decomposition is a process by which we can
formally notate the geometric structure of a given writing system
entity.

Composition and decomposition have always been an integral part of all human
writing systems. For example, the letters 'ä', 'ø', and 'ç' are conventionally
thought of as 'a with two dots', 'o crossed with a slanted stroke', and 'c with
cedilla (comma) beneath'. In the age of typewriters when available type bars
were a limited resource, one often had to resort to overstrinking 'a' with '¨'
'o' with '/' and 'c' with ',' two get the appearance of the desired letter.

Similarly, users of CJK characters think of many characters as being made up from
smaller parts; up to a few hundred of frequently recurring parts have acquired
commonly used names such as '氵' being known as 'three-dots (or drops) of water',
'冫' as 'two-dots (or drops) of water', and so on.

When decomposing a given glyph into its constituent parts, it is essential
to keep in mind a few pertinent considerations:

####

#### Positional and Stylistic Variants

[http://kanji-database.sourceforge.net/ucs/ucv.html](http://kanji-database.sourceforge.net/ucs/ucv.html)

Unicode purports to identify "Characters, not Glyphs" (see section 2.2 of [The
Unicode Standard])

  344511534 │   │ ┌ 食                             u-cjk-98df
  34451154  │   └ 飠                               u-cjk-98e0

#### Historical (etymological) 'truth' vs. apparent / conventional / visual 'fact'

#### Ambiguity of Decomposition (where to draw the line)

sfo5763u-cjk/6380 掀 ⿰折欠
sfo5764u-cjk/6380 掀 ⿰扌欣
sfo5765u-cjk/6380 掀 ⿻扻斤

sfo1033u-cjk/514a 兊 ⿱公儿
sfo1034u-cjk/514a 兊 ⿱八允
sfo1048u-cjk/5156 兖 ⿱亠兊

#### Ambiguity of Atomicity

While the letter 'G' is nowadays considered an atomic, non-decomposable entity
of the Latin alphabet,
a certain Roman by the name of Spurius Carvilius Ruga, around 230 BCE

  34  ├ 人                                   u-cjk-4eba
  341 │ ├ 亼                                 u-cjk-4ebc
  34112431  │ │ └ 金                               u-cjk-91d1
  34112431x │ │   ├ 鍂                             u-cjk-9342
  34112431xx  │ │   └ 鑫                             u-cjk-946b
  341251  │ │   合                             x u-cjk-5408
  34125134  │ │   └ 㑒                             u-cjk-xa-3452
  344 │ └ 亽                                 u-cjk-4ebd
  3444  │   ├ 仒                               u-cjk-4ed2
  3445113251  │   ├ 倉                               u-cjk-5009

亠
衣, 立, 方, 言, 主, 卞, 亦, 文, 六

u-cjk/4ea4  交 ⿱亠父
u-cjk/4ea4  交 ⿱六乂
u-cjk/4ea4  交 ⿻文八


#### Reduplications

人
从, 仌, 众, 𠈌
言
誩, 𧨟, 𧮦

### Differences between CJKVI and Jizura Formulas

```
HOLLERITH/copy  ☛  read 109'984 records
HOLLERITH/copy  ☛  read categories for 109'984 glyphs
HOLLERITH/copy  ☛  read 81'869 records
HOLLERITH/copy  ☛  filtering counts:
HOLLERITH/copy  ☛
{ unknown: 5945,
  'cp/inner/original': 74595,
  'cp/inner/mapped': 778,
  'cp/outer/original': 284,
  'cp/outer/mapped': 267 }
HOLLERITH/copy  ☛
HOLLERITH/copy  ☛  of the 5'945 unknown codepoints,
HOLLERITH/copy  ☛  56 are *not* from Unicode V8 CJK Ext. E:
HOLLERITH/copy  ☛
[ 'glyph u-grek-3b1 α',
  'glyph u-llsym-2113 ℓ',
  'glyph u-geoms-25b3 △',
  'glyph u-enalp-2460 ①',
  'glyph u-enalp-2461 ②',
  'glyph u-enalp-2462 ③',
  'glyph u-enalp-2463 ④',
  'glyph u-enalp-2464 ⑤',
  'glyph u-enalp-2465 ⑥',
  'glyph u-enalp-2466 ⑦',
  'glyph u-enalp-2467 ⑧',
  'glyph u-enalp-2468 ⑨',
  'glyph u-enalp-2469 ⑩',
  'glyph u-enalp-246a ⑪',
  'glyph u-enalp-246b ⑫',
  'glyph u-enalp-246c ⑬',
  'glyph u-enalp-246d ⑭',
  'glyph u-enalp-246e ⑮',
  'glyph u-enalp-246f ⑯',
  'glyph u-enalp-2470 ⑰',
  'glyph u-enalp-2471 ⑱',
  'glyph u-enalp-2472 ⑲',
  'glyph u-enalp-2473 ⑳',
  'glyph u-cjk-hira-3044 い',
  'glyph u-cjk-hira-3088 よ',
  'glyph u-cjk-kata-30ad キ',
  'glyph u-cjk-kata-30b5 サ',
  'glyph u-cjk-9fcd 鿍',
  'glyph u-cjk-9fce 鿎',
  'glyph u-cjk-9fcf 鿏',
  'glyph u-cjk-9fd0 鿐',
  'glyph u-cjk-9fd1 鿑',
  'glyph u-cjk-9fd2 鿒',
  'glyph u-cjk-9fd3 鿓',
  'glyph u-cjk-9fd4 鿔',
  'glyph u-cjk-9fd5 鿕',
  'glyph u-cjk-9fd6 鿖',
  'glyph u-cjk-9fd7 鿗',
  'glyph u-cjk-9fd8 鿘',
  'glyph u-cjk-9fd9 鿙',
  'glyph u-cjk-9fda 鿚',
  'glyph u-cjk-9fdb 鿛',
  'glyph u-cjk-9fdc 鿜',
  'glyph u-cjk-9fdd 鿝',
  'glyph u-cjk-9fde 鿞',
  'glyph u-cjk-9fdf 鿟',
  'glyph u-cjk-9fe0 鿠',
  'glyph u-cjk-9fe1 鿡',
  'glyph u-cjk-9fe2 鿢',
  'glyph u-cjk-9fe3 鿣',
  'glyph u-cjk-9fe4 鿤',
  'glyph u-cjk-9fe5 鿥',
  'glyph u-cjk-9fe6 鿦',
  'glyph u-cjk-9fe7 鿧',
  'glyph u-cjk-9fe8 鿨',
  'glyph u-cjk-9fe9 鿩' ]
HOLLERITH/copy  ☛  differences in formulas:
HOLLERITH/copy  ☛  glyphs:             74'595
HOLLERITH/copy  ☛  missing formulas:   0
HOLLERITH/copy  ☛  different formulas: 21'210
```

These figures mean that around two thirds of all Unicode CJK character
decompositions are identical in the original and the Jizura data set, while one
third differs (either because of changes in the CJKVI or in the Jizura data
set).

```
difference: u-cjk-5018 倘 ⿰亻尙 [ '⿰亻尚' ]
difference: u-cjk-5019 候 ⿰&cdp#x8b7a;&cdp#x8bc7; [ '⿰&jzr#xe219;(⿱&jzr#xe1c2;矢)' ]
difference: u-cjk-4fbb 侻 ⿰亻兌 [ '⿰亻兑' ]
difference: u-cjk-4fc8 俈 ⿰亻吿 [ '⿰亻告' ]
difference: u-cjk-5149 光 ⿳⺌一儿 [ '(⿱⺌一儿)' ]
difference: u-cjk-514a 兊 ⿱八允 [ '⿱公儿' ]
difference: u-cjk-514c 兌 ⿱㕣儿 [ '⿱八兄' ]

difference: u-cjk-5153 兓 ⿰兂兂 [ '⿰旡旡' ]

difference: u-cjk-xd-2b798 𫞘 ⿰氵⿲丿关丨 [ '(⿰氵丿关丨)' ]
difference: u-cjk-xd-2b799 𫞙 ⿰氵⿱共〓 [ '⿰氵⿱共⿰卄丶' ]
difference: u-cjk-xd-2b815 𫠕 ⿸广⿱隹〓 [ '⿸㢈〓' ]
```

### 'Song Characters'

In some cases, Song forms are encoded as compatibility characters:

```
sid1338u-cjk/4ee4   令   u-cjk-cmpi1/f9a8    令
```


### Stroke Classifications

[Kangxi] has 了 with two strokes and 子 with three strokes, and probably the majority
of modern dictionaries (e.g. [新华写字字典]) follow it in this respect.

[Yu Peilin 1990] and [Hadamitzky 2002] (pp 100, 132, 134, 276 etc) both have 了 with one stroke and 子 with two strokes




### Formulas

### Factors

## Bibliography

[Kangxi] — 《康熙字典》

[Hadamitzky 2002] — 漢独小字典 = Japanisch-deutsches Zeichenwörterbuch / Wolfgang Hadamitzky. Hamburg: Buske, 2002

[LSZWZD] — 李氏中文字典 / 李卓敏. 香港: 中文大學出版社, 1989

[Yu Peilin 1990] — 中文字序學 / 俞佩琳. 臺北: 啓業書局, 1990

<!-- [GYBXZD] —《國語筆形字典》(周徐慶, 臺灣高雄市大順公司, 1987) -->

[新华写字字典] — 新华写字字典 / 商务印书馆辞书研究中心. 北京: 商务印书馆, 2010

https://github.com/cjkvi/cjkvi-ids, http://kanji-database.sourceforge.net/

[The Unicode Standard] — http://www.unicode.org/versions/Unicode8.0.0/






