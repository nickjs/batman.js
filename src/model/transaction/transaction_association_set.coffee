class Batman.TransactionAssociationSet extends Batman.Set
  isTransaction: true
  constructor: (associationSet, visited, stack) ->
    @set('associationSet', associationSet)
    @_visited = visited
    @_stack = stack
    @_storage = []
    @_originalStorage = []
    @_removedStorage = []
    @_loadOriginals(associationSet.toArray())

  @delegate 'association', 'foreignKeyValue', to: 'associationSet'

  add: @mutation (items...) ->
    addedTransactions = []
    for i in items
      if i instanceof Batman.Model && !i.isTransaction
        t = i._transaction(@_visited, @_stack)
        @_storage.push(t)
        addedTransactions.push(t)
      # just in case:
      originalIndex = @_originalStorage.indexOf(i)
      if originalIndex is -1
        @_originalStorage.push(i)
      # if was previously removed, it's not removed anymore!
      removedIndex = @_removedStorage.indexOf(i)
      if removedIndex > -1
        @_removedStorage.splice(removedIndex, 1)

    @length = @_storage.length
    @fire 'itemsWereAdded', addedTransactions if addedTransactions.length
    addedTransactions

  _loadOriginals: (itemArray) ->
    @_loadingOriginals = true
    @add(itemArray...)
    @_loadingOriginals = false

  remove: @mutation (transactions...) ->
    removedTransactions = []
    for t in transactions
      if t.isTransaction
        transactionIndex = @_storage.indexOf(t)
        if transactionIndex > -1
          @_storage.splice(transactionIndex, 1)
          removedTransactions.push(t)

        i = t.base()
        originalIndex = @_originalStorage.indexOf(i)
        if originalIndex > -1
          @_removedStorage.push(i)
          @_originalStorage.splice(originalIndex, 1)
      else
        throw "Tried to remove real item from transaction set: #{t.toJSON()}"

    @length = @_storage.length
    @fire 'itemsWereRemoved', removedTransactions if removedTransactions.length
    removedTransactions

  applyChanges: (visited) ->
    for t in @_storage
      t.applyChanges(visited)
    originals = new Batman.Set(@_originalStorage...)
    target = @get('associationSet')
    target.replace(originals)
    target.set('removedItems', new Batman.Set(@_removedStorage...))
    target

  @accessor 'length', ->
    @registerAsMutableSource()
    @length

  build: Batman.AssociationSet::build
