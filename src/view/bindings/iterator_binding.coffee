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

  handleArrayChanged: (newItems) =>
    unless @backingView.isDead
      @backingView.destroySubviews()
      @handleItemsAdded(newItems)

  handleItemsAdded: (newItems) =>
    unless @backingView.isDead
      @backingView.beginAppendItems()
      @backingView.appendItem(item) for item in newItems if newItems
      @backingView.finishAppendItems()

  handleItemsRemoved: (oldItems) =>
    unless @backingView.isDead
      for item in oldItems
        for subview in @backingView.subviews._storage
          if subview.get(@attributeName) == item
            subview.unset(@attributeName)
            subview.die()
            break
    return

  die: ->
    @prototypeNode = null
    super
