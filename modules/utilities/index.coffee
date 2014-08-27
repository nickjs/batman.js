Immediates = require './set_clear_immediate'

module.exports = Utilities = {
  Inflector:              require './inflector'
  helpers:                require './string_helpers'
  URI:                    require './uri'
  StateMachine:           require './state_machine'
  DelegatingStateMachine: require './delegating_state_machine'
  Request:                require './request'
  LifecycleEvents:        require './lifecycle_events'
  setImmediate: Immediates.setImmediate
  clearImmediate: Immediates.clearImmediate
}