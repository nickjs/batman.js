class Batman.DOM.InsertionBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  bindImmediately: false

  constructor: (definition) ->
    {@invert} = definition
    super

    @placeholderNode = document.createComment("batman-insertif=\"#{@keyPath}\"")

  initialized: ->
    @bind()

  dataChange: (value) ->
    view = Batman.View.viewForNode(@node, false)
    parentNode = @placeholderNode.parentNode || @node.parentNode

    if !!value is !@invert
      # Show
      view?.fireAndCall('viewWillShow')
      if not @node.parentNode?
        parentNode.insertBefore(@node, @placeholderNode)
        parentNode.removeChild(@placeholderNode)
      view?.fireAndCall('viewDidShow')
    else
      # Hide
      view?.fireAndCall('viewWillHide')
      if @node.parentNode?
        parentNode.insertBefore(@placeholderNode, @node)
        parentNode.removeChild(@node)

      view?.fireAndCall('viewDidHide')

  die: ->
    @placeholderNode = null
    super
