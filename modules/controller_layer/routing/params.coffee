{Hash} = require 'foundation'


module.exports = class Params extends Hash
  constructor: (@hash, @navigator) ->
    super(@hash)

    @url = new Batman.UrlParams({}, @navigator, this)

  @accessor 'url', -> @url
