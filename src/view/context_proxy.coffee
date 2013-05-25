class Batman.ContextProxy extends Batman.Object
  isContextProxy: true

  # Reveal the binding's final value.
  @accessor 'proxiedObject', -> @binding.get('filteredValue')
  # Proxy all gets to the proxied object.
  @accessor
    get: (key) -> @get("proxiedObject.#{key}")
    set: (key, value) -> @set("proxiedObject.#{key}", value)
    unset: (key) -> @unset("proxiedObject.#{key}")

  constructor: (definition) ->
    @binding = new Batman.DOM.AbstractBinding(definition)
