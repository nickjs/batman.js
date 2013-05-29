class Batman.IteratorView extends Batman.View
  loadView: ->
    @prototypeNode.removeAttribute("data-foreach-#{@iteratorName}")
    return document.createComment("iterator-#{@iteratorName}=#{@iteratorPath}")

  addToDOM: ->
    @prototypeNode.parentNode.insertBefore(@get('node'), @prototypeNode)

  beginAppendItems: ->
    @fragment = document.createDocumentFragment()

  appendItem: (item) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true))
    iterationView.set(@iteratorName, item)

    @subviews.set(item, iterationView)

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

  addToDOM: null
