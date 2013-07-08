class Batman.IteratorView extends Batman.View
  loadView: ->
    document.createComment("batman-iterator-#{@iteratorName}=\"#{@iteratorPath}\"")

  beginAppendItems: ->
    @fragment = document.createDocumentFragment()
    @appendedViews = []
    @get('node')

  appendItem: (item) -> @insertItem(item)
  insertItem: (item, targetIndex) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true), parentNode: @fragment)
    iterationView.set(@iteratorName, item)

    if targetIndex?
      iterationView.targetIndex = targetIndex
      iterationView.nextSiblingNode = @subviews.at(targetIndex)?.get('node') or @node
      iterationView.parentNode = @node.parentNode
      iterationView.get('node')
    else
      @subviews.add(iterationView)
      iterationView.parentNode = null

    @appendedViews.push(iterationView)

  finishAppendItems: ->
    isInDOM = document.body.contains(@node)

    if isInDOM
      subview.propagateToSubviews('viewWillAppear') for subview in @appendedViews

    for subview in @appendedViews
      @subviews.insert([subview], [subview.targetIndex]) if subview.targetIndex?

    @node.parentNode.insertBefore(@fragment, @node)
    @fire('itemsWereRendered')

    if isInDOM
      for subview in @appendedViews
        subview.propagateToSubviews('isInDOM', isInDOM)
        subview.propagateToSubviews('viewDidAppear')

    @appendedViews = null
    @fragment = null

class Batman.IterationView extends Batman.View
