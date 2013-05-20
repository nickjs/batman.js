Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
Clunk  = require '../lib/clunk.coffee'

set = new Batman.SimpleSet

Watson.trackMemory 'simple set memory usage with strings', 10000, (i) ->
  set.add "fooooooo" + i
  if i % 2000 == 0
    set.clear()
