#= require ../object

class Batman.ParamsReplacer extends Batman.Object
  constructor: (@navigator, @params) ->
  redirect: -> @navigator.redirect(@toObject(), true)
  replace: (params) ->
    @params.replace(params)
    @redirect()
  update: (params) ->
    @params.update(params)
    @redirect()
  clear: () ->
    @params.clear()
    @redirect()
  toObject: -> @params.toObject()
  @accessor
    get: (k) -> @params.get(k)
    set: (k,v) ->
      oldValue = @params.get(k)
      result = @params.set(k,v)
      @redirect() if oldValue isnt v
      result
    unset: (k) ->
      hadKey = @params.hasKey(k)
      result = @params.unset(k)
      @redirect() if hadKey
      result
