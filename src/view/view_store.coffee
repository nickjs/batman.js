class Batman.ViewStore extends Batman.Object
  @prefix: 'views'

  constructor: ->
    super
    @_viewContents = {}
    @_requestedPaths = new Batman.SimpleSet

  propertyClass: Batman.Property

  fetchView: (path) ->
    Batman.developer.do ->
      unless typeof Batman.View::prefix is 'undefined'
        Batman.developer.warn "Batman.View.prototype.prefix has been removed, please use Batman.ViewStore.prefix instead."
    new Batman.Request
      url: Batman.Navigator.normalizePath(@constructor.prefix, "#{path}.html")
      type: 'html'
      success: (response) => @set(path, response)
      error: (response) -> throw new Error("Could not load view from #{path}")

  @accessor
    'final': true
    get: (path) ->
      return @get("/#{path}") unless path[0] is '/'
      return @_viewContents[path] if @_viewContents[path]
      return if @_requestedPaths.has(path)
      @fetchView(path)
      return
    set: (path, content) ->
      return @set("/#{path}", content) unless path[0] is '/'
      @_requestedPaths.add(path)
      @_viewContents[path] = content

  prefetch: (path) ->
    @get(path)
    true
