
<<(multi-column>>

## URLs, Footnotes, and Links


### URLs

<<(url>>https://link.com/2<<)>>

<<(url>>https://example.com/a/uniform/resource<<)>>

An example <<(url>>https://example.com/a/uniform/resource<<)>> for a URL.
And yet <<(url>>http://x.com<<)>> another one.

<<(url>>https://example.com/a/uniform/resource/locator/commonly/informally/termed/a/web/address/is/a/reference/to/a/web/resource/that/specifies/its/location/on/a/computer/network/and/a/mechanism/for/retrieving/it<<)>>


### Footnotes

foo^[bar]


### Links

When MD link syntax is used `[like here](https://example.com/#like)`
[like here](https://example.com/#like), a footnote is generated; a footnote mark
(a superscript number) is placed after the linked text, and the URL will appear in
the footnotes wherever they will be generated. Since the anchor text is in no way
marked, it is possible to achieve the same effect by leaving the anchor text
empty; however, if you intend to use the same source for other output formats,
it would probably be a good idea to always use a non-empty anchor text.^[... and not
to use 'click here' and similar wordings that only make sense in an interactive setting.]


<<!footnotes>>
<<multi-column)>>

<<!end>>
