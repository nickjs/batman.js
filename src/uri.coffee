# A lightweight URI class for parsing and param juggling.
#
# URI parsing logic taken from parseUri by Steven Levithan:
#
# http://stevenlevithan.com/demo/parseuri/js/
#
# Nested query logic taken from Rack:
#
# https://github.com/rack/rack/blob/master/lib/rack/utils.rb
class Batman.URI
  ###
  # URI parsing
  ###
  strictParser = /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/
  attributes   = ["source","protocol","authority","userInfo","user","password","hostname","port","relative","path","directory","file","query","hash"]

  constructor: (str) ->
    matches = strictParser.exec(str)
    i = 14
    while (i--)
      @[attributes[i]] = matches[i] or ''

  queryParams: -> @constructor.paramsFromQuery(@query)

  ###
  # query parsing
  ###
  @paramsFromQuery: (query) ->
    params = {}
    for segment in query.split('&')
      if matches = segment.match(keyVal)
        normalizeParams(params, decodeQueryComponent(matches[1]), decodeQueryComponent(matches[2]))
      else
        normalizeParams(params, decodeQueryComponent(segment), null)

    params

  @decodeQueryComponent: decodeQueryComponent = (str) ->
    decodeURIComponent(str.replace(plus, '%20'))

  nameParser       = /^[\[\]]*([^\[\]]+)\]*(.*)/
  childKeyMatchers = [/^\[\]\[([^\[\]]+)\]$/, /^\[\](.+)$/]
  plus             = /\+/g
  r20              = /%20/g
  keyVal           = /^([^=]*)=(.*)/
  normalizeParams  = (params, name, v) ->
    if matches = name.match(nameParser)
      k = matches[1]
      after = matches[2]
    else
      return

    if after is ''
      params[k] = v
    else if after is '[]'
      params[k] ?= []
      throw new Error("expected Array (got #{Batman.typeOf(params[k])}) for param \"#{k}\"") unless Batman.typeOf(params[k]) is 'Array'
      params[k].push(v)
    else if matches = (after.match(childKeyMatchers[0]) or after.match(childKeyMatchers[1]))
      childKey = matches[1]
      params[k] ?= []
      throw new Error("expected Array (got #{Batman.typeOf(params[k])}) for param \"#{k}\"") unless Batman.typeOf(params[k]) is 'Array'
      last = params[k][params[k].length-1]
      if Batman.typeOf(last) is 'Object' and not (childKey of last)
        normalizeParams(last, childKey, v)
      else
        params[k].push(normalizeParams({}, childKey, v))
    else
      params[k] ?= {}
      throw new Error("expected Object (got #{Batman.typeOf(params[k])}) for param \"#{k}\"") unless Batman.typeOf(params[k]) is 'Object'
      params[k] = normalizeParams(params[k], after, v)

    params

  ###
  # query building
  ###
  @queryFromParams: queryFromParams = (value, prefix) ->
    return prefix unless value?
    valueType = Batman.typeOf(value)
    unless prefix? or valueType is 'Object'
      throw new Error("value must be an Object")
    switch valueType
      when 'Array'
        (queryFromParams(v, "#{prefix}[]") for v in value).join("&")
      when 'Object'
        (queryFromParams(v, if prefix then "#{prefix}[#{encodeQueryComponent(k)}]" else encodeQueryComponent(k)) for k, v of value).join("&")
      else
        if prefix?
          "#{prefix}=#{encodeQueryComponent(value)}"
        else
          encodeQueryComponent(value)

  @encodeComponent: encodeComponent = (str) ->
    if str?
      encodeURIComponent(str)
    else
      ''
  @encodeQueryComponent: encodeQueryComponent = (str) ->
    encodeComponent(str).replace(r20, '+')
