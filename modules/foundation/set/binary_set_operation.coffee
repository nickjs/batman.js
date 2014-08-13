Set = require './set'
SetProxy = require './set_proxy'

module.exports = class BinarySetOperation extends Set
  constructor: (@left, @right) ->
    super()
    @_setup @left, @right
    @_setup @right, @left

  _setup: (set, opposite) =>
    set.on 'itemsWereAdded', (items) =>
      @_itemsWereAddedToSource(set, opposite, items...)
    set.on 'itemsWereRemoved', (items) =>
      @_itemsWereRemovedFromSource(set, opposite, items...)
    @_itemsWereAddedToSource set, opposite, set.toArray()...

  merge: (others...) ->
    merged = new Set
    others.unshift(@)
    for set in others
      set.forEach (v) -> merged.add v
    merged

  filter: SetProxy::filter
