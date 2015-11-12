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
