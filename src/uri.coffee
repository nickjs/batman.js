# A lightweight URI class for parsing and param juggling.
# Parsing logic taken from parseUri by Steven Levithan:
#
# http://stevenlevithan.com/demo/parseuri/js/
class Batman.URI
  @paramsFromQuery: (query) ->
    params = {}
    decode = @decodeQueryComponent
    query.replace queryParser, (_, key, value) ->
      params[decode(key)] = decode(value) if key
    params

  @queryFromParams: (params) ->
    encode = @encodeQueryComponent
    ("#{encode(key)}=#{encode(value)}" for key, value of params).join("&")

  strictParser   = /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/
  attributes  = ["source","protocol","authority","userInfo","user","password","hostname","port","relative","path","directory","file","query","hash"]
  queryParser = /(?:^|&)([^&=]*)=?([^&]*)/g
  plus        = /\+/g
  r20         = /%20/g

  constructor: (str) ->
    matches = strictParser.exec(str)
    i = 14
    while (i--)
      @[attributes[i]] = matches[i] or ''

  queryParams: -> @constructor.paramsFromQuery(@query)

  @decodeQueryComponent: (str) ->
    decodeURIComponent(str.replace(plus, '%20'))
  @encodeComponent: encodeComponent = (str) ->
    if str?
      encodeURIComponent(str)
    else
      ''
  @encodeQueryComponent: (str) ->
    encodeComponent(str).replace(r20, '+')
