#= require ./singular_association
#= require ./belongs_to_proxy

class Batman.BelongsToAssociation extends Batman.SingularAssociation
  associationType: 'belongsTo'
  proxyClass: Batman.BelongsToProxy
  indexRelatedModelOn: 'primaryKey'
  defaultOptions:
    saveInline: false
    autoload: true
    encodeForeignKey: true

  constructor: (model, label, options) ->
    if options?.polymorphic
      delete options.polymorphic
      return new Batman.PolymorphicBelongsToAssociation(arguments...)
    super
    @foreignKey = @options.foreignKey or "#{@label}_id"
    @primaryKey = @options.primaryKey or "id"
    @model.encode @foreignKey if @options.encodeForeignKey

  encoder: -> (val) -> val.toJSON()
  decoder: ->
    association = @
    (data, _, __, ___, childRecord) ->
      return unless data?
      relatedModel = association.getRelatedModel()
      record = relatedModel.createFromJSON(data)
      if association.options.inverseOf
        if inverse = association.inverse()
          if inverse instanceof Batman.HasManyAssociation
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
