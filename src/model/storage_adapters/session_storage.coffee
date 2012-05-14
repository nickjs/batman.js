#= require ./local_storage

class Batman.SessionStorage extends Batman.LocalStorage
  constructor: ->
    if typeof window.sessionStorage is 'undefined'
      return null
    super
    @storage = sessionStorage
