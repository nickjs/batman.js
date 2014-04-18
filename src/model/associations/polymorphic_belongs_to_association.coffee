#= require ./belongs_to_association
#= require ./polymorphic_belongs_to_proxy

class Batman.PolymorphicBelongsToAssociation extends Batman.BelongsToAssociation
  isPolymorphic: true
  proxyClass: Batman.PolymorphicBelongsToProxy
  defaultOptions: Batman.mixin({}, Batman.BelongsToAssociation::defaultOptions, {encodeForeignTypeKey: true})

  constructor: ->
    super
    @foreignTypeKey = @options.foreignTypeKey or "#{@label}_type"
    @model.encode @foreignTypeKey if @options.encodeForeignTypeKey
    @typeIndices = {}

  getRelatedModel: false
  setIndex: false
  inverse: false

  apply: (base) ->
    super
    if instanceOrProxy = base.get(@label)
      foreignTypeValue = if instanceOrProxy instanceof Batman.PolymorphicBelongsToProxy
        instanceOrProxy.get('foreignTypeValue')
      else
        instanceOrProxy.constructor.get('resourceName')
      base.set @foreignTypeKey, foreignTypeValue

  getAccessor: (self, model, label) ->
    # Check whether the relation has already been set on this model
    if recordInAttributes = self.getFromAttributes(@)
      return recordInAttributes

    # Make sure the related model has been loaded
    if self.getRelatedModelForType(@get(self.foreignTypeKey))
      proxy = @associationProxy(self)
      Batman.Property.withoutTracking ->
        if not proxy.get('loaded') and self.options.autoload
          proxy.load()
      proxy

  url: (recordOptions) ->
    type = recordOptions.data?[@foreignTypeKey]
    if type && inverse = @inverseForType(type)
      root = Batman.helpers.pluralize(type).toLowerCase()
      id = recordOptions.data?[@foreignKey]
      helper = if inverse.isSingular then "singularize" else "pluralize"
      ending = Batman.helpers[helper](inverse.label)

      return "/#{root}/#{id}/#{ending}"

  getRelatedModelForType: (type) ->
    scope = @options.namespace or Batman.currentApp
    if type
      relatedModel = scope?[type]
      relatedModel ||= scope?[Batman.helpers.camelize(type)]
    Batman.developer.do ->
      if Batman.currentApp? and not relatedModel
        Batman.developer.warn "Related model #{type} for belongsTo polymorphic association #{@label} not found."
    relatedModel

  setIndexForType: (type) ->
    @typeIndices[type] ||= new Batman.PolymorphicUniqueAssociationSetIndex(@, type, @primaryKey)
    @typeIndices[type]

  inverseForType: (type) ->
    if relatedAssocs = @getRelatedModelForType(type)?._batman.get('associations')
      if @options.inverseOf
        return relatedAssocs.getByLabel(@options.inverseOf)

      inverse = null
      relatedAssocs.forEach (label, assoc) =>
        if assoc.getRelatedModel() is @model
          inverse = assoc
      inverse

  decoder: ->
    association = @
    (data, key, response, ___, childRecord) ->
      foreignTypeValue = response[association.foreignTypeKey] || childRecord.get(association.foreignTypeKey)
      relatedModel = association.getRelatedModelForType(foreignTypeValue)
      record = relatedModel.createFromJSON(data)
      if association.options.inverseOf
        if inverse = association.inverseForType(foreignTypeValue)
          if inverse instanceof Batman.PolymorphicHasManyAssociation
            # Rely on the parent's set index to get this out.
            childRecord.set(association.foreignKey, record.get(association.primaryKey))
            childRecord.set(association.foreignTypeKey, foreignTypeValue)
          else
            record.set(inverse.label, childRecord)
      childRecord.set(association.label, record)
      record
