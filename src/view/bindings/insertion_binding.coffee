class Batman.DOM.InsertionBinding extends Batman.DOM.AbstractBinding
  isTwoWay: false
  bindImmediately: false
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {@invert} = definition
    super

    @placeholderNode = document.createComment("insertif=\"#{@keyPath}\"")
    @view.on 'ready', =>
      @bind()

  dataChange: (value) ->
    view = Batman._data(@node, 'view') || Batman._data(@node, 'backingView')
    parentNode = @placeholderNode.parentNode || @node.parentNode

    if !!value is !@invert
      # Show
      view?.fire('viewWillShow')
      if not @node.parentNode?
        parentNode.insertBefore(@node, @placeholderNode)
        Batman.DOM.removeNode(@placeholderNode)
      view?.fire('viewDidShow')
    else
      # Hide
      view?.fire('viewWillHide')
      if @node.parentNode?
        parentNode.insertBefore(@placeholderNode, @node)
        Batman.DOM.removeNode(@node)
      view?.fire('viewDidHide')

  die: ->
    return if @dead
    {node, placeholderNode} = this
    filteredValue = @get('filteredValue')

    super

    # If the tree is currently hidden, destroy it too
    if !!filteredValue is not @invert
      Batman.DOM.destroyNode(placeholderNode)
    else
      Batman.DOM.destroyNode(node)
