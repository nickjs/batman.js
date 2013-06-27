class Batman.IteratorView extends Batman.View
  loadView: ->
    document.createComment("batman-iterator-#{@iteratorName}=\"#{@iteratorPath}\"")

  beginAppendItems: ->
    @fragment = document.createDocumentFragment()
    @appendedViews = []

  appendItem: (item) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true), parentNode: @fragment)
    iterationView.set(@iteratorName, item)

    @subviews.add(iterationView)
    @appendedViews.push(iterationView)
    iterationView.parentNode = null

  finishAppendItems: ->
    node = @get('node')
    isInDOM = document.body.contains(node)

    if isInDOM
      subview.propagateToSubviews('viewWillAppear') for subview in @appendedViews

    node.parentNode.insertBefore(@fragment, node)
    @fire('itemsWereRendered')

    if isInDOM
      for subview in @appendedViews
        subview.propagateToSubviews('isInDOM', isInDOM)
        subview.propagateToSubviews('viewDidAppear')

    @appendedViews = null
    @fragment = null

class Batman.IterationView extends Batman.View
