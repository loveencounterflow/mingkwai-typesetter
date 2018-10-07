


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
#...........................................................................................................
# MKTS                      = require './main'
CS                        = require 'coffeescript'
VM                        = require 'vm'

#-----------------------------------------------------------------------------------------------------------
@evaluate = ( source, settings ) =>
  #.........................................................................................................
  language                  = settings?.language ? 'coffee'
  local_filename            = '<STRING>'
  macro_output              = []
  sandbox                   = {}
  # sandbox_backup            = MK.TS.DIFFPATCH.snapshot sandbox
  VM.createContext sandbox
  #.........................................................................................................
  switch language
    when 'js'
      js_source = raw_source
    when 'coffee'
      # wrapped_source  = "do =>\n  " + source.replace /\n/g, "\n  "
      wrapped_source  = source
      js_source       = CS.compile wrapped_source, { bare: true, filename: local_filename, }
    else
      throw new Error "unknown language #{rpr language}"
  #.....................................................................................................
  R = VM.runInContext js_source, sandbox, { filename: local_filename, }
  # debug '77783', sandbox
  return R

############################################################################################################
unless module.parent?
  debug '77733', @evaluate """
  foo:
    bar: 'baz'
    """, { language: 'coffee', }



