#= require ./abstract_binding

Batman.developer.do ->
  class DebuggerBinding extends Batman.DOM.AbstractBinding
    constructor: ->
      super
      debugger

  Batman.DOM.readers.debug = (definition) ->
    new DebuggerBinding(definition)
