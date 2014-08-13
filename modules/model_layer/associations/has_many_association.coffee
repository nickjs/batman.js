PluralAssociation = require './plural_association'
{Property, developer, mixin} = require 'foundation'
{helpers} = require 'utilities'

module.exports = class HasManyAssociation extends PluralAssociation
  associationType: 'hasMany'
  indexRelatedModelOn: 'foreignKey'

  constructor: (model, label, options) ->
    if options?.as
      return new Batman.PolymorphicHasManyAssociation(arguments...)
    super
    @primaryKey = @options.primaryKey
    @foreignKey = @options.foreignKey

  provideDefaults: ->
    mixin super,
      primaryKey: "id"
      foreignKey: "#{helpers.underscore(@model.get('resourceName'))}_id"
      replaceFromJSON: true

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relations = @getFromAttributes(base)
        primaryKeyValue = base.get(@primaryKey)
        relations.forEach (childRecord) =>
          childRecord.set(@foreignKey, primaryKeyValue)

      base.set @label, set = @setForRecord(base)
      if base.lifecycle.get('state') == 'creating'
        set.markAsLoaded()

  encoder: ->
    if @options.encodeWithIndexes
      @_objectEncoder.bind(@)
    else
      @_arrayEncoder.bind(@)

  _objectEncoder:  (relationSet, _, __, record) ->
    if relationSet?
      json = {}

      unless relationSet instanceof Array
        relationSet = relationSet.toArray()

      for i, relation of relationSet
        relationJSON = relation.toJSON()
        if !@inverse() || @inverse().options.encodeForeignKey
          relationJSON[@foreignKey] = record.get(@primaryKey)
        json[i] = relationJSON
      json

  _arrayEncoder: (relationSet, _, __, record) ->
    if relationSet?
      jsonArray = []
      relationSet.forEach (relation) =>
        relationJSON = relation.toJSON()
        if !@inverse() || @inverse().options.encodeForeignKey
          relationJSON[@foreignKey] = record.get(@primaryKey)
        jsonArray.push relationJSON
      jsonArray

  decoder: ->
    association = this
    (data, key, _, __, parentRecord) ->
      unless relatedModel = association.getRelatedModel()
        developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
        return

      children = association.setForRecord(parentRecord)
      newChildren = children.filter((relation) -> relation.isNew()).toArray()

      recordsToMap = []
      allRecords = []

      for i, jsonObject of data
        id = jsonObject[relatedModel.primaryKey]
        record = relatedModel._loadIdentity(id)

        if !record?
          if newChildren.length > 0
            record = newChildren.shift()
          else
            record = new relatedModel
          recordsToMap.push(record) if id?

        allRecords.push(record)

        record._withoutDirtyTracking ->
          @fromJSON(jsonObject)

          if association.options.inverseOf
            record.set(association.options.inverseOf, parentRecord)

      # We're already sure that these records aren't in the map already, since we just checked
      relatedModel.get('loaded').addArray(recordsToMap)

      if association.options.replaceFromJSON
        children.replace(allRecords)
      else
        children.addArray(allRecords)

      children.markAsLoaded()
      children
