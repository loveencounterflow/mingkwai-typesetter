

### Hint: do not use `require` statements in this file unless they refer to built in modules. ###


module.exports = options =

  #.........................................................................................................
  texinputs:
    routes: [
      './node_modules/cxltx-styles/styles//'
      './tex-inputs//'
      ]

  #.........................................................................................................
  content:
    filename:       '.content.tex'
  #.........................................................................................................
  main:
    filename:       'main.md'
  #.........................................................................................................
  master:
    filename:       '.master.tex'
  #.........................................................................................................
  cache:
    # route:          './tmp/.cache.json'
    route:          './.cache.json'

  #.........................................................................................................
  'xelatex-command':          "bin/pdf-from-tex.sh"

  #.........................................................................................................
  defs:
    foobar:     "this variable has been set in `options`"

  #.........................................................................................................
  layout:
    lineheight: '5.26mm'

  #.........................................................................................................
  ### type may be `tex` or `text` ###
  entities:
    'nl':           { type: 'tex',  value: '\\\\', }                  ### new line ###
    'obr':          { type: 'tex',  value: '\\allowbreak{}', }        ### optional linebreak ###
    'amp':          { type: 'tex',  value: '\\&', }                   ### ampersand ###
    'np':           { type: 'tex',  value: '\\null\\newpage{}', }     ### new page ###
    # 'par':          { type: 'tex',  value: '\n\n', }                  ### paragraph break ###
    'thinspace':    { type: 'tex',  value: '\\thinspace{}', }         ### thin space ###
    'cspc':         { type: 'tex',  value: '\\cspc{}', }              ### thin constant space ###
    'ccspc':        { type: 'tex',  value: '\\ccspc{}', }             ### CJK constant space ###
    'hfill':        { type: 'tex',  value: '\\hfill{}', }             ### medium hfill ###
    '%':            { type: 'tex',  value: '%', }                     ### TeX comment ###
    'geta':         { type: 'text', value: '〓', }                    ### Geta mark ###
    'MKTS':         { type: 'tex',  value: 'MKTS', }                  ### MKTS logo ###
    'TeX':          { type: 'tex',  value: '\\TeX{}', }               ### TeX logo ###
    'LaTeX':        { type: 'tex',  value: '\\LaTeX{}', }             ### LaTeX logo ###
    'identical':    { type: 'tex',  value: '{\\mktsFontfileHanamina{}≡}', }
    'similar':      { type: 'tex',  value: '{\\mktsFontfileHanamina{}≋}', }
    'nbsp':         { type: 'tex',  value: '~', }                     ### Non-Breaking Space ###
    '~':            { type: 'tex',  value: '~', }                     ### Non-Breaking Space ###
    '~~':           { type: 'tex',  value: '~~', }                    ### 2 Non-Breaking Spaces ###
    '~~~~':         { type: 'tex',  value: '~~~~', }                  ### 4 Non-Breaking Spaces ###
    '~~~~~~':       { type: 'tex',  value: '~~~~~~', }                ### 6 Non-Breaking Spaces ###
    'lt':           { type: 'tex',  value: '<', }                     ### Left Pointy Bracket ###
    'gt':           { type: 'tex',  value: '>', }                     ### Right Pointy Bracket ###
    'bt':           { type: 'tex',  value: '`', }                     ### backtick ###
    '3lines':       { type: 'tex',  value: '{\\mktsFontfileHanamina{}☰}', }      ### 3 lines ###
    'deleatur':     { type: 'tex',  value: '{\\mktsFontfileSunexta{}₰}', }        ### Deleatur/Denarius ###
    # ⪧
    # Black right-pointing pointer: ►
    'ulsymbolr':    { type: 'tex', value: "\\makebox[\\mktsLineheight][r]{{\\mktsFontfileLmromantenregular{}•}}", }
    'ulsymbol':     { type: 'tex', value: "\\makebox[\\mktsLineheight][l]{{\\mktsFontfileLmromantenregular{}•}}", }
    # 'ulsymbolr':    { type: 'tex', value: "\\makebox[\\mktsLineheight][r]{{\\mktstfPushRaise{-0.2}{-0.1}\\mktsFontfileHanamina{}◼}}", }
    # 'ulsymbol':     { type: 'tex', value: "\\makebox[\\mktsLineheight][l]{{\\mktstfPushRaise{-0.2}{-0.1}\\mktsFontfileHanamina{}◼}}", }

    ### TAINT these are special-interest symbols that should be defined locally ###
    # 'Quasi':        { type: 'text', value: '𝕼', }
    # 'Clusters':     { type: 'text', value: '𝕮', }
    # 'Factors':      { type: 'text', value: '𝕱', }
    # 'Traits':       { type: 'text', value: '𝕿', }
    # 'repetitive':   { type: 'text', value: '𝖗', }
    # 'simplex':      { type: 'text', value: '𝖘', }
    # 'complex':      { type: 'text', value: '𝖝', }

    # 'Glyphs':       { type: 'text', value: '𝔾', }
    # 'Characters':   { type: 'text', value: 'ℤ', }
    # 'Quasi':        { type: 'text', value: 'ℚ', }
    # 'Clusters':     { type: 'text', value: 'ℂ', }
    # 'Factors':      { type: 'text', value: '𝔽', }
    # 'Aggregates':   { type: 'text', value: '𝔸', }
    # 'Traits':       { type: 'text', value: '𝕋', }
    # 'repetitive':   { type: 'text', value: '𝕣', }
    # 'simplex':      { type: 'text', value: '𝕤', }
    # 'complex':      { type: 'text', value: '𝕩', }

    'Glyphs':       { type: 'tex', value: '\\mktsWPillbox{G}', }
    'Characters':   { type: 'tex', value: '\\mktsWPillbox{Z}', }
    'Quasi':        { type: 'tex', value: '\\mktsWPillbox{Q}', }
    'Clusters':     { type: 'tex', value: '\\mktsWPillbox{C}', }
    'Factors':      { type: 'tex', value: '\\mktsWPillbox{F}', }
    'Aggregates':   { type: 'tex', value: '\\mktsWPillbox{A}', }
    'Traits':       { type: 'tex', value: '\\mktsWPillbox{T}', }
    'repetitive':   { type: 'tex', value: '\\mktsWPillbox{r}', }
    'simplex':      { type: 'tex', value: '\\mktsWPillbox{s}', }
    'complex':      { type: 'tex', value: '\\mktsWPillbox{x}', }
    'sC':           { type: 'tex', value: '\\mktsWPillbox{sC}', }
    'sA':           { type: 'tex', value: '\\mktsWPillbox{sA}', }
    'sT':           { type: 'tex', value: '\\mktsWPillbox{sT}', }
    'xC':           { type: 'tex', value: '\\mktsWPillbox{xC}', }
    'xA':           { type: 'tex', value: '\\mktsWPillbox{xA}', }
    'xT':           { type: 'tex', value: '\\mktsWPillbox{xT}', }
    'rC':           { type: 'tex', value: '\\mktsWPillbox{rC}', }
    'rA':           { type: 'tex', value: '\\mktsWPillbox{rA}', }
    'rT':           { type: 'tex', value: '\\mktsWPillbox{rT}', }
    #.......................................................................................................
    'readC':        { type: 'tex',  value: '\\mktsCWPillbox{C}', }
    'readK':        { type: 'tex',  value: '\\mktsCWPillbox{K}', }
    'readJ':        { type: 'tex',  value: '\\mktsCWPillbox{J}', }
    'readY':        { type: 'tex',  value: '\\mktsCWPillbox{Y}', }
    'readE':        { type: 'tex',  value: '\\mktsCWPillbox{E}', }
    # 'readC':        { type: 'tex',  value: '{\\mktstfRaise{-0.1}\\mktsFontfileSourcehansansbold{}Ⓒ}', }
    # 'readK':        { type: 'tex',  value: '{\\mktstfRaise{-0.1}\\mktsFontfileSourcehansansbold{}Ⓚ}', }
    # 'readJ':        { type: 'tex',  value: '{\\mktstfRaise{-0.1}\\mktsFontfileSourcehansansbold{}Ⓙ}', }
    # 'readY':        { type: 'tex',  value: '{\\mktstfRaise{-0.1}\\mktsFontfileSourcehansansbold{}Ⓨ}', }

  #.........................................................................................................
  newcommands:
    ### TAINT use relative routes ###
    ### TAINT `mktsPathsMktsHome` is duplicate from texinputs ###
    mktsPathsMktsHome:    './tex-inputs'
    mktsPathsFontsHome:   '../jizura-fonts/fonts'
    # \newcommand{\permille}{{\jzrFontOptima‰}}

  #.........................................................................................................
  fonts:

    #.......................................................................................................
    main: '\\mktsFontfileEbgaramondtwelveregular'
    # main: '\\mktsFontSunexta'
    home: '\\mktsPathsFontsHome'
    files: [
      # { texname: 'mktsFontfileJizurathreeb',                   filename: 'jizura3b-from-svg-rewritten-by-fontforge.ttf',                        }
      { texname: 'mktsFontfileBabelstonehan',                  filename: 'BabelStoneHan.ttf',                   }
      { texname: 'mktsFontfileBiaukai',                        filename: 'BiauKai.ttf',                         }
      { texname: 'mktsFontfileCwtexqfangsongmedium',           filename: 'cwTeXQFangsong-Medium.ttf',           }
      { texname: 'mktsFontfileCwtexqheibold',                  filename: 'cwTeXQHei-Bold.ttf',                  }
      { texname: 'mktsFontfileCwtexqkaimedium',                filename: 'cwTeXQKai-Medium.ttf',                }
      { texname: 'mktsFontfileCwtexqmingmedium',               filename: 'cwTeXQMing-Medium.ttf',               }
      { texname: 'mktsFontfileCwtexqyuanmedium',               filename: 'cwTeXQYuan-Medium.ttf',               }
      { texname: 'mktsFontfileDejavusans',                     filename: 'DejaVuSans.ttf',                      }
      { texname: 'mktsFontfileDejavusansbold',                 filename: 'DejaVuSans-Bold.ttf',                 }
      { texname: 'mktsFontfileDejavusansboldoblique',          filename: 'DejaVuSans-BoldOblique.ttf',          }
      { texname: 'mktsFontfileDejavusanscondensed',            filename: 'DejaVuSansCondensed.ttf',             }
      { texname: 'mktsFontfileDejavusanscondensedbold',        filename: 'DejaVuSansCondensed-Bold.ttf',        }
      { texname: 'mktsFontfileDejavusanscondensedboldoblique', filename: 'DejaVuSansCondensed-BoldOblique.ttf', }
      { texname: 'mktsFontfileDejavusanscondensedoblique',     filename: 'DejaVuSansCondensed-Oblique.ttf',     }
      { texname: 'mktsFontfileDejavusansmono',                 filename: 'DejaVuSansMono.ttf',                  }
      { texname: 'mktsFontfileDejavusansmonobold',             filename: 'DejaVuSansMono-Bold.ttf',             }
      { texname: 'mktsFontfileDejavusansmonoboldoblique',      filename: 'DejaVuSansMono-BoldOblique.ttf',      }
      { texname: 'mktsFontfileDejavusansmonooblique',          filename: 'DejaVuSansMono-Oblique.ttf',          }
      { texname: 'mktsFontfileDejavusansoblique',              filename: 'DejaVuSans-Oblique.ttf',              }
      { texname: 'mktsFontfileDejavuserif',                    filename: 'DejaVuSerif.ttf',                     }
      { texname: 'mktsFontfileDejavuserifbold',                filename: 'DejaVuSerif-Bold.ttf',                }
      { texname: 'mktsFontfileDejavuserifbolditalic',          filename: 'DejaVuSerif-BoldItalic.ttf',          }
      { texname: 'mktsFontfileDejavuserifcondensed',           filename: 'DejaVuSerifCondensed.ttf',            }
      { texname: 'mktsFontfileDejavuserifcondensedbold',       filename: 'DejaVuSerifCondensed-Bold.ttf',       }
      { texname: 'mktsFontfileDejavuserifcondensedbolditalic', filename: 'DejaVuSerifCondensed-BoldItalic.ttf', }
      { texname: 'mktsFontfileDejavuserifcondenseditalic',     filename: 'DejaVuSerifCondensed-Italic.ttf',     }
      { texname: 'mktsFontfileDejavuserifitalic',              filename: 'DejaVuSerif-Italic.ttf',              }
      { texname: 'mktsFontfileDroidsansfallbackfull',          filename: 'DroidSansFallbackFull.ttf',           }
      { texname: 'mktsFontfileDroidsansjapanese',              filename: 'DroidSansJapanese.ttf',               }
      { texname: 'mktsFontfileEbgaramondeightitalic',   otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond08-Italic.otf',             }
      # { texname: 'mktsFontfileEbgaramondeightregular',  otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond08-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondeightregular',  otf: 'Numbers={Monospaced,Lining}', filename: 'EBGaramond08-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondeightsc',       otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramondSC08-Regular.otf',          }
      { texname: 'mktsFontfileEbgaramondinitials',      otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond-Initials.otf',             }
      { texname: 'mktsFontfileEbgaramondinitialsfone',  otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond-InitialsF1.otf',           }
      { texname: 'mktsFontfileEbgaramondinitialsftwo',  otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond-InitialsF2.otf',           }
      { texname: 'mktsFontfileEbgaramondtwelveallsc',   otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond12-AllSC.otf',              }
      { texname: 'mktsFontfileEbgaramondtwelvesc',      otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramondSC12-Regular.otf',          }
      # { texname: 'mktsFontfileEbgaramondtwelveregular', otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveregular', otf: 'Numbers={Monospaced,Lining}', filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveregularScupper', otf: 'Letters={UppercaseSmallCaps},Numbers={Monospaced,Lining}',  filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveregularSclower', otf: 'Letters={SmallCaps},Numbers={Monospaced,Lining}', filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveregularScall',   otf: 'Letters={SmallCaps,UppercaseSmallCaps},Numbers={Monospaced,Lining}', filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveitalic',  otf: 'Numbers={Monospaced,Lining},Ligatures={Rare,Historic}', filename: 'EBGaramond12-Italic.otf',             }
      { texname: 'mktsFontfileEbgaramondtwelveitalicscupper', otf: 'Letters={UppercaseSmallCaps},Numbers={Monospaced,Lining}',  filename: 'EBGaramond12-Italic.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveitalicsclower', otf: 'Letters={SmallCaps},Numbers={Monospaced,Lining}', filename: 'EBGaramond12-Italic.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelveitalicscall',   otf: 'Letters={SmallCaps,UppercaseSmallCaps},Numbers={Monospaced,Lining}', filename: 'EBGaramond12-Italic.otf',            }
      { texname: 'mktsFontfileEpgyobld',                       filename: 'EPGYOBLD.TTF',                        }
      { texname: 'mktsFontfileEpgyosho',                       filename: 'EPGYOSHO.TTF',                        }
      { texname: 'mktsFontfileEpkaisho',                       filename: 'EPKAISHO.TTF',                        }
      { texname: 'mktsFontfileEpkgobld',                       filename: 'EPKGOBLD.TTF',                        }
      { texname: 'mktsFontfileEpkyouka',                       filename: 'EPKYOUKA.TTF',                        }
      { texname: 'mktsFontfileEpmarugo',                       filename: 'EPMARUGO.TTF',                        }
      { texname: 'mktsFontfileEpmgobld',                       filename: 'EPMGOBLD.TTF',                        }
      { texname: 'mktsFontfileEpminbld',                       filename: 'EPMINBLD.TTF',                        }
      { texname: 'mktsFontfileFandolfangregular',              filename: 'FandolFang-Regular.otf',              }
      { texname: 'mktsFontfileFandolheibold',                  filename: 'FandolHei-Bold.otf',                  }
      { texname: 'mktsFontfileFandolheiregular',               filename: 'FandolHei-Regular.otf',               }
      { texname: 'mktsFontfileFandolkairegular',               filename: 'FandolKai-Regular.otf',               }
      { texname: 'mktsFontfileFandolsongbold',                 filename: 'FandolSong-Bold.otf',                 }
      { texname: 'mktsFontfileFandolsongregular',              filename: 'FandolSong-Regular.otf',              }
      { texname: 'mktsFontfileFiracodebold',                   filename: 'FiraCode-Bold.otf',                   }
      { texname: 'mktsFontfileFiracodelight',                  filename: 'FiraCode-Light.otf',                  }
      { texname: 'mktsFontfileFiracodemedium',                 filename: 'FiraCode-Medium.otf',                 }
      { texname: 'mktsFontfileFiracoderegular',                filename: 'FiraCode-Regular.otf',                }
      { texname: 'mktsFontfileFiracoderetina',                 filename: 'FiraCode-Retina.otf',                 }
      { texname: 'mktsFontfileFlowdejavusansmono',             filename: 'FlowDejaVuSansMono.ttf',              }
      { texname: 'mktsFontfileFontsjapanesegothic',            filename: 'fonts-japanese-gothic.ttf',           }
      { texname: 'mktsFontfileFontsjapanesemincho',            filename: 'fonts-japanese-mincho.ttf',           }
      { texname: 'mktsFontfileHanamina',                       filename: 'HanaMinA.ttf',                        }
      { texname: 'mktsFontfileHanaminb',                       filename: 'HanaMinB.ttf',                        }
      { texname: 'mktsFontfileIpaexg',                         filename: 'ipaexg.ttf',                          }
      { texname: 'mktsFontfileIpaexm',                         filename: 'ipaexm.ttf',                          }
      { texname: 'mktsFontfileIpag',                           filename: 'ipag.ttf',                            }
      { texname: 'mktsFontfileIpagp',                          filename: 'ipagp.ttf',                           }
      { texname: 'mktsFontfileIpam',                           filename: 'ipam.ttf',                            }
      { texname: 'mktsFontfileIpamp',                          filename: 'ipamp.ttf',                           }
      { texname: 'mktsFontfileJizurathreeb',                   filename: 'jizura3b.ttf',                        }
      { texname: 'mktsFontfileJizurafourbmp',                  filename: 'jizura4bmp.ttf',                      }
      { texname: 'mktsFontfileKai',                            filename: 'Kai.ttf',                             }
      { texname: 'mktsFontfileMonoidbold',                     filename: 'Monoid-Bold.ttf',                     }
      { texname: 'mktsFontfileMonoiditalic',                   filename: 'Monoid-Italic.ttf',                   }
      { texname: 'mktsFontfileMonoidregular',                  filename: 'Monoid-Regular.ttf',                  }
      { texname: 'mktsFontfileMonoidretina',                   filename: 'Monoid-Retina.ttf',                   }
      { texname: 'mktsFontfileNanumgothic',                    filename: 'NanumGothic.ttc',                     }
      { texname: 'mktsFontfileNanummyeongjo',                  filename: 'NanumMyeongjo.ttc',                   }
      { texname: 'mktsFontfileOptima',                         filename: 'Optima.ttc',                          }
      { texname: 'mktsFontfilePtsans',                         filename: 'PTSans.ttc',                          }
      { texname: 'mktsFontfileSimsun',                         filename: 'simsun.ttc',                          }
      { texname: 'mktsFontfileSourcecodeproblack',             filename: 'SourceCodePro-Black.otf',             }
      { texname: 'mktsFontfileSourcecodeprobold',              filename: 'SourceCodePro-Bold.otf',              }
      { texname: 'mktsFontfileSourcecodeproextralight',        filename: 'SourceCodePro-ExtraLight.otf',        }
      { texname: 'mktsFontfileSourcecodeprolight',             filename: 'SourceCodePro-Light.otf',             }
      { texname: 'mktsFontfileSourcecodepromedium',            filename: 'SourceCodePro-Medium.otf',            }
      { texname: 'mktsFontfileSourcecodeproregular',           filename: 'SourceCodePro-Regular.otf',           }
      { texname: 'mktsFontfileSourcecodeprosemibold',          filename: 'SourceCodePro-Semibold.otf',          }
      { texname: 'mktsFontfileSourcehansansbold',              filename: 'SourceHanSans-Bold.ttc',              }
      { texname: 'mktsFontfileSourcehansansextralight',        filename: 'SourceHanSans-ExtraLight.ttc',        }
      { texname: 'mktsFontfileSourcehansansheavy',             filename: 'SourceHanSans-Heavy.ttc',             }
      { texname: 'mktsFontfileSourcehansanslight',             filename: 'SourceHanSans-Light.ttc',             }
      { texname: 'mktsFontfileSourcehansansmedium',            filename: 'SourceHanSans-Medium.ttc',            }
      { texname: 'mktsFontfileSourcehansansnormal',            filename: 'SourceHanSans-Normal.ttc',            }
      { texname: 'mktsFontfileSourcehansansregular',           filename: 'SourceHanSans-Regular.ttc',           }
      { texname: 'mktsFontfileSunexta',                        filename: 'sun-exta.ttf',                        }
      { texname: 'mktsFontfileSunextb',                        filename: 'Sun-ExtB.ttf',                        }
      { texname: 'mktsFontfileSunflowerucjkxb',                filename: 'sunflower-u-cjk-xb.ttf',              }
      { texname: 'mktsFontfileTakaopgothic',                   filename: 'TakaoPGothic.ttf',                    }
      { texname: 'mktsFontfileUbuntub',                        filename: 'Ubuntu-B.ttf',                        }
      { texname: 'mktsFontfileUbuntubi',                       filename: 'Ubuntu-BI.ttf',                       }
      { texname: 'mktsFontfileUbuntuc',                        filename: 'Ubuntu-C.ttf',                        }
      { texname: 'mktsFontfileUbuntul',                        filename: 'Ubuntu-L.ttf',                        }
      { texname: 'mktsFontfileUbuntuli',                       filename: 'Ubuntu-LI.ttf',                       }
      { texname: 'mktsFontfileUbuntumonob',                    filename: 'UbuntuMono-B.ttf',                    }
      { texname: 'mktsFontfileUbuntumonobi',                   filename: 'UbuntuMono-BI.ttf',                   }
      { texname: 'mktsFontfileUbuntumonor',                    filename: 'UbuntuMono-R.ttf',                    }
      { texname: 'mktsFontfileUbuntumonori',                   filename: 'UbuntuMono-RI.ttf',                   }
      { texname: 'mktsFontfileUbuntur',                        filename: 'Ubuntu-R.ttf',                        }
      { texname: 'mktsFontfileUbunturi',                       filename: 'Ubuntu-RI.ttf',                       }
      { texname: 'mktsFontfileUkai',                           filename: 'ukai.ttc',                            }
      { texname: 'mktsFontfileUming',                          filename: 'uming.ttc',                           }
      # { texname: 'mktsFontfileIosevkaslabbold',                subfolder: 'iosevska', filename: 'iosevka-slab-bold.ttf',              }
      # { texname: 'mktsFontfileIosevkaslabbolditalic',          subfolder: 'iosevska', filename: 'iosevka-slab-bolditalic.ttf',        }
      # { texname: 'mktsFontfileIosevkaslabboldoblique',         subfolder: 'iosevska', filename: 'iosevka-slab-boldoblique.ttf',       }
      # { texname: 'mktsFontfileIosevkaslabextralight',          subfolder: 'iosevska', filename: 'iosevka-slab-extralight.ttf',        }
      # { texname: 'mktsFontfileIosevkaslabextralightitalic',    subfolder: 'iosevska', filename: 'iosevka-slab-extralightitalic.ttf',  }
      # { texname: 'mktsFontfileIosevkaslabextralightoblique',   subfolder: 'iosevska', filename: 'iosevka-slab-extralightoblique.ttf', }
      # { texname: 'mktsFontfileIosevkaslabheavy',               subfolder: 'iosevska', filename: 'iosevka-slab-heavy.ttf',             }
      # { texname: 'mktsFontfileIosevkaslabheavyitalic',         subfolder: 'iosevska', filename: 'iosevka-slab-heavyitalic.ttf',       }
      # { texname: 'mktsFontfileIosevkaslabheavyoblique',        subfolder: 'iosevska', filename: 'iosevka-slab-heavyoblique.ttf',      }
      # { texname: 'mktsFontfileIosevkaslabitalic',              subfolder: 'iosevska', filename: 'iosevka-slab-italic.ttf',            }
      # { texname: 'mktsFontfileIosevkaslablight',               subfolder: 'iosevska', filename: 'iosevka-slab-light.ttf',             }
      # { texname: 'mktsFontfileIosevkaslablightitalic',         subfolder: 'iosevska', filename: 'iosevka-slab-lightitalic.ttf',       }
      # { texname: 'mktsFontfileIosevkaslablightoblique',        subfolder: 'iosevska', filename: 'iosevka-slab-lightoblique.ttf',      }
      # { texname: 'mktsFontfileIosevkaslabmedium',              subfolder: 'iosevska', filename: 'iosevka-slab-medium.ttf',            }
      # { texname: 'mktsFontfileIosevkaslabmediumitalic',        subfolder: 'iosevska', filename: 'iosevka-slab-mediumitalic.ttf',      }
      # { texname: 'mktsFontfileIosevkaslabmediumoblique',       subfolder: 'iosevska', filename: 'iosevka-slab-mediumoblique.ttf',     }
      # { texname: 'mktsFontfileIosevkaslaboblique',             subfolder: 'iosevska', filename: 'iosevka-slab-oblique.ttf',           }
      # { texname: 'mktsFontfileIosevkaslabregular',             subfolder: 'iosevska', filename: 'iosevka-slab-regular.ttf',           }
      # { texname: 'mktsFontfileIosevkaslabthin',                subfolder: 'iosevska', filename: 'iosevka-slab-thin.ttf',              }
      # { texname: 'mktsFontfileIosevkaslabthinitalic',          subfolder: 'iosevska', filename: 'iosevka-slab-thinitalic.ttf',        }

      # { texname: 'mktsFontfileIosevkafivebolditalic',                subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-bolditalic.ttf',              }
      # { texname: 'mktsFontfileIosevkafiveboldoblique',               subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-boldoblique.ttf',             }
      # { texname: 'mktsFontfileIosevkafivebold',                      subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-bold.ttf',                    }
      # { texname: 'mktsFontfileIosevkafiveextrabolditalic',           subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extrabolditalic.ttf',         }
      # { texname: 'mktsFontfileIosevkafiveextraboldoblique',          subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extraboldoblique.ttf',        }
      # { texname: 'mktsFontfileIosevkafiveextrabold',                 subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extrabold.ttf',               }
      # { texname: 'mktsFontfileIosevkafiveextralightitalic',          subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extralightitalic.ttf',        }
      # { texname: 'mktsFontfileIosevkafiveextralightoblique',         subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extralightoblique.ttf',       }
      # { texname: 'mktsFontfileIosevkafiveextralight',                subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-extralight.ttf',              }
      # { texname: 'mktsFontfileIosevkafiveheavyitalic',               subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-heavyitalic.ttf',             }
      # { texname: 'mktsFontfileIosevkafiveheavyoblique',              subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-heavyoblique.ttf',            }
      # { texname: 'mktsFontfileIosevkafiveheavy',                     subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-heavy.ttf',                   }
      # { texname: 'mktsFontfileIosevkafiveitalic',                    subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-italic.ttf',                  }
      # { texname: 'mktsFontfileIosevkafivelightitalic',               subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-lightitalic.ttf',             }
      # { texname: 'mktsFontfileIosevkafivelightoblique',              subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-lightoblique.ttf',            }
      # { texname: 'mktsFontfileIosevkafivelight',                     subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-light.ttf',                   }
      # { texname: 'mktsFontfileIosevkafivemediumitalic',              subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-mediumitalic.ttf',            }
      # { texname: 'mktsFontfileIosevkafivemediumoblique',             subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-mediumoblique.ttf',           }
      # { texname: 'mktsFontfileIosevkafivemedium',                    subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-medium.ttf',                  }
      # { texname: 'mktsFontfileIosevkafiveoblique',                   subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-oblique.ttf',                 }
      # { texname: 'mktsFontfileIosevkafiveregular',                   subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-regular.ttf',                 }
      # { texname: 'mktsFontfileIosevkafivesemibolditalic',            subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-semibolditalic.ttf',          }
      # { texname: 'mktsFontfileIosevkafivesemiboldoblique',           subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-semiboldoblique.ttf',         }
      # { texname: 'mktsFontfileIosevkafivesemibold',                  subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-semibold.ttf',                }
      # { texname: 'mktsFontfileIosevkafivethinitalic',                subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-thinitalic.ttf',              }
      # { texname: 'mktsFontfileIosevkafivethinoblique',               subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-thinoblique.ttf',             }
      # { texname: 'mktsFontfileIosevkafivethin',                      subfolder: 'iosevka-ss05', filename: 'iosevka-ss05-thin.ttf',                    }

      # { texname: 'mktsFontfileIosevkatypeslabmedium',       otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-type-slab-2.0.0', filename: 'iosevka-type-slab-medium.ttf',                  }
      # { texname: 'mktsFontfileIosevkatypeslabbold',         otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-type-slab-2.0.0', filename: 'iosevka-type-slab-bold.ttf',                  }

      { texname: 'mktsFontfileIosevkatermslabbolditalic',   otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-term-slab-2.0.0', filename: 'iosevka-term-slab-bolditalic.ttf',   }
      { texname: 'mktsFontfileIosevkatermslabbold',         otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-term-slab-2.0.0', filename: 'iosevka-term-slab-bold.ttf',         }
      { texname: 'mktsFontfileIosevkatermslabmediumitalic', otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-term-slab-2.0.0', filename: 'iosevka-term-slab-mediumitalic.ttf',  }
      { texname: 'mktsFontfileIosevkatermslabmedium',       otf: 'CharacterVariant={15,21,3,24,19,17,23,51,46,44,34}', subfolder: 'iosevka-term-slab-2.0.0', filename: 'iosevka-term-slab-medium.ttf',        }

      { texname: 'mktsFontfileFjallaoneregular',                subfolder: 'Fjalla_One',              filename: 'FjallaOne-Regular.ttf'               }
      { texname: 'mktsFontfileMerriweatherblack',               subfolder: 'Merriweather',            filename: 'Merriweather-Black.ttf'              }
      { texname: 'mktsFontfileMerriweatherblackitalic',         subfolder: 'Merriweather',            filename: 'Merriweather-BlackItalic.ttf'        }
      { texname: 'mktsFontfileMerriweatherbold',                subfolder: 'Merriweather',            filename: 'Merriweather-Bold.ttf'               }
      { texname: 'mktsFontfileMerriweatherbolditalic',          subfolder: 'Merriweather',            filename: 'Merriweather-BoldItalic.ttf'         }
      { texname: 'mktsFontfileMerriweatheritalic',              subfolder: 'Merriweather',            filename: 'Merriweather-Italic.ttf'             }
      { texname: 'mktsFontfileMerriweatherlight',               subfolder: 'Merriweather',            filename: 'Merriweather-Light.ttf'              }
      { texname: 'mktsFontfileMerriweatherlightitalic',         subfolder: 'Merriweather',            filename: 'Merriweather-LightItalic.ttf'        }
      { texname: 'mktsFontfileMerriweatherregular',             subfolder: 'Merriweather',            filename: 'Merriweather-Regular.ttf'            }
      { texname: 'mktsFontfileOswaldbold',                      subfolder: 'Oswald',                  filename: 'Oswald-Bold.ttf'                     }
      { texname: 'mktsFontfileOswaldlight',                     subfolder: 'Oswald',                  filename: 'Oswald-Light.ttf'                    }
      { texname: 'mktsFontfileOswaldregular',                   subfolder: 'Oswald',                  filename: 'Oswald-Regular.ttf'                  }
      { texname: 'mktsFontfileRobotoblack',                     subfolder: 'Roboto',                  filename: 'Roboto-Black.ttf'                    }
      { texname: 'mktsFontfileRobotoblackitalic',               subfolder: 'Roboto',                  filename: 'Roboto-BlackItalic.ttf'              }
      { texname: 'mktsFontfileRobotobold',                      subfolder: 'Roboto',                  filename: 'Roboto-Bold.ttf'                     }
      { texname: 'mktsFontfileRobotobolditalic',                subfolder: 'Roboto',                  filename: 'Roboto-BoldItalic.ttf'               }
      { texname: 'mktsFontfileRobotoitalic',                    subfolder: 'Roboto',                  filename: 'Roboto-Italic.ttf'                   }
      { texname: 'mktsFontfileRobotolight',                     subfolder: 'Roboto',                  filename: 'Roboto-Light.ttf'                    }
      { texname: 'mktsFontfileRobotolightitalic',               subfolder: 'Roboto',                  filename: 'Roboto-LightItalic.ttf'              }
      { texname: 'mktsFontfileRobotomedium',                    subfolder: 'Roboto',                  filename: 'Roboto-Medium.ttf'                   }
      { texname: 'mktsFontfileRobotomediumitalic',              subfolder: 'Roboto',                  filename: 'Roboto-MediumItalic.ttf'             }
      { texname: 'mktsFontfileRobotoregular',                   subfolder: 'Roboto',                  filename: 'Roboto-Regular.ttf'                  }
      { texname: 'mktsFontfileRobotothin',                      subfolder: 'Roboto',                  filename: 'Roboto-Thin.ttf'                     }
      { texname: 'mktsFontfileRobotothinitalic',                subfolder: 'Roboto',                  filename: 'Roboto-ThinItalic.ttf'               }
      { texname: 'mktsFontfileRobotocondensedbold',             subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-Bold.ttf'            }
      { texname: 'mktsFontfileRobotocondensedbolditalic',       subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-BoldItalic.ttf'      }
      { texname: 'mktsFontfileRobotocondenseditalic',           subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-Italic.ttf'          }
      { texname: 'mktsFontfileRobotocondensedlight',            subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-Light.ttf'           }
      { texname: 'mktsFontfileRobotocondensedlightitalic',      subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-LightItalic.ttf'     }
      { texname: 'mktsFontfileRobotocondensedregular',          subfolder: 'Roboto_Condensed',        filename: 'RobotoCondensed-Regular.ttf'         }
      { texname: 'mktsFontfileRobotoslabbold',                  subfolder: 'Roboto_Slab',             filename: 'RobotoSlab-Bold.ttf'                 }
      { texname: 'mktsFontfileRobotoslablight',                 subfolder: 'Roboto_Slab',             filename: 'RobotoSlab-Light.ttf'                }
      { texname: 'mktsFontfileRobotoslabregular',               subfolder: 'Roboto_Slab',             filename: 'RobotoSlab-Regular.ttf'              }
      { texname: 'mktsFontfileRobotoslabthin',                  subfolder: 'Roboto_Slab',             filename: 'RobotoSlab-Thin.ttf'                 }
      { texname: 'mktsFontfileSourcesansproblack',              subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Black.ttf'             }
      { texname: 'mktsFontfileSourcesansproblackitalic',        subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-BlackItalic.ttf'       }
      { texname: 'mktsFontfileSourcesansprobold',               subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Bold.ttf'              }
      { texname: 'mktsFontfileSourcesansprobolditalic',         subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-BoldItalic.ttf'        }
      { texname: 'mktsFontfileSourcesansproextralight',         subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-ExtraLight.ttf'        }
      { texname: 'mktsFontfileSourcesansproextralightitalic',   subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-ExtraLightItalic.ttf'  }
      { texname: 'mktsFontfileSourcesansproitalic',             subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Italic.ttf'            }
      { texname: 'mktsFontfileSourcesansprolight',              subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Light.ttf'             }
      { texname: 'mktsFontfileSourcesansprolightitalic',        subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-LightItalic.ttf'       }
      { texname: 'mktsFontfileSourcesansproregular',            subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Regular.ttf'           }
      { texname: 'mktsFontfileSourcesansprosemibold',           subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-Semibold.ttf'          }
      { texname: 'mktsFontfileSourcesansprosemibolditalic',     subfolder: 'Source_Sans_Pro',         filename: 'SourceSansPro-SemiboldItalic.ttf'    }
      { texname: 'mktsFontfileStintultracondensedregular',      subfolder: 'Stint_Ultra_Condensed',   filename: 'StintUltraCondensed-Regular.ttf'     }
      { texname: 'mktsFontfileYanonekaffeesatzbold',            subfolder: 'Yanone_Kaffeesatz',       filename: 'YanoneKaffeesatz-Bold.ttf'           }
      { texname: 'mktsFontfileYanonekaffeesatzextralight',      subfolder: 'Yanone_Kaffeesatz',       filename: 'YanoneKaffeesatz-ExtraLight.ttf'     }
      { texname: 'mktsFontfileYanonekaffeesatzlight',           subfolder: 'Yanone_Kaffeesatz',       filename: 'YanoneKaffeesatz-Light.ttf'          }
      { texname: 'mktsFontfileYanonekaffeesatzregular',         subfolder: 'Yanone_Kaffeesatz',       filename: 'YanoneKaffeesatz-Regular.ttf'        }
      { texname: 'mktsFontfilePermianslabseriftypeface',        subfolder: 'Permian_Slab',            filename: 'PermianSlabSerifTypeface.otf',        }
      { texname: 'mktsFontfilePermianslabseriftypefacebold',    subfolder: 'Permian_Slab',            filename: 'PermianSlabSerifTypeface-Bold.otf',   }
      { texname: 'mktsFontfilePermianslabseriftypefaceitalic',  subfolder: 'Permian_Slab',            filename: 'PermianSlabSerifTypeface-Italic.otf', }
      { texname: 'mktsFontfileBitterbold',                      subfolder: 'Bitter',                  filename: 'Bitter-Bold.otf',                     }
      { texname: 'mktsFontfileBitterbolditalic',                subfolder: 'Bitter',                  filename: 'Bitter-BoldItalic.otf',               }
      { texname: 'mktsFontfileBitteritalic',                    subfolder: 'Bitter',                  filename: 'Bitter-Italic.otf',                   }
      { texname: 'mktsFontfileBitterregular',                   subfolder: 'Bitter',                  filename: 'Bitter-Regular.otf',                  }
      { texname: 'mktsFontfileAleobold',                        subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-Bold.otf',        }
      { texname: 'mktsFontfileAleobolditalic',                  subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-BoldItalic.otf',  }
      { texname: 'mktsFontfileAleoitalic',                      subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-Italic.otf',      }
      { texname: 'mktsFontfileAleolight',                       subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-Light.otf',       }
      { texname: 'mktsFontfileAleolightitalic',                 subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-LightItalic.otf', }
      { texname: 'mktsFontfileAleoregular',                     subfolder: 'Aleo_font_v1.2.2/Desktop OTF', filename: 'Aleo-Regular.otf',     }

      { texname: 'mktsFontfileUnifrakturcook',                subfolder: 'unifraktur', filename: 'UnifrakturCook.ttf',        }
      { texname: 'mktsFontfileUnifrakturcooklight',           subfolder: 'unifraktur', filename: 'UnifrakturCook-Light.ttf',  }
      { texname: 'mktsFontfileUnifrakturmaguntia',            subfolder: 'unifraktur', filename: 'UnifrakturMaguntia.ttf',    }

      { texname: 'mktsFontfileGltsukijifivego',               subfolder: 'GL-Tsukiji-5go', filename: 'GL-Tsukiji-5go.ttf',    }

      { texname: 'mktsFontfileThtshynpzero',                  subfolder: 'TH-Tshyn', filename: 'TH-Tshyn-P0.ttf',    }
      { texname: 'mktsFontfileThtshynpone',                   subfolder: 'TH-Tshyn', filename: 'TH-Tshyn-P1.ttf',    }
      { texname: 'mktsFontfileThtshynptwo',                   subfolder: 'TH-Tshyn', filename: 'TH-Tshyn-P2.ttf',    }

      { texname: 'mktsFontfileNotoserifjpblack',              subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-Black.otf',    }
      { texname: 'mktsFontfileNotoserifjpbold',               subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-Bold.otf',    }
      { texname: 'mktsFontfileNotoserifjpextralight',         subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-ExtraLight.otf',    }
      { texname: 'mktsFontfileNotoserifjplight',              subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-Light.otf',    }
      { texname: 'mktsFontfileNotoserifjpmedium',             subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-Medium.otf',    }
      { texname: 'mktsFontfileNotoserifjpregular',            subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-Regular.otf',    }
      { texname: 'mktsFontfileNotoserifjpsemibold',           subfolder: 'NotoSerifJP', filename: 'NotoSerifJP-SemiBold.otf',    }

      { texname: 'mktsFontfileThkhaaitpzero',                 subfolder: 'TH-Khaai', filename: 'TH-Khaai-TP0.ttf', }
      { texname: 'mktsFontfileThkhaaitptwo',                  subfolder: 'TH-Khaai', filename: 'TH-Khaai-TP2.ttf', }

      { texname: 'mktsFontfileHminglanr',                     subfolder: 'MingLan', filename: 'H-MingLan-R.ttf', }
      { texname: 'mktsFontfileHminglanb',                     subfolder: 'MingLan', filename: 'H-MingLan-B.ttf', }

      { texname: 'mktsFontfileRkaisubold',                    filename: 'R-Kai-SUBold.ttf', }
      { texname: 'mktsFontfileRkantingliuwnine',              filename: 'R-KanTingLiu-W9.ttf', }

      { texname: 'mktsFontfileSushikii',                      subfolder: 'sushiki_ub',  filename: 'sushikii.ttf', }

      ### TAINT TTC fonts from the Sarasa series have several regional / usage variants, as seen in BabelMap, these should
                be selected and made available here ###
      { texname: 'mktsFontfileSarasabold',                    subfolder: 'sarasa-gothic-0.6.0', filename: 'sarasa-bold.ttc',        }
      { texname: 'mktsFontfileSarasabolditalic',              subfolder: 'sarasa-gothic-0.6.0', filename: 'sarasa-bolditalic.ttc',  }
      { texname: 'mktsFontfileSarasaitalic',                  subfolder: 'sarasa-gothic-0.6.0', filename: 'sarasa-italic.ttc',      }
      { texname: 'mktsFontfileSarasaregular',                 subfolder: 'sarasa-gothic-0.6.0', filename: 'sarasa-regular.ttc',     }

      { texname: 'mktsFontfileAsanamath',                                                       filename: 'Asana-Math.otf',         }

      # { texname: 'mktsFontfileLmmonotenitalic',               home: '', filename: 'lmmono10-italic.otf',            }
      # { texname: 'mktsFontfileLmmonotenregular',              home: '', filename: 'lmmono10-regular.otf',           }
      # { texname: 'mktsFontfileLmmonotwelveregular',           home: '', filename: 'lmmono12-regular.otf',           }
      # { texname: 'mktsFontfileLmmonoeightregular',            home: '', filename: 'lmmono8-regular.otf',            }
      # { texname: 'mktsFontfileLmmononineregular',             home: '', filename: 'lmmono9-regular.otf',            }
      # { texname: 'mktsFontfileLmmonocapstenoblique',          home: '', filename: 'lmmonocaps10-oblique.otf',       }
      # { texname: 'mktsFontfileLmmonocapstenregular',          home: '', filename: 'lmmonocaps10-regular.otf',       }
      # { texname: 'mktsFontfileLmmonolttenboldoblique',        home: '', filename: 'lmmonolt10-boldoblique.otf',     }
      # { texname: 'mktsFontfileLmmonolttenbold',               home: '', filename: 'lmmonolt10-bold.otf',            }
      # { texname: 'mktsFontfileLmmonolttenoblique',            home: '', filename: 'lmmonolt10-oblique.otf',         }
      # { texname: 'mktsFontfileLmmonolttenregular',            home: '', filename: 'lmmonolt10-regular.otf',         }
      # { texname: 'mktsFontfileLmmonoltcondtenoblique',        home: '', filename: 'lmmonoltcond10-oblique.otf',     }
      # { texname: 'mktsFontfileLmmonoltcondtenregular',        home: '', filename: 'lmmonoltcond10-regular.otf',     }
      # { texname: 'mktsFontfileLmmonoproptenoblique',          home: '', filename: 'lmmonoprop10-oblique.otf',       }
      # { texname: 'mktsFontfileLmmonoproptenregular',          home: '', filename: 'lmmonoprop10-regular.otf',       }
      # { texname: 'mktsFontfileLmmonoproplttenboldoblique',    home: '', filename: 'lmmonoproplt10-boldoblique.otf', }
      # { texname: 'mktsFontfileLmmonoproplttenbold',           home: '', filename: 'lmmonoproplt10-bold.otf',        }
      # { texname: 'mktsFontfileLmmonoproplttenoblique',        home: '', filename: 'lmmonoproplt10-oblique.otf',     }
      # { texname: 'mktsFontfileLmmonoproplttenregular',        home: '', filename: 'lmmonoproplt10-regular.otf',     }
      # { texname: 'mktsFontfileLmmonoslanttenregular',         home: '', filename: 'lmmonoslant10-regular.otf',      }
      # { texname: 'mktsFontfileLmromantenbolditalic',          home: '', filename: 'lmroman10-bolditalic.otf',       }
      # { texname: 'mktsFontfileLmromantenbold',                home: '', filename: 'lmroman10-bold.otf',             }
      { texname: 'mktsFontfileLmromantenitalic',              home: '', filename: 'lmroman10-italic.otf',           }
      { texname: 'mktsFontfileLmromantenregular',             home: '', filename: 'lmroman10-regular.otf',          }
      # { texname: 'mktsFontfileLmromantwelvebold',             home: '', filename: 'lmroman12-bold.otf',             }
      # { texname: 'mktsFontfileLmromantwelveitalic',           home: '', filename: 'lmroman12-italic.otf',           }
      # { texname: 'mktsFontfileLmromantwelveregular',          home: '', filename: 'lmroman12-regular.otf',          }
      # { texname: 'mktsFontfileLmromanseventeenregular',       home: '', filename: 'lmroman17-regular.otf',          }
      # { texname: 'mktsFontfileLmromanfivebold',               home: '', filename: 'lmroman5-bold.otf',              }
      # { texname: 'mktsFontfileLmromanfiveregular',            home: '', filename: 'lmroman5-regular.otf',           }
      # { texname: 'mktsFontfileLmromansixbold',                home: '', filename: 'lmroman6-bold.otf',              }
      # { texname: 'mktsFontfileLmromansixregular',             home: '', filename: 'lmroman6-regular.otf',           }
      # { texname: 'mktsFontfileLmromansevenbold',              home: '', filename: 'lmroman7-bold.otf',              }
      # { texname: 'mktsFontfileLmromansevenitalic',            home: '', filename: 'lmroman7-italic.otf',            }
      # { texname: 'mktsFontfileLmromansevenregular',           home: '', filename: 'lmroman7-regular.otf',           }
      # { texname: 'mktsFontfileLmromaneightbold',              home: '', filename: 'lmroman8-bold.otf',              }
      # { texname: 'mktsFontfileLmromaneightitalic',            home: '', filename: 'lmroman8-italic.otf',            }
      # { texname: 'mktsFontfileLmromaneightregular',           home: '', filename: 'lmroman8-regular.otf',           }
      # { texname: 'mktsFontfileLmromanninebold',               home: '', filename: 'lmroman9-bold.otf',              }
      # { texname: 'mktsFontfileLmromannineitalic',             home: '', filename: 'lmroman9-italic.otf',            }
      # { texname: 'mktsFontfileLmromannineregular',            home: '', filename: 'lmroman9-regular.otf',           }
      # { texname: 'mktsFontfileLmromancapstenoblique',         home: '', filename: 'lmromancaps10-oblique.otf',      }
      # { texname: 'mktsFontfileLmromancapstenregular',         home: '', filename: 'lmromancaps10-regular.otf',      }
      # { texname: 'mktsFontfileLmromandemitenoblique',         home: '', filename: 'lmromandemi10-oblique.otf',      }
      # { texname: 'mktsFontfileLmromandemitenregular',         home: '', filename: 'lmromandemi10-regular.otf',      }
      # { texname: 'mktsFontfileLmromandunhtenoblique',         home: '', filename: 'lmromandunh10-oblique.otf',      }
      # { texname: 'mktsFontfileLmromandunhtenregular',         home: '', filename: 'lmromandunh10-regular.otf',      }
      # { texname: 'mktsFontfileLmromanslanttenbold',           home: '', filename: 'lmromanslant10-bold.otf',        }
      # { texname: 'mktsFontfileLmromanslanttenregular',        home: '', filename: 'lmromanslant10-regular.otf',     }
      # { texname: 'mktsFontfileLmromanslanttwelveregular',     home: '', filename: 'lmromanslant12-regular.otf',     }
      # { texname: 'mktsFontfileLmromanslantseventeenregular',  home: '', filename: 'lmromanslant17-regular.otf',     }
      # { texname: 'mktsFontfileLmromanslanteightregular',      home: '', filename: 'lmromanslant8-regular.otf',      }
      # { texname: 'mktsFontfileLmromanslantnineregular',       home: '', filename: 'lmromanslant9-regular.otf',      }
      # { texname: 'mktsFontfileLmromanunsltenregular',         home: '', filename: 'lmromanunsl10-regular.otf',      }
      # { texname: 'mktsFontfileLmsanstenboldoblique',          home: '', filename: 'lmsans10-boldoblique.otf',       }
      # { texname: 'mktsFontfileLmsanstenbold',                 home: '', filename: 'lmsans10-bold.otf',              }
      # { texname: 'mktsFontfileLmsanstenoblique',              home: '', filename: 'lmsans10-oblique.otf',           }
      # { texname: 'mktsFontfileLmsanstenregular',              home: '', filename: 'lmsans10-regular.otf',           }
      # { texname: 'mktsFontfileLmsanstwelveoblique',           home: '', filename: 'lmsans12-oblique.otf',           }
      # { texname: 'mktsFontfileLmsanstwelveregular',           home: '', filename: 'lmsans12-regular.otf',           }
      # { texname: 'mktsFontfileLmsansseventeenoblique',        home: '', filename: 'lmsans17-oblique.otf',           }
      # { texname: 'mktsFontfileLmsansseventeenregular',        home: '', filename: 'lmsans17-regular.otf',           }
      # { texname: 'mktsFontfileLmsanseightoblique',            home: '', filename: 'lmsans8-oblique.otf',            }
      # { texname: 'mktsFontfileLmsanseightregular',            home: '', filename: 'lmsans8-regular.otf',            }
      # { texname: 'mktsFontfileLmsansnineoblique',             home: '', filename: 'lmsans9-oblique.otf',            }
      # { texname: 'mktsFontfileLmsansnineregular',             home: '', filename: 'lmsans9-regular.otf',            }
      # { texname: 'mktsFontfileLmsansdemicondtenoblique',      home: '', filename: 'lmsansdemicond10-oblique.otf',   }
      # { texname: 'mktsFontfileLmsansdemicondtenregular',      home: '', filename: 'lmsansdemicond10-regular.otf',   }
      # { texname: 'mktsFontfileLmsansquoteightboldoblique',    home: '', filename: 'lmsansquot8-boldoblique.otf',    }
      # { texname: 'mktsFontfileLmsansquoteightbold',           home: '', filename: 'lmsansquot8-bold.otf',           }
      # { texname: 'mktsFontfileLmsansquoteightoblique',        home: '', filename: 'lmsansquot8-oblique.otf',        }
      # { texname: 'mktsFontfileLmsansquoteightregular',        home: '', filename: 'lmsansquot8-regular.otf',        }



      ]


  #.........................................................................................................
  styles:
    mktsStyleTitleChapter: """
      \\Huge%
      \\mktsFontfileUbuntub%
      \\protect\\renewcommand{\\cn}[1]{{\\adjustCjkIdeograph{\\mktsFontfileCwtexqheibold{}##1}}}%"""
    mktsStyleTitleSection: """
      \\mktsFontfileUbuntub%
      \\protect\\renewcommand{\\cn}[1]{{\\adjustCjkIdeograph{\\mktsFontfileCwtexqheibold{}##1}}}%"""
  #.........................................................................................................
  'tex':
    'ignore-latin':             yes
    #.......................................................................................................
    'tex-command-by-rsgs':
      'u-latn':                 'latin'
      'u-latn-a':               'latin'
      'u-latn-b':               'latin'
      'u-latn-1':               'latin'
      'u-punct':                'latin'
      'u-grek':                 'latin'
      'u-cdm':                  'latin' # combining diacritical marks
      'u-cyrl':                 'latin'
      'u-cyrl-s':               'latin'
      'u-cjk':                  'cn'
      'u-halfull':              'cn'
      'u-cjk-enclett':          'cn'
      'u-dingb':                'cn'
      'u-cjk-xa':               'cnxa'
      'u-cjk-xb':               'cnxb'
      'u-cjk-xc':               'cnxc'
      'u-cjk-xd':               'cnxd'

      ### NOTE in anticipation of upcoming version where all codepoins will get simply
      annotated with their RSGs, which in turn are LaTeX commands: ###
      'u-cjk-cmp':              'cnUcjkcmp'       ### CJK Compatibility                       ###
      'u-cjk-cmpf':             'cnUcjkcmpf'      ### CJK Compatibility Forms                 ###
      'u-cjk-cmpi1':            'cnUcjkcmpione'   ### CJK Compatibility Ideographs            ###
      'u-cjk-cmpi2':            'cnUcjkcmpitwo'   ### CJK Compatibility Ideographs Supplement ###

      # 'u-cjk-cmp':              'cncone'
      # 'u-cjk-cmpi1':            'cncone'
      # 'u-cjk-cmpi2':            'cnctwo'
      'u-cjk-rad1':             'cnrone'
      'u-cjk-rad2':             'cnrtwo'
      'u-cjk-sym':              'cnsym'
      'u-cjk-strk':             'cnstrk'
      'u-pua':                  'cnjzr'
      'jzr-fig':                'cnjzr'
      'u-cjk-kata':             'ka'
      'u-cjk-hira':             'hi'
      'u-hang-syl':             'hg'
      'u-cjk-encsupp':          'cnencsupp'
      #.....................................................................................................
      'fallback':               'mktsRsgFb' ### Fallback Font ###
    #.......................................................................................................
    ### LIST of Unicode Range Sigils that contain codepoints to be treated as CJK characters: ###
    'cjk-rsgs': [
      'u-cjk'
      'u-halfull'
      # 'u-dingb'
      'u-cjk-xa'
      'u-cjk-xb'
      'u-cjk-xc'
      'u-cjk-xd'
      'u-cjk-xe'
      'u-cjk-xf'
      'u-cjk-cmpi1'
      'u-cjk-cmpi2'
      'u-cjk-rad1'
      'u-cjk-rad2'
      'u-cjk-sym'
      'u-cjk-strk'
      'u-pua'
      'jzr-fig'
      'u-cjk-kata'
      'u-cjk-hira'
      'u-hang-syl'
      'u-cjk-enclett'
      'u-cjk-encsupp'
      ]
    #.......................................................................................................
    # fallback_glyph: { glyph: '▉', cmd: 'cnxBabel', }
    fallback_glyph: { glyph: '▉', cmd: 'cn', }
    #.......................................................................................................
    'glyph-styles':
      ### Other stuff: ###
      # '‰':          '{\\mktsFontfileOptima‰}'
      '·':                                cmd: 'mktsFontfileEbgaramondtwelveregular' # U+00B7 MIDDLE DOT
      # '↕':      raise: -0.2,   cmd: 'cnxJzr',      glyph: ''
      ### ASCII Art / Box Drawing: ###
      '─':      cmd: 'mktsStyleBoxDrawing'
      '│':      cmd: 'mktsStyleBoxDrawing'
      '└':      cmd: 'mktsStyleBoxDrawing'
      '├':      cmd: 'mktsStyleBoxDrawing'
      '═':      cmd: 'mktsStyleBoxDrawing'
      '║':      cmd: 'mktsStyleBoxDrawing'
      '╔':      cmd: 'mktsStyleBoxDrawing'
      '╗':      cmd: 'mktsStyleBoxDrawing'
      '╚':      cmd: 'mktsStyleBoxDrawing'
      '╝':      cmd: 'mktsStyleBoxDrawing'
      '╠':      cmd: 'mktsStyleBoxDrawing'
      '╣':      cmd: 'mktsStyleBoxDrawing'
      '╤':      cmd: 'mktsStyleBoxDrawing'
      '╧':      cmd: 'mktsStyleBoxDrawing'
      '╪':      cmd: 'mktsStyleBoxDrawing'
      ### Arrows ###
      '⤾':      cmd: 'mktsFontfileDejavuserif'
      '₰':      cmd: 'mktsFontfileSunexta'

      ### Ideographic description characters: ###
      '↻':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '↔':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '↕':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '●':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '◰':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '≈':         cmd: 'cnxJzr',      glyph: ''       # raise: -0.2,
      '﹋':         cmd: 'cnxBabel',   push: -0.35             # raise: -0.2,
      # '⿰':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿱':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿺':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿸':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿹':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿶':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿷':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿵':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿴':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,
      # '⿻':        cmd: 'cnxJzr',      glyph: ''      # raise: -0.2,

      ### 'Late Additions' in upper part of CJK unified ideographs (Unicode v5.2); glyphs are missing
        from Sun-ExtA but are included in BabelstoneHan: ###
      '龺':                                cmd: 'cnxBabel'
      '龻':                                cmd: 'cnxBabel'
      '龼':                                cmd: 'cnxBabel'
      '龽':                                cmd: 'cnxBabel'
      '龾':                                cmd: 'cnxBabel'
      '龿':                                cmd: 'cnxBabel'
      '鿀':                                cmd: 'cnxBabel'
      '鿁':                                cmd: 'cnxBabel'
      '鿂':                                cmd: 'cnxBabel'
      '鿃':                                cmd: 'cnxBabel'
      '鿄':                                cmd: 'cnxBabel'
      '鿅':                                cmd: 'cnxBabel'
      '鿆':                                cmd: 'cnxBabel'
      '鿇':                                cmd: 'cnxBabel'
      '鿈':                                cmd: 'cnxBabel'
      '鿉':                                cmd: 'cnxBabel'
      '鿊':                                cmd: 'cnxBabel'
      '鿋':                                cmd: 'cnxBabel'
      '鿌':                                cmd: 'cnxBabel'
      #.....................................................................................................
      ### This glyph is damaged in Sun-ExtA; it happens to be included in HanaMinA: ###
      '䗍':                                cmd: 'cnxHanaA'

      #.....................................................................................................
      '🈻':                                cmd: 'mktsFontfileThtshynpone'
      '🉠':                                cmd: 'mktsStyleCjkRoundSymbol{🉠}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      '🉡':                                cmd: 'mktsStyleCjkRoundSymbol{🉡}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      '🉢':                                cmd: 'mktsStyleCjkRoundSymbol{🉢}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      '🉣':                                cmd: 'mktsStyleCjkRoundSymbol{🉣}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      '🉤':                                cmd: 'mktsStyleCjkRoundSymbol{🉤}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      '🉥':                                cmd: 'mktsStyleCjkRoundSymbol{🉥}', glyph: '' ### TAINT dirty trick, update configuration syntax ###
      #.....................................................................................................
      ### Ideographic Space: ###
      # '&#x3000;':                         cmd: 'cnjzr',       glyph: ''

      #.....................................................................................................
      '▷':                                cmd: 'mktsFontfileCwtexqheibold'

      #.....................................................................................................
      ### Ideographic Punctuation, Fullwidth Forms: ###
      '《':             raise: -0.2
      '》':             raise: -0.2
      '《':                                cmd: 'mktsFontfileNanummyeongjo'
      '》':                                cmd: 'mktsFontfileNanummyeongjo'
      '【':                                cmd: 'mktsFontfileNanummyeongjo'
      '】':                                cmd: 'mktsFontfileNanummyeongjo'
      '。':  push: 0.5, raise: 0.25,       cmd: 'cn'
      '、':  push: 0.5, raise: 0.25,       cmd: 'cn'
      '，':  push: 0.5, raise: 0.25,       cmd: 'cn'
      '．':  null
      '：':  push: 0.5, raise: 0.25,       cmd: 'cn'
      '；':  null
      '！':  null
      '？':  null
      '＂':  null
      '＇':  null
      '｀':  null
      '＾':  null
      '～':  null
      '￣':  null
      '＿':  null
      '＆':  null
      '＠':  null
      '＃':  null
      '％':  null
      '＋':  null
      '－':  null
      '＊':  null
      '＝':  null
      '＜':  null
      '＞':  null
      '（':  push: -0.25
      '）':  push:  0.25
      '［':  null
      '］':  null
      '｛':  null
      '｝':  null
      '｟':  null
      '｠':  null
      '｜':  null
      '￤':  null
      '／':  null
      '＼':  null
      '￢':  null
      '＄':  null
      '￡':  null
      '￠':  null
      '￦':  null
      '￥':  null

      #.....................................................................................................
      '囗':                                cmd: 'cnjzr',       glyph: ''
      # '扌':  push: 0.5
      '扌':  push: 0.05
      '亻':  push: 0.6
      '釒':  push: 0.5
      '钅':  push: 0.4
      '冫':  push: 0.55
      '牜':  push: 0.5
      '飠':  push: 0.4
      '犭':  push: 0.3
      '忄':  push: 0.5
      '礻':  push: 0.3
      '衤':  push: 0.2
      '讠':  push: 0.5
      '𧾷':  push: 0.5,                    cmd: 'cnxb'
      '卩':  push: -0.4
      '':  push: 0.5, raise: -0.2
      '糹':  push: 0.4
      '纟':  push: 0.4
      '阝':  push: 0.6
      '𩰊':  push: -0.25,                  cmd: 'cnxb'
      '𩰋':  push: 0.25,                   cmd: 'cnxb'
      '彳':  push: 0.15
      '灬':             raise: 0.4
      '爫':             raise: -0.125
      '覀':             raise: -0.0
      '癶':             raise: -0.2,       cmd: 'cnxBabel'
      '':             raise: 0.1,        cmd: 'cnxJzr'
      '乛':             raise: -0.25
      '龸':             raise: -0.15
      '䒑':             raise: -0.1,      cmd: 'cnxa'
      '宀':             raise: -0.2
      '𥫗':             raise: -0.2,       cmd: 'cnxb'
      '罓':             raise: -0.2
      '龵':             raise: -0.1,       cmd: 'cnxBabel'
      '龹':             raise: -0.12
      '〇':             raise: -0.05,      cmd: 'cnxBabel'
      # '⺍':                                cmd: 'cnjzr',       glyph: ''
      #.....................................................................................................
      ### Glyphs represented by other codepoints and/or with other than the standard fonts: ###
      # '⺊':                                cmd: 'cnxHanaA'
      # '⺑':                                cmd: 'cnxHanaA'
      # '⺕':                                cmd: 'cnxHanaA'
      # '⺴':                                cmd: 'cnxHanaA'
      # '⺿':                                cmd: 'cnxHanaA'
      # '〆':                                cmd: 'cnxHanaA'
      # '〻':                                cmd: 'cnxHanaA'
      # '㇀':                                cmd: 'cnxHanaA'
      # '㇊':                                cmd: 'cnxHanaA'
      # '㇎':                                cmd: 'cnxHanaA'
      # '㇏':                                cmd: 'cnxHanaA'
      # '丷':                                cmd: 'cnxHanaA'
      # '饣':                                cmd: 'cnxHanaA'
      # '⺀':                                cmd: 'cnxHanaA'
      '⺀':                                cmd: 'cnxHanaA'
      '⺄':                                cmd: 'cnxHanaA'
      '⺆':                                cmd: 'cnxBabel'
      '⺌':                                cmd: 'cnxHanaA'
      # '⺍':                                cmd: 'cnxHanaA'
      '⺍':                                cmd: 'cnxHanaA'
      '⺗':                                cmd: 'cnxHanaA'
      # '⺝':                                cmd: 'cnxBabel'
      '⺝':                                cmd: 'cnxHanaA'
      '⺥':                                cmd: 'cnxHanaA'
      '⺳':                                cmd: 'cnxHanaA'
      '⺶':                                cmd: 'cnxUming'
      '⺻':                                cmd: 'cnxHanaA'
      '⺼':                                cmd: 'cnxBabel'
      # '〓':                                cmd: 'cnxBabel'
      '〓':                                cmd: 'cnxBabel'
      '〢':                                cmd: 'cnxSunXA'
      '〣':                                cmd: 'cnxSunXA'
      # '〥':                                cmd: 'cnxBabel'
      '〥':                                cmd: 'cnxSunXA'
      '〧':                                cmd: 'cnxBabel'
      '〨':                                cmd: 'cnxBabel'
      '〽':                                cmd: 'cnxSunXA'
      '㇁':                                cmd: 'cnxBabel'
      '㇂':                                cmd: 'cnxHanaA'
      '㇃':                                cmd: 'cnxBabel'
      '㇄':                                cmd: 'cnxBabel'
      '㇅':                                cmd: 'cnxBabel'
      '㇈':                                cmd: 'cnxBabel'
      '㇉':                                cmd: 'cnxHanaA'
      '㇋':                                cmd: 'cnxBabel'
      '㇌':                                cmd: 'cnxHanaA'
      '㇢':                                cmd: 'cnxHanaA'
      '㓁':                                cmd: 'cnxBabel'
      '冖':                                cmd: 'cnxHanaA'
      '刂':                                cmd: 'cnxHanaA'
      '氵':                                cmd: 'cnxHanaA'
      '罒':                                cmd: 'cnxHanaA'
      '龴':                                cmd: 'cnxHanaA'
      '𠂉':                                cmd: 'cnxHanaA'
      '帯':                                cmd: 'cnxHanaA'
      '齒':                                cmd: 'cnxBabel'
      '龰':                                cmd: 'cnxBabel'
      '𤴔':                                cmd: 'cnxBabel'
      '㐃':                                cmd: 'cnxBabel'
      '𠚜':                                cmd: 'cnxHanaB'
      '𠚡':                                cmd: 'cnxHanaB'
      '𠥧':                                cmd: 'cnxHanaB'
      '𠥩':                                cmd: 'cnxHanaB'
      '𠥪':                                cmd: 'cnxHanaB'
      '𠥫':                                cmd: 'cnxHanaB'
      '𠥬':                                cmd: 'cnxHanaB'
      '𧀍':                                cmd: 'cnxHanaB'
      '覀':                                cmd: 'cnxJzr',      glyph: ''
      '⻗':                                cmd: 'cnxJzr',      glyph: ''
      '𡗗':                   raise: -0.1, cmd: 'cnxHanaA',    glyph: '𡗗'
      '丿':                                cmd: 'cnxJzr',      glyph: ''
      '𠥓':                                cmd: 'cnxJzr',      glyph: ''
      '龷':                                cmd: 'cnxJzr',      glyph: ''
      '龶':                                cmd: 'cnxJzr',      glyph: ''

      'ℼ':                                cmd: 'mktsFontfileAsanamath'
      'ℽ':                                cmd: 'mktsFontfileAsanamath'
      'ℾ':                                cmd: 'mktsFontfileAsanamath'
      'ℿ':                                cmd: 'mktsFontfileAsanamath'
      '⅀':                                cmd: 'mktsFontfileAsanamath'
      'ⅅ':                                cmd: 'mktsFontfileAsanamath'
      'ⅆ':                                cmd: 'mktsFontfileAsanamath'
      'ⅇ':                                cmd: 'mktsFontfileAsanamath'
      'ⅈ':                                cmd: 'mktsFontfileAsanamath'
      'ⅉ':                                cmd: 'mktsFontfileAsanamath'
      '𝔸':                                cmd: 'mktsFontfileAsanamath'
      '𝔹':                                cmd: 'mktsFontfileAsanamath'
      'ℂ':                                cmd: 'mktsFontfileAsanamath'
      '𝔻':                                cmd: 'mktsFontfileAsanamath'
      '𝔼':                                cmd: 'mktsFontfileAsanamath'
      '𝔽':                                cmd: 'mktsFontfileAsanamath'
      '𝔾':                                cmd: 'mktsFontfileAsanamath'
      'ℍ':                                cmd: 'mktsFontfileAsanamath'
      '𝕀':                                cmd: 'mktsFontfileAsanamath'
      '𝕁':                                cmd: 'mktsFontfileAsanamath'
      '𝕂':                                cmd: 'mktsFontfileAsanamath'
      '𝕃':                                cmd: 'mktsFontfileAsanamath'
      '𝕄':                                cmd: 'mktsFontfileAsanamath'
      'ℕ':                                cmd: 'mktsFontfileAsanamath'
      '𝕆':                                cmd: 'mktsFontfileAsanamath'
      'ℙ':                                cmd: 'mktsFontfileAsanamath'
      'ℚ':                                cmd: 'mktsFontfileAsanamath'
      'ℝ':                                cmd: 'mktsFontfileAsanamath'
      '𝕊':                                cmd: 'mktsFontfileAsanamath'
      '𝕋':                                cmd: 'mktsFontfileAsanamath'
      '𝕌':                                cmd: 'mktsFontfileAsanamath'
      '𝕍':                                cmd: 'mktsFontfileAsanamath'
      '𝕎':                                cmd: 'mktsFontfileAsanamath'
      '𝕏':                                cmd: 'mktsFontfileAsanamath'
      '𝕐':                                cmd: 'mktsFontfileAsanamath'
      'ℤ':                                cmd: 'mktsFontfileAsanamath'
      '𝕒':                                cmd: 'mktsFontfileAsanamath'
      '𝕓':                                cmd: 'mktsFontfileAsanamath'
      '𝕔':                                cmd: 'mktsFontfileAsanamath'
      '𝕕':                                cmd: 'mktsFontfileAsanamath'
      '𝕖':                                cmd: 'mktsFontfileAsanamath'
      '𝕗':                                cmd: 'mktsFontfileAsanamath'
      '𝕘':                                cmd: 'mktsFontfileAsanamath'
      '𝕙':                                cmd: 'mktsFontfileAsanamath'
      '𝕚':                                cmd: 'mktsFontfileAsanamath'
      '𝕛':                                cmd: 'mktsFontfileAsanamath'
      '𝕜':                                cmd: 'mktsFontfileAsanamath'
      '𝕝':                                cmd: 'mktsFontfileAsanamath'
      '𝕞':                                cmd: 'mktsFontfileAsanamath'
      '𝕟':                                cmd: 'mktsFontfileAsanamath'
      '𝕠':                                cmd: 'mktsFontfileAsanamath'
      '𝕡':                                cmd: 'mktsFontfileAsanamath'
      '𝕢':                                cmd: 'mktsFontfileAsanamath'
      '𝕣':                                cmd: 'mktsFontfileAsanamath'
      '𝕤':                                cmd: 'mktsFontfileAsanamath'
      '𝕥':                                cmd: 'mktsFontfileAsanamath'
      '𝕦':                                cmd: 'mktsFontfileAsanamath'
      '𝕧':                                cmd: 'mktsFontfileAsanamath'
      '𝕨':                                cmd: 'mktsFontfileAsanamath'
      '𝕩':                                cmd: 'mktsFontfileAsanamath'
      '𝕪':                                cmd: 'mktsFontfileAsanamath'
      '𝕫':                                cmd: 'mktsFontfileAsanamath'
      '𝕬':                                cmd: 'mktsFontfileAsanamath'
      '𝕭':                                cmd: 'mktsFontfileAsanamath'
      '𝕮':                                cmd: 'mktsFontfileAsanamath'
      '𝕯':                                cmd: 'mktsFontfileAsanamath'
      '𝕰':                                cmd: 'mktsFontfileAsanamath'
      '𝕱':                                cmd: 'mktsFontfileAsanamath'
      '𝕲':                                cmd: 'mktsFontfileAsanamath'
      '𝕳':                                cmd: 'mktsFontfileAsanamath'
      '𝕴':                                cmd: 'mktsFontfileAsanamath'
      '𝕵':                                cmd: 'mktsFontfileAsanamath'
      '𝕶':                                cmd: 'mktsFontfileAsanamath'
      '𝕷':                                cmd: 'mktsFontfileAsanamath'
      '𝕸':                                cmd: 'mktsFontfileAsanamath'
      '𝕹':                                cmd: 'mktsFontfileAsanamath'
      '𝕺':                                cmd: 'mktsFontfileAsanamath'
      '𝕻':                                cmd: 'mktsFontfileAsanamath'
      '𝕼':                                cmd: 'mktsFontfileAsanamath'
      '𝕽':                                cmd: 'mktsFontfileAsanamath'
      '𝕾':                                cmd: 'mktsFontfileAsanamath'
      '𝕿':                                cmd: 'mktsFontfileAsanamath'
      '𝖀':                                cmd: 'mktsFontfileAsanamath'
      '𝖁':                                cmd: 'mktsFontfileAsanamath'
      '𝖂':                                cmd: 'mktsFontfileAsanamath'
      '𝖃':                                cmd: 'mktsFontfileAsanamath'
      '𝖄':                                cmd: 'mktsFontfileAsanamath'
      '𝖅':                                cmd: 'mktsFontfileAsanamath'
      '𝖆':                                cmd: 'mktsFontfileAsanamath'
      '𝖇':                                cmd: 'mktsFontfileAsanamath'
      '𝖈':                                cmd: 'mktsFontfileAsanamath'
      '𝖉':                                cmd: 'mktsFontfileAsanamath'
      '𝖊':                                cmd: 'mktsFontfileAsanamath'
      '𝖋':                                cmd: 'mktsFontfileAsanamath'
      '𝖌':                                cmd: 'mktsFontfileAsanamath'
      '𝖍':                                cmd: 'mktsFontfileAsanamath'
      '𝖎':                                cmd: 'mktsFontfileAsanamath'
      '𝖏':                                cmd: 'mktsFontfileAsanamath'
      '𝖐':                                cmd: 'mktsFontfileAsanamath'
      '𝖑':                                cmd: 'mktsFontfileAsanamath'
      '𝖒':                                cmd: 'mktsFontfileAsanamath'
      '𝖓':                                cmd: 'mktsFontfileAsanamath'
      '𝖔':                                cmd: 'mktsFontfileAsanamath'
      '𝖕':                                cmd: 'mktsFontfileAsanamath'
      '𝖖':                                cmd: 'mktsFontfileAsanamath'
      '𝖗':                                cmd: 'mktsFontfileAsanamath'
      '𝖘':                                cmd: 'mktsFontfileAsanamath'
      '𝖙':                                cmd: 'mktsFontfileAsanamath'
      '𝖚':                                cmd: 'mktsFontfileAsanamath'
      '𝖛':                                cmd: 'mktsFontfileAsanamath'
      '𝖜':                                cmd: 'mktsFontfileAsanamath'
      '𝖝':                                cmd: 'mktsFontfileAsanamath'
      '𝖞':                                cmd: 'mktsFontfileAsanamath'
      '𝖟':                                cmd: 'mktsFontfileAsanamath'



