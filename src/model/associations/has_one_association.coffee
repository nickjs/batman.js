#= require ./singular_association
#= require ./has_one_proxy

class Batman.HasOneAssociation extends Batman.SingularAssociation
  associationType: 'hasOne'
  proxyClass: Batman.HasOneProxy
  indexRelatedModelOn: 'foreignKey'

  constructor: ->
    super
    @primaryKey = @options.primaryKey
    @foreignKey = @options.foreignKey

  provideDefaults: ->
    Batman.mixin super,
      primaryKey: "id"
      foreignKey: "#{Batman.helpers.underscore(@model.get('resourceName'))}_id"

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
