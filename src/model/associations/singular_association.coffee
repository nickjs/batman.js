#= require ./association

class Batman.SingularAssociation extends Batman.Association
  isSingular: true

  getAccessor: (self, model, label) ->
    # Check whether the relation has already been set on this model
    if recordInAttributes = self.getFromAttributes(@)
      return recordInAttributes

    # Make sure the related model has been loaded
    if self.getRelatedModel()
      proxy = @associationProxy(self)
      record = false
      parent = @
      proxy._loadSetter ?= proxy.once 'loaded', (child) -> parent.set(self.label, child)
      if not Batman.Property.withoutTracking(-> proxy.get('loaded'))
        if self.options.autoload
          Batman.Property.withoutTracking(-> proxy.load())
        else
          record = proxy.loadFromLocal()
      record || proxy

  setIndex: ->
    @index ||= new Batman.UniqueAssociationSetIndex(@, @[@indexRelatedModelOn])
    @index
