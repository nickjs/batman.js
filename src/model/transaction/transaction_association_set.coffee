class Batman.TransactionAssociationSet extends Batman.Set
  isTransaction: true
  constructor: (associationSet, visited, stack) ->
    @set('associationSet', associationSet)
    # in case they're being loaded:
    @_loader = @_addFromAssociationSet.bind(@)
    associationSet.on 'itemsWereAdded', @_loader
    @_visited = visited
    @_stack = stack
    @_storage = []
    @_originalStorage = []
    @_removedStorage = []
    @add(associationSet.toArray()...)

  @delegate 'association', 'foreignKeyValue', to: 'associationSet'

  _addFromAssociationSet: (items, indexes) -> @add(items...)
  add: @mutation (items...) ->
    addedTransactions = []
    for item in items
      unless item instanceof Batman.Model && !item.isTransaction
        Batman.developer.warn("You tried to add a #{item.constructor.name} to a TransactionAssociationSet (#{@get('association.label')})", item)
        continue
      transactionItem = item._transaction(@_visited, @_stack)
      @_storage.push(transactionItem)
      addedTransactions.push(transactionItem)
      originalIndex = @_originalStorage.indexOf(item)
      if originalIndex is -1
        @_originalStorage.push(item)
      # if was previously removed, it's not removed anymore!
      removedIndex = @_removedStorage.indexOf(item)
      if removedIndex > -1
        @_removedStorage.splice(removedIndex, 1)

    @length = @_storage.length
    @fire 'itemsWereAdded', addedTransactions if addedTransactions.length
    addedTransactions

  remove: @mutation (transactions...) ->
    removedTransactions = []
    for transactionItem in transactions
      if !transactionItem.isTransaction
        throw "Tried to remove real item from transaction set: #{t.toJSON()}"
      transactionIndex = @_storage.indexOf(transactionItem)
      if transactionIndex > -1
        @_storage.splice(transactionIndex, 1)
        removedTransactions.push(transactionItem)

      item = transactionItem.base()
      originalIndex = @_originalStorage.indexOf(item)
      if originalIndex > -1
        @_removedStorage.push(item)
        @_originalStorage.splice(originalIndex, 1)

    @length = @_storage.length
    @fire 'itemsWereRemoved', removedTransactions if removedTransactions.length
    removedTransactions

  applyChanges: (visited) ->
    for transactionItem in @_storage
      transactionItem.applyChanges(visited)
    originals = new Batman.Set(@_originalStorage...)
    target = @get('associationSet')
    target.off 'itemsWereAdded', @_loader
    target.replace(originals)
    target.set('removedItems', new Batman.Set(@_removedStorage...))
    target

  @accessor 'length', ->
    @registerAsMutableSource()
    @length

  build: Batman.AssociationSet::build
