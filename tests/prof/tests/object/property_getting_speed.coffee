Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
Clunk  = require '../lib/clunk'
Random = require '../lib/number_generator'

Watson.benchmark 'property getting', (error, suite) ->
  throw error if error

  do ->
    clunks = (new Clunk({i}) for i in [0..1000])
    suite.add 'getting with no sources', ->
      for clunk in clunks
        clunk.property('i').cached = false
        clunk.get('i')
      true

  do ->
    class ClunkWithAccessor extends Clunk
      @accessor 'bar', ->
        @get('i') + 1

    clunks = (new ClunkWithAccessor({i}) for i in [0..1000])

    suite.add 'getting with 1 source', ->
      for clunk in clunks
        clunk.property('bar').cached = false
        clunk.get('bar')
      true

  do ->
    class ClunkWithAccessor extends Clunk
      @accessor 'bar', ->
        @get('foo')
        @get('baz')
        @get('i') + 1

    clunks = (new ClunkWithAccessor({i}) for i in [0..1000])

    suite.add 'getting with 3 sources', ->
      for clunk in clunks
        clunk.property('bar').cached = false
        clunk.get('bar')
      true

  do ->
    clunks = for i in [0..1000]
      clunk = new Batman.InternalObject
      clunk.set 'i', i
      clunk

    suite.add 'InternalObject: getting with no sources', ->
      for clunk in clunks
        clunk.property('i').cached = false
        clunk.get('i')
      true

  do ->
    class ClunkWithAccessor extends Batman.InternalObject
      @accessor 'bar', ->
        @get('i') + 1

    clunks = (new ClunkWithAccessor({i}) for i in [0..1000])

    suite.add 'InternalObject: getting with 1 source', ->
      for clunk in clunks
        clunk.property('bar').cached = false
        clunk.get('bar')
      true

  do ->
    class ClunkWithAccessor extends Batman.InternalObject
      @accessor 'bar', ->
        @get('foo')
        @get('baz')
        @get('i') + 1

    clunks = (new ClunkWithAccessor({i}) for i in [0..1000])

    suite.add 'InternalObject: getting with 3 sources', ->
      for clunk in clunks
        clunk.property('bar').cached = false
        clunk.get('bar')
      true

  suite.run()
