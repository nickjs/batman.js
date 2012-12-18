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
          model.set @foreignKey, base.get(@primaryKey)
      base.set @label, set = @setForRecord(base)
      if base.lifecycle.get('state') == 'creating'
        set.markAsLoaded()

  encoder: ->
    association = @
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
    association = @
    (data, key, _, __, parentRecord) ->
      unless relatedModel = association.getRelatedModel()
        Batman.developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
        return

      existingRelations = association.setForRecord(parentRecord)
      newRelations = existingRelations.filter((relation) -> relation.isNew()).toArray()

      for jsonObject in data
        id = jsonObject[relatedModel.primaryKey]
        existingRecord = relatedModel.get('loaded.indexedByUnique.id').get(id)

        if existingRecord?
          existingRecord._withoutDirtyTracking -> @fromJSON jsonObject
          record = existingRecord
        else
          if newRelations.length > 0
            savedRecord = newRelations.shift()
            savedRecord._withoutDirtyTracking -> @fromJSON jsonObject
            record = relatedModel._mapIdentity(savedRecord)
          else
            record = relatedModel._makeOrFindRecordFromData(jsonObject)

        existingRelations.add record

        if association.options.inverseOf
          record.set association.options.inverseOf, parentRecord

      existingRelations.markAsLoaded()
      existingRelations
