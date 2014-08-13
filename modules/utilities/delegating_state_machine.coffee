StateMachine = require './state_machine'
module.exports = class DelegatingStateMachine extends StateMachine
  constructor: (startState, @base) ->
    super(startState)

  fire: ->
    result = super
    @base.fire(arguments...)
    result