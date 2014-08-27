SingularAssociation = require './singular_association'
BelongsToProxy = require './belongs_to_proxy'
HasManyAssociation = require './has_many_association'

{mixin} = require 'foundation'

module.exports = class BelongsToAssociation extends SingularAssociation
  associationType: 'belongsTo'
  proxyClass: BelongsToProxy
  indexRelatedModelOn: 'primaryKey'

  constructor: (model, label, options) ->
    if options?.polymorphic
      delete options.polymorphic
      return new Batman.PolymorphicBelongsToAssociation(arguments...)
    super

    @model.encode @foreignKey if @options.encodeForeignKey

  provideDefaults: ->
    mixin super,
      encodeForeignKey: true
      foreignKey: "#{@label}_id"
      primaryKey: "id"

  encoder: -> (val) -> val.toJSON()
  decoder: ->
    association = @
    (data, _, __, ___, childRecord) ->
      relatedModel = association.getRelatedModel()
      record = relatedModel.createFromJSON(data)
      if association.options.inverseOf
        if inverse = association.inverse()
          if inverse instanceof HasManyAssociation
            # Rely on the parent's set index to get this out.
            childRecord.set(association.foreignKey, record.get(association.primaryKey))
          else
            record.set(inverse.label, childRecord)
      childRecord.set(association.label, record)
      record

  apply: (base) ->
    if model = base.get(@label)
      foreignValue = model.get(@primaryKey)
      if foreignValue isnt undefined
        base.set @foreignKey, foreignValue
