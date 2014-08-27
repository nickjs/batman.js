AbstractBinding = require './abstract_binding'

BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class ShowHideBinding extends AbstractBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    display = definition.node.style.display
    display = '' if not display or display is 'none'
    @originalDisplay = display

    {@invert} = definition
    super

  dataChange: (value) ->
    view = Batman.View.viewForNode(@node, false)

    if value?.isProxy
      value = value.get('target')

    if !!value is not @invert
      view?.fireAndCall('viewWillShow')
      @node.style.display = @originalDisplay
      view?.fireAndCall('viewDidShow')
    else
      view?.fireAndCall('viewWillHide')
      Batman.DOM.setStyleProperty(@node, 'display', 'none', 'important')
      view?.fireAndCall('viewDidHide')
