#= require singular_association

class Batman.HasOneAssociation extends Batman.SingularAssociation
  associationType: 'hasOne'
  proxyClass: Batman.HasOneProxy
  indexRelatedModelOn: 'foreignKey'

  constructor: ->
    super
    @primaryKey = @options.primaryKey or "id"
    @foreignKey = @options.foreignKey or "#{Batman.helpers.underscore(@model.get('resourceName'))}_id"

  apply: (baseSaveError, base) ->
    if relation = @getFromAttributes(base)
      relation.set @foreignKey, base.get(@primaryKey)

  encoder: ->
    association = @
    return {
      encode: (val, key, object, record) ->
        return unless association.options.saveInline
        if json = val.toJSON()
          json[association.foreignKey] = record.get(association.primaryKey)
        json
      decode: (data, _, __, ___, parentRecord) ->
        relatedModel = association.getRelatedModel()
        record = new (relatedModel)()
        record.fromJSON(data)
        if association.options.inverseOf
          record.set association.options.inverseOf, parentRecord
        record = relatedModel._mapIdentity(record)
        record
    }
