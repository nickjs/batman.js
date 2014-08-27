AbstractBinding = require './abstract_binding'
View = require '../view'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

class DeferredRenderView extends View
  bindImmediately: false

module.exports = class DeferredRenderBinding extends AbstractBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data
  backWithView: DeferredRenderView
  skipChildren: true

  constructor: (definition) ->
    {@invert} = definition
    @attributeName = if @invert then 'data-deferif' else 'data-renderif'
    super

  dataChange: (value) ->
    if !!value is !@invert and not @backingView.isBound
      @node.removeAttribute(@attributeName)
      @backingView.initializeBindings()
