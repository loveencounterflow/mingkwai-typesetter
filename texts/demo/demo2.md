




A fascinating description of a global language, *A Grammar of Mandarin* combines broad perspectives with illuminating depth. Crammed with examples from everyday conversations, it aims to let the language speak for itself. The book opens with an overview of the language situation and a thorough account of Mandarin speech sounds. Nine core chapters explore syntactic, morphological and lexical dimensions. A final chapter traces the Chinese character script from oracle-bone inscriptions to today’s digital pens.

<<!multi-column>>
<<(:thequestion>>*What is the meaning of life,
the universe, and everything?*<<:)>>
<<(:theanswer>>**42**<<:)>>
<<(:TEX>><<(raw>>\TeX{}<<raw)>><<:)>>
<<(:LATEX>><<(raw>>\LaTeX{}<<raw)>><<:)>>
<<(:MKTS>>**MKTS**<<:)>>
<<(:MKTS2>><<(raw>>**MKTS**<<raw)>><<:)>>
<<(:MKTS/MD>>**MKTS/MD**<<:)>>

@johnfrazer

<<!MKTS>> and <<!MKTS2>>
<<!end>>

<!-- <<{definitions>>
  thequestion:    "*What is the meaning of life, the universe, and everything?*"
  theanswer:      "**42**"
  TEX:            "<<(raw>>\TeX{}<<raw)>>"
  LATEX:          "<<(raw>>\LaTeX{}<<raw)>>"
  MKTS:           "**MKTS**"
  MKTS/MD:        "**MKTS/MD**"
  MKTS2:          "<<(raw>>**MKTS**<<raw)>>"
<<definitions}>> -->



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


# MKTS/MD

## Regions, Blocks and Spans

### The Fine Print

A fascinating description of a global language, *A Grammar of Mandarin* combines broad perspectives with illuminating depth. Crammed with examples from everyday conversations, it aims to let the language speak for itself. The book opens with an overview of the language situation and a thorough account of Mandarin speech sounds. Nine core chapters explore syntactic, morphological and lexical dimensions. A final chapter traces the Chinese character script from oracle-bone inscriptions to today’s digital pens.



This work will cater to language learners and linguistic specialists alike. Easy reference is provided by more than eighty tables, figures, appendices, and a glossary. The main text is enriched by sections in finer print, offering further analysis and reflection. Example sentences are fully glossed, translated, and explained from diverse angles, with a keen eye for recent linguistic change. This grammar, in short, reveals a Mandarin language in full swing.


## Math Mode

It's perfectly possible to take advantage of
<<!TEX>>'s famous Math Mode; for example,
you can now effortlessly have formulas like

<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>

in your documents (and of course, inline math *à la*
<<(raw>>$\lim_{x \to \infty}$<<raw)>> works as well).

<<{single-column>>
Some math: `<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>`

Some math: <<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>
<<single-column}>>

## Quotes, Character Entities, <<!TEX>> Special Characters

foo 'bar' baz. &jzr#xe170; beautiful!

<!-- <<{multi-column>> -->
You can use `<<{raw>> ... <<raw}>>` or `<<(raw>> ... <<raw)>>` to directly insert <<!LATEX>>
code into your script; for example, you could
use `<<(raw>>\LaTeX{}<<raw)>>`
to obtain the <<(raw>>\LaTeX{}<<raw)>> logogram.
Observe that we had to write `\LaTeX{}` here instead of `\LaTeX` to preserve the space between the logogram itself and
the word 'logogram'—<<!MKTS>> will not intervene to make that happen
automatically, as a careful, scientific study has demonstrated
that this problem—preserving spaces following commands in a
general way that does not rely on parsing <<(raw>>\LaTeX{}<<raw)>>
source and is not going to muck with very deep
<<!TEX>>
internals—is NP-complete.

Another potential use of  is to <<(raw>>{\color{red}<<raw)>>COLORIZE!<<(raw>>}<<raw)>> your text, here done by inserting
```latex
<<(raw>>{\color{red}<<raw)>>
COLORIZE!
<<(raw>>}<<raw)>>
```
(with or without the line breaks) into the script.


## MKTS Regions 中國皇帝

To indicate the start of an <<!MKTS/MD>> Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
you can put a `<<{keep-lines>>` region inside a `<<{single-column>>` region as
done here:


<<{single-column>>
Here are some formulas:
<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿
<<keep-lines}>>
At this point, a line consisting of a triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, *this
paragraph runs across the entire width* of the documents text
area.
<<single-column}>>
Now a `}single-column` <<!MKTS/MD>> event has been encountered
that was triggered by a triple-at command in the manuscript;
accordingly, typesetting is reverted back to multi-column mode,
which is why you can see this paragraph set in two columns.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



