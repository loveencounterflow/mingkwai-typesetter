

<<(multi-column>>

## The Extended Ideographic Description Language (IDLx)

<<(single-column>>
|          |              Unicode Name |        A         |                       Name | B  |     B      | Examples                    |
|---------:|--------------------------:|:----------------:|---------------------------:|:--:|:----------:|:----------------------------|
|  **a-1** |             left to right | <<<{\cjk{}⿰}>>> |                 left-right |   |           | 𪷈:⿰氵貫                   |
|  **a-2** |            above to below | <<<{\cjk{}⿱}>>> |                   top-down |   |           | 𪲪:⿱㐭木                   |
|  **a-3** | surround from bottom left | <<<{\cjk{}⿺}>>> |       L-shaped, left first |  |           | 毯:⿺毛炎                   |
|  **a-4** |                       ... |       ...        |        L-shaped, top first |  |           | 廷:壬廴                    |
|  **a-5** |  surround from upper left | <<<{\cjk{}⿸}>>> |                   Γ-shaped |   |           | 慮:⿸虍思                   |
|  **a-6** | surround from upper right | <<<{\cjk{}⿹}>>> |                    package |   |           | 截:⿹𢦏隹                   |
|  **a-7** |                        ／ |        ／        | surround from bottom right |   |           | &jzr#xe232;:◰一弋           |
|  **a-8** |       surround from below | <<<{\cjk{}⿶}>>> |                       plug |   |           | 𠚍:⿶𠂭凵                   |
|  **a-9** |        surround from left | <<<{\cjk{}⿷}>>> |                   C-shaped |   |           | 玉:⿷王丶                   |
| **a-10** |         surround from top | <<<{\cjk{}⿵}>>> |          surround from top |   |           | 閒:⿵門月                   |
| **a-11** |                        ／ |        ／        |           reverse C-shaped |   |           | 𢏚:⿷弓工工                |
| **a-12** |             full surround | <<<{\cjk{}⿴}>>> |                   surround |   |           | 囪:⿴&jzr#xe105;&jzr#xe134; |
| **a-13** |                  overlaid | <<<{\cjk{}⿻}>>> |                  crossover |   |           | 夫:⿻二人                   |
| **a-14** |                        ／ |        ／        |                no operator |    |           | 亅:                        |
| **a-15** |                        ／ |        ／        |                  geta mark |    |     〓     | 𠪕:⿸严〓                   |
| **a-16** |                        ／ |        ／        |                rotate 180° |    |           | 𠄔:↻予                      |
| **a-17** |                        ／ |        ／        |            horizontal flip |    |           | 𣥄:正                      |
| **a-18** |                        ／ |        ／        |                    similar |    |           | 𠉒:⿱从≈电                  |
| **a-19** |                        ／ |        ／        |         parentheses; group |    | (&#x3000;) | 埊:(⿱山水土)               |
<<single-column)>>


## System used in 《汉字信息字典》

《汉字信息字典》
上海交通大学汉字编码组, 上海汉语拼音文字研究组编著, 樊静责任编辑; 上海: 1988

本书使用的数字，符号一览表

字形结构

<<(single-column>>
|    符号    |       表示内容       |            举例           |
|------------|----------------------|---------------------------|
| /          | 表示上下组合关系     | 星:日/生                  |
| //         | 表示左右组合关系     | 把:扌//巴                 |
| >, <       | 表示包容或被包容关系 | 这:文<辶 ("辶" 包容 "文") |
|            | 表示嵌套关系         | 国:<<<{\cjk{}囗}>>>玉                    |
| (&#x3000;) | 表示层次关系         | 疑:(匕/矢)//(龴/疋)       |
<<single-column)>>



*Notes*:

**a-1**, **a-2**: The left-right operator  and the top-down operator 
are the most basic analytical operators of IDLx.

**a-3**: The L-shape, , is the only binary relationship that occurs in both of
its realizations, ⿺ and ; this case is well known to learners of Kanji, as
there are many common glyphs with either type of operator.

The choice between ⿺ and  depends on the element that occupies the left and bottom of the character in
question: only 廴 and 辶 (⻍, ⻎) are written *after* the top right and hence
need , as in 這:言辶 (observe that using standard Unicode IDL, we are forced to write
this as
這:<<<\cjkgGlue{\cjk{}⿺}\cjkgGlue{}>>>辶言, which,
crucially, does not preserve the order in which the factors are normally written).^[see
<<(url>>https://raw.githubusercontent.com/cjkvi/cjkvi-ids/master/ids.txt<<)>> for actual examples]

All other elements (i.e. except for 廴 and 辶) that enclose another one from the left and
from below in an L-shape take precedence; hence, in e.g. 赲, 走 comes first and 力
comes second, so its formula is 赲:⿺走力.

**a-11**: XXXXX XXXXX XXXXX XXXXX XXXXX the reversed C-shape: lowest frequency, missing from Unicode IDCs,
erroneously replaced by ⿴ in formula
𢏚:<<<\cjkgGlue{\cjk{}⿷⿴}\cjkgGlue{}>>>弓工工 for which we write 𢏚:⿷弓工工.

**a-15**: The symbol 〓 originated in Japanese manual typesetting. When a composer
couldn't clearly read a character in the manuscript or was unable to find
a certain kanji in the type cases, they'd instead pick any sort and
put it wrong side first onto the composing stick. When galley proofs were
printed, that upside-down sort would leave a mark similar to 〓, making it
visually clear that something was still missing. In the same way, we
use 〓 to stand in for an unresolved element in the formulas. For
example, we know the upper left part of 𠪕 is 严, a fairly common element,
but the lower right part is seemingly not encoded in Unicode, so we write
out the formula 𠪕:⿸严〓; this is a syntactically valid way of stating what
we can and what we cannot say about that glyph. In other words,
〓 represents the unspecified element as much as an *x* in a mathematical
formula represents the unknown quantity.

**a-13**: The crossover operator  is to operators what the geta mark
〓 is to elements; it represents an unspecified or underspecified operation. Most of
the time,  really represents an element being overlaid onto another
one, as in 夫:⿻二人, but more generally, it may be used in any place
where no other operator fits, as, for example, in 〓〓〓〓〓〓.

<<!footnotes>>


<<(keep-lines>>
徵:(⿰彳(⿱山一𡈼)夊)
毯:毛炎 as 毯:(∪)毛炎<<< >>>
廷:壬廴 as 廷:(∩)壬廴<<< >>>
玉:⿷王丶 as 玉:(∪)王丶<<< >>>
𠚍:⿶𠂭凵 as 𠚍:(∩)𠂭凵<<< >>>
國:⿴囗或 as 國:(∪)囗或<<< >>>
<<keep-lines)>>


<<(single-column>>
|          |                       Name |     B      | Examples                    | X                                |
|---------:|---------------------------:|:----------:|:----------------------------|:---------------------------------|
|  **a-1** |                 left-right |           | 𪷈:⿰氵貫                   |                                  |
|  **a-2** |                   top-down |           | 𪲪:⿱㐭木                   |                                  |
|  **a-3** |       L-shaped, left first |           | 毯:⿺毛炎                   | 毯:(∪)毛炎                     |
|  **a-4** |        L-shaped, top first |           | 廷:壬廴                    | 廷:(∩)壬廴                     |
|  **a-5** |                   Γ-shaped |           | 慮:⿸虍思                   | 慮:(∪)虍思                     |
|  **a-6** |                    package |           | 截:⿹𢦏隹                   | 截:(∪)𢦏隹                     |
|  **a-7** | surround from bottom right |           | &jzr#xe232;:◰一弋           | &jzr#xe232;:(∩)一弋            |
|  **a-8** |                       plug |           | 𠚍:⿶𠂭凵                   | 𠚍:(∩)𠂭凵                    |
|  **a-9** |                   C-shaped |           | 玉:⿷王丶                   | 玉:(∪)王丶                    |
| **a-10** |          surround from top |           | 閒:⿵門月                   | 閒:(∪)門月                    |
| **a-11** |           reverse C-shaped |           | 𢏚:⿷弓工工                | 𢏚:⿷(∪)弓工工                |
| **a-12** |                   surround |           | 囪:⿴&jzr#xe105;&jzr#xe134; | 囪:(∪)&jzr#xe105;&jzr#xe134; |
| **a-13** |                  crossover |           | 夫:⿻二人                   |                                  |
| **a-14** |                no operator |           | 亅:                        |                                  |
| **a-15** |                  geta mark |     〓     | 𠪕:⿸严〓                   |                                  |
| **a-16** |                rotate 180° |           | 𠄔:↻予                      |                                  |
| **a-17** |            horizontal flip |           | 𣥄:正                      |                                  |
| **a-18** |                    similar |           | 𠉒:⿱从≈电                  |                                  |
| **a-19** |         parentheses; group | (&#x3000;) | 亴:(⿱亠口冖土九)           |                                  |
<<single-column)>>

<<(single-column>>
|          | Used | G | B | Op | L | T |    R     |    B     | l | t | r | b |
|---------:|:----:|:-:|:-:|:--:|:-:|:-:|:--------:|:--------:|:-:|:-:|:-:|:-:|
|  **c-1** | Yes  |  |  |    |   |   | &#x3000; | &#x3000; |   |   |   |   |
|  **c-2** | Yes  |  |  |    |   |   |          |          |   |   |   |   |
| **c-15** |  No  |  |  | ¬  |  |   |          |          |   |   |   |   |
| **c-16** |  No  |  |  | ¬  |   |  |          |          |   |   |   |   |

|          | Used | G |    | B | Op | L | T | R | B | l | t | r | b |
|---------:|:----:|:-:|:--:|:-:|:--:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|  **c-7** | Yes  |  |    |  | ∩  |  |  |   |   | + | + |   |   |
|  **c-4** | Yes  |  |  |  | ∩  |   |  |  |   | – | + | + |   |
|  **c-3** | Yes  |  |  |  | ∪  |  |   |   |  | + | – | + | + |
|  **c-5** | Yes  |  |    |  | ∪  |  |  |   |   | + | + |   | + |
|  **c-6** | Yes  |  |    |  | ∪  |   |  |  |   | + | + | + |   |
| **c-19** |  No  |  |    |  | ∪  |   |   |  |  | – | – | + | + |
| **c-17** |  No  |  |    |  | ∩  |   |   |  |  | – | – | + | + |
| **c-18** |  No  |  |    |  | ∩  |  |   |   |  | + | – |   | + |

|          | Used | G | B | Op | L | T | R | B | l | t | r | b |
|---------:|:----:|:-:|:-:|:--:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **c-12** | Yes  |  |  | ∪  |   |  |  |  | – | + | + | + |
|  **c-8** | Yes  |  |  | ∩  |  |  |  |   | + | + | + |   |
|  **c-9** | Yes  |  |  | ∪  |  |  |   |  | + | + |   | + |
| **c-10** | Yes  |  |  | ∪  |  |  |  |   | + | + | + |   |
| **c-25** |  No  |  |  | ∩  |  |  |   |  | + | + |   | + |
| **c-20** |  No  |  |  | ∪  |  |   |  |  |   |   |   |   |
| **c-22** |  No  |  |  | ∩  |   |  |  |  |   |   |   |   |
| **c-24** |  No  |  |  | ∩  |  |   |  |  |   |   |   |   |

|          | Used | G | B | Op | L | T | R | B | l | t | r | b |
|---------:|:----:|:-:|:-:|:--:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **c-14** | Yes  |  |  | ∪  |  |  |  |  |   |   |   |   |
| **c-26** |  No  |  |  | ∩  |  |  |  |  |   |   |   |   |
<<single-column)>>



<<(single-column>>
|          |                       Name | B | E  |
|---------:|---------------------------:|:-:|:--:|
|  **b-1** |                 left/right |  |   |
|  **b-2** |                   top/down |  |   |
|  **b-3** |  surround from bottom left |  | ／ |
|  **b-4** |   surround from upper left |  |   |
|  **b-5** |  surround from upper right |  |   |
|  **b-6** | surround from bottom right |  |   |
|  **b-7** |        surround from below |  |   |
|  **b-8** |         surround from left |  |   |
|  **b-9** |          surround from top |  |   |
| **b-10** |                   surround |  |   |
| **b-11** |               any operator |   |   |
| **b-12** |              vertical flip |   |   |
<<single-column)>>



<<(single-column>>
|    |              Unicode Name |        A         |                       Name | C  | E  | Examples                    |
|---:|--------------------------:|:----------------:|---------------------------:|:--:|:--:|:----------------------------|
|  1 |             left to right | <<<{\cjk{}⿰}>>> |                 left/right |   |   | 𪷈:⿰氵貫                   |
|  2 |            above to below | <<<{\cjk{}⿱}>>> |                   top/down |   |   | 𪲪:⿱㐭木                   |
|  3 | surround from bottom left | <<<{\cjk{}⿺}>>> |  surround from bottom left |  |    | 毯:⿺毛炎                   |
|  4 |                           |                  |                            |    |    | 廷:壬廴                    |
|  5 |  surround from upper left | <<<{\cjk{}⿸}>>> |   surround from upper left |   |   | 慮:⿸虍思                   |
|  6 | surround from upper right | <<<{\cjk{}⿹}>>> |  surround from upper right |   |   | 截:⿹𢦏隹                   |
|  7 |                        ／ |        ／        | surround from bottom right |   |   | &jzr#xe232;:◰一弋           |
|  8 |       surround from below | <<<{\cjk{}⿶}>>> |        surround from below |   |   | 𠚍:⿶𠂭凵                   |
|  9 |        surround from left | <<<{\cjk{}⿷}>>> |         surround from left |   |   | 玉:⿷王丶                   |
| 10 |         surround from top | <<<{\cjk{}⿵}>>> |          surround from top |   |   | 閒:⿵門月                   |
| 11 |                        ／ |        ／        |        surround from right |    |  |                             |
| 12 |             full surround | <<<{\cjk{}⿴}>>> |                   surround |   |   | 囪:⿴&jzr#xe105;&jzr#xe134; |
| 13 |                  overlaid | <<<{\cjk{}⿻}>>> |                  crossover |   |    | 夫:⿻二人                   |
| 14 |                        ／ |        ／        |               any operator |   |    |                             |
| 15 |                        ／ |        ／        |                no operator |   |    | 亅:                        |
| 16 |                        ／ |        ／        |        unspecified element | 〓 |    | 𠪕:⿸严〓                   |
| 17 |                        ／ |        ／        |                rotate 180° |   |    | 𠄔:↻予                      |
| 18 |                        ／ |        ／        |            horizontal flip |   |    | 𣥄:正                      |
| 19 |                        ／ |        ／        |              vertical flip |    |   |                             |
| 20 |                        ／ |        ／        |                    similar |   |    | 𠉒:⿱从≈电                  |
| 21 |                        ／ |        ／        |         parentheses; group |    |    | 亴:(⿱亠口冖土九)           |
| 22 |  left to middle and right | <<<{\cjk{}⿲}>>> |                         ／ |    |    | 衍:(⿰彳氵亍)               |
| 23 | above to middle and below | <<<{\cjk{}⿳}>>> |                         ／ |    |    | 衰:(⿱亠&jzr#xe206;𧘇)      |
<<single-column)>>


xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx
xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx xxx

<<(single-column>>
|    |              Unicode Name |        A         |                       Name |     B      | C  | E  | Examples                    |
|---:|--------------------------:|:----------------:|---------------------------:|:----------:|:--:|:--:|:----------------------------|
|  1 |             left to right | <<<{\cjk{}⿰}>>> |                 left/right |           |   |   | 𪷈:⿰氵貫                   |
|  2 |            above to below | <<<{\cjk{}⿱}>>> |                   top/down |           |   |   | 𪲪:⿱㐭木                   |
|  3 | surround from bottom left | <<<{\cjk{}⿺}>>> |  surround from bottom left |           |  |    | 毯:⿺毛炎                   |
|    |                           |                  |                            |            |    |    | 廷:壬廴                    |
|  4 |  surround from upper left | <<<{\cjk{}⿸}>>> |   surround from upper left |           |   |   | 慮:⿸虍思                   |
|  5 | surround from upper right | <<<{\cjk{}⿹}>>> |  surround from upper right |           |   |   | 截:⿹𢦏隹                   |
|  6 |                        ／ |        ／        | surround from bottom right |           |   |   | &jzr#xe232;:◰一弋           |
|  7 |       surround from below | <<<{\cjk{}⿶}>>> |        surround from below |           |   |   | 𠚍:⿶𠂭凵                   |
|  8 |        surround from left | <<<{\cjk{}⿷}>>> |         surround from left |           |   |   | 玉:⿷王丶                   |
|  9 |         surround from top | <<<{\cjk{}⿵}>>> |          surround from top |           |   |   | 閒:⿵門月                   |
| 10 |                        ／ |        ／        |        surround from right |           |    |  |                             |
| 11 |             full surround | <<<{\cjk{}⿴}>>> |                   surround |           |   |   | 囪:⿴&jzr#xe105;&jzr#xe134; |
| 12 |                  overlaid | <<<{\cjk{}⿻}>>> |                  crossover |            |   |    | 夫:⿻二人                   |
| 15 |                        ／ |        ／        |               any operator |            |   |    |                             |
| 16 |                        ／ |        ／        |                no operator |            |   |    | 亅:                        |
| 15 |                        ／ |        ／        |        unspecified element |            | 〓 |    | 𠪕:⿸严〓                   |
| 17 |                        ／ |        ／        |                rotate 180° |            |   |    | 𠄔:↻予                      |
| 18 |                        ／ |        ／        |            horizontal flip |            |   |    | 𣥄:正                      |
| 19 |                        ／ |        ／        |              vertical flip |            |    |   |                             |
| 20 |                        ／ |        ／        |                    similar |            |   |    | 𠉒:⿱从≈电                  |
| 13 |                        ／ |        ／        |         parentheses; group | (&#x3000;) |    |    | 亴:(⿱亠口冖土九)           |
| 13 |  left to middle and right | <<<{\cjk{}⿲}>>> |                         ／ |     ／     |    |    | 衍:(⿰彳氵亍)               |
| 14 | above to middle and below | <<<{\cjk{}⿳}>>> |                         ／ |     ／     |    |    | 衰:(⿱亠&jzr#xe206;𧘇)      |
<<single-column)>>

<!--
|      |                              |                    |                              |            |     |     | 弋:⿺&jzr#xe1af;丶          |
|   |   |   |   |   |  |   |   |   |
-->


<!--  -->

