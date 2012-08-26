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
      Batman.Property.withoutTracking =>
        if not proxy.get('loaded') and self.options.autoload
          parent = @
          proxy.load (err, child) ->
            self.setIntoAttributes(parent, child) unless err
      proxy

  setIndex: ->
    @index ||= new Batman.UniqueAssociationSetIndex(@, @[@indexRelatedModelOn])
    @index
