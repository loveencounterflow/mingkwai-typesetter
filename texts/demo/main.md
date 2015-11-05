
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
