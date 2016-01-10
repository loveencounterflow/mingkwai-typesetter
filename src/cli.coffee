
############################################################################################################
( require 'source-map-support' ).install()


############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/cli'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
# #...........................................................................................................
# D                         = require 'pipedreams'
# $                         = D.remit.bind D
# $async                    = D.remit_async.bind D
# #...........................................................................................................
# ASYNC                     = require 'async'
# #...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require './HELPERS'
# # options                   = require './options'
# TEXLIVEPACKAGEINFO        = require './TEXLIVEPACKAGEINFO'
# options_route             = '../options.coffee'
# { CACHE, OPTIONS, }       = require './OPTIONS'
# SEMVER                    = require 'semver'
# #...........................................................................................................
# MKTS                      = require './main'




app       = require 'commander'
app_name  = process.argv[ 1 ]

app
  .version ( require '../package.json' )[ 'version' ]
  .command 'mkts <filename>'
  .action ( filename ) ->
    help ( CND.grey "#{app_name}" ), ( CND.gold 'mkts' ), ( CND.lime filename )
    MKTS = require './main'
    MKTS.TEX_WRITER.pdf_from_md filename

app.parse process.argv
# debug '©nES6R', process.argv

