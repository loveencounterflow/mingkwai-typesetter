

###


## Motivation

This module is a slight shim for [`changeset`](https://github.com/eugeneware/changeset), an amazing
(and small!) piece of software that does diffing (i.e. changeset generation) and patching (i.e.
changeset application) for nested JavaScript datastructures.

Chnagesets are implemented as lists of PODs, each detailing one atomic change step and formatted
so they can be directly fit into a (suitably structured) LvelDB instance (using `level`/`levelup`).
It even claims to respect cyclic references, which is great.

We're here less concerned with feeding changesets into a DB; rather, the problem we want
to solve is how to keep track of local state within a processing pipeline.

As an example, let's consider this MD document:

```md
<<(.>>@S.COLUMNS.count = 3<<)>>
<<!columns>>
<<!yadda>>

<<(.>>@S.COLUMNS.count = 4<<)>>
<<!columns>>
<<!yadda>>
```

We want this source to result in a PDF that has two paragraphs of Lore Ipsum mumbo (``<<!yadda>>`),
the first one typeset into three (`<<(.>>@S.COLUMNS.count = 3<<)>>`), and the second one into
four (`<<(.>>@S.COLUMNS.count = 4<<)>>`) columns (`<<!columns>>`).

If we were to use global state—which is communicated via the `S` variable—then that *might* work
out as long as the chain of piped transforms were to act in a strictly lockstep fashion; in other
words, if each event that originates somewhere near the top of the chain were guaranteed to be fully
processed and its consequences all written out to the bottom of the chain before the next event
gets to be processed. However, that is not the case, since some processing steps like footnotes
and TOC compilation need to buffer the entire sequence of events before giving control to the
ensuing step (otherwise you can't have a table of contents in the opening matter of a book).

In the presence of such buffering, a phenomenon reminiscent of a 'failed closure' surfaces: some
step early on knows that the default column count is 2, and may set global state accordingly; at
some later point, a change to 3 is encountered, and S gets changed; still later, a change to 4
is encountered, and S will be modified again. But in the presence of an intermediate buffering
step, that step will only send on events once the document has been finished, and all that remains
in global state is a setting of 4, not 2 or 3 columns per page.

The solution to this problem is to treat changes to local state like any other instructions
from the document source, have them travel down the chain of transforms as events, and require
all interested parties to listen to those change events and rebuild their local copies of local
state themselves. This adds a certain overhead to processing, but the upside is that we can
always be sure that local state will be up to date within each stream transform as long as
events don't get re-ordered.


## Usage

The DIFFPATCH (DP) API is fairly minimal; you get three methods:

```coffee
@snapshot = ( original )      -> LODASH.cloneDeep original
@diff     = ( x, y )          -> diff x, y
@patch    = ( changeset, x )  -> diff.apply changeset, x
```

`DP.diff x, y` results in a changeset (a list of changes) that tells you which steps are needed
to modify `x` so that it will test deep-equal to `y`. Changesets are what we'll send doen the
pipeline; there'll be a single initial changeset after the document construction stream has started
that allows any interested parties to 'jumpstart', as it were, their local state copy:
you take an empty POD `local = {}`, apply the changeset, and you're good:
`local = DP.patch changeset, local`.

In case a stream transform has to modify local state, it needs a reference point on which to base
its own change events unto, which is what `DO.snapshot` is for:

```coffee
backup            = DIFFPATCH.snapshot local               # create reference point
local             = DIFFPATCH.patch changeset_event, local # update local state
[...]
local.n           = 12345678                               # modify local state
[...]
changeset_out     = DIFFPATCH.diff backup, local           # create changeset for
                                                           # ensuing transforms to listen to
```

```

#-----------------------------------------------------------------------------------------------------------
test_functions_in_changeset = ->
  rpr = ( x ) -> ( ( require 'util' ).inspect x, colors: yes, depth: 2 ).replace /\n * /g, ' '
  my_function = -> 108
  #.........................................................................................................
  changeset_event = null
  do =>
    sandbox =
      n:        42
      f:        my_function
      foo:      Array.from 'shrdlu'
      bar:      { x: 33, y: 54, f: my_function, }
    changeset_event = DIFFPATCH.diff {}, sandbox
  #.........................................................................................................
  do =>
    local             = DIFFPATCH.patch changeset_event, {}
    backup            = DIFFPATCH.snapshot local
    log CND.truth  local[ 'f' ] is my_function
    log CND.truth backup[ 'f' ] is my_function
    whisper 'A', backup
    local.n           = 12345678
    local.bar[ 'x' ]  = 2357
    local.foo.push 'ZZ'
    changeset_out     = DIFFPATCH.diff backup, local
    log CND.truth  local[ 'f' ] is my_function
    log CND.truth backup[ 'f' ] is my_function
    # log rpr local
    #.........................................................................................................
    for change in changeset_out
      log 'C', rpr change
  #.........................................................................................................
# test_functions_in_changeset()

#-----------------------------------------------------------------------------------------------------------
test_changeset = ->
  LODASH                    = require 'lodash'
  D                         = require 'pipedreams'
  $                         = D.remit.bind D
  $async                    = D.remit_async.bind D
  $observe                  = D.$observe.bind D
  MD_READER                 = ( require '../mingkwai-typesetter' ).MD_READER
  hide                      = MD_READER.hide.bind        MD_READER
  copy                      = MD_READER.copy.bind        MD_READER
  stamp                     = MD_READER.stamp.bind       MD_READER
  unstamp                   = MD_READER.unstamp.bind     MD_READER
  select                    = MD_READER.select.bind      MD_READER
  is_hidden                 = MD_READER.is_hidden.bind   MD_READER
  is_stamped                = MD_READER.is_stamped.bind  MD_READER
  input                     = D.create_throughstream()
  rpr                      = ( x ) -> ( ( require 'util' ).inspect x, colors: yes, depth: 2 ).replace /\n * /g, ' '
  #.........................................................................................................
  sandbox =
    f:        -> 108
    n:        42
    foo:      Array.from 'shrdlu'
    bar:      { x: 33, y: 54, }
  #.........................................................................................................
  input
    #.......................................................................................................
    .pipe do =>
      local   = {}
      backup  = null
      #.....................................................................................................
      return $ ( event, send ) =>
        #...................................................................................................
        if select event, '~', 'change'
          [ _, _, parameters, _, ]  = event
          [ name, changeset, ]      = parameters
          #.................................................................................................
          if name is 'sandbox'
            local   = DIFFPATCH.patch changeset, local
          #.................................................................................................
          send event
        #...................................................................................................
        else if select event, '~', 'add-ten'
          send event
          #.................................................................................................
          backup    = DIFFPATCH.snapshot local
          local.n   = ( local.n ? 0 ) + 10
          changeset = DIFFPATCH.diff backup, local
          #.................................................................................................
          log 'A', rpr local
          send [ '~', 'change', [ 'sandbox', changeset, ], null, ]
        #...................................................................................................
        else if select event, '~', 'frob'
          send event
          #.................................................................................................
          backup    = DIFFPATCH.snapshot local
          local.foo.push [ 'X', 'Y', 'Z', ]
          changeset = DIFFPATCH.diff backup, local
          #.................................................................................................
          log 'A', rpr local
          send [ '~', 'change', [ 'sandbox', changeset, ], null, ]
        #...................................................................................................
        else if select event, '~', 'drab'
          send event
          #.................................................................................................
          backup    = DIFFPATCH.snapshot local
          local.bar[ 'z' ] = local.foo
          changeset = DIFFPATCH.diff backup, local
          #.................................................................................................
          log 'A', rpr local
          send [ '~', 'change', [ 'sandbox', changeset, ], null, ]
        #...................................................................................................
        else
          send event
    #.......................................................................................................
    # .pipe $observe ( event ) => log rpr event
    #.......................................................................................................
    .pipe $observe ( event ) =>
      #.....................................................................................................
      if select event, '~', 'change'
        [ _, _, parameters, _, ]  = event
        [ name, changeset, ]      = parameters
        #.................................................................................................
        if name is 'sandbox'
          for change in changeset
            whisper change
    #.......................................................................................................
    .pipe do =>
      local   = {}
      #.....................................................................................................
      return $observe ( event ) =>
        #...................................................................................................
        if select event, '~', 'change'
          [ _, _, parameters, _, ]  = event
          [ name, changeset, ]      = parameters
          #.................................................................................................
          if name is 'sandbox'
            local = DIFFPATCH.patch changeset, local
            log 'B', rpr local
  #.........................................................................................................
  changeset = DIFFPATCH.diff {}, sandbox
  input.write [ '~', 'change', [ 'sandbox', changeset, ], null, ]
  input.write [ '~', 'add-ten', null, null, ]
  # input.write [ '~', 'frob', null, null, ]
  # input.write [ '~', 'drab', null, null, ]
  input.end()
test_changeset()
```


###





############################################################################################################
# CND                       = require 'cnd'
# rpr                       = CND.rpr
# badge                     = 'MK/TS/JIZURA/main'
# log                       = CND.get_logger 'plain',     badge
# info                      = CND.get_logger 'info',      badge
# whisper                   = CND.get_logger 'whisper',   badge
# alert                     = CND.get_logger 'alert',     badge
# debug                     = CND.get_logger 'debug',     badge
# warn                      = CND.get_logger 'warn',      badge
# help                      = CND.get_logger 'help',      badge
# urge                      = CND.get_logger 'urge',      badge
# echo                      = CND.echo.bind CND
diff                      = require 'changeset'
LODASH                    = require 'lodash'

#-----------------------------------------------------------------------------------------------------------
@snapshot = ( original )      -> LODASH.cloneDeep original
@diff     = ( x, y )          -> diff x, y
@patch    = ( changeset, x )  -> diff.apply changeset, x
