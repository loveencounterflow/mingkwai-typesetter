



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/HELPERS'
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
ASYNC                     = require 'async'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D

# #-----------------------------------------------------------------------------------------------------------
# @provide_tmp_folder = ( options ) ->
#   njs_fs.mkdirSync options[ 'tmp-home' ] unless njs_fs.existsSync options[ 'tmp-home' ]
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @tmp_locator_for_extension = ( layout_info, extension ) ->
#   tmp_home            = layout_info[ 'tmp-home' ]
#   tex_locator         = layout_info[ 'tex-locator' ]
#   ### TAINT should extension be sanitized? maybe just check for /^\.?[-a-z0-9]$/? ###
#   throw new Error "need non-empty extension" unless extension.length > 0
#   extension           = ".#{extension}" unless ( /^\./ ).test extension
#   return njs_path.join CND.swap_extension tex_locator, extension

#-----------------------------------------------------------------------------------------------------------
@new_layout_info = ( options, source_route ) ->
  xelatex_command       = options[ 'xelatex-command' ]
  source_home           = njs_path.resolve process.cwd(), source_route
  source_name           = options[ 'main' ][ 'filename' ]
  source_locator        = njs_path.join source_home, source_name
  #.........................................................................................................
  throw new Error "unable to locate #{source_home}"     unless njs_fs.existsSync source_home
  throw new Error "not a directory: #{source_home}"     unless ( njs_fs.statSync source_home ).isDirectory()
  throw new Error "unable to locate #{source_locator}"  unless njs_fs.existsSync source_locator
  throw new Error "not a file: #{source_locator}"       unless ( njs_fs.statSync source_locator ).isFile()
  #.........................................................................................................
  # tex_locator           = njs_path.join tmp_home, CND.swap_extension source_name, '.tex'
  job_name              = njs_path.basename source_home
  aux_locator           = njs_path.join source_home, "#{job_name}.aux"
  pdf_locator           = njs_path.join source_home, "#{job_name}.pdf"
  mkscript_locator           = njs_path.join source_home, "#{job_name}.mkscript"
  # tex_inputs_home       = njs_path.resolve __dirname, '..', 'tex-inputs'
  master_name           = options[ 'master' ][ 'filename' ]
  master_ext            = njs_path.extname master_name
  master_locator        = njs_path.join source_home, master_name
  content_name          = options[ 'content' ][ 'filename' ]
  content_locator       = njs_path.join source_home, content_name
  ### TAINT duplication: tex_inputs_home, texinputs_value ###
  texinputs_value       = options[ 'texinputs' ][ 'value' ]
  #.........................................................................................................
  R =
    'aux-locator':                aux_locator
    'content-locator':            content_locator
    'job-name':                   job_name
    'master-locator':             master_locator
    'master-name':                master_name
    'pdf-locator':                pdf_locator
    'mkscript-locator':           mkscript_locator
    'source-home':                source_home
    'source-locator':             source_locator
    'source-name':                source_name
    'source-route':               source_route
    # 'tex-inputs-home':            tex_inputs_home
    'tex-inputs-value':           texinputs_value
    'xelatex-command':            xelatex_command
    'xelatex-run-count':          0
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@write_pdf = ( layout_info, handler ) ->
  #.........................................................................................................
  job_name            = layout_info[ 'job-name'             ]
  source_home         = layout_info[ 'source-home'          ]
  xelatex_command     = layout_info[ 'xelatex-command'      ]
  master_locator      = layout_info[ 'master-locator'       ]
  aux_locator         = layout_info[ 'aux-locator'          ]
  pdf_locator         = layout_info[ 'pdf-locator'          ]
  last_digest         = null
  last_digest         = CND.id_from_route aux_locator if njs_fs.existsSync aux_locator
  digest              = null
  count               = 0
  texinputs_value     = layout_info[ 'tex-inputs-value' ]
  parameters          = [ texinputs_value, source_home, job_name, master_locator, ]
  error_lines         = []
  urge "#{xelatex_command}"
  whisper "$#{idx + 1}: #{parameters[ idx ]}" for idx in [ 0 ... parameters.length ]
  log "#{xelatex_command} #{parameters.join ' '}"
  #.........................................................................................................
  pdf_from_tex = ( next ) =>
    count += 1
    urge "run ##{count}"
    # CND.spawn xelatex_command, parameters, ( error, data ) =>
    cp = ( require 'child_process' ).spawn xelatex_command, parameters
    #.......................................................................................................
    cp.stdout
      .pipe D.$split()
      .pipe D.$observe ( line ) =>
        echo CND.grey line
    #.......................................................................................................
    cp.stderr
      .pipe D.$split()
      .pipe D.$observe ( line ) =>
        error_lines.push line
        echo CND.red line
    #.......................................................................................................
    cp.on 'close', ( error ) =>
      error = undefined if error is 0
      if error?
        alert error
        return handler error
      if error_lines.length > 0
        ### TAINT looks like we're getting empty lines on stderr? ###
        message = ( line for line in error_lines when line.length > 0 ).join '\n'
        if message.length > 0
          alert message
          return handler message
      digest = CND.id_from_route aux_locator
      if digest is last_digest
        echo ( CND.grey badge ), CND.lime "done."
        layout_info[ 'xelatex-run-count' ] = count
        ### TAINT move pdf to layout_info[ 'source-home' ] ###
        handler null
      else
        last_digest = digest
        next()
  #.........................................................................................................
  ASYNC.forever pdf_from_tex

