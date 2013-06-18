class Batman.DOM.InsertionBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  bindImmediately: false

  constructor: (definition) ->
    {@invert} = definition
    super

    @placeholderNode = document.createComment("batman-insertif=\"#{@keyPath}\"")

  ready: ->
    @bind()

  dataChange: (value) ->
    view = Batman.View.viewForNode(@node, false)
    parentNode = @placeholderNode.parentNode || @node.parentNode

    if !!value is !@invert
      # Show
      view?.fire('viewWillShow')
      if not @node.parentNode?
        parentNode.insertBefore(@node, @placeholderNode)
        parentNode.removeChild(@placeholderNode)
      view?.fire('viewDidShow')
    else
      # Hide
      view?.fire('viewWillHide')
      if @node.parentNode?
        parentNode.insertBefore(@placeholderNode, @node)
        parentNode.removeChild(@node)

      view?.fire('viewDidHide')

  die: ->
    @placeholderNode = null
    super
