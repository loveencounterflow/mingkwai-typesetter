


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
unified                   = require 'unified'
remark_parse              = require 'remark-parse'
stringify                 = require 'rehype-stringify'
remark_to_rehype          = require 'remark-rehype'
remark_to_html            = require 'remark-html'
remark_grid_tables        = require 'remark-grid-tables'

#-----------------------------------------------------------------------------------------------------------
show_permutations = ->
  columns = [ 'O', 'A', 'B', 'C', 'Z', ]
  rows    = [ 'O', 'A', 'B', 'C', 'Z', ]

  for column in columns
    for row in rows
      echo "      \\node[color=gray] at ( \\c#{column}, \\r#{row} ) {{\\mktsStyleCode{}#{column}#{row}}};"

#-----------------------------------------------------------------------------------------------------------
x = unified()
  .use remark_parse
  .use remark_grid_tables
  # .use remark_to_rehype
  .use stringify
  .use remark_to_html

demo_1 = """
+-------+----------+------+
| Table Headings   | Here |
+-------+----------+------+
| Sub   | Headings | Too  |
+=======+==========+======+
| cell  | column spanning |
+ spans +----------+------+
| rows  | normal   | cell |
+-------+----------+------+
| multi | cells can be    |
| line  | *formatted*     |
|       | **paragraphs**  |
| cells |                 |
| too   |                 |
+-------+-----------------+

"""
debug x.stringify x.parse demo_1

demo_2 = """
  +-------+----------+------+
  | Table Headings   | Here |
  +-------+----------+------+
  | Sub   | Headings | Too  |
  +-------+----------+------+
  | Sub   | Headings | Too  |
  +=======+==========+======+
  | cell  | column spanning |
  + spans +----------+------+
  | rows  | normal   | cell |
  +-------+----------+------+
  | multi | cells can be    |
  | line  | *formatted*     |
  |       | **paragraphs**  |
  | cells |                 |
  | too   |                 |
  +-------+-----------------+



"""
debug x.stringify x.parse demo_2

