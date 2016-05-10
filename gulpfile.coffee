

############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs-extra'
# join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/gulp'
warn                      = CND.get_logger 'warn',    badge
help                      = CND.get_logger 'help',    badge
debug                     = CND.get_logger 'debug',    badge
info                      = CND.get_logger 'info',    badge
# echo                      = CND.echo.bind CND
#...........................................................................................................
gulp                      = require 'gulp'
coffee                    = require 'gulp-coffee'
sourcemaps                = require 'gulp-sourcemaps'
stylus                    = require 'gulp-stylus'


#-----------------------------------------------------------------------------------------------------------
get_timestamp = ->
  unless handler?
    R = ( new Date() ).toISOString()
    R = R.replace 'T', '-'
    R = R.replace /:/g, '-'
    R = R.replace /\..*$/g, ''
    return R

#-----------------------------------------------------------------------------------------------------------
gulp.task 'build', [
  'build-coffee'
  'build-stylus'
  ]

#-----------------------------------------------------------------------------------------------------------
gulp.task 'build-coffee', ->
  return gulp.src 'src/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee().on 'error', ( error ) -> throw error
    .pipe sourcemaps.write '../sourcemaps'
    .pipe gulp.dest './lib'

#-----------------------------------------------------------------------------------------------------------
gulp.task 'build-stylus', ->
  return gulp.src 'src/styles/mkts-main.styl'
    .pipe sourcemaps.init()
    .pipe stylus().on 'error', ( error ) -> throw error
    # .pipe stylus().on 'error', warn
    .pipe sourcemaps.write '../sourcemaps'
    .pipe gulp.dest 'lib/styles'

#-----------------------------------------------------------------------------------------------------------
gulp.task 'test', [ 'build-coffee', ], ->
  tests = require './lib/tests'
  tests._main()
  return 'x'

