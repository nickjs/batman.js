AbstractBinding = require './abstract_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class ViewArgumentBinding extends AbstractBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

  constructor: (definition, @option, @targetView) ->
    super(definition)

    @targetView.observe @option, @_updateValue = (value) =>
      return if @isDataChanging
      @view.setKeypath(@keyPath, value)

  dataChange: (value) ->
    @isDataChanging = true
    @targetView.set(@option, value)
    @isDataChanging = false

  die: ->
    @targetView.forget(@option, @_updateValue)
    @targetView = null
    super