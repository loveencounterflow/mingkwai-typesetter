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
> look good.

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



