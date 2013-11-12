#= require ./association

class Batman.SingularAssociation extends Batman.Association
  isSingular: true

  getAccessor: (association, model, label) ->
    # Check whether the relation has already been set on this model
    if recordInAttributes = association.getFromAttributes(this)
      return recordInAttributes

    # Make sure the related model has been loaded
    if association.getRelatedModel()
      proxy = @associationProxy(association)
      record = false

      unless Batman.Property.withoutTracking(-> proxy.get('loaded'))
        if association.options.autoload
          Batman.Property.withoutTracking(-> proxy.load())
        else
          record = proxy.loadFromLocal()

      record || proxy

  setIndex: ->
    @index ||= new Batman.UniqueAssociationSetIndex(this, @[@indexRelatedModelOn])

