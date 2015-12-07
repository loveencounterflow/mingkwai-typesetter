<<The <<<\LaTeX{}>>> Logo: `<<<\LaTeX{}>>>`

The <<<\\LaTeX{}>>> Logo: `<<<\\LaTeX{}>>>`

The &#x3c;<<\\LaTeX{}>>> Logo: `&#x3c;<<\\LaTeX{}>>>`

The \&#x3c;<<\\LaTeX{}>>> Logo: `\&#x3c;<<\\LaTeX{}>>>`

&#x5c; &#x23; \ {} # $ % _ ^ ~ &

`&#x5c; &#x23; \ {} # $ % _ ^ ~ &`

The &lt;<<\LaTeX{}>>> Logo: `&lt;<<\LaTeX{}>>>`

The \<<<\LaTeX{}>>> Logo: `\<<<\LaTeX{}>>>`

The \\<<<\LaTeX{}>>> Logo: `\\<<<\LaTeX{}>>>`

<<!end>>

<<(:>>( name for name of here )<<)>>

<<(:>>@x = 42<<)>>

There are <<$x>> bulls on the meadow.

There are <<$y>> bulls on the meadow.

some << unlicensed >> stuff here.

some \<< licensed \>> stuff here.

<<!end>>

<<(:>>( name for name of @ )<<)>>


<<(:>>y = 108<<)>>


<<(:>>global.y = 108<<)>>

<<(:>>`(function(){`
( name for name of mkts )
`}).apply(this)`<<)>>

<<(:>>
R = do =>
  ( name for name of mkts )
R<<)>>

<<(:>>
do =>
  ( name for name of mkts )
<<)>>




<<(:>>64<<)>>

<<(:>>q = ( name for name of @ )<<)>>


<<(:>>mkts.reserved_names<<)>>

<<(.>>
x = 32
y = 64
@z = 128
<<)>>

x: <<(:>>rpr x<<)>>,
y: <<(:>>rpr y<<)>>,
z: <<(:>>rpr z<<)>>,
name: <<(:>>rpr name<<)>>.

<!-- <<(:>>f 42<<)>> -->

<<(:js>>f( 42 )<<)>>

<<(:>>"xxx" 123<<)>>

<<(:json>>"xxx" 123<<)>>




<<{do>>
define
  TEX:            "<<(raw>>\\TeX{}<<raw)>>"
  MKTS:           "**MKTS**"
<<do}>>

a<<!TEX>>b<<!MKTS>>c\*\*DEF**d

`a\<<!TEX>>b<<!MKTS>>c**DEF**d`

Here is a footnote reference,[^1] and another,[^longnote]
and a third[^3] one.

[^1]: Here is the footnote.

[^3]: Third footnote.

[^longnote]: Here's one with multiple blocks.

    Subsequent paragraphs are indented to show that they
belong to the previous footnote.

Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note.]

Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note.] Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note. <<(raw>>Raw content: \TeX{}<<raw)>>.]

XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXX^[XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX ]

XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXX^[XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX ]

XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXX^[XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX ]


a line with <<(raw>>raw content: \TeX{}<<raw)>> displaying a logogram.
<<!end>>

<!-- a short
comment -->

A fascinating description of a global language, *A Grammar of Mandarin* combines broad perspectives with illuminating depth. Crammed with examples from everyday conversations, it aims to let the language speak for itself. The book opens with an overview of the language situation and a thorough account of Mandarin speech sounds. Nine core chapters explore syntactic, morphological and lexical dimensions. A final chapter traces the Chinese character script from oracle-bone inscriptions to today’s digital pens.

<!-- a short
comment -->
<!-- another comment -->

<<{do>>
define
  thequestion:    "*What is the meaning of life, the universe, and everything?*"
  theanswer:      "**42**"
  TEX:            "<<(raw>>\\TeX{}<<raw)>>"
  LATEX:          "<<(raw>>\\LaTeX{}<<raw)>>"
  MKTS:           "**MKTS**"
  'MKTS/MD':      "**MKTS/MD**"
  MKTS2:          "<<(raw>>**MKTS**<<raw)>>"
  h2:             "## Another Heading"
  empty:          ""
<<do}>>


A list of variable expansions:
- 'thequestion': <<!thequestion>>;
- 'theanswer': <<!theanswer>>;
- 'TEX': <<!TEX>>;
- 'LATEX': <<!LATEX>>;
- 'MKTS': <<!MKTS>>;
- 'MKTS/MD': <<!MKTS/MD>>;
- 'MKTS2': <<!MKTS2>>.

A list of variable expansions:
* `<<!thequestion>>`: <<!thequestion>>;
* `<<!theanswer>>`: <<!theanswer>>;
* `<<!TEX>>`: <<!TEX>>;
* `<<!LATEX>>`: <<!LATEX>>;
* `<<!MKTS>>`: <<!MKTS>>;
* `<<!MKTS/MD>> **XXX**`: <<!MKTS/MD>>;
* `<<!MKTS2>>`: <<!MKTS2>>.

The expansion of an empty string is ><<!empty>>< empty.

-(<<!h2>>)-

<<!end>>




multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column

<<{single-column>>
single column!
<<single-column}>>

<<!TEX>>
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
multi-column multi-column multi-column multi-column multi-column multi-column multi-column multi-column
