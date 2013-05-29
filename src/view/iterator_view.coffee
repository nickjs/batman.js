class Batman.IteratorView extends Batman.View
  loadView: ->
    return document.createComment("iterator-#{@iteratorName}=#{@iteratorPath}")

  addToDOM: ->
    @prototypeNode.removeAttribute("data-foreach-#{@iteratorName}")
    @prototypeNode.parentNode.insertBefore(@get('node'), @prototypeNode)

  beginAppendItems: ->
    @fragment = document.createDocumentFragment()

  appendItem: (item) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true))
    iterationView.set(@iteratorName, item)

    @subviews.set(item, iterationView)
    iterationView.initializeBindings()

  finishAppendItems: ->
    node = @get('node')
    node.parentNode.insertBefore(@fragment, node)

    @fragment = null

  _addSubview: (as, subview) ->
    super
    @fragment.appendChild(subview.get('node'))


class Batman.IterationView extends Batman.View
  constructor: (options) ->
    {node} = options
    Batman._data(node, 'backingView', this) if node

    super

  bindImmediately: false
  addToDOM: null
