

- [MingKwai Type Setter 明快排字機](#mingkwai-type-setter-明快排字機)
- [Syntax](#syntax)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# MingKwai Type Setter 明快排字機

A streaming MarkDown -> LaTeX (i.e. XeLaTeX, LuaLaTeX) -> PDF typesetter,
implemented in CoffeeScript.

# Syntax

MingKwai TypeSetter (MKTS) uses
[`markdown-it`](https://github.com/markdown-it/markdown-it)[^1] and, as such,
supports all the parts of [CommonMark, the Common Markdown
Spec](http://commonmark.org/) that are supported by `markdown-it` core—or any
available syntax plugin—offers, provided an adapter for the given feature has
been integrated into the MKTS processing pipeline.

[^1]: this may change in the future, since `markdown-it` does not currently
support parsing sources in a piecemeal fashion as would be appropriate
for an all-out streaming framework.

Since `markdown-it` accepts raw HTML tag,

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
