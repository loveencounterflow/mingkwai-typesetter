


'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MKTS/TEX-WRITER/MKTSTABLE'
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
jr                        = JSON.stringify
#...........................................................................................................
I                         = require 'immutable'
debug '36333', Object.keys I

#-----------------------------------------------------------------------------------------------------------
get       = ( me, key, value  ) -> me.get key, value
set       = ( me, key, value  ) -> me.set key, value
push      = ( me, value       ) -> me.push value
pop       = ( me              ) -> me.pop()
same_as   = ( me, you         ) -> me is you

#-----------------------------------------------------------------------------------------------------------
equals = ( me, you ) ->
  ### TAINT no way to make sure `equals` is a method and that it tests for deep equality ###
  if  me.equals?  then return    me.equals you
  if you.equals?  then return   you.equals me
  return                        CND.equals me, you

{ Map, List } = I
map1 = Map { a: 1, b: 2, c: 3 }
map2 = set map1, 'b', 50
info ( get map1, 'b' ) + " vs. " + ( get map2, 'b' )
info map1
info map2
info jr map1
info jr map2

d = List ( x for x in [ 5 .. 12 ] by +2 )

debug '27723', map1[ 'x' ]
debug '27723', Object.keys map1
debug '27723 IN   ', jr ( key for key in map1 )
debug '27723 OF   ', jr ( key for key of map1 )
debug '27723 FROM ', jr ( key for key from map1 )
debug '27723 IN   ', jr ( key for key in d )
debug '27723 OF   ', jr ( key for key of d )
debug '27723 FROM ', jr ( key for key from d )

d1 = d
d2 = push d, 3
d3 = pop  d2
info 'd             ', d
info 'd1            ', d1
info 'd2            ', d2
info 'd is d1       ', d is d1
info 'd1 is d2      ', d1 is d2
info 'd1 is d3      ', d1 is d3
info 'd1.equals d3  ', equals d1, d3

d4 = set d, 0, 'helo'

for x from d4
  debug '33444', x
for [ x, y, ] from map1
  debug '33444', x, y

urge a = Map Object.assign {}, { x: 42, }, map1.toJS()
urge b = Map Object.assign {}, map1.toJS(), { x: 42, }

info a is b
info I.is a, b
info a.equals b
info equals a, b

info()
info equals a, b
x = [3,4,]
y = [3,4,]
a = set a, 'oops', x
b = set b, 'oops', y
urge a
push x, 42
push y, 42
urge a
urge b
info equals a, b

# foo = set a, 'baz', 'fuckyeah'
# urge()
# urge foo.baz
# urge ( get foo, 'baz' )
# urge get( foo, 'baz' )
# urge foo.get( 'baz' )
# urge ( foo.get 'baz' )

# urge ( u.baz foo )
# foo.bar.baz

# ( u.baz u.bar foo )
# ( u.bar.baz foo )
# # f'foo.bar.baz' = 42

handler =
  get: ( target, key ) ->
    debug '36631', 'get', rpr key
    return target[ key ] if key of target
    return '**no such value**'

  set: ( target, key, value ) ->
    debug '36633', 'set', target
    R = wrap target.set key, value
    debug '36633', 'R', rpr R
    return R

# new_cpod = ( P... ) -> new Proxy ( Object.freeze Object.assign {}, P... ), handler
wrap      = ( x ) -> new Proxy x, handler
new_cpod  = ( P... ) -> wrap ( Map Object.assign {}, P... )

# p = new Proxy { foo: 45, }, handler
p = new_cpod { foo: 45, }
delete p.foo
debug '99902', p


# debug '99902', p.foo
# debug '99902', p.helo
# q = ( p.bar = 'what a bar!' )
# q = set p.bar, 'what a bar!'
# q = set p, 'bar', 'what a bar!'
# debug '10101', p.bar
# debug '10101', rpr q
# debug '10101', q.bar


# debug d = Object.freeze { x: 42, }
# d.x = 108
# debug d











