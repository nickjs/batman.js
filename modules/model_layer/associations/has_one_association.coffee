SingularAssociation = require './singular_association'
HasOneProxy = require './has_one_proxy'
{helpers} = require 'utilities'
{mixin} = require 'foundation'

module.exports = class HasOneAssociation extends SingularAssociation
  associationType: 'hasOne'
  proxyClass: HasOneProxy
  indexRelatedModelOn: 'foreignKey'

  provideDefaults: ->
    mixin super,
      primaryKey: "id"
      foreignKey: "#{helpers.underscore(@model.get('resourceName'))}_id"

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relation = @getFromAttributes(base)
        relation.set @foreignKey, base.get(@primaryKey)

  encoder: ->
    association = this
    (val, key, object, record) ->
      return unless association.options.saveInline
      if json = val.toJSON()
        json[association.foreignKey] = record.get(association.primaryKey)
      json

  decoder: ->
    association = this
    (data, _, __, ___, parentRecord) ->
      return unless data
      relatedModel = association.getRelatedModel()
      record = relatedModel.createFromJSON(data)
      if association.options.inverseOf
        record.set association.options.inverseOf, parentRecord
      record
