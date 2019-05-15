<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [MingKwai Type Setter 明快排字機](#mingkwai-type-setter-%E6%98%8E%E5%BF%AB%E6%8E%92%E5%AD%97%E6%A9%9F)
- [Syntax](#syntax)
  - [Level 1—MarkDown Syntax](#level-1%E2%80%94markdown-syntax)
  - [Level 2—HTML Tags](#level-2%E2%80%94html-tags)
  - [Level 3—MKTS Tags (MingKwai TypeScript)](#level-3%E2%80%94mkts-tags-mingkwai-typescript)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



- [MingKwai Type Setter 明快排字機](#mingkwai-type-setter-明快排字機)
- [Syntax](#syntax)
	- [Level 1—MarkDown Syntax](#level-1—markdown-syntax)
	- [Level 2—HTML Tags](#level-2—html-tags)
	- [Level 3—MKTS Tags (MingKwai TypeScript)](#level-3—mkts-tags-mingkwai-typescript)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# MingKwai Type Setter 明快排字機

A streaming MarkDown -> LaTeX (i.e. XeLaTeX, LuaLaTeX) -> PDF typesetter,
implemented in CoffeeScript.

# Syntax

## Level 1—MarkDown Syntax

MingKwai TypeSetter (MKTS) uses
[`markdown-it`](https://github.com/markdown-it/markdown-it)* and, as such,
supports all the parts of [CommonMark, the Common MarkDown
Spec](http://commonmark.org/) that are supported by `markdown-it` core—or any
available syntax plugin—offers, provided an adapter for the given feature has
been integrated into the MKTS processing pipeline.

> **\*)** this may change in the future, since `markdown-it` does not currently
> support parsing sources in a piecemeal fashion as would be appropriate
> for an all-out streaming framework.

## Level 2—HTML Tags

Since `markdown-it` accepts raw HTML tags, it is possible to 'escape to HTML' to
quickly get features not available in MarkDown as such; however, this also
presupposes that an HTML-to-TeX translation for the HTML tags has been implemented.*

> **\*)** at the time of this writng, no plug-in structure for syntax extensions
> has been establish, but that will hopefully change in the future.

## Level 3—MKTS Tags (MingKwai TypeScript)



* HTML:
* Raw (i.e. <<(raw>>\TeX<<raw)>>/<<(raw>>\LaTeX<<raw)>>): `<<<...raw material...>>>`
<!-- * Raw (i.e. <<<\TeX>>>/<<<\LaTeX>>>): `<<<...raw material...>>>` -->
* Regions:
  <!-- distinction between span and block needed? -->
  * Spans: `<<(span>>...<<span)>>`
  * Blocks: `<<[block>>...<<block]>>`
* ...
  * ...
    * Actions: `<<!action>>`
    * Exec-Block: <<(!>>exec block<<!)>>
  * Value Interpolation:
    <!-- * Variables: `<<$variable>>` -->
    * Eval-Block: `<<(\$>>eval block<<\$)>>`



# Fonts and Styles

The MKTS design philosophy rejects the idea of there being stylistic variations of a given typeface;
instead, it treats each font (German: Schriftschnitt) as an entity in its own right.

* what can be done algorithmically vs what can only be done by conscious choice by the designer

  * Italic: Nope—Oblique yes, but no Italic in the proper sense
  * Bold: Easier than Italic, but no thanks

It turns out that in present day digital typesetting, all the algorithmic type variation that you can both
get and actually use in a serious publication is retricted to, basically, scaling ( type size). You *can*
squeeze and stretch type a teenie-weenie bit, but that's about it.

> In theory underlines are very well within the reach of algorithmic type modification, but, astoundingly,
> in practice almost all underlined text looks ugly. That should not be the case, given how straightforward
> it is to add an underline to text. The [Shady Characters](http://www.shadycharacters.co.uk/) website is a
> the rare exception; there, the designers went to lengths and devised ways to ensure that underlined text
> look good.[^There's a very interesting proposal for a CSS property `text-decoration-skip` to provide for,
> inter alia, gaps in the underline where it would otherwise cross descenders; as of 2016, it hasn't been
> implemented in any browser, though.]

Some (like Knuth) would argue that even mere font scaling produces another font (Schriftschnitt), and this
was indeed, by and large, the matter of affairs with movable type, where you had one case with, say Times
Roman @ 12pt and a separate one with Times Roman @ 10pt.

> But observe that (1)&nbsp;even Knuth probably did not provide hand-tailored separate masters for *each* of
> the envisioned type sizes, not even the several small and very small ones (citation needed);
> (2)&nbsp;Knuths multiple masters were probably done algorithmically with _MetaFont_ (citation needed); and
> that (3)&nbsp;even in the olden days, designers used mechanical devices like
> [pantographs](https://en.wikipedia.org/wiki/Pantograph) to be able to just-so produce multiple sizes from
> the exact same *urbild* (some adjustments notwithstanding, like keeping hairlines to a certain minimum
> required widths—that's what we have font hinting and ClearType for in the digital world).

* Algorithmic Variation vs Hand-Picked Matches
* Convenient Packaging vs Freedom of Choice
* Helps Simplicity, Ease and Clarity of Implementation

<!--

Whenever you select a font in a word processor like Microsoft Word or OpenOffice Writer and then highlight
a word and press the Italic or the Bold button on the toolbar, the program will try to interpret your font choice

 -->

## Related Projects

### SILE

Written in Lua, C++

* https://www.youtube.com/watch?v=t_kk20vlamo
* https://www.youtube.com/watch?v=5BIP_N9qQm4
* http://sile-typesetter.org
* http://sile-typesetter.org/images/sile-0.9.4.pdf
* https://news.ycombinator.com/item?id=13680910
* https://news.ycombinator.com/item?id=8392653

### Pollen

Written in Rackett

* https://docs.racket-lang.org/pollen/

Written with Pollen:

* Butterick’s Practical Typography, 2nd Edition: https://practicaltypography.com/

### Patoline

* http://patoline.org/patobook.pdf

### Glenn Vanderburg - Cló: The Algorithms of TeX in Clojure

* https://www.youtube.com/watch?v=824yVKUPFjU

> "Cló is a typesetting library for Clojure, implementing the core typesetting algorithms of TeX as
> composable functions. Although much work remains before Cló is useful in practice, even at an early stage
> it is instructive, providing interestingly complex examples of real-world procedural algorithms translated
> into functional form. Thinking about typesetting as a functional problem has yielded valuable clarity and
> insight about these algorithms, even though in their original form they were written with instruction and
> teaching in mind (the notion of "literate programming" was invented for TeX). In this talk, I'll share
> some of the background, code, results, and lessons learned so far."

### Rinohtype, The Python document processor

> "Rinohtype is a document processor in the style of LaTeX. It renders structured documents to PDF based on
> a document template and a style sheet. An important goal of rinohtype is to be more user-friendly than
> LaTeX. This includes providing clear error messages and making it very easy to adjust the document style."

* https://github.com/brechtm/rinohtype
* http://www.mos6581.org/rinohtype

(v0.3.0 released on Dec 7, 2016)

### CSS Paged Media Module Level 3

> W3C Working Draft, 18 October 2018
>
> "This CSS module specifies how pages are generated and laid out to hold fragmented content in a paged
> presentation. It adds functionality for controlling page margins, page size and orientation, and headers
> and footers, and extends generated content to enable page numbering and running headers / footers. The
> process of paginating a flow into such generated pages is covered in [CSS3-BREAK].
>
> CSS is a language for describing the rendering of structured documents (such as HTML and XML) on screen,
> on paper, etc."

* https://www.w3.org/TR/css-page-3/

### Prince


> "Prince is an ideal printing component for server-based software, such as web applications that need to
> print reports or invoices. Using Prince, it is quick and easy to create PDF files that can be printed,
> archived, or downloaded.
>
> Prince can also be used by authors and publishers to typeset and print documents written in HTML, XHTML,
> or one of the many XML-based document formats. Prince is capable of formatting academic papers, journals,
> magazines, and books."

* https://www.princexml.com/
* http://css4.pub/2015/icelandic/dictionary.pdf

## Status of Japanese (and CJK) typesetting with TeX in Debian

* https://www.youtube.com/watch?v=i0UO44PNMWM



