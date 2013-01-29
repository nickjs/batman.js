class Batman.ViewStore extends Batman.Object
  constructor: ->
    super
    @_viewContents = {}
    @_requestedPaths = new Batman.SimpleSet

  propertyClass: Batman.Property

  fetchView: (path) ->
    new Batman.Request
      url: Batman.Navigator.normalizePath(Batman.config.viewPrefix, "#{path}.html")
      type: 'html'
      success: (response) => @set(path, response)
      error: (response) -> throw new Error("Could not load view from #{path}")

  @accessor
    'final': true
    get: (path) ->
      return @get("/#{path}") unless path.charAt(0) is '/'
      return @_viewContents[path] if @_viewContents[path]
      return if @_requestedPaths.has(path)
      return contents if contents = @_sourceFromDOM(path)
      if Batman.config.fetchRemoteViews
        @fetchView(path)
      else
        throw new Error("Couldn't find view source for \'#{path}\'!")
      return
    set: (path, content) ->
      return @set("/#{path}", content) unless path.charAt(0) is '/'
      @_requestedPaths.add(path)
      @_viewContents[path] = content

  prefetch: (path) ->
    @get(path)
    true

  _sourceFromDOM: (path) ->
    relativePath = path.slice(1)
    if node = Batman.DOM.querySelector(document, "[data-defineview*='#{relativePath}']")
      Batman.setImmediate -> node.parentNode?.removeChild(node)
      Batman.DOM.defineView(path, node)
