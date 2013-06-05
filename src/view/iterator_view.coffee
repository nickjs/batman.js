class Batman.IteratorView extends Batman.View
  loadView: ->
    document.createComment("batman-iterator-#{@iteratorName}=#{@iteratorPath}")

  beginAppendItems: ->
    @fragment = document.createDocumentFragment()

  appendItem: (item) ->
    iterationView = new Batman.IterationView(node: @prototypeNode.cloneNode(true), parentNode: @fragment)
    iterationView.set(@iteratorName, item)

    @subviews.add(iterationView)
    iterationView.parentNode = null

  finishAppendItems: ->
    node = @get('node')
    node.parentNode.insertBefore(@fragment, node)

    @fragment = null

class Batman.IterationView extends Batman.View
