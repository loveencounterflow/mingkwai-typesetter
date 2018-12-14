
'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'HTML-TAGS/TESTS'
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
test                      = require 'guy-test'
eq                        = CND.equals
jr                        = JSON.stringify
#...........................................................................................................
join                      = ( x, joiner = '' ) -> x.join joiner
assign                    = Object.assign
# XREGEXP                   = require 'xregexp'
HP2                       = require 'htmlparser2'
close_tag_pattern         = /^(?<all><\/(?<name>[^>\s]+?)>)/

#-----------------------------------------------------------------------------------------------------------
settings  =
  lowerCaseTags:              false
  lowerCaseAttributeNames:    false
  decodeEntities:             false
  xmlMode:                    false
  recognizeSelfClosing:       true
  recognizeCDATA:             false

#-----------------------------------------------------------------------------------------------------------
provide_handlers = ( handler ) ->

  #---------------------------------------------------------------------------------------------------------
  @onopentag = ( name, attributes ) ->
    start = @parser.startIndex
    end   = @parser.endIndex
    handler null, { mark: '(', name, attributes, start, end, }

  #---------------------------------------------------------------------------------------------------------
  @ontext = ( text ) ->
    start = @parser.startIndex
    end   = @parser.endIndex
    handler null, { mark: '.', name: 'text', value: text, start, end, }

  #---------------------------------------------------------------------------------------------------------
  @onclosetag = ( name ) ->
    start = @parser.startIndex
    end   = @parser.endIndex
    handler null, { mark: ')', name, start, end, }

  #---------------------------------------------------------------------------------------------------------
  @onprocessinginstruction = ( name, data ) ->
    return handler new Error "encounter illegal XML processing instruction: #{rp { name, data, }}"

  #---------------------------------------------------------------------------------------------------------
  @onerror = ( error ) -> handler error

  #---------------------------------------------------------------------------------------------------------
  @oncomment =              ( data              ) -> whisper 'comment', rpr { data, }
  @oncommentend =           ()                    -> whisper 'commentend'

  # onopentag:                ( name,  attributes ) -> whisper 'opentag'
  # onopentagname:            ( name              ) -> whisper 'opentagname', rpr name
  # onattribute:              ( name,  value      ) -> whisper 'attribute', rpr { name: value }
  # ontext:                   ( text              ) -> whisper 'text'
  # onclosetag:               ( name              ) -> whisper 'closetag'
  # onprocessinginstruction:  ( name,  data       ) -> whisper 'processinginstruction', rpr { name, data, }
  # oncdatastart:             ()                    -> whisper 'cdatastart'
  # oncdataend:               ()                    -> whisper 'cdataend'
  # onreset:                  ()                    -> whisper 'reset'
  # onend:                    ()                    -> whisper 'end'
  return @

############################################################################################################
unless module.parent?
  sources = [
    "helo <x:tag>world"
    "helo <x:tag></x:tag>world"
    "helo <x:tag> </x:tag>world"
    "helo <tag> </ignored>world"
    "helo <x:tag/>world"
    "helo <いきましょうか/>world"
    "<div>just a </div> that is closed"
    "just a </div> that is closed"
    "some < lonely > brackets"
    "some < lonely brackets"
    "some lonely > brackets"
    # """<?xml-stylesheet type="text/xsl" href="style.xsl"?>foobar"""
    # "helo <x:b>world</x:b>"
    # "helo <b><i>world"
    # "helo <tag foo/>world"
    # "helo <tag foo>world</tag>"
    # "helo <tag foo=bar/>world"
    # "helo <TAG FOO=BAR/>world"
    # "helo <tag foo='bar'/>world"
    # "helo <TAG FOO='BAR'/>world"
    ]
  handlers        = provide_handlers.call {}, ( error, d ) ->
    throw error if error?
    color = switch d.mark
      when '.' then CND.white
      when '(' then CND.lime
      when ')' then CND.orange
      else CND.red
    urge color jr d
  handlers.parser = new HP2.Parser handlers, settings
  for source in sources
    info rpr source
    lone_tag_idx = source.indexOf '</'
    if ( lone_tag_idx = source.indexOf '</' ) > -1 and lone_tag_idx <= ( source.indexOf '<' )
      head  = source[ ... lone_tag_idx ]
      tail  = source[ lone_tag_idx .. ]
      urge rpr head
      unless ( match = tail.match close_tag_pattern )?
        throw new Error "illegal HTML markup at ##{lone_tag_idx}: #{rpr source}"
      urge 'close tag:', match.groups.name
      # debug match.groups.all.length
      source = tail[ match.groups.all.length .. ]
    handlers.parser.write source
    handlers.parser.reset()
    # parser.end()
    # parser.parseComplete()




