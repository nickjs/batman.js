#= require ./abstract_collection_binding

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  currentActionNumber: 0
  queuedActionNumber: 0
  bindImmediately: false

  constructor: (sourceNode, @iteratorName, @key, @context, @parentRenderer) ->
    @nodeMap = new Batman.SimpleHash
    @rendererMap = new Batman.SimpleHash
    @fragment = document.createDocumentFragment()

    @prototypeNode = sourceNode.cloneNode(true)
    @prototypeNode.removeAttribute "data-foreach-#{@iteratorName}"

    # Create a reference sibling node in order to know where this foreach ends,
    # and move any Batman._data from the sourceNode to the sibling because we need to
    # retain the bindings, and we want to dispose of the node.
    previousSiblingNode = sourceNode.nextSibling
    @startNode = document.createComment "start #{@iteratorName}-#{@get('_batmanID')}"
    @endNode = document.createComment "end #{@iteratorName}-#{@get('_batmanID')}"
    @endNode[Batman.expando] = sourceNode[Batman.expando]
    delete sourceNode[Batman.expando] if Batman.canDeleteExpando
    Batman.insertBefore sourceNode.parentNode, @startNode, previousSiblingNode
    Batman.insertBefore sourceNode.parentNode, @endNode, previousSiblingNode

    # Don't let the parent emit its rendered event until this iteration has set up
    @parentRenderer.prevent 'rendered'

    # Remove the original node once the parent has moved past it.
    Batman.DOM.onParseExit sourceNode.parentNode, =>
      Batman.destroyNode sourceNode
      @bind()
      @parentRenderer.allowAndFire 'rendered'

    super(@endNode, @iteratorName, @key, @context, @parentRenderer)

  # The parent node can change if this content is yielded into a different container,
  # so use a function to grab it.
  parentNode: -> @endNode.parentNode

  die: ->
    @dead = true
    super

  dataChange: (collection)->
    if collection?
      unless @bindCollection(collection)
        items = if collection?.forEach
          _items = []
          collection.forEach (item) -> _items.push item
          _items
         else
          Object.keys(collection)
        @handleArrayChanged(items)
    else
      @handleArrayChanged([])

  handleArrayChanged: (newItems) =>
    parentNode = @parentNode()
    startIndex = @_getStartNodeIndex() + 1
    unseenNodeMap = @nodeMap.merge() # duplicate

    for newItem, index in newItems
      # Check if the node at this index is already the one destined for that position
      nodeAtIndex = parentNode.childNodes[startIndex + index]
      if nodeAtIndex? && @_itemForNode(nodeAtIndex) == newItem
        unseenNodeMap.unset(newItem)
        continue
      else
        # Otherwise, create a new or move the existing node for that position to the desired position
        node = if (existingNode = @nodeMap.get(newItem))
          unseenNodeMap.unset(newItem)
          existingNode
        else
          @_newNodeForItem(newItem)
        Batman.insertBefore @parentNode(), node, nodeAtIndex

    unseenNodeMap.forEach (item, node) =>
      @_removeItem(item)
    return

  _itemForNode: (node) ->
    Batman._data(node, "#{@iteratorName}Item")

  _newNodeForItem: (newItem) ->
    newNode = @prototypeNode.cloneNode(true)
    Batman._data(newNode, "#{@iteratorName}Item", newItem)
    @nodeMap.set(newItem, newNode)
    @parentRenderer.prevent 'rendered'
    renderer = new Batman.Renderer newNode, @renderContext.descend(newItem, @iteratorName), @parentRenderer.view
    renderer.on 'rendered', =>
      Batman.propagateBindingEvents(newNode)
      @fire 'nodeAdded', newNode, newItem
      @parentRenderer.allowAndFire 'rendered'
    newNode

  _getStartNodeIndex: ->
    # Get start index
    for node, index in @parentNode().childNodes
      if node == @startNode
        return index
    0

  _removeItem: (item) ->
    node = @nodeMap.unset(item)

    Batman.destroyNode(node)
    @fire 'nodeRemoved', node, item

