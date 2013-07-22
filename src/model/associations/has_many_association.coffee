#= require ./plural_association

class Batman.HasManyAssociation extends Batman.PluralAssociation
  associationType: 'hasMany'
  indexRelatedModelOn: 'foreignKey'

  constructor: (model, label, options) ->
    if options?.as
      return new Batman.PolymorphicHasManyAssociation(arguments...)
    super
    @primaryKey = @options.primaryKey or "id"
    @foreignKey = @options.foreignKey or "#{Batman.helpers.underscore(model.get('resourceName'))}_id"

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relations = @getFromAttributes(base)
        relations.forEach (model) =>
          model.set(@foreignKey, base.get(@primaryKey))

      base.set @label, set = @setForRecord(base)
      if base.lifecycle.get('state') == 'creating'
        set.markAsLoaded()

  encoder: ->
    association = this
    (relationSet, _, __, record) ->
      if relationSet?
        jsonArray = []
        relationSet.forEach (relation) ->
          relationJSON = relation.toJSON()
          if !association.inverse() || association.inverse().options.encodeForeignKey
            relationJSON[association.foreignKey] = record.get(association.primaryKey)
          jsonArray.push relationJSON

      jsonArray

  decoder: ->
    association = this
    (data, key, _, __, parentRecord) ->
      unless relatedModel = association.getRelatedModel()
        Batman.developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
        return

      children = association.setForRecord(parentRecord)
      newChildren = children.filter((relation) -> relation.isNew()).toArray()

      recordsToMap = []
      recordsToAdd = []

      for jsonObject in data
        id = jsonObject[relatedModel.primaryKey]
        record = relatedModel._loadIdentity(id)

        if record?
          recordsToAdd.push(record)
        else
          if newChildren.length > 0
            record = newChildren.shift()
            recordsToMap.push(record) if id?
          else
            record = new relatedModel
            recordsToMap.push(record) if id?
            recordsToAdd.push(record)

        record._withoutDirtyTracking ->
          @fromJSON(jsonObject)

          if association.options.inverseOf
            record.set(association.options.inverseOf, parentRecord)

      # We're already sure that these records aren't in the map already, since we just checked
      relatedModel.get('loaded').add(recordsToMap...)

      children.add(recordsToAdd...)
      children.markAsLoaded()
      children
