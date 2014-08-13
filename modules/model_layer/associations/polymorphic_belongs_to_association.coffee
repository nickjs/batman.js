BelongsToAssociation = require './belongs_to_association'
PolymorphicBelongsToProxy = require './polymorphic_belongs_to_proxy'
PolymorphicUniqueAssociationSetIndex = require './polymorphic_unique_association_set_index'
PolymorphicHasManyAssociation = require './polymorphic_has_many_association'

{Property, developer, mixin} = require 'foundation'
{helpers} = require 'utilities'

module.exports = class PolymorphicBelongsToAssociation extends BelongsToAssociation
  isPolymorphic: true
  proxyClass: PolymorphicBelongsToProxy

  constructor: ->
    super
    @foreignTypeKey = @options.foreignTypeKey
    @model.encode @foreignTypeKey if @options.encodeForeignTypeKey
    @typeIndices = {}

  getRelatedModel: false
  setIndex: false
  inverse: false

  provideDefaults: ->
    mixin super,
      encodeForeignTypeKey: true
      foreignTypeKey: "#{@label}_type"

  apply: (base) ->
    super
    if instanceOrProxy = base.get(@label)
      foreignTypeValue = if instanceOrProxy instanceof PolymorphicBelongsToProxy
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
      Property.withoutTracking ->
        if not proxy.get('loaded') and self.options.autoload
          proxy.load()
      proxy

  url: (recordOptions) ->
    type = recordOptions.data?[@foreignTypeKey]
    if type && inverse = @inverseForType(type)
      root = helpers.pluralize(type).toLowerCase()
      id = recordOptions.data?[@foreignKey]
      helper = if inverse.isSingular then "singularize" else "pluralize"
      ending = helpers[helper](inverse.label)

      return "/#{root}/#{id}/#{ending}"

  getRelatedModelForType: (type) ->
    scope = @scope()
    if type
      relatedModel = scope?[type]
      relatedModel ||= scope?[helpers.camelize(type)]
    developer.do ->
      if Batman.currentApp? and not relatedModel
        developer.warn "Related model #{type} for belongsTo polymorphic association #{@label} not found."
    relatedModel

  setIndexForType: (type) ->
    @typeIndices[type] ||= new PolymorphicUniqueAssociationSetIndex(@, type, @primaryKey)
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
          if inverse instanceof PolymorphicHasManyAssociation
            # Rely on the parent's set index to get this out.
            childRecord.set(association.foreignKey, record.get(association.primaryKey))
            childRecord.set(association.foreignTypeKey, foreignTypeValue)
          else
            record.set(inverse.label, childRecord)
      childRecord.set(association.label, record)
      record
