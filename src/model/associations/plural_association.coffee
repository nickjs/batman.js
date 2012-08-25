#= require ./association

class Batman.PluralAssociation extends Batman.Association
  proxyClass: Batman.AssociationSet
  isSingular: false

  constructor: ->
    super
    @_resetProxyHashes()

  setForRecord: (record) ->
    indexValue = @indexValueForRecord(record)
    Batman.Property.withoutTracking =>
      @_recordProxies.getOrSet record, =>
        if indexValue?
          existingValueSet = @_keyValueProxies.get(indexValue)
          if existingValueSet?
            return existingValueSet
        newSet = new @proxyClass(indexValue, @)
        if indexValue?
          @_keyValueProxies.set indexValue, newSet
        newSet
    if indexValue?
      @setIndex().get(indexValue)
    else
      @_recordProxies.get(record)

  setForKey: Batman.Property.wrapTrackingPrevention (indexValue) ->
    foundSet = undefined
    @_recordProxies.forEach (record, set) =>
      return if foundSet?
      foundSet = set if @indexValueForRecord(record) == indexValue
    if foundSet?
      foundSet.foreignKeyValue = indexValue
      return foundSet
    @_keyValueProxies.getOrSet indexValue, => new @proxyClass(indexValue, @)

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

  indexValueForRecord: (record) -> record.get(@primaryKey)

  reset: ->
    super
    @_resetProxyHashes()

  _resetProxyHashes: ->
    @_recordProxies = new Batman.SimpleHash
    @_keyValueProxies = new Batman.SimpleHash
