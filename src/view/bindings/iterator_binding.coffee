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
      @backingView.destroySubviews()
      @handleItemsAdded(newItems) if newItems?.length

  handleItemsAdded: (addedItems, addedIndexes) =>
    unless @backingView.isDead
      @backingView.beginAppendItems()
      if addedIndexes
        @backingView.insertItem(item, addedIndexes[i]) for item, i in addedItems
      else
        @backingView.appendItem(item) for item in addedItems
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

  handleItemMoved: (item, newIndex, oldIndex) =>
    unless @backingView.isDead
      @backingView.moveItem(oldIndex, newIndex)

  die: ->
    @prototypeNode = null
    super
