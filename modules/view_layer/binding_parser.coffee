{BatmanObject} = require 'foundation'
DOM = require './dom/dom'
{_data} = require './data'
readers = require './dom/readers'
attrReaders = require './dom/attribute_readers'
ReaderBindingDefinition = require './dom/reader_binding_definition'
AttrReaderBindingDefinition = require './dom/attribute_reader_binding_definition'

# `Batman.BindingParser` will take a node and parse all recognized data attributes out of it and its children.
module.exports = class BindingParser extends BatmanObject
  constructor: (@view) ->
    super()
    @node = @view.node
    @parseTree(@node)

  bindingSortOrder = ["defineview", "foreach", "renderif", "view", "formfor", "context", "bind", "source", "target", "track", "event"]
  viewBackedBindings = ["foreach", "renderif", "formfor", "context"]

  bindingSortPositions = {}
  bindingSortPositions[name] = pos for name, pos in bindingSortOrder

  _sortBindings: (a,b) ->
    aindex = bindingSortPositions[a[0]]
    bindex = bindingSortPositions[b[0]]
    aindex ?= bindingSortOrder.length # put unspecified bindings last
    bindex ?= bindingSortOrder.length
    if aindex > bindex
      1
    else if bindex > aindex
      -1
    else if a[0] > b[0]
      1
    else if b[0] > a[0]
      -1
    else
      0

  parseTree: (root) ->
    while root
      skipChildren = @parseNode(root)
      root = @nextNode(root, skipChildren)

    @fire('bindingsInitialized')
    return

  parseNode: (node) ->
    isViewBacked = false
    if node.getAttribute and node.attributes
      bindings = []
      for attribute in node.attributes
        continue unless attribute.nodeName?.substr(0, 5) is "data-"
        name = attribute.nodeName.substr(5)

        attrIndex = name.indexOf('-')
        bindings.push if attrIndex isnt -1
          [name.substr(0, attrIndex), name.substr(attrIndex + 1), attribute.value]
        else
          [name, undefined, attribute.value]

      for [name, attr, value] in bindings.sort(@_sortBindings)
        continue if isViewBacked and viewBackedBindings.indexOf(name) == -1

        binding = if attr
          if reader = attrReaders[name]
            bindingDefinition = new AttrReaderBindingDefinition(node, attr, value, @view)
            reader(bindingDefinition)
        else
          if reader = readers[name]
            bindingDefinition = new ReaderBindingDefinition(node, value, @view)
            reader(bindingDefinition)

        if binding?.initialized # FIXME when nextNode gets less stupid this can be immediate
          @once('bindingsInitialized', do (binding) -> -> binding.initialized.call(binding))

        if binding?.skipChildren
          return true

        if binding?.backWithView
          isViewBacked = true

    if isViewBacked and backingView = _data(node, 'view')
      backingView.initializeBindings()

    return isViewBacked

  nextNode: (node, skipChildren) ->
    if not skipChildren
      children = node.childNodes
      return children[0] if children?.length

    sibling = node.nextSibling
    return if @node == node
    return sibling if sibling

    nextParent = node
    while nextParent = nextParent.parentNode
      parentSibling = nextParent.nextSibling
      return if @node == nextParent
      return parentSibling if parentSibling

    return
