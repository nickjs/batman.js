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

    @backingView.set('attributeName', @attributeName)
    @view.prevent('ready')
    Batman.setImmediate =>
      parentNode = @prototypeNode.parentNode
      parentNode.insertBefore(@backingView.get('node'), @prototypeNode)
      parentNode.removeChild(@prototypeNode)

      @bind()
      @view.allowAndFire('ready')

  handleArrayChanged: (newItems) =>
    unless @backingView.isDead
      @backingView.destroySubviews()
      @handleItemsAdded(newItems) if newItems?.length

  handleItemsAdded: (addedItems, addedIndexes) =>
    unless @backingView.isDead
      @backingView.addItems(addedItems, addedIndexes)

  handleItemsRemoved: (removedItems, removedIndexes) =>
    return if @backingView.isDead

    if @collection.length
      @backingView.removeItems(removedItems, removedIndexes)
    else
      @backingView.destroySubviews()

  handleItemMoved: (item, newIndex, oldIndex) =>
    unless @backingView.isDead
      @backingView.moveItem(oldIndex, newIndex)

  die: ->
    @prototypeNode = null
    super
