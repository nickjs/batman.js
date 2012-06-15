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

  paramsFromPath: (pathAndQuery) ->
    uri = new Batman.URI(pathAndQuery)
    namedArguments = @get('namedArguments')
    params = Batman.extend {path: uri.path}, @get('baseParams')

    matches = @get('regexp').exec(uri.path).slice(1)
    for match, index in matches
      name = namedArguments[index]
      params[name] = match

    Batman.extend params, uri.queryParams

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

    query = Batman.URI.queryFromParams(params)
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

  pathAndParamsFromArgument: (pathOrParams) ->
    if typeof pathOrParams is 'string'
      params = @paramsFromPath(pathOrParams)
      path = pathOrParams
    else
      params = pathOrParams
      path = @pathFromParams(pathOrParams)

    [path, params]

  dispatch: (params) ->
    return false unless @test(params)

    @get('callback')(params)

  callback: -> throw new Batman.DevelopmentError "Override callback in a Route subclass"
