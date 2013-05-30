#= require ./abstract_collection_binding
#= require ../iterator_view

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: Batman.IteratorView
  skipChildren: true

  constructor: (definition) ->
    @iteratorName = definition.attr
    @prototypeNode = definition.node
    @prototypeNode.removeAttribute("data-foreach-#{@iteratorName}")

    definition.viewOptions = {@prototypeNode, @iteratorName, iteratorPath: definition.keyPath}
    definition.node = null

    super

  ready: ->
    parentNode = @prototypeNode.parentNode
    parentNode.insertBefore(@backingView.get('node'), @prototypeNode)
    parentNode.removeChild(@prototypeNode)

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

  handleArrayChanged: (newItems) =>
    @backingView.subviews.clear()
    @handleItemsAdded(newItems)

  handleItemsAdded: (newItems) =>
    @backingView.beginAppendItems()
    @backingView.appendItem(item) for item in newItems
    @backingView.finishAppendItems()

  handleItemsRemoved: (oldItems) =>
    for subview in @backingView.subviews._storage
      if subview.get(@attributeName) == item
        subview.removeFromSuperview()
    return
