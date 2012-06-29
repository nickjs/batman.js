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
      base.set @label, @setForRecord(base)

  encoder: ->
    association = @
    return {
      encode: (relationSet, _, __, record) ->
        return if association._beingEncoded
        association._beingEncoded = true
        return unless association.options.saveInline
        if relationSet?
          jsonArray = []
          relationSet.forEach (relation) ->
            relationJSON = relation.toJSON()
            if !association.inverse() || association.inverse().options.encodeForeignKey
              relationJSON[association.foreignKey] = record.get(association.primaryKey)
            jsonArray.push relationJSON

        delete association._beingEncoded
        jsonArray

      decode: (data, key, _, __, parentRecord) ->
        if relatedModel = association.getRelatedModel()
          existingRelations = association.getFromAttributes(parentRecord) || association.setForRecord(parentRecord)
          newRelations = existingRelations.filter((relation) -> relation.isNew()).toArray()
          for jsonObject in data
            record = new relatedModel()
            record._withoutDirtyTracking -> @fromJSON(jsonObject)
            existingRecord = relatedModel.get('loaded').indexedByUnique('id').get(record.get('id'))
            if existingRecord?
              existingRecord._withoutDirtyTracking -> @fromJSON jsonObject
              record = existingRecord
            else
              if newRelations.length > 0
                savedRecord = newRelations.shift()
                savedRecord._withoutDirtyTracking -> @fromJSON jsonObject
                record = savedRecord
            record = relatedModel._mapIdentity(record)
            existingRelations.add record

            if association.options.inverseOf
              record.set association.options.inverseOf, parentRecord

          existingRelations.set 'loaded', true
        else
          Batman.developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
        existingRelations
    }

