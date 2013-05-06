Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
Clunk  = require '../lib/clunk.coffee'

hash = new Batman.Hash
Batman.developer?.suppress()

Watson.trackMemory 'hash memory usage with objects', 10000, (i) ->
  hash.set {i}, new Clunk
  if i % 2000 == 0
    hash.clear()