front #1 #,2<<(:foo1>>FOO<<:)>>. <<!foo1>>, <\<!foo1>>, \<<!foo1>>, back.

front #1 #,2<<(:foo2>>#FOO#<<:)>>. <<!foo2>>, <\<!foo2>>, \<<!foo2>>, back.

A <<(:x1>> <\<(raw>>\TeX{} <\<raw)>> <<:)>>: (<<!x1>>) Z

A <<(:x2>> <<(raw>>\TeX{} <<raw)>> <<:)>>: (<<!x2>>) Z

<<(:redefined>>[first value]<<:)>><<!redefined>>

<<(:redefined>>[second value]<<:)>><<!redefined>>

&lt;&lt;!redefined>>!!!

a <\<b>> \c
<!-- <<multi-column}>> -->


<<(:two-pars>>first first first first first first
first first first first first first first first first
first first first first first first first first first

second second second second second second second second second
second second second second second second second second second
second second second second second second second second second
second second second second second second second second second
<<:)>>


<<!two-pars>>

Use of definition: The question is "<<!thequestion>>"; the
answer is "<<!theanswer>>".

<<multi-column}>>
<!-- <<!end>> -->

Use of the logo: <<!LATEX>>.

## Generalized Command Syntax

foo <\<bar>> baz

Here we inserted '<<!LATEX>>' using `<<!LATEX>>`.

<!-- <<!end>> -->

<<{multi-column>>

## Math Mode

It's perfectly possible to take advantage of
<<!TEX>>'s famous Math Mode; for example,
you can now effortlessly have formulas like

<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>

in your documents (and of course, inline math *à la*
<<(raw>>$\lim_{x \to \infty}$<<raw)>> works as well).

<<multi-column}>>


Some math: `<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>`

Some math: <<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>

xxx

## Quotes, Character Entities, <<!TEX>> Special Characters

foo 'bar' baz. &jzr#xe170; beautiful!

<<{multi-column>>
You can use `<<{raw>> ... <<raw}>>` or `<<(raw>> ... <<raw)>>` to directly insert <<!LATEX>>
code into your script; for example, you could
use `<<(raw>>\LaTeX{}<<raw)>>`
to obtain the <<(raw>>\LaTeX{}<<raw)>> logogram.
Observe that we had to write `\LaTeX{}` here instead of `\LaTeX` to preserve the space between the logogram itself and
the word 'logogram'—<<!MKTS>> will not intervene to make that happen
automatically, as a careful, scientific study has demonstrated
that this problem—preserving spaces following commands in a
general way that does not rely on parsing <<(raw>>\LaTeX{}<<raw)>>
source and is not going to muck with very deep
<<!TEX>>
internals—is NP-complete.

Another potential use of  is to <<(raw>>{\color{red}<<raw)>>COLORIZE!<<(raw>>}<<raw)>> your text, here done by inserting
```latex
<<(raw>>{\color{red}<<raw)>>
COLORIZE!
<<(raw>>}<<raw)>>
```
(with or without the line breaks) into the script.
<<multi-column}>>

xxx


`<<<document>>...<<document>>>`


