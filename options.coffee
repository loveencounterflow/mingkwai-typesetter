

### Hint: do not use `require` statements in this file unless they refer to built in modules. ###


module.exports = options =

  #.........................................................................................................
  texinputs:
    routes: [
      './node_modules/cxltx-styles/styles//'
      './tex-inputs'
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
    foobar:   "this variable has been set in `options`"

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
      { texname: 'mktsFontfileBabelstonehan',                  filename: 'BabelStoneHan.ttf',                   }
      { texname: 'mktsFontfileCwtexqfangsongmedium',           filename: 'cwTeXQFangsong-Medium.ttf',           }
      { texname: 'mktsFontfileCwtexqheibold',                  filename: 'cwTeXQHei-Bold.ttf',                  }
      { texname: 'mktsFontfileCwtexqkaimedium',                filename: 'cwTeXQKai-Medium.ttf',                }
      { texname: 'mktsFontfileCwtexqmingmedium',               filename: 'cwTeXQMing-Medium.ttf',               }
      { texname: 'mktsFontfileCwtexqyuanmedium',               filename: 'cwTeXQYuan-Medium.ttf',               }
      { texname: 'mktsFontfileDejavusansbold',                 filename: 'DejaVuSans-Bold.ttf',                 }
      { texname: 'mktsFontfileDejavusansboldoblique',          filename: 'DejaVuSans-BoldOblique.ttf',          }
      { texname: 'mktsFontfileDejavusansoblique',              filename: 'DejaVuSans-Oblique.ttf',              }
      { texname: 'mktsFontfileDejavusans',                     filename: 'DejaVuSans.ttf',                      }
      { texname: 'mktsFontfileDejavusanscondensedbold',        filename: 'DejaVuSansCondensed-Bold.ttf',        }
      { texname: 'mktsFontfileDejavusanscondensedboldoblique', filename: 'DejaVuSansCondensed-BoldOblique.ttf', }
      { texname: 'mktsFontfileDejavusanscondensedoblique',     filename: 'DejaVuSansCondensed-Oblique.ttf',     }
      { texname: 'mktsFontfileDejavusanscondensed',            filename: 'DejaVuSansCondensed.ttf',             }
      { texname: 'mktsFontfileDejavusansmonobold',             filename: 'DejaVuSansMono-Bold.ttf',             }
      { texname: 'mktsFontfileDejavusansmonoboldoblique',      filename: 'DejaVuSansMono-BoldOblique.ttf',      }
      { texname: 'mktsFontfileDejavusansmonooblique',          filename: 'DejaVuSansMono-Oblique.ttf',          }
      { texname: 'mktsFontfileDejavusansmono',                 filename: 'DejaVuSansMono.ttf',                  }
      { texname: 'mktsFontfileDejavuserifbold',                filename: 'DejaVuSerif-Bold.ttf',                }
      { texname: 'mktsFontfileDejavuserifbolditalic',          filename: 'DejaVuSerif-BoldItalic.ttf',          }
      { texname: 'mktsFontfileDejavuserifitalic',              filename: 'DejaVuSerif-Italic.ttf',              }
      { texname: 'mktsFontfileDejavuserif',                    filename: 'DejaVuSerif.ttf',                     }
      { texname: 'mktsFontfileDejavuserifcondensedbold',       filename: 'DejaVuSerifCondensed-Bold.ttf',       }
      { texname: 'mktsFontfileDejavuserifcondensedbolditalic', filename: 'DejaVuSerifCondensed-BoldItalic.ttf', }
      { texname: 'mktsFontfileDejavuserifcondenseditalic',     filename: 'DejaVuSerifCondensed-Italic.ttf',     }
      { texname: 'mktsFontfileDejavuserifcondensed',           filename: 'DejaVuSerifCondensed.ttf',            }
      { texname: 'mktsFontfileEbgaramondinitials',             filename: 'EBGaramond-Initials.otf',             }
      { texname: 'mktsFontfileEbgaramondinitialsfone',         filename: 'EBGaramond-InitialsF1.otf',           }
      { texname: 'mktsFontfileEbgaramondinitialsftwo',         filename: 'EBGaramond-InitialsF2.otf',           }
      { texname: 'mktsFontfileEbgaramondeightitalic',          filename: 'EBGaramond08-Italic.otf',             }
      { texname: 'mktsFontfileEbgaramondeightregular',         filename: 'EBGaramond08-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondeightsc',              filename: 'EBGaramond08-SC.otf',                 }
      { texname: 'mktsFontfileEbgaramondtwelveallsc',          filename: 'EBGaramond12-AllSC.otf',              }
      { texname: 'mktsFontfileEbgaramondtwelveitalic',         filename: 'EBGaramond12-Italic.otf',             }
      { texname: 'mktsFontfileEbgaramondtwelveregular',        filename: 'EBGaramond12-Regular.otf',            }
      { texname: 'mktsFontfileEbgaramondtwelvesc',             filename: 'EBGaramond12-SC.otf',                 }
      { texname: 'mktsFontfileFlowdejavusansmono',             filename: 'FlowDejaVuSansMono.ttf',              }
      { texname: 'mktsFontfileHanamina',                       filename: 'HanaMinA.ttf',                        }
      { texname: 'mktsFontfileHanaminb',                       filename: 'HanaMinB.ttf',                        }
      { texname: 'mktsFontfileSunexta',                        filename: 'sun-exta.ttf',                        }
      { texname: 'mktsFontfileSunextb',                        filename: 'Sun-ExtB.ttf',                        }
      { texname: 'mktsFontfileSunflowerucjkxb',                filename: 'sunflower-u-cjk-xb.ttf',              }
      { texname: 'mktsFontfileUbuntub',                        filename: 'Ubuntu-B.ttf',                        }
      { texname: 'mktsFontfileUbuntubi',                       filename: 'Ubuntu-BI.ttf',                       }
      { texname: 'mktsFontfileUbuntuc',                        filename: 'Ubuntu-C.ttf',                        }
      { texname: 'mktsFontfileUbuntul',                        filename: 'Ubuntu-L.ttf',                        }
      { texname: 'mktsFontfileUbuntuli',                       filename: 'Ubuntu-LI.ttf',                       }
      { texname: 'mktsFontfileUbuntur',                        filename: 'Ubuntu-R.ttf',                        }
      { texname: 'mktsFontfileUbunturi',                       filename: 'Ubuntu-RI.ttf',                       }
      { texname: 'mktsFontfileUbuntumonob',                    filename: 'UbuntuMono-B.ttf',                    }
      { texname: 'mktsFontfileUbuntumonobi',                   filename: 'UbuntuMono-BI.ttf',                   }
      { texname: 'mktsFontfileUbuntumonor',                    filename: 'UbuntuMono-R.ttf',                    }
      { texname: 'mktsFontfileUbuntumonori',                   filename: 'UbuntuMono-RI.ttf',                   }
      { texname: 'mktsFontfileSourcecodeproblack',             filename: 'SourceCodePro-Black.otf',             }
      { texname: 'mktsFontfileSourcecodeprobold',              filename: 'SourceCodePro-Bold.otf',              }
      { texname: 'mktsFontfileSourcecodeproextralight',        filename: 'SourceCodePro-ExtraLight.otf',        }
      { texname: 'mktsFontfileSourcecodeprolight',             filename: 'SourceCodePro-Light.otf',             }
      { texname: 'mktsFontfileSourcecodepromedium',            filename: 'SourceCodePro-Medium.otf',            }
      { texname: 'mktsFontfileSourcecodeproregular',           filename: 'SourceCodePro-Regular.otf',           }
      { texname: 'mktsFontfileSourcecodeprosemibold',          filename: 'SourceCodePro-Semibold.otf',          }
      { texname: 'mktsFontfileOptima',                         filename: 'Optima.ttc',                          }
      { texname: 'mktsFontfilePtsans',                         filename: 'PTSans.ttc',                          }
      { texname: 'mktsFontfileKai',                            filename: 'Kai.ttf',                             }
      { texname: 'mktsFontfileNanumgothic',                    filename: 'NanumGothic.ttc',                     }
      { texname: 'mktsFontfileNanummyeongjo',                  filename: 'NanumMyeongjo.ttc',                   }
      { texname: 'mktsFontfileJizurathreeb',                   filename: 'jizura3b.ttf',                        }
      # { texname: 'mktsFontfileJizurathreeb',                   filename: 'jizura3b-from-svg-rewritten-by-fontforge.ttf',                        }
      { texname: 'mktsFontfileBiaukai',                        filename: 'BiauKai.ttf',                         }
      { texname: 'mktsFontfileFiracodebold',                   filename: 'FiraCode-Bold.otf',                   }
      { texname: 'mktsFontfileFiracodelight',                  filename: 'FiraCode-Light.otf',                  }
      { texname: 'mktsFontfileFiracodemedium',                 filename: 'FiraCode-Medium.otf',                 }
      { texname: 'mktsFontfileFiracoderegular',                filename: 'FiraCode-Regular.otf',                }
      { texname: 'mktsFontfileFiracoderetina',                 filename: 'FiraCode-Retina.otf',                 }
      { texname: 'mktsFontfileMonoidbold',                     filename: 'Monoid-Bold.ttf',                     }
      { texname: 'mktsFontfileMonoiditalic',                   filename: 'Monoid-Italic.ttf',                   }
      { texname: 'mktsFontfileMonoidregular',                  filename: 'Monoid-Regular.ttf',                  }
      { texname: 'mktsFontfileMonoidretina',                   filename: 'Monoid-Retina.ttf',                   }

      { texname: 'mktsFontfileSimsun',                         filename: 'simsun.ttc',                          }
      { texname: 'mktsFontfileFandolfangregular',              filename: 'FandolFang-Regular.otf',              }
      { texname: 'mktsFontfileFandolheibold',                  filename: 'FandolHei-Bold.otf',                  }
      { texname: 'mktsFontfileFandolheiregular',               filename: 'FandolHei-Regular.otf',               }
      { texname: 'mktsFontfileFandolkairegular',               filename: 'FandolKai-Regular.otf',               }
      { texname: 'mktsFontfileFandolsongbold',                 filename: 'FandolSong-Bold.otf',                 }
      { texname: 'mktsFontfileFandolsongregular',              filename: 'FandolSong-Regular.otf',              }
      { texname: 'mktsFontfileIpaexg',                         filename: 'ipaexg.ttf',                          }
      { texname: 'mktsFontfileIpaexm',                         filename: 'ipaexm.ttf',                          }
      { texname: 'mktsFontfileIpag',                           filename: 'ipag.ttf',                            }
      { texname: 'mktsFontfileIpagp',                          filename: 'ipagp.ttf',                           }
      { texname: 'mktsFontfileIpam',                           filename: 'ipam.ttf',                            }
      { texname: 'mktsFontfileIpamp',                          filename: 'ipamp.ttf',                           }
      { texname: 'mktsFontfileIpaexg',                         filename: 'ipaexg.ttf',                          }
      { texname: 'mktsFontfileIpaexm',                         filename: 'ipaexm.ttf',                          }
      { texname: 'mktsFontfileIpag',                           filename: 'ipag.ttf',                            }
      { texname: 'mktsFontfileIpagp',                          filename: 'ipagp.ttf',                           }
      { texname: 'mktsFontfileIpam',                           filename: 'ipam.ttf',                            }
      { texname: 'mktsFontfileIpamp',                          filename: 'ipamp.ttf',                           }
      { texname: 'mktsFontfileUkai',                           filename: 'ukai.ttc',                            }
      { texname: 'mktsFontfileUming',                          filename: 'uming.ttc',                           }
      { texname: 'mktsFontfileDroidsansfallbackfull',          filename: 'DroidSansFallbackFull.ttf',           }
      { texname: 'mktsFontfileDroidsansjapanese',              filename: 'DroidSansJapanese.ttf',               }
      { texname: 'mktsFontfileFontsjapanesegothic',            filename: 'fonts-japanese-gothic.ttf',           }
      { texname: 'mktsFontfileFontsjapanesemincho',            filename: 'fonts-japanese-mincho.ttf',           }
      { texname: 'mktsFontfileTakaopgothic',                   filename: 'TakaoPGothic.ttf',                    }
      { texname: 'mktsFontfileSourcehansansbold',              filename: 'SourceHanSans-Bold.ttc',              }
      { texname: 'mktsFontfileSourcehansansextralight',        filename: 'SourceHanSans-ExtraLight.ttc',        }
      { texname: 'mktsFontfileSourcehansansheavy',             filename: 'SourceHanSans-Heavy.ttc',             }
      { texname: 'mktsFontfileSourcehansanslight',             filename: 'SourceHanSans-Light.ttc',             }
      { texname: 'mktsFontfileSourcehansansmedium',            filename: 'SourceHanSans-Medium.ttc',            }
      { texname: 'mktsFontfileSourcehansansnormal',            filename: 'SourceHanSans-Normal.ttc',            }
      { texname: 'mktsFontfileSourcehansansregular',           filename: 'SourceHanSans-Regular.ttc',           }

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
      'u-cjk':                  'cn'
      'u-halfull':              'cn'
      'u-dingb':                'cn'
      'u-cjk-xa':               'cnxa'
      'u-cjk-xb':               'cnxb'
      'u-cjk-xc':               'cnxc'
      'u-cjk-xd':               'cnxd'
      'u-cjk-cmpi1':            'cncone'
      'u-cjk-cmpi2':            'cnctwo'
      'u-cjk-rad1':             'cnrone'
      'u-cjk-rad2':             'cnrtwo'
      'u-cjk-sym':              'cnsym'
      'u-cjk-strk':             'cnstrk'
      'u-pua':                  'cnjzr'
      'jzr-fig':                'cnjzr'
      'u-cjk-kata':             'ka'
      'u-cjk-hira':             'hi'
      'u-hang-syl':             'hg'
      'fallback':               'mktsRsgFb'
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
      ]
    #.......................................................................................................
    'glyph-styles':
      ### Other stuff: ###
      '‰':          '{\\mktsFontfileOptima‰}'
      ### Ideographic description characters: ###
      '↻':                                cmd: 'cnxJzr',      glyph: ''
      '↔':                                cmd: 'cnxJzr',      glyph: ''
      '↕':                                cmd: 'cnxJzr',      glyph: ''
      '●':                                cmd: 'cnxJzr',      glyph: ''
      '◰':                                cmd: 'cnxJzr',      glyph: ''
      '≈':                                cmd: 'cnxJzr',      glyph: ''
      '⿰':                                cmd: 'cnxJzr',      glyph: ''
      '⿱':                                cmd: 'cnxJzr',      glyph: ''
      '⿺':                                cmd: 'cnxJzr',      glyph: ''
      '⿸':                                cmd: 'cnxJzr',      glyph: ''
      '⿹':                                cmd: 'cnxJzr',      glyph: ''
      '⿶':                                cmd: 'cnxJzr',      glyph: ''
      '⿷':                                cmd: 'cnxJzr',      glyph: ''
      '⿵':                                cmd: 'cnxJzr',      glyph: ''
      '⿴':                                cmd: 'cnxJzr',      glyph: ''
      '⿻':                                cmd: 'cnxJzr',      glyph: ''

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
      ### Shifted glyphs: ###
      '&#x3000;':                         cmd: 'cnjzr',       glyph: ''
      '《':             raise: -0.2
      '》':             raise: -0.2
      '囗':                                cmd: 'cnjzr',       glyph: ''
      '。':  push: 0.5, raise: 0.25,       cmd: 'cn'
      '亻':  push: 0.4
      '冫':  push: 0.5
      '灬':             raise: 0.25
      '爫':             raise: -0.125
      '牜':  push: 0.4
      '飠':  push: 0.4
      '扌':  push: 0.05
      '犭':  push: 0.3
      '忄':  push: 0.4
      '礻':  push: 0.2
      '衤':  push: 0.1
      '覀':             raise: -0.125
      '讠':  push: 0.4
      '𧾷':  push: 0.4,                    cmd: 'cnxb'
      '卩':  push: -0.4
      '癶':             raise: -0.2,       cmd: 'cnxBabel'
      '':             raise: 0.1,        cmd: 'cnxJzr'
      '':  push: 0.5, raise: -0.2
      '乛':             raise: -0.2
      '糹':  push: 0.4
      '纟':  push: 0.4
      '𥫗':             raise: -0.2,       cmd: 'cnxb'
      '罓':             raise: -0.2
      '钅':  push: 0.3
      '阝':  push: 0.4
      '龵':             raise: -0.1,       cmd: 'cnxBabel'
      '𩰊':  push: -0.15,                  cmd: 'cnxb'
      '𩰋':  push: 0.15,                   cmd: 'cnxb'
      '彳':  push: 0.15
      '龹':             raise: -0.12
      '龸':             raise: -0.15
      '䒑':             raise: -0.15,      cmd: 'cnxa'
      '宀':             raise: -0.15
      '〇':             raise: -0.05,      cmd: 'cnxBabel'
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
      '⺶':                                cmd: 'cnxBabel'
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
      '𡗗':                                cmd: 'cnxJzr',      glyph: ''
      '丿':                                cmd: 'cnxJzr',      glyph: ''
      '𠥓':                                cmd: 'cnxJzr',      glyph: ''
      '龷':                                cmd: 'cnxJzr',      glyph: ''
      '龶':                                cmd: 'cnxJzr',      glyph: ''
