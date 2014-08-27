LocalStorage = require './local_storage'

module.exports = class SessionStorage extends LocalStorage
  constructor: ->
    if typeof window.sessionStorage is 'undefined'
      return null
    super
    @storage = sessionStorage
