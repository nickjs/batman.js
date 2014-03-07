# Properties that are mixed into model instances returned from Model::transaction()
Batman.Transaction =
  isTransaction: true

  base: ->
    @_batman.base

  applyChanges: (visited = []) ->
    # prevent infinite loops!
    return @base if visited.indexOf(this) != -1
    visited.push(this)

    attributes = @get('attributes').toObject()
    # handle special attributes:
    for own key, value of attributes
      if value instanceof Batman.Model && value.isTransaction
        value.applyChanges(visited)
        delete attributes[key]

      else if value instanceof Batman.TransactionAssociationSet
        updatedAssociationSet = value.applyChanges(visited)
        attributes[key] = updatedAssociationSet

    # mixin the rest:
    base = @base()
    base.mixin(attributes)
    base.applyChanges?() ? base

  save: (options, callback) ->
    if !callback
      [options, callback] = [{}, options]

    @once 'validated', validated = => @applyChanges()

    finish = =>
      @off 'validated', validated
      callback?(arguments...)

    # save has been overriden on this instance. Gotta go back to the prototype:
    @constructor::save.call this, options, (err, result) =>
      if not err
        result = @base()
        result.get('dirtyKeys').clear()
        result.get('_dirtiedKeys').clear()
        result.get('lifecycle').startTransition('save')
        result.get('lifecycle').startTransition('saved')

      finish(err, result)
