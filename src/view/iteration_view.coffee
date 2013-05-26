#= require ./view

class Batman.IterationView extends Batman.View
  addToDOM: (rootNode, subviewNode) ->
    rootNode.parentNode.insertBefore(subviewNode, rootNode)
