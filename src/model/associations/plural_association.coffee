#= require ./association

class Batman.PluralAssociation extends Batman.Association
  proxyClass: Batman.AssociationSet
  isSingular: false

  constructor: (@model, @label, options = {}) ->
    super
    @_resetSetHashes()

  provideDefaults:  ->
    Batman.mixin super,
      name: Batman.helpers.camelize(Batman.helpers.singularize(@label))

  setForRecord: (record) ->
    indexValue = @indexValueForRecord(record)
    childModelSetIndex = @setIndex()
    Batman.Property.withoutTracking =>
      @_setsByRecord.getOrSet record, =>
        # Return an existing set from the value proxies if we have a value
        if indexValue?
          existingValueSet = @_setsByValue.get(indexValue)
          if existingValueSet?
            return existingValueSet

        # Otherwise, add a new set to the record proxies, and stick it in the value proxies if we have a value.
        newSet = @proxyClassInstanceForKey(indexValue)
        if indexValue?
          @_setsByValue.set indexValue, newSet
        newSet

    if indexValue?
      childModelSetIndex.get(indexValue)
    else
      @_setsByRecord.get(record)

  setForKey: Batman.Property.wrapTrackingPrevention (indexValue) ->
    # If we have a set for a record who has the value matching the one passed in, return it.
    record = @_setsByRecord.find (record, set) =>
      @indexValueForRecord(record) is indexValue

    if record?
      foundSet = @_setsByRecord.get(record)
      foundSet.foreignKeyValue = indexValue
      return foundSet

    # Otherwise, set a new set into the value keyd sets which will get picked up in `setForRecord`.
    @_setsByValue.getOrSet indexValue, => @proxyClassInstanceForKey(indexValue)

  proxyClassInstanceForKey: (indexValue) ->
    new @proxyClass(indexValue, this)

  getAccessor: (self, model, label) ->
    return unless self.getRelatedModel()

    # Check whether the relation has already been set on this model
    if setInAttributes = self.getFromAttributes(this)
      setInAttributes
    else
      relatedRecords = self.setForRecord(this)
      self.setIntoAttributes(this, relatedRecords)

      Batman.Property.withoutTracking =>
        if self.options.autoload and not @isNew() and not relatedRecords.loaded
          relatedRecords.load (error, records) -> throw error if error

      relatedRecords

  parentSetIndex: ->
    @parentIndex ||= @model.get('loaded').indexedByUnique(@primaryKey)
    @parentIndex

  setIndex: ->
    @index ||= new Batman.AssociationSetIndex(this, @[@indexRelatedModelOn])
    @index

  indexValueForRecord: (record) -> record.get(this.primaryKey)

  reset: ->
    super
    @_resetSetHashes()

  _resetSetHashes: ->
    @_setsByRecord = new Batman.SimpleHash
    @_setsByValue = new Batman.SimpleHash
