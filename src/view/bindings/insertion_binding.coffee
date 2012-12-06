class Batman.DOM.InsertionBinding extends Batman.DOM.AbstractBinding
  isTwoWay: false
  bindImmediately: false
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {@invert} = definition
    @placeholderNode = document.createComment "detached node #{@get('_batmanID')}"

    super

    Batman.DOM.onParseExit @node, =>
      @bind()
      Batman.DOM.trackBinding(@, @placeholderNode) if @placeholderNode?

  dataChange: (value) ->
    parentNode = @placeholderNode.parentNode || @node.parentNode
    if !!value is not @invert
      # Show
      if !@node.parentNode?
        Batman.DOM.insertBefore parentNode, @node, @placeholderNode
        parentNode.removeChild @placeholderNode
    else
      # Hide
      if @node.parentNode?
        parentNode.insertBefore @placeholderNode, @node
        Batman.DOM.removeNode @node

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
