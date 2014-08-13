AbstractBinding = require './abstract_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class RouteParamsBinding extends AbstractBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

  constructor: (definition, @routeBinding) ->
    super(definition)

  dataChange: (value) ->
    @routeBinding.dataChange(@routeBinding.get('filteredValue'), @node, value)