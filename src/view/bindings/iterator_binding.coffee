#= require ../view
#= require ./abstract_collection_binding

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {node: sourceNode, attr: @iteratorName, view: superview} = definition

    @prototypeNode = sourceNode
    @prototypeNode.removeAttribute("data-foreach-#{@iteratorName}")

    @iteratorView = new Batman.IteratorView(iteratorPath: definition.keyPath, iteratorName: @iteratorName)
    definition.node = @iteratorView.get('node')

    @yieldName = "<iterator-#{@_batmanID()}-#{@iteratorName}>"
    superview.declareYieldNode(@yieldName, sourceNode)
    superview.subviews.set(@yieldName, @iteratorView)

    superview.on 'ready', -> # FIXME When parseNode goes away this will not need to nextTick
      sourceNode.parentNode.removeChild(sourceNode)

    super

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
    @iteratorView.subviews.clear()
    @handleItemsAdded(newItems)

  handleItemsAdded: (newItems) =>
    fragment = document.createDocumentFragment()

    for item in newItems
      iterationView = new Batman.IterationView(displayName: @iteratorName, prototypeNode: @prototypeNode, iteratorName: @iteratorName, fragment: fragment)
      iterationView.set(@iteratorName, item)

      @iteratorView.subviews.set(item, iterationView)

    @iteratorView.insertFragment(fragment)

  handleItemsRemoved: (oldItems) =>
    for item in oldItems
      @iteratorView.subviews.unset(item)

  die: ->
    @superview.unset(@yieldName)
    @superview = null
    @view = null
    super

class Batman.IteratorView extends Batman.View
  loadView: ->
    return document.createComment("data-iterator=#{@iteratorPath}")

  insertFragment: (fragment) ->
    node = @get('node')
    node.parentNode.insertBefore(fragment, node)

  addToDOM: (sourceNode) ->
    sourceNode.parentNode.insertBefore(@get('node'), sourceNode)

class Batman.IterationView extends Batman.View
  loadView: ->
    @prototypeNode.cloneNode(true)

  addToDOM: (commentNode) ->
    @fragment.appendChild(@get('node'))
