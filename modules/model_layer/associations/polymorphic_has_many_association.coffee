HasManyAssociation = require './has_many_association'
PolymorphicAssociationSet = require './polymorphic_association_set'
PolymorphicAssociationSetIndex = require './polymorphic_association_set_index'

{developer, mixin} = require 'foundation'
{helpers} = require 'utilities'

module.exports = class PolymorphicHasManyAssociation extends HasManyAssociation
  proxyClass: PolymorphicAssociationSet
  isPolymorphic: true

  constructor: (model, label, options) ->
    @foreignLabel = options.as
    delete options.as

    super(model, label, options)

    @foreignTypeKey = options.foreignTypeKey || "#{@foreignLabel}_type"
    @model.encode @foreignTypeKey

  provideDefaults: (options) ->
    mixin {}, super,
      inverseOf: @foreignLabel
      foreignKey: "#{@foreignLabel}_id"

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relations = @getFromAttributes(base)
        super
        relations.forEach (model) => model.set @foreignTypeKey, @modelType()
    return

  proxyClassInstanceForKey: (indexValue) ->
    new @proxyClass(indexValue, @modelType(), this)

  getRelatedModelForType: (type) ->
    scope = @scope()

    if type
      relatedModel = scope?[type]
      relatedModel ||= scope?[helpers.camelize(type)]
    else
      relatedModel = @getRelatedModel()

    developer.do ->
      if Batman.currentApp? and not relatedModel
        developer.warn "Related model #{type} for hasMany polymorphic association #{@label} not found."

    relatedModel

  modelType: -> @model.get('resourceName')

  setIndex: ->
    @typeIndex ||= new PolymorphicAssociationSetIndex(this, @modelType(), @[@indexRelatedModelOn])

  encoder: ->
    association = this
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
    association = this
    (data, key, _, __, parentRecord) ->
      children = association.getFromAttributes(parentRecord) || association.setForRecord(parentRecord)
      newChildren = children.filter((relation) -> relation.isNew()).toArray()

      allRecords = []

      for jsonObject in data
        type = jsonObject[association.options.foreignTypeKey]

        unless relatedModel = association.getRelatedModelForType(type)
          developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
          return

        id = jsonObject[relatedModel.primaryKey]
        record = relatedModel._loadIdentity(id)
        if record?
          record._withoutDirtyTracking -> @fromJSON(jsonObject)
          allRecords.push(record)
        else
          if newChildren.length > 0
            record = newChildren.shift()
            record._withoutDirtyTracking -> @fromJSON(jsonObject)
            record = relatedModel._mapIdentity(record)
          else
            record = relatedModel.createFromJSON(jsonObject)
          allRecords.push(record)

        if association.options.inverseOf
          record._withoutDirtyTracking ->
            record.set(association.options.inverseOf, parentRecord)

      if association.options.replaceFromJSON
        children.replace(allRecords)
      else
        children.addArray(allRecords)
      children.markAsLoaded()
      children
