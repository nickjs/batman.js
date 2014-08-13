AbstractBinding = require './abstract_binding'

module.exports = class DebuggerBinding extends AbstractBinding
    constructor: ->
      super
      debugger


