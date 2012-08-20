class Batman.Proxy extends Batman.Object
  isProxy: true

  constructor: (target) ->
    super()
    @set 'target', target if target?

  @accessor 'target', Batman.Property.defaultAccessor

  @accessor
    get: (key) -> @get('target')?.get(key)
    set: (key, value) -> @get('target')?.set(key, value)
    unset: (key) -> @get('target')?.unset(key)
