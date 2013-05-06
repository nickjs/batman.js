Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter.coffee'
Clunk  = require '../lib/clunk.coffee'

clunks = []
observerA = ->
observerB = ->

Watson.trackMemory 'object instantiation with observers memory usage', 2000, (i) ->
  clunks.push clunk = new Clunk(foo: i)
  clunk.observe 'foo', observerA
  clunk.on 'explode', observerB