<<{raw>>
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA\begin{multicols}{2}\end{multicols}BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB\begin{multicols}{2}XXXXXXXXXX\end{multicols}CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
<<raw}>>

<<{raw>>to insert <<!LATEX>> commands
<<raw}>>
<<{multi-column>>
<<multi-column}>>

Helo <<(code>>world<<code)>>! = Helo `world`!

<!-- <<!end>> -->

<<{multi-column>>

^[h2^<<!MKTS>> Regions 中國皇帝^]h2^

## Footnotes

Here is a footnote reference,[^1] and another.[^longnote]

[^1]: Here is the footnote.

[^longnote]: Here's one with multiple blocks.

    Subsequent paragraphs are indented to show that they
belong to the previous footnote.

## MKTS Regions 中國皇帝

To indicate the start of an <<!MKTS>>/MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
you can put a `<<{keep-lines>>` region inside a `<<{single-column>>` region as
done here:

## Code Regions

x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
```
this is
a code block &jzr#xe202;
with three lines & an XNCR
```
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

It's possible to switch on `inline code`. It's also possible
to have a region of code with lines rendered as in the source:
<<{single-column>>
```
#-------------------------------------------------------------------------------------
@_shuffle = ( list, ratio, rnd, random_integer ) ->
  #...................................................................................
  return list if ( this_idx = list.length ) < 2
  #...................................................................................
  loop
    this_idx += -1
    return list if this_idx < 1
    if ratio >= 1 or rnd() <= ratio
      # return list if this_idx < 1
      that_idx = random_integer 0, this_idx
      [ list[ that_idx ], list[ this_idx ] ] = [ list[ this_idx ], list[ that_idx ] ]
  #...................................................................................
  return list
```
<<single-column}>>
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

Code sample, keeping indentations:

```
x
  x
    x
```
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

## MKTS Regions 中國皇帝

To indicate the start of an <<!MKTS>>/MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
you can put a `<<{keep-lines>>` region inside a `<<{single-column>>` region as
done here:


<<{single-column>>
Here are some formulas:
<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿
<<keep-lines}>>
At this point, a line consisting of a triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, *this
paragraph runs across the entire width* of the documents text
area.
<<single-column}>>
Now a `}single-column` <<!MKTS>>/MD event has been encountered
that was triggered by a triple-at command in the manuscript;
accordingly, typesetting is reverted back to multi-column mode,
which is why you can see this paragraph set in two columns.


## Using HTML

This section tests HTML that occurs as 'blocks' (i.e. as typographical blocks
that start with an HTML tag) and 'inline' (i.e. inside of MD blocks).

<p>helo <i>world</i> and **everyone**</p>

A paragraph with <i foo=bar><b>some</b></i> HTML in it.

Here's MD with *single* and **double** stars.

Testing *italics with Chinese: 義大利體* and **bold with Chinese: 黑體, ゴシック体**

# Regions

Regions are started and ended using `@@@` (triple at-signs); the opener
must be followed by a key word indicating the region's type.


## Code

Here's `some code` within a fenced block:
```
This is a code region;
lines are kept as they appear
in the MD manuscript,
but in addition,
the font is monospaced
```
And this is the text following the fence.

## Keep-Lines Regions: Formulas Example

To preserve line breaks in the PDF the way they were entered in
the MD manuscript, use `<<{keep-lines>>` regions. Currently, the
best idea is to position the sentinels in a 'tight' way, without
intervening blank lines between the sentinels and the surrounding
paragraph.

Here are some formulas:
<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿
<<keep-lines}>>
These formulas may be recursively resolved by way of substitution to their
ultimate constituent parts—strokes. Somewhere along that process of
deconstruction, we meet with fairly recurrent figures or shapes.


## Keep-Lines Regions: All in One Paragraph

<<{single-column>>
A-before
<<{keep-lines>>
A-within
A-within
A-within
<<keep-lines}>>
A-after
<<single-column}>>

