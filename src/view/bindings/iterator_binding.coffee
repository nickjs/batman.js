#= require abstract_collection_binding

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  deferEvery: 50
  currentActionNumber: 0
  queuedActionNumber: 0
  bindImmediately: false

  constructor: (sourceNode, @iteratorName, @key, @context, @parentRenderer) ->
    @nodeMap = new Batman.SimpleHash
    @actionMap = new Batman.SimpleHash
    @rendererMap = new Batman.SimpleHash
    @actions = []

    @prototypeNode = sourceNode.cloneNode(true)
    @prototypeNode.removeAttribute "data-foreach-#{@iteratorName}"
    @pNode = sourceNode.parentNode
    previousSiblingNode = sourceNode.nextSibling
    @siblingNode = document.createComment "end #{@iteratorName}"
    @siblingNode[Batman.expando] = sourceNode[Batman.expando]
    delete sourceNode[Batman.expando] if Batman.canDeleteExpando
    Batman.insertBefore sourceNode.parentNode, @siblingNode, previousSiblingNode
    # Remove the original node once the parent has moved past it.
    @parentRenderer.on 'parsed', =>
      # Move any Batman._data from the sourceNode to the sibling; we need to
      # retain the bindings, and we want to dispose of the node.
      Batman.destroyNode sourceNode
      # Attach observers.
      @bind()

    # Don't let the parent emit its rendered event until all the children have.
    # This `prevent`'s matching allow is run once the queue is empty in `processActionQueue`.
    @parentRenderer.prevent 'rendered'

    # Tie this binding to a node using the default behaviour in the AbstractBinding
    super(@siblingNode, @iteratorName, @key, @context, @parentRenderer)

    @fragment = document.createDocumentFragment()

  parentNode: -> @siblingNode.parentNode

  die: ->
    super
    @dead = true

  unbindCollection: ->
    if @collection
      @nodeMap.forEach (item) => @cancelExistingItem(item)
      super

  dataChange: (newCollection) ->
    if @collection != newCollection
      @removeAll()

    @bindCollection(newCollection) # Unbinds the old collection as well.
    if @collection
      if @collection.toArray
        @handleArrayChanged()
      else if @collection.forEach
        @collection.forEach (item) => @addOrInsertItem(item)
      else
        @addOrInsertItem(key) for own key, value of @collection

    Batman.developer.do =>
      @_warningTimeout ||= setTimeout =>
        unless @collection?
          Batman.developer.warn "Warning! data-foreach-#{@iteratorName} called with an undefined binding. Key was: #{@key}."
      , 1000

    @processActionQueue()

  handleItemsWereAdded: (items...) => @addOrInsertItem(item, {fragment: false}) for item in items; return
  handleItemsWereRemoved: (items...) => @removeItem(item) for item in items; return

  handleArrayChanged: =>
    newItemsInOrder = @collection.toArray()
    nodesToRemove = (new Batman.SimpleHash).merge(@nodeMap)
    for item in newItemsInOrder
      @addOrInsertItem(item, {fragment: false})
      nodesToRemove.unset(item)

    nodesToRemove.forEach (item, node) => @removeItem(item)

  addOrInsertItem: (item, options = {}) ->
    existingNode = @nodeMap.get(item)
    if existingNode
      @insertItem(item, existingNode)
    else
      @addItem(item, options)

  addItem: (item, options = {fragment: true}) ->
    @parentRenderer.prevent 'rendered'

    # Remove any renderers in progress or actions lined up for an item, since we now know
    # this item belongs at the end of the queue.
    @cancelExistingItemActions(item) if @actionMap.get(item)?

    self = @
    options.actionNumber = @queuedActionNumber++

    # Render out the child in the custom context, and insert it once the render has completed the parse.
    childRenderer = new Batman.Renderer @_nodeForItem(item), (->
      self.rendererMap.unset(item)
      self.insertItem(item, @node, options)
    ), @renderContext.descend(item, @iteratorName), @parentRenderer.view

    @rendererMap.set(item, childRenderer)

    finish = =>
      return if @dead
      @parentRenderer.allowAndFire 'rendered'

    childRenderer.on 'rendered', finish
    childRenderer.on 'stopped', =>
      return if @dead
      @actions[options.actionNumber] = false
      finish()
      @processActionQueue()
    item

  removeItem: (item) ->
    return if @dead || !item?
    oldNode = @nodeMap.unset(item)
    @cancelExistingItem(item)
    if oldNode
      Batman.destroyNode(oldNode)
      @fire 'nodeRemoved', oldNode, item if oldNode

  removeAll: -> @nodeMap.forEach (item) => @removeItem(item)

  insertItem: (item, node, options = {}) ->
    return if @dead
    if !options.actionNumber?
      options.actionNumber = @queuedActionNumber++

    existingActionNumber = @actionMap.get(item)
    if existingActionNumber > options.actionNumber
      # Another action for this item is scheduled for the future, do it then instead of now. Actions
      # added later enforce order, so we make this one a noop and let the later one have its proper effects.
      @actions[options.actionNumber] = ->
    else
      # Another action has been scheduled for this item. It hasn't been done yet because
      # its in the actionmap, but this insert is scheduled to happen after it. Skip it since its now defunct.
      if existingActionNumber
        @cancelExistingItemActions(item)

      # Update the action number map to now reflect this new action which will go on the end of the queue.
      @actionMap.set item, options.actionNumber
      @actions[options.actionNumber] = ->
        if options.fragment
          @fragment.appendChild node
        else
          if options.fragment
            @fragment.appendChild node
          else
            Batman.insertBefore @parentNode(), node, @siblingNode
            Batman.propagateBindingEvents node

        if addItem = node.getAttribute 'data-additem'
          @renderer.context.contextForKey(addItem)?[addItem]?(item, node)
        @fire 'nodeAdded', node, item

      @actions[options.actionNumber].item = item
    @processActionQueue()

  cancelExistingItem: (item) ->
    @cancelExistingItemActions(item)
    @cancelExistingItemRender(item)

  cancelExistingItemActions: (item) ->
    oldActionNumber = @actionMap.get(item)
    # Only remove actions which haven't been completed yet.
    if oldActionNumber? && oldActionNumber >= @currentActionNumber
      @actions[oldActionNumber] = false

    @actionMap.unset item

  cancelExistingItemRender: (item) ->
    oldRenderer = @rendererMap.get(item)
    if oldRenderer
      oldRenderer.stop()
      Batman.destroyNode(oldRenderer.node)

    @rendererMap.unset item

  processActionQueue: ->
    return if @dead
    unless @actionQueueTimeout
      # Prevent the parent which will then be allowed when the timeout actually runs
      @actionQueueTimeout = Batman.setImmediate =>
        return if @dead
        delete @actionQueueTimeout
        startTime = new Date

        while (f = @actions[@currentActionNumber])?
          delete @actions[@currentActionNumber]
          @actionMap.unset f.item
          f.call(@) if f
          @currentActionNumber++

          if @deferEvery && (new Date - startTime) > @deferEvery
            return @processActionQueue()

        if @fragment && @rendererMap.length is 0 && @fragment.hasChildNodes()
          addedNodes = Array::slice.call(@fragment.childNodes)
          Batman.insertBefore @parentNode(), @fragment, @siblingNode
          Batman.propagateBindingEvents(node) for node in addedNodes

          @fragment = document.createDocumentFragment()

        if @currentActionNumber == @queuedActionNumber
          @parentRenderer.allowAndFire 'rendered'

  _nodeForItem: (item) ->
    newNode = @prototypeNode.cloneNode(true)
    @nodeMap.set(item, newNode)
    newNode
