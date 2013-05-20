Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter.coffee'
Clunk  = require '../lib/clunk.coffee'

clunks = []

Watson.trackMemory 'object instantiation memory usage', 2000, (i) ->
  clunks.push new Clunk(foo: i)
