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
      iterationView._targeted = true
      @subviews.insert([iterationView], [targetIndex])
    else
      @subviews.add(iterationView)

    iterationView.parentNode = null
    @appendedViews.push(iterationView)

  finishAppendItems: ->
    isInDOM = document.body.contains(@node)

    if isInDOM
      subview.propagateToSubviews('viewWillAppear') for subview in @appendedViews

    for subview, index in @subviews.toArray() when subview._targeted
      @node.parentNode.insertBefore(subview.get('node'), @subviews.at(index + 1)?.get('node') or @node)
      delete subview._targeted

    @node.parentNode.insertBefore(@fragment, @node)
    @fire('itemsWereRendered')

    if isInDOM
      for subview in @appendedViews
        subview.propagateToSubviews('isInDOM', isInDOM)
        subview.propagateToSubviews('viewDidAppear')

    @appendedViews = null
    @fragment = null

  moveItem: (oldIndex, newIndex) ->
    source = @subviews.at(oldIndex)
    @subviews._storage.splice(oldIndex, 1)

    target = @subviews.at(newIndex)
    @subviews._storage.splice(newIndex, 0, source)

    @node.parentNode.insertBefore(source.node, target?.node || @node)

class Batman.IterationView extends Batman.View
