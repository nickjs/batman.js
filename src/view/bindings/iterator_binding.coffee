#= require ./abstract_collection_binding
#= require ../iterator_view

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: Batman.IteratorView
  skipChildren: true
  bindImmediately: false

  constructor: (definition) ->
    @iteratorName = definition.attr
    @prototypeNode = definition.node
    @prototypeNode.removeAttribute("data-foreach-#{@iteratorName}")

    definition.viewOptions = {@prototypeNode, @iteratorName, iteratorPath: definition.keyPath}
    definition.node = null

    super

    @view.prevent('ready')
    Batman.setImmediate =>
      parentNode = @prototypeNode.parentNode
      parentNode.insertBefore(@backingView.get('node'), @prototypeNode)
      parentNode.removeChild(@prototypeNode)

      @bind()
      @view.allowAndFire('ready')

  dataChange: (collection) ->
    if collection?
      unless @bindCollection(collection)
        items = if collection?.forEach
          _items = []
          collection.forEach (item) -> _items.push item
          _items
        else
          Object.keys(collection)
        @handleArrayChanged(items)
    else
      @handleArrayChanged([])
    return

  handleArrayChanged: (newItems, oldItems) =>
    unless @backingView.isDead
      if newItems?.length
        #if @collection.isSorted and newItems.length == oldItems.length
        #  subsequence = @longestIncreasingSubsequence(oldItems, @collection.compareElements)
        #else
        @backingView.destroySubviews()
        @handleItemsAdded(newItems)
      else
        @backingView.destroySubviews()

  handleItemsAdded: (addedItems, addedIndexes) =>
    unless @backingView.isDead
      @backingView.beginAppendItems()
      if addedIndexes
        @backingView.insertItem(item, addedIndexes[i]) for item, i in addedItems
      else
        @backingView.appendItem(item) for item in addedItems if addedItems
      @backingView.finishAppendItems()

  handleItemsRemoved: (removedItems, removedIndexes) =>
    unless @backingView.isDead
      if @collection.length
        if removedIndexes
          @backingView.subviews.at(removedIndexes[i]).die() for item, i in removedItems
        else
          for item in removedItems
            for subview in @backingView.subviews._storage
              if subview.get(@attributeName) == item
                subview.unset(@attributeName)
                subview.die()
                break
      else
        @backingView.destroySubviews()

  die: ->
    @prototypeNode = null
    super

  @_longestIncreasingSubsequence: (values, compare) ->
    subsequenceLength = 0
    lastIndexForLength = [] # the i'th element is the index of the last element of the monotonically increasing subsequence of length i + 1
    predecessors = []

    for val, index in values
      start = 0
      end = subsequenceLength

      while end >= start
        lastIndex = ((end - start) >> 1) + start

        if compare(values[lastIndexForLength[lastIndex]], val) is 1
          end = lastIndex - 1
        else
          start = lastIndex + 1

      newIndex = end # at the end of the search, 'end' is the element before the position we want to insert into
      predecessors[index] = lastIndexForLength[newIndex] # undefined if newIndex is -1

      if newIndex is subsequenceLength or compare(val, values[lastIndexForLength[newIndex + 1]]) is -1
        lastIndexForLength[newIndex + 1] = index
        subsequenceLength = Math.max(subsequenceLength, newIndex + 1)

    # build the subsequence from the predecessor array
    currIndex = lastIndexForLength[subsequenceLength]
    subsequence = []
    while currIndex?
      subsequence.unshift values[currIndex]
      currIndex = predecessors[currIndex]
    subsequence
