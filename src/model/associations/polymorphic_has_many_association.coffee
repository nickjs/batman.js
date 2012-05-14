#= require ./has_many_association

class Batman.PolymorphicHasManyAssociation extends Batman.HasManyAssociation
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

  getRelatedModelForType: -> @getRelatedModel()

  modelType: -> @model.get('resourceName')

  setIndex: ->
    if !@typeIndex
      @typeIndex = new Batman.PolymorphicAssociationSetIndex(@, @modelType(), @[@indexRelatedModelOn])
    @typeIndex

  encoder: ->
    association = @
    encoder = super
    encoder.encode = (relationSet, _, __, record) ->
      return if association._beingEncoded
      association._beingEncoded = true

      return unless association.options.saveInline
      if relationSet?
        jsonArray = []
        relationSet.forEach (relation) ->
          relationJSON = relation.toJSON()
          relationJSON[association.foreignKey] = record.get(association.primaryKey)
          relationJSON[association.foreignTypeKey] = association.modelType()
          jsonArray.push relationJSON

      delete association._beingEncoded
      jsonArray
    encoder

