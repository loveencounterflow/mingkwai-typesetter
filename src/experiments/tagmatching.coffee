


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/MACRO-ESCAPER/tagmatching'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
XREGEXP                   = require 'xregexp'


#-----------------------------------------------------------------------------------------------------------
str1 = '(t((e))s)t()(ing)'
whisper '--( 1 )--', XREGEXP.matchRecursive(str1, '\\(', '\\)', 'g')
### -> ['t((e))s', '', 'ing'] ###

### Extended information mode with valueNames ###
str2 = 'Here is <div> <div>an</div></div> example'
whisper '--( 2 )--', XREGEXP.matchRecursive(str2, '<div\\s*>', '</div>', 'gi', {
    valueNames: ['between', 'left', 'match', 'right']
})
###
 -> [
{name: 'between', value: 'Here is ',       start: 0,  end: 8},
{name: 'left',    value: '<div>',          start: 8,  end: 13},
{name: 'match',   value: ' <div>an</div>', start: 13, end: 27},
{name: 'right',   value: '</div>',         start: 27, end: 33},
{name: 'between', value: ' example',       start: 33, end: 41}
]
###

### Omitting unneeded parts with null valueNames, and using escapeChar ###
str3 = '...{1}.\\{{function(x,y){return {y:x}}}'
whisper '--( 3 )--', XREGEXP.matchRecursive(str3, '{', '}', 'g', {
    valueNames: ['literal', null, 'value', null],
    escapeChar: '\\'
})
###
 -> [
{name: 'literal', value: '...',  start: 0, end: 3},
{name: 'value',   value: '1',    start: 4, end: 5},
{name: 'literal', value: '.\\{', start: 6, end: 9},
{name: 'value',   value: 'function(x,y){return {y:x}}', start: 10, end: 37}
]
###

### Sticky mode via flag y ###
str4 = '<1><<<2>>><3>4<5>'
whisper '--( 4 )--', XREGEXP.matchRecursive(str4, '<', '>', 'gy')
### -> ['1', '<<2>>', '3'] ###


source    = 'Here is a <raw>somewhat contrived</raw> and <raw>longer</raw> example'
# source    = 'Here is a <raw> <raw>somewhat <raw>contrived</raw> and </raw> longer</raw> example'
# source    = 'Here is a <raw>example</raw>.'
settings  = { valueNames: [ 'between', 'left', 'match', 'right', ], }
matches   = XREGEXP.matchRecursive source, '<raw>', '</raw>', 'gi', settings
if matches?
  for match in matches
    urge match

