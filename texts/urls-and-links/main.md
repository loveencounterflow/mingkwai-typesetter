
<<!columns>>

## URLs, Footnotes, and Links

### Code Samples

<<!columns 1>>
```
helo world
\<<(url>>https://link.com/2\<<)>>
\<<(url>>https://example.com/a/uniform/resource\<<)>>
your main text^[the annotation]
```
<<!columns 'pop'>>

### URLs

<<(url>>https://link.com/2<<)>>

<<(url>>https://example.com/a/uniform/resource<<)>>

Yadda yadda <<(url>>https://example.com/a/uniform/resource/locator?x=42&y=108<<)>> yadda yadda yadda yadda yadda yadda.

An example <<(url>>https://example.com/a/uniform/resource<<)>> for a URL.
And yet <<(url>>http://x.com<<)>> another one.

When URLs get longer, they can quickly interfere with line breaking. In order
to mitigate unsightly effects, two measures have been taken. For one thing,
breakpoints are inserted^[breakpoints in URLs follow the rules of the Unicode
Line Breaking Algorithm  (<<!url
'http://www.unicode.org/reports/tr14/#SampleCode'>>) as implemented by the
NodeJS `linebreak` module (<<!url 'https://github.com/devongovett/linebreak'>>).]

<<(url>>https://example.com/a/uniform/resource/locator/commonly/informally/termed/a/web/address/is/a/reference/to/a/web/resource/that/specifies/its/location/on/a/computer/network/and/a/mechanism/for/retrieving/it<<)>>



### Footnotes

Two ways to markup footnotes

get realized as footnotes or endnotes; in the latter case, use `\<<!footnotes>>`
command to place them

```
your main text^[the annotation]
```

your main text^[the annotation]



### Links

When MD link syntax is used `[like here](https://example.com/#like)`
[like here](https://example.com/#like), a footnote is generated; a footnote mark
(a superscript number) is placed after the linked text, and the URL will appear in
the footnotes wherever they will be generated. 

Since the anchor text is in no way
marked, it is possible to achieve the same effect by leaving the anchor text
empty; however, if you intend to use the same source for other output formats,
it would probably be a good idea to always use a non-empty anchor text.^[... and not
to use 'click here' and similar wordings that only make sense in an interactive setting.]


########################################################

<<!footnotes>>
