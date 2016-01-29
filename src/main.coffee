


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/main'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#-----------------------------------------------------------------------------------------------------------
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
#...........................................................................................................
@HELPERS                  = require './helpers'
@MACRO_ESCAPER            = require './macro-escaper'
@MACRO_INTERPRETER        = require './macro-interpreter'
@MD_READER                = require './md-reader'
@TEX_WRITER               = require './tex-writer'
@MKTSCRIPT_WRITER         = require './mktscript-writer'
@PLUGIN_MANAGER           = require './plugin-manager'

route                 = njs_path.resolve __dirname, '../node_modules'
# plugin_info_by_routes = @PLUGIN_MANAGER.find_plugin_package_infos route, { keyword: 'peerDependencies', }
plugin_info_by_routes = @PLUGIN_MANAGER.find_plugin_package_infos route #, { keyword: 'ansi', }
for plugin_route, plugin_info of plugin_info_by_routes
  debug '234627', plugin_info[ 'name' ]
  # debug '234627', require plugin_info[ 'name' ]
  # debug '234627', require plugin_route








