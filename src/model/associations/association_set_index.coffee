#= require ../../set/set_index

class Batman.AssociationSetIndex extends Batman.SetIndex
  constructor: (@association, key) ->
    super @association.getRelatedModel().get('loaded'), key

  _resultSetForKey: (key) -> @association.setForKey(key)

  forEach: (iterator, ctx) ->
    @association.proxies.forEach (record, set) =>
      key = @association.indexValueForRecord(record)
      iterator.call(ctx, key, set, this) if set.get('length') > 0

  toArray: ->
    results = []
    @forEach (key, set) -> results.push(key)
    results
