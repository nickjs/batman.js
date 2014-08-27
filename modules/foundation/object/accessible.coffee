BatmanObject = require './object'

module.exports = class Accessible extends BatmanObject
  constructor: -> @accessor.apply(@, arguments)
