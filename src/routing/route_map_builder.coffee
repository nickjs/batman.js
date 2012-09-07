class Batman.RouteMapBuilder
  @BUILDER_FUNCTIONS = ['resources', 'member', 'collection', 'route', 'root']
  @ROUTES =
    index:
      cardinality: 'collection'
      path: (resource) -> resource
      name: (resource) -> resource
    new:
      cardinality: 'collection'
      path: (resource) -> "#{resource}/new"
      name: (resource) -> "#{resource}.new"
    show:
      cardinality: 'member'
      path: (resource) -> "#{resource}/:id"
      name: (resource) -> resource
    edit:
      cardinality: 'member'
      path: (resource) -> "#{resource}/:id/edit"
      name: (resource) -> "#{resource}.edit"
    collection:
      cardinality: 'collection'
      path: (resource, name) -> "#{resource}/#{name}"
      name: (resource, name) -> "#{resource}.#{name}"
    member:
      cardinality: 'member'
      path: (resource, name) -> "#{resource}/:id/#{name}"
      name: (resource, name) -> "#{resource}.#{name}"

  constructor: (@app, @routeMap, @parent, @baseOptions = {}) ->
    if @parent
      @rootPath = @parent._nestingPath()
      @rootName = @parent._nestingName()
    else
      @rootPath = ''
      @rootName = ''

  resources: (args...) ->
    resourceNames = (arg for arg in args when typeof arg is 'string')
    callback = args.pop() if typeof args[args.length - 1] is 'function'
    if typeof args[args.length - 1] is 'object'
      options = args.pop()
    else
      options = {}

    actions = {index: true, new: true, show: true, edit: true}

    if options.except
      actions[k] = false for k in options.except
      delete options.except
    else if options.only
      actions[k] = false for k, v of actions
      actions[k] = true for k in options.only
      delete options.only

    for resourceName in resourceNames
      resourceRoot = Batman.helpers.pluralize(resourceName)
      controller = Batman.helpers.camelize(resourceRoot, true)
      childBuilder = @_childBuilder({controller})

      # Call the callback so that routes defined within it are matched
      # before the standard routes defined by `resources`.
      callback?.call(childBuilder)

      for action, included of actions when included
        routeTemplate = @constructor.ROUTES[action]
        as = routeTemplate.name(resourceRoot)
        path = routeTemplate.path(resourceRoot)
        routeOptions = Batman.extend {controller, action, path, as}, options
        childBuilder[routeTemplate.cardinality](action, routeOptions)

    true

  member: -> @_addRoutesWithCardinality('member', arguments...)
  collection: -> @_addRoutesWithCardinality('collection', arguments...)

  root: (signature, options) -> @route '/', signature, options

  route: (path, signature, options, callback) ->
    if !callback
      if typeof options is 'function'
        callback = options
        options = undefined
      else if typeof signature is 'function'
        callback = signature
        signature = undefined

    if !options
      if typeof signature is 'string'
        options = {signature}
      else
        options = signature
      options ||= {}
    else
      options.signature = signature if signature
    options.callback = callback if callback
    options.as ||= @_nameFromPath(path)
    options.path = path
    @_addRoute(options)

  _addRoutesWithCardinality: (cardinality, names..., options) ->
    if typeof options is 'string'
      names.push options
      options = {}
    options = Batman.extend {}, @baseOptions, options
    options[cardinality] = true
    routeTemplate = @constructor.ROUTES[cardinality]
    resourceRoot = Batman.helpers.underscore(options.controller)
    for name in names
      routeOptions = Batman.extend {action: name}, options
      unless routeOptions.path?
        routeOptions.path = routeTemplate.path(resourceRoot, name)
      unless routeOptions.as?
        routeOptions.as = routeTemplate.name(resourceRoot, name)
      @_addRoute(routeOptions)
    true

  _addRoute: (options = {}) ->
    path = @rootPath + options.path
    name = @rootName + Batman.helpers.camelize(options.as, true)
    delete options.as
    delete options.path
    klass = if options.callback then Batman.CallbackActionRoute else Batman.ControllerActionRoute
    options.app = @app
    route = new klass(path, options)
    @routeMap.addRoute(name, route)

  _nameFromPath: (path) ->
    path = path
      .replace(Batman.Route.regexps.namedOrSplat, '')
      .replace(/\/+/g, '.')
      .replace(/(^\.)|(\.$)/g, '')
    path

  _nestingPath: ->
    unless @parent
      ""
    else
      nestingParam = ":" + Batman.helpers.singularize(@baseOptions.controller) + "Id"
      nestingSegment = Batman.helpers.underscore(@baseOptions.controller)
      "#{@parent._nestingPath()}/#{nestingSegment}/#{nestingParam}/"

  _nestingName: ->
    unless @parent
      ""
    else
      @baseOptions.controller + "."

  _childBuilder: (baseOptions = {}) -> new Batman.RouteMapBuilder(@app, @routeMap, @, baseOptions)