## Keep-Lines Regions: With separate Before, After Paragraphs

<<{single-column>>
B-before

<<{keep-lines>>
B-within
B-within
B-within
<<keep-lines}>>

B-after

<<single-column}>>

## Keep-Lines Regions: Region Starts, Ends within Paragraph

<<{single-column>>
C-before
<<{keep-lines>>

C-within
C-within
C-within

<<keep-lines}>>
C-after
<<single-column}>>

## Keep-Lines Regions: Region Starts, Ends with separate Paragraph

<<{single-column>>
D-before

<<{keep-lines>>

D-within
D-within
D-within

<<keep-lines}>>

D-after
<<single-column}>>


# This is a Demonstration 中國皇帝

## A Section Title 1 中國皇帝



14‰, A, able, about, account, acid, across, act, addition as done in mathematics, adjustment,
advertisement, after, again, against, agreement, air, all, almost a full sentence here
to show the effects of microtypography, among,
amount, amusement, and, angle, angry, animal, answer, ant, any, apparatus,
apple, approval, arch, argument, arm, army, art, as, at, attack, attempt,
attention, attraction, authority, automatic, awake, baby, back, bad, bag,
balance, ball, band, base, basin, basket, bath, be, beautiful, because, bed,
bee, before, behaviour, belief, bell, bent, berry, between, bird, birth, bit,
bite, bitter, black, blade, blood, blow, blue, board, boat, body, boiling,
bone, book, boot, bottle, box, boy, brain, brake, branch, brass, bread,
breath, brick, a bridge to span the chasm, bright, broken, brother, brown, brush, bucket,
building, bulb, burn, burst, business, but, butter, button, by, cake, camera,
canvas, card, care, carriage, cart, cat, cause, certain, chain, chalk, chance,
change, cheap, cheese, chemical, chest, chief, chin, church, circle, clean,
clear, clock, cloth, cloud, coal, coat, cold, collar, colour, comb, come,
comfort, committee, common, company, comparison, competition, complete,
complex, condition, connection, conscious, control, cook, copper, copy, cord,
cork, cotton, cough, country, cover, cow, crack, credit, crime, cruel, crush,
cry, cup, cup, current, curtain, curve, cushion, damage, danger, dark,
daughter, day, dead, dear, death, debt, decision, deep, degree, delicate,
dependent, design, desire, destruction, detail, development, different,
digestion, direction, dirty, discovery, discussion, disease, disgust,
distance, distribution, division, do, dog, door, doubt, down, drain, drawer,
dress, drink, driving, drop, dry, dust, ear, early, earth, east, edge,
education, effect, egg, elastic, electric, end, engine, enough, equal, error,
even, event, ever, every, example, exchange, existence, expansion, experience,
expert, eye, face, fact, fall, false, family, far, farm, fat, father, fear,
feather, feeble, feeling, female, fertile, fiction, field, fight, finger,
fire, first, fish, fixed, flag, flame, flat, flight, floor, flower, fly, fold,
food, foolish, foot, for, force, fork, form, forward, fowl, frame, free,
frequent, friend, from, front, fruit, full, future, garden, general, get,
girl, give, glass, glove, go, goat, gold, good, government, grain, grass,
great, green, grey, grip, group, growth, guide, gun, hair, hammer, hand,
hanging, happy, harbour, hard, harmony, hat, hate, have, he, head, healthy,
hear, hearing, heart, heat, help, high, history, hole, hollow, hook, hope,
horn, horse, hospital, hour, house, how, humour, I, ice, idea, if, ill,
important, impulse, in, increase, industry, ink, insect, instrument,
insurance, interest, invention, iron, island, jelly, jewel, join, journey,
judge, jump, keep, kettle, key, kick, kind, kiss, knee, knife, knot,
knowledge, land, language, last, late, laugh, law, lead, leaf, learning,
leather, left, leg, let, letter, level, library, lift, light, like, limit,
line, linen, lip, liquid, list, little, living, lock, long, look, loose, loss,
loud, love, low, machine, make, male, man, manager, map, mark, market,
married, mass, match, material, may, meal, measure, meat, medical, meeting,
memory, metal, middle, military, milk, mind, mine, minute, mist, mixed, money,
monkey, month, moon, morning, mother, motion, mountain, mouth, move, much,
muscle, music, nail, name, narrow, nation, natural, near, necessary, neck,
need, needle, nerve, net, new, news, night, no, noise, normal, north, nose,
not, note, now, number, nut, observation, of, off, offer, office, oil, old,
on, only, open, operation, opinion, opposite, or, orange, order, organization,
ornament, other, out, oven, over, owner, page, pain, paint, paper, parallel,
parcel, part, past, paste, payment, peace, pen, pencil, person, physical,
picture, pig, pin, pipe, place, plane, plant, plate, play, please, pleasure,
plough, pocket, point, poison, polish, political, poor, porter, position,
possible, pot, potato, powder, power, present, price, print, prison, private,
probable, process, produce, profit, property, prose, protest, public, pull,
pump, punishment, purpose, push, put, quality, question, quick, quiet, quite,
rail, rain, range, rat, rate, ray, reaction, reading, ready, reason, receipt,
record, red, regret, regular, relation, religion, representative, request,
respect, responsible, rest, reward, rhythm, rice, right, ring, river, road,
rod, roll, roof, room, root, rough, round, rub, rule, run, sad, safe, sail,
salt, same, sand, say, scale, school, science, scissors, screw, sea, seat,
second, secret, secretary, see, seed, seem, selection, self, send, sense,
separate, serious, servant, sex, shade, shake, shame, sharp, sheep, shelf,
ship, shirt, shock, shoe, short, shut, side, sign, silk, silver, simple,
sister, size, skin, skirt, sky, sleep, slip, slope, slow, small, smash, smell,
smile, smoke, smooth, snake, sneeze, snow, so, soap, society, sock, soft,
solid, some, son, song, sort, sound, soup, south, space, spade, special,
sponge, spoon, spring, square, stage, stamp, star, start, statement, station,
steam, steel, stem, step, stick, sticky, stiff, still, stitch, stocking,
stomach, stone, stop, store, story, straight, strange, street, stretch,
strong, structure, substance, such, sudden, sugar, suggestion, summer, sun,
support, surprise, sweet, swim, system, table, tail, take, talk, tall, taste,
tax, teaching, tendency, test, than, that, the, then, theory, there, thick,
thin, thing, this, thought, thread, throat, through, through, thumb, thunder,
ticket, tight, till, time, tin, tired, to, toe, together, tomorrow, tongue,
tooth, top, touch, town, trade, train, transport, tray, tree, trick, trouble,
trousers, true, turn, twist, umbrella, under, unit, up, use, value, verse,
very, vessel, view, violent, voice, waiting, walk, wall, war, warm, wash,
waste, watch, water, wave, wax, way, weather, week, weight, well, west, wet,
wheel, when, where, while, whip, whistle, white, who, why, wide, will, wind,
window, wine, wing, winter, wire, wise, with, woman, wood, wool, word, work,
worm, wound, writing, wrong, year, yellow, yes, yesterday, you, young.


yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 2 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 3 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

# Another Demonstration

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

--------------------------------------------------------------

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

**************************************************************

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda



## Raw Content

Below we have inserted the following code; note
the empty lines:

<<{single-column>>
```mktxmd
Raw content: <<(raw>>\textregistered\textomega<<raw)>>

Raw content: <<[raw>>\textregistered\textomega<<raw]>>

Raw content: <<{raw>>\textregistered\textomega<<raw}>>
```
<<single-column}>>

And here are the results:

Raw content: <<(raw>>\textregistered\textomega<<raw)>>

Raw content: <<[raw>>\textregistered\textomega<<raw]>>

Raw content: <<{raw>>\textregistered\textomega<<raw}>>

In essence, `<<raw>>` allows you to tunnel content
through the <<!MKTS>> machinery, to be dealt with
only when the generated <<!LATEX>> source gets
interpreted. As it stands, the three variations—`<<(raw)>>`,
`<<[raw]>>`, and `<<{raw}>>`—get processed identically,
except for the paragraph breaks that will be inserted
before the block- and the region-level forms.




# This is a Demonstration 中國皇帝

## A Section Title 1 中國皇帝

14‰

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 2 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 3 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## MKTS Regions 中國皇帝

To indicate the start of an MKTS-MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
<<!new-page>>
you can put a `<<{keep-lines>>` region inside a `<<{single-column>>` region as
done here:


