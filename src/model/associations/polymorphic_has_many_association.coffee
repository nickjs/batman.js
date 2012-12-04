#= require ./has_many_association

class Batman.PolymorphicHasManyAssociation extends Batman.HasManyAssociation
  proxyClass: Batman.PolymorphicAssociationSet
  isPolymorphic: true
  constructor: (model, label, options) ->
    options.inverseOf = @foreignLabel = options.as
    delete options.as
    options.foreignKey ||= "#{@foreignLabel}_id"
    super(model, label, options)
    @foreignTypeKey = options.foreignTypeKey || "#{@foreignLabel}_type"
    @model.encode @foreignTypeKey

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relations = @getFromAttributes(base)
        super
        relations.forEach (model) => model.set @foreignTypeKey, @modelType()
    true

  proxyClassInstanceForKey: (indexValue) ->
    new @proxyClass(indexValue, @modelType(), this)

  getRelatedModelForType: (type) ->
    scope = @options.namespace or Batman.currentApp
    if type
      relatedModel = scope?[type]
      relatedModel ||= scope?[Batman.helpers.camelize(type)]
    else
      relatedModel = @getRelatedModel()
    Batman.developer.do ->
      if Batman.currentApp? and not relatedModel
        Batman.developer.warn "Related model #{type} for polymorphic association not found."
    relatedModel

  modelType: -> @model.get('resourceName')

  setIndex: ->
    @typeIndex ||= new Batman.PolymorphicAssociationSetIndex(@, @modelType(), @[@indexRelatedModelOn])
    @typeIndex

  encoder: ->
    association = @
    (relationSet, _, __, record) ->
      if relationSet?
        jsonArray = []
        relationSet.forEach (relation) ->
          relationJSON = relation.toJSON()
          relationJSON[association.foreignKey] = record.get(association.primaryKey)
          relationJSON[association.foreignTypeKey] = association.modelType()
          jsonArray.push relationJSON

      jsonArray

  decoder: ->
    association = @
    (data, key, _, __, parentRecord) ->
      if relatedModel = association.getRelatedModel()
        existingRelations = association.getFromAttributes(parentRecord) || association.setForRecord(parentRecord)
        newRelations = existingRelations.filter((relation) -> relation.isNew()).toArray()
        for jsonObject in data
          type = jsonObject[association.options.foreignTypeKey];
          subType = association.getRelatedModelForType(type)
          record = new subType()
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

        existingRelations.markAsLoaded()
      else
        Batman.developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
      existingRelations
