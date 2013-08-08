class Batman.IteratorView extends Batman.View
  loadView: ->
    document.createComment("batman-iterator-#{@iteratorName}=\"#{@iteratorPath}\"")

  addItems: (items, indexes) ->
    @_beginAppendItems()
    if indexes
      @_insertItem(item, indexes[i]) for item, i in items
    else
      @_insertItem(item) for item in items
    @_finishAppendItems()

  removeItems: (items, indexes) ->
    if indexes 
      @subviews.at(indexes[i]).die() for item, i in items
    else
      for item in items
        for subview in @subviews._storage when subview.get(@attributeName) == item
          subview.unset(@attributeName)
          subview.die()
          break

  moveItem: (oldIndex, newIndex) ->
    source = @subviews.at(oldIndex)
    @subviews._storage.splice(oldIndex, 1)

    target = @subviews.at(newIndex)
    @subviews._storage.splice(newIndex, 0, source)

    @node.parentNode.insertBefore(source.node, target?.node || @node)

  _beginAppendItems: ->
    @fragment = document.createDocumentFragment()
    @appendedViews = []
    @get('node')

  _insertItem: (item, targetIndex) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true), parentNode: @fragment)
    iterationView.set(@iteratorName, item)

    if targetIndex?
      iterationView._targeted = true
      @subviews.insert([iterationView], [targetIndex])
    else
      @subviews.add(iterationView)

    iterationView.parentNode = null
    @appendedViews.push(iterationView)

  _finishAppendItems: ->
    isInDOM = document.body.contains(@node)

    if isInDOM
      subview.propagateToSubviews('viewWillAppear') for subview in @appendedViews

    for subview, index in @subviews.toArray() by -1 when subview._targeted
      if sibling = @subviews.at(index + 1)?.get('node')
        sibling.parentNode.insertBefore(subview.get('node'), sibling)
      else
        @fragment.appendChild(subview.get('node'))
      delete subview._targeted

    @node.parentNode.insertBefore(@fragment, @node)
    @fire('itemsWereRendered')

    if isInDOM
      for subview in @appendedViews
        subview.propagateToSubviews('isInDOM', isInDOM)
        subview.propagateToSubviews('viewDidAppear')

    @appendedViews = null
    @fragment = null

class Batman.IterationView extends Batman.View
