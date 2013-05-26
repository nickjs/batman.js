#= require ./abstract_collection_binding

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {node: sourceNode, attr: @iteratorName, view: @superview} = definition

    @yieldName = "<#{@iteratorName}Iterator-#{@_batmanID()}>"
    commentNode = document.createComment(@yieldName)

    @prototypeNode = sourceNode.cloneNode(true)
    @prototypeNode.removeAttribute "data-foreach-#{@iteratorName}"

    view = new Batman.IterationView
    view.set('node', commentNode)

    @superview.declareYieldNode(@yieldName, sourceNode.parentNode)
    @superview.subviews.set(@yieldName, view)

    @superview.on 'ready', -> # FIXME When parseNode goes away this will not need to nextTick
      sourceNode.parentNode.removeChild(sourceNode)

    definition.node = commentNode
    definition.view = view
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
    @view.subviews.clear()

    for item, index in newItems
      iterationView = new Batman.View
      iterationNode = @prototypeNode.cloneNode(true)

      iterationView.set(@iteratorName, item)
      iterationView.set('node', iterationNode)

      @view.subviews.set("#{@iteratorName}-#{index}", iterationView)

    return

  die: ->
    @superview.unset(@yieldName)
    @superview = null
    @view = null
    super
