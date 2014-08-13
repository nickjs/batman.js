AbstractAttributeBinding = require './abstract_attribute_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class ClickTrackingBinding extends AbstractAttributeBinding
  onlyObserve: BindingDefinitionOnlyObserve.None
  bindImmediately: false

  constructor: ->
    super

    callback = => Batman.Tracking.trackEvent('click', @get('filteredValue'), @node)
    Batman.DOM.events.click(@node, callback, @view, 'click', false)

    @bind()

