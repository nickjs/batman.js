AbstractAttributeBinding = require './abstract_attribute_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class ViewTrackingBinding extends AbstractAttributeBinding
  onlyObserve: BindingDefinitionOnlyObserve.None

  constructor: ->
    super
    Batman.Tracking.trackEvent('view', @get('filteredValue'), @node)
