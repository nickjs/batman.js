# Properties that are mixed into model instances returned from Model::transaction()
Batman.Transaction =
  isTransaction: true

  base: ->
    @_batman.base

  applyChanges: (visited = [], options = {}) ->
    return @base() if this in visited
    visited.push(this)

    only = options.only
    if only? and Batman.typeOf(only) isnt "Array"
      only = [only]

    except = options.except
    if except? and Batman.typeOf(except) isnt "Array"
      except = [except]

    attributes = @get('attributes').toObject()

    for own key, value of attributes
      if except? and key in except
        delete attributes[key]
      else if only? and !(key in only)
        delete attributes[key]
      else if value instanceof Batman.Model && value.isTransaction
        value.applyChanges(visited)
        delete attributes[key]
      else if value instanceof Batman.TransactionAssociationSet
        updatedAssociationSet = value.applyChanges(visited)
        attributes[key] = updatedAssociationSet

    base = @base()
    base.mixin(attributes)
    base.applyChanges?() ? base

  save: (options, callback) ->
    if !callback
      [options, callback] = [{}, options]

    applyChangesOptions = {only: options.only, except: options.except}

    @once 'validated', validated = =>
      @applyChanges([], applyChangesOptions)

    finish = =>
      @off 'validated', validated
      callback?(arguments...)

    @constructor::save.call this, options, (err, result) =>
      if not err
        result = @base()
        result.get('dirtyKeys').clear()
        result.get('_dirtiedKeys').clear()
        result.get('lifecycle').startTransition('save')
        result.get('lifecycle').startTransition('saved')

      finish(err, result)
