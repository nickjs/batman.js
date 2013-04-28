Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter'
Clunk  = require '../lib/clunk'

clunks = []
internalClunks = []

Watson.trackMemory 'object instantiation memory usage', 2000, (i) ->
  clunks.push new Clunk(foo: i)

Watson.trackMemory 'interal object instantiation memory usage', 2000, (i) ->
  internalClunks.push clunk = new Batman.InternalObject()
  clunk.set 'foo', i
