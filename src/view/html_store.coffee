class Batman.HTMLStore extends Batman.Object
  constructor: ->
    super
    @_htmlContents = {}
    @_requestedPaths = new Batman.SimpleSet

  propertyClass: Batman.Property

  fetchHTML: (path) ->
    new Batman.Request
      url: Batman.Navigator.normalizePath(Batman.config.pathToHTML, "#{path}.html")
      type: 'html'
      success: (response) => @set(path, response)
      error: (response) -> throw new Error("Could not load html from #{path}")

  @accessor
    'final': true
    get: (path) ->
      return @get("/#{path}") unless path.charAt(0) is '/'
      return @_htmlContents[path] if @_htmlContents[path]
      return if @_requestedPaths.has(path)
      return contents if contents = @_sourceFromDOM(path)
      if Batman.config.fetchRemoteHTML
        @fetchHTML(path)
      else
        throw new Error("Couldn't find html source for \'#{path}\'!")
      return
    set: (path, content) ->
      return @set("/#{path}", content) unless path.charAt(0) is '/'
      @_requestedPaths.add(path)
      @_htmlContents[path] = content

  prefetch: (path) ->
    @get(path)
    true

  _sourceFromDOM: (path) ->
    relativePath = path.slice(1)
    if node = Batman.DOM.querySelector(document, "[data-defineview*='#{relativePath}']")
      Batman.setImmediate -> node.parentNode?.removeChild(node)
      Batman.DOM.defineView(path, node)
