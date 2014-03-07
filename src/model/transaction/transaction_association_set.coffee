class Batman.TransactionAssociationSet extends Batman.Proxy
  constructor: (associationSet, visited, stack) ->
    super(associationSet)
    @_visited = visited
    @_stack = stack
    @_transactionStorage = []
    @_originalStorage = []
    @_loadOriginals(associationSet.toArray())

  add: @mutation (items...) ->
    addedTransactions = []
    for i in items
      if i instanceof Batman.Model && !i.isTransaction
        t = i._transaction(@_visited, @_stack)
        @_transactionStorage.push(t)
        addedTransactions.push(t)
      @_originalStorage.push(i)
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
        transactionIndex = @_transactionStorage.indexOf(t)
        if transactionIndex > -1
          @_transactionStorage.splice(transactionIndex, 1)
          removedTransactions.push(t)
        i = t.base()
        originalIndex = @_originalStorage.indexOf(i)
        if originalIndex > -1
          @_originalStorage.splice(originalIndex, 1)
      else
        throw "Tried to remove real item from transaction set: #{t.toJSON()}"
    @fire 'itemsWereRemoved', removedTransactions if removedTransactions.length
    removedTransactions

  applyChanges: (visited) ->
    for t in @_transactionStorage
      t.applyChanges(visited)
    originals = new Batman.Set(@_originalStorage...)
    target = @get('target')
    target.replace(originals)
    target

  toArray: -> @_transactionStorage.slice()

  @accessor 'toArray', ->
    @registerAsMutableSource?()
    @toArray()

  @accessor 'length', ->
    @registerAsMutableSource?()
    @_transactionStorage.length

  @accessor 'first', -> @toArray()[0]

  forEach: (iterator, ctx) ->
    @get('target').registerAsMutableSource?()
    iterator.call(ctx, e, i, this) for e, i in @_transactionStorage
    return

  build: Batman.AssociationSet::build