<<{single-column>>
Here are some formulas:
<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿

<<keep-lines}>>

At this point, a line consisting of a triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, *this
paragraph runs across the entire width* of the documents text
area.

xxxx

<<single-column}>>

# Another Demonstration

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

--------------------------------------------------------------

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

**************************************************************

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda



#############################################################



a rule:

--------------------------------------------------------------


## Regions

To indicate the start of an MKTS-MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
you can put a `<<{keep-lines>>` region inside a `<<{single-column>>` region as
done here:


<<{single-column>>
Here are some formulas:
<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿
<<keep-lines}>>
At this point, a line consisting of a  triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, this
paragraph runs across the entire width of the document's text
area.

<<single-column}>>


# This is a Demonstration

<<{single-column>>

<<{keep-lines>>
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶
`u-cjk/4e3d`  丽   ⿱一⿰&jzr#xe202;&jzr#xe202;
`u-cjk/4e3e`  举   ⿵兴&jzr#xe10d;
`u-cjk/4e3f`  丿   ●
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶
`u-cjk/4e3d`  丽   ⿱一⿰&jzr#xe202;&jzr#xe202;
`u-cjk/4e3e`  举   ⿵兴&jzr#xe10d;
`u-cjk/4e3f`  丿   ●
`u-cjk/4e40`  乀   ●
`u-cjk/4e41`  乁   ●
`u-cjk/4e42`  乂   ⿻丿㇏
`u-cjk/4e43`  乃   ⿹𠄎丿
`u-cjk/4e44`  乄   ⿻㇢丶
`u-cjk/4e45`  久   ⿰𠂊㇏
`u-cjk/4e46`  乆   ⿰𠄌人
`u-cjk/4e47`  乇   ⿱丿七
`u-cjk/4e48`  么   ⿱丿厶
`u-cjk/4e49`  义   ⿱丶乂
`u-cjk/4e4a`  乊   ⿱丿丷
`u-cjk/4e4b`  之   (⿱亠丿㇏)
`u-cjk/4e4c`  乌   ⿹&jzr#xe203;一
`u-cjk/4e4d`  乍   ⿰&jzr#xe13d;二
`u-cjk/4e4e`  乎   ⿻𠂌丷
`u-cjk/4e4f`  乏   ⿱丿之
`u-cjk/4e50`  乐   (⿻⿱丿𠃊小朩)
`u-cjk/9db7`  鶷   ⿰害鳥
`u-cjk/9db8`  鶸   ⿰弱鳥
`u-cjk/9db9`  鶹   ⿰留鳥
`u-cjk/9dba`  鶺   ⿰脊鳥
`u-cjk/9dbb`  鶻   ⿰骨鳥
`u-cjk/9dbc`  鶼   ⿰兼鳥
`u-cjk/9dbd`  鶽   ⿰隼鳥
`u-cjk/9dbe`  鶾   ⿰𠦝⿱𠂉鳥
`u-cjk/9dbf`  鶿   ⿱兹鳥
`u-cjk/9dc0`  鷀   ⿰兹鳥
`u-cjk/9dc1`  鷁   ⿰益鳥
`u-cjk/9dc2`  鷂   ⿰䍃鳥
`u-cjk/9dc3`  鷃   ⿰晏鳥
`u-cjk/9dc4`  鷄   ⿰奚鳥
`u-cjk-xb/2501f`  𥀟   ⿰⿱𠈌日皮
`u-cjk-xb/25020`  𥀠   ⿰皮貴
`u-cjk-xb/25021`  𥀡   ⿱⿰(⿱厶一⺝)⿷&jzr#xe276;匕皮
`u-cjk-xb/25021`  𥀡   ⿱≈能皮
`u-cjk-xb/25022`  𥀢   ⿰賁皮
`u-cjk-xb/25023`  𥀣   ⿱𦥯皮
`u-cjk-xb/25024`  𥀤   ⿰皮(⿱日罒方)
`u-cjk-xb/250b5`  𥂵   ⿱⿰氵𦘔皿
`u-cjk-xb/250b6`  𥂶   (⿱亠〓皿)
`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿
<<keep-lines}>>

<<single-column}>>


The above are just a few of the over 75,000 formulas in the Jizura collection.


-------------------------------------------------------------------


## Of Markdown Features

Here comes a `keeplines` block:

<<{keep-lines>>
lines are kept
as they are
in the markdown source
<<keep-lines}>>

<div>
this line directly below `keeplines` block
</div>

Here comes another `keeplines` block:

'It IS a long tail, certainly,' said Alice, looking down with wonder at
the Mouse's tail; 'but why do you call it sad?' And she kept on puzzling
about it while the Mouse was speaking, so that her idea of the tale was
something like this:--

<<{keep-lines>>
         'Fury said to a
         mouse, That he
        met in the
       house,
     "Let us
      both go to
       law: I will
        prosecute
         YOU.--Come,
           I'll take no
           denial; We
          must have a
        trial: For
      really this
     morning I've
    nothing
    to do."
     Said the
      mouse to the
       cur, "Such
        a trial,
         dear Sir,
            With
          no jury
        or judge,
       would be
      wasting
      our
      breath."
       "I'll be
        judge, I'll
         be jury,"
            Said
         cunning
          old Fury:
          "I'll
          try the
            whole
            cause,
              and
           condemn
           you
          to
           death."'
<<keep-lines}>>

<<!new-page>>

this line *not* directly below `keeplines` block

&jzr#xe202;
`&jzr#xe202;`

```
this is
a code block &jzr#xe202;
with three lines & an XNCR
```

some **bold** attempts
some *slants* attempts

@somewhere

4 > 3
&gt;
\&gt;


<<{single-column>>
It was the White Rabbit, trotting slowly back again, and looking
anxiously about as it went, as if it had lost something; and she heard
it muttering to itself 'The Duchess! The Duchess! Oh my dear paws! Oh
my fur and whiskers! She'll get me executed, as sure as ferrets are
ferrets! Where CAN I have dropped them, I wonder?' Alice guessed in a
moment that it was looking for the fan and the pair of white kid gloves,
and she very good-naturedly began hunting about for them, but they were
nowhere to be seen--everything seemed to have changed since her swim in
the pool, and the great hall, with the glass table and the little door,
had vanished completely.

<<{keep-lines>>
foobar 1
foobar 2
foobar 3
foobar 4
foobar 5

foobar 6
foobar 7
foobar 8
foobar 9
foobar 10
<<keep-lines}>>

Very soon the Rabbit noticed Alice, as she went hunting about, and
called out to her in an angry tone, 'Why, Mary Ann, what ARE you doing
out here? Run home this moment, and fetch me a pair of gloves and a fan!
Quick, now!' And Alice was so much frightened that she ran off at once
in the direction it pointed to, without trying to explain the mistake it
had made.
<<single-column}>>



'He took me for his housemaid,' she said to herself as she ran. 'How
surprised he'll be when he finds out who I am! But I'd better take him
his fan and gloves--that is, if I can find them.' As she said this, she
came upon a neat little house, on the door of which was a bright brass
plate with the name 'W. RABBIT' engraved upon it. She went in without
knocking, and hurried upstairs, in great fear lest she should meet the
real Mary Ann, and be turned out of the house before she had found the
fan and gloves.

'How queer it seems,' Alice said to herself, 'to be going messages for
a rabbit! I suppose Dinah'll be sending me on messages next!' And she
began fancying the sort of thing that would happen: '"Miss Alice! Come
here directly, and get ready for your walk!" "Coming in a minute,
nurse! But I've got to see that the mouse doesn't get out." Only I don't
think,' Alice went on, 'that they'd let Dinah stop in the house if it
began ordering people about like that!'






# This is a Demonstration

## Of Typesetting Features

### Using Special Characters



m&jzr#xe219;&jzr#xe219;&jzr#xe219;m

c&cdp#x8b7a;c

xxx

```
m&jzr#xe219;m
c&cdp#x8b7a;c
```

difference: u-cjk-5019 候 ⿰&cdp#x8b7a;&cdp#x8bc7; [ '⿰&jzr#xe219;(⿱&jzr#xe1c2;矢)' ]

'this' & "that"

between 20‰ and 3%

### Ideographic Description Chracters (IDCs)

<<{keep-lines>>
'↻': 
'↔': 
'↕': 
'●': 
'⿰':  
'⿱':  
'⿺':  
'⿸':  
'⿹':  
'◰': 
'⿶':  
'⿷':  
'⿵':  
'⿴':  
'⿻':  
'≈': 
<<keep-lines}>>

### Code Sections

```
Code sections
use a non-proportional font
and keep line breaks
```

### Chracter Formulas

difference: u-cjk-5019 候 ⿰&cdp#x8b7a;&cdp#x8bc7; [ '⿰&jzr#xe219;(⿱&jzr#xe1c2;矢)' ]

&jzr#xe219;

+&jzr#xe219;+

候 ⿰ +&cdp#x8b7a;+&cdp#x8bc7;+ +&jzr#xe219;+&jzr#xe1c2;矢+

```
候 ⿰ +&cdp#x8b7a;+&cdp#x8bc7;+ +&jzr#xe219;+&jzr#xe1c2;矢+
```





&jzr#xe219; `&cdp#x8b7a;`

It's possible to switch on `inline code`. It's also possible
to have a block of code with lines rendered as in the source:

<<{single-column>>

```
#-------------------------------------------------------------------------------------
@_shuffle = ( list, ratio, rnd, random_integer ) ->
  #...................................................................................
  return list if ( this_idx = list.length ) < 2
  #...................................................................................
  loop
    this_idx += -1
    return list if this_idx < 1
    if ratio >= 1 or rnd() <= ratio
      # return list if this_idx < 1
      that_idx = random_integer 0, this_idx
      [ list[ that_idx ], list[ this_idx ] ] = [ list[ this_idx ], list[ that_idx ] ]
  #...................................................................................
  return list
```

<<single-column}>>

Code sample, keeping indentations:

```
x
  x
    x
```

### [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.


<b foo='bar'>xxx</b>

3 > 2

Here we reference a @user. "Fancy" 'quotes' are possible.
 <!--
comments
in MD
will appear in <b>TeX</b> --> xxx

### Lists
An unordered list:

<!--
* America
* Europe
* Australia

  (includes Oceania) -->


An ordered list:

1) South America
1) Central Asia
1) Polar Regions
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)

x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x









<<!new-page>>


## Fenced Code Blocks

Fenced code blocks are ended and started by pairs of triple backticks.
Here's a code sample that shows how line breaks and indentations are
kept:

```

if a > 10
  if b < 100
    echo "success!"
```


## Lists
An unordered list:

<!--
* America
* Europe
* Australia

  (includes Oceania) -->


An ordered list:

1) South America
1) Central Asia
1) Polar Regions
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)


## Footnotes

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnotes **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.
