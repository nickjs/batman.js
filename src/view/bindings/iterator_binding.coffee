#= require ./abstract_collection_binding
#= require ../iterator_view

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: Batman.IteratorView

  constructor: (definition) ->
    prototypeNode = definition.node
    definition.viewOptions = {prototypeNode, iteratorName: definition.attr, iteratorPath: definition.keyPath}
    definition.node = null

    super

    @superview.on 'ready', -> # FIXME When parseNode goes away this will not need to nextTick
      prototypeNode.parentNode.removeChild(prototypeNode)

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

  handleArrayChanged: (newItems) =>
    @backingView.subviews.clear()
    @handleItemsAdded(newItems)

  handleItemsAdded: (newItems) =>
    @backingView.beginAppendItems()
    @backingView.appendItem(item) for item in newItems
    @backingView.finishAppendItems()

  handleItemsRemoved: (oldItems) =>
    @backingView.subviews.unset(item) for item in oldItems
