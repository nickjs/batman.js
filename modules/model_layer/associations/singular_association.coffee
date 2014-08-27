Association = require './association'
UniqueAssociationSetIndex = require './unique_association_set_index'
{Property, mixin} = require 'foundation'
{helpers} = require 'utilities'


module.exports = class SingularAssociation extends Association
  isSingular: true

  constructor: (@model, @label, options = {}) ->
    super
    @foreignKey = @options.foreignKey
    @primaryKey = @options.primaryKey

  provideDefaults: ->
    mixin super,
      name: helpers.camelize(@label)

  getAccessor: (association, model, label) ->
    # Check whether the relation has already been set on this model
    if recordInAttributes = association.getFromAttributes(this)
      return recordInAttributes

    # Make sure the related model has been loaded
    if association.getRelatedModel()
      proxy = @associationProxy(association)

      alreadyLoaded = Property.withoutTracking(-> proxy.get('loaded'))
      if !alreadyLoaded && association.options.autoload
        Property.withoutTracking(-> proxy.load())

    proxy

  setIndex: ->
    @index ||= new UniqueAssociationSetIndex(this, @[@indexRelatedModelOn])
