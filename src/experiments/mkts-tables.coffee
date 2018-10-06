


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MK/TS/MACRO-ESCAPER/mkts-tables'
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
columns = [ 'O', 'A', 'B', 'C', 'Z', ]
rows    = [ 'O', 'A', 'B', 'C', 'Z', ]

for column in columns
  for row in rows
    echo "      \\node[color=gray] at ( \\c#{column}, \\r#{row} ) {{\\mktsStyleCode{}#{column}#{row}}};"
