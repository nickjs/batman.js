Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter'
Clunk  = require '../lib/clunk'

clunks = []
internalClunks = []
observerA = ->
observerB = ->

Watson.trackMemory 'object instantiation with observers memory usage', 2000, (i) ->
  clunks.push clunk = new Clunk(foo: i)
  clunk.observe 'foo', observerA
  clunk.on 'explode', observerB

Watson.trackMemory 'internal object instantiation with observers memory usage', 2000, (i) ->
  clunks.push clunk = new Batman.InternalObject()
  clunk.set 'foo', i
  clunk.observe 'foo', observerA
  clunk.on 'explode', observerB
