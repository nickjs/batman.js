class Batman.DOM.InsertionBinding extends Batman.DOM.AbstractBinding
  isTwoWay: false
  bindImmediately: false
  constructor: (node, className, key, context, parentRenderer, @invert = false) ->
    @placeholderNode = document.createComment "detached node #{@get('_batmanID')}"
    result = super
    Batman.DOM.onParseExit @node, =>
      @bind()
      Batman.DOM.trackBinding(@, @placeholderNode) if @placeholderNode?
    result

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
    super
    # If the tree is currently hidden, destroy it too
    if !!@get('filteredValue') is not @invert
      Batman.DOM.destroyNode(@placeholderNode)
    else
      Batman.DOM.destroyNode(@node)
