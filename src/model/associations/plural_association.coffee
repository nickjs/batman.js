#= require association

class Batman.PluralAssociation extends Batman.Association
  isSingular: false

  setForRecord: Batman.Property.wrapTrackingPrevention (record) ->
    if id = record.get(@primaryKey)
      @setIndex().get(id)
    else
      new Batman.AssociationSet(undefined, @)

  getAccessor: (self, model, label) ->
    return unless self.getRelatedModel()

    # Check whether the relation has already been set on this model
    if setInAttributes = self.getFromAttributes(@)
      setInAttributes
    else
      relatedRecords = self.setForRecord(@)
      self.setIntoAttributes(@, relatedRecords)

      Batman.Property.withoutTracking =>
        if self.options.autoload and not @isNew() and not relatedRecords.loaded
          relatedRecords.load (error, records) -> throw error if error

      relatedRecords

  setIndex: ->
    @index ||= new Batman.AssociationSetIndex(@, @[@indexRelatedModelOn])
    @index
