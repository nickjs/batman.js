#= require ../object

class Batman.Route extends Batman.Object
  # Route regexes courtesy of Backbone
  @regexps =
    namedParam: /:([\w\d]+)/g
    splatParam: /\*([\w\d]+)/g
    queryParam: '(?:\\?.+)?'
    namedOrSplat: /[:|\*]([\w\d]+)/g
    namePrefix: '[:|\*]'
    escapeRegExp: /[-[\]{}()+?.,\\^$|#\s]/g

  optionKeys: ['member', 'collection']
  testKeys: ['controller', 'action']
  isRoute: true
  constructor: (templatePath, baseParams) ->
    regexps = @constructor.regexps
    templatePath = "/#{templatePath}" if templatePath.indexOf('/') isnt 0
    pattern = templatePath.replace(regexps.escapeRegExp, '\\$&')

    regexp = ///
      ^
      #{pattern
          .replace(regexps.namedParam, '([^\/]+)')
          .replace(regexps.splatParam, '(.*?)') }
      #{regexps.queryParam}
      $
    ///

    namedArguments = (matches[1] while matches = regexps.namedOrSplat.exec(pattern))

    properties = {templatePath, pattern, regexp, namedArguments, baseParams}
    for k in @optionKeys
      properties[k] = baseParams[k]
      delete baseParams[k]

    super(properties)

  paramsFromPath: (path) ->
    [path, query] = path.split '?'
    namedArguments = @get('namedArguments')
    params = Batman.extend {path}, @get('baseParams')

    matches = @get('regexp').exec(path).slice(1)
    for match, index in matches
      name = namedArguments[index]
      params[name] = match

    if query
      query = query.replace(/\+/g, '%20')
      query = decodeURIComponent(query)
      for pair in query.split('&')
        [key, value] = pair.split '='
        params[key] = value

    params

  pathFromParams: (argumentParams) ->
    params = Batman.extend {}, argumentParams
    path = @get('templatePath')

    # Replace the names in the template with their values from params
    for name in @get('namedArguments')
      regexp = ///#{@constructor.regexps.namePrefix}#{name}///
      newPath = path.replace regexp, (if params[name]? then params[name] else '')
      if newPath != path
        delete params[name]
        path = newPath

    for key in @testKeys
      delete params[key]
    # Append the rest of the params as a query string
    e = encodeURIComponent
    query = ("#{e(key)}=#{e(value)}" for key, value of params).join("&")
    path += "?#{query}" if query

    path

  test: (pathOrParams) ->
    if typeof pathOrParams is 'string'
      path = pathOrParams
    else if pathOrParams.path?
      path = pathOrParams.path
    else
      path = @pathFromParams(pathOrParams)
      for key in @testKeys
        if (value = @get(key))?
          return false unless pathOrParams[key] == value

    @get('regexp').test(path)

  dispatch: (pathOrParams) ->
    return false unless @test(pathOrParams)
    if typeof pathOrParams is 'string'
      params = @paramsFromPath(pathOrParams)
      path = pathOrParams
    else
      params = pathOrParams
      path = @pathFromParams(pathOrParams)
    @get('callback')(params)
    return path

  callback: -> throw new Batman.DevelopmentError "Override callback in a Route subclass"
