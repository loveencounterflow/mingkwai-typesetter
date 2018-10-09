


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
jr                        = JSON.stringify

#-----------------------------------------------------------------------------------------------------------
show_permutations = ->
  columns = [ 'O', 'A', 'B', 'C', 'Z', ]
  rows    = [ 'O', 'A', 'B', 'C', 'Z', ]

  for column in columns
    for row in rows
      echo "      \\node[color=gray] at ( \\c#{column}, \\r#{row} ) {{\\mktsStyleCode{}#{column}#{row}}};"

#-----------------------------------------------------------------------------------------------------------
demo_tableparsing = ->
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


### ==================================================================================================== ###

# debug EXCJSCC = require '../../src/experiments/exceljs-col-cache-module'
EXCJSCC                   = require '../exceljs-spreadsheet-address-codec'


debug '77762-1', EXCJSCC.l2n               'A'    ### letter_from_number ###
debug '77762-2', EXCJSCC.l2n               'Z'
debug '77762-3', EXCJSCC.l2n               'AA'
# debug '77762-4', EXCJSCC.l2n               'zz' ### must be uppercase ###
debug '77762-5', EXCJSCC.n2l               '1'    ### letter_from_number ###
debug '77762-6', EXCJSCC.n2l               '256'
debug '77762-7', EXCJSCC.n2l               256
# debug '77762-8', EXCJSCC.validateAddress   '*+'
debug '77762-9', EXCJSCC.validateAddress   'AA1'
# debug '77762-10', EXCJSCC.validateAddress   'A:A'
debug '77762-11', EXCJSCC.decodeAddress     'A1'  ### convert address string into structure ###
debug '77762-12', EXCJSCC.decodeAddress     'AA1' ### like `{ address: 'A1', col: 1, row: 1, '$col$row': '$A$1' }` ###
debug '77762-13', EXCJSCC.getAddress        'AA1' ### convert r,c into structure (if only 1 arg, assume r is address string) ###
debug '77762-13', EXCJSCC.getAddress        '1', '2'
debug '77762-13', EXCJSCC.getAddress        1, 2
debug '77762-14', EXCJSCC.decode            'AA1' ### convert [address], [tl:br] into address structures ###
debug '77762-14', EXCJSCC.decode            'A1:B2'
# debug '77762-15', EXCJSCC.decodeEx          'AA1'
debug '77762-16', EXCJSCC.encodeAddress     1, 1 ### convert row,col into address string ###
debug '77762-16', EXCJSCC.encodeAddress     1234, 1234
debug '77762-17', EXCJSCC.encode            1234, 1234 ### convert row,col into string address or t,l,b,r into range ###
debug '77762-17', EXCJSCC.encode            1, 2, 3, 4

