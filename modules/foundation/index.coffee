# BatmanObject and BatmanEvent get renamed later. Don't want to overwrite real Object and Event.

ObjectHelpers = require './object_helpers'

Foundation = {
  # Object
  BatmanEvent:          require "./event_emitter/event"
  EventEmitter:         require './event_emitter/event_emitter'
  Property:             require "./observable/property"
  Keypath:              require "./observable/keypath"
  Observable:           require './observable/observable'
  BatmanObject:         require './object/object'
  TerminalAccessible:   require './object/terminal_accessible'
  Accessible:           require './object/accessible'
  Proxy:                require './object/proxy'

  # Enumerables
  Enumerable:           require './enumerable'
  SimpleHash:           require './hash/simple_hash'
  Hash:                 require './hash/hash'

  SimpleSet:            require './set/simple_set'
  Set:                  require './set/set'
  SetProxy:             require './set/set_proxy'
  SetObserver:          require './set/set_observer'
  SetSort:              require './set/set_sort'
  SetIndex:             require './set/set_index'
  UniqueSetIndex:       require './set/unique_set_index'
  SetMapping:           require './set/set_mapping'
  SetIntersection:      require './set/set_intersection'
  SetComplement:        require './set/set_complement'
  SetUnion:             require './set/set_union'

  developer:            require './developer'
}

ObjectHelpers.extend(Foundation, ObjectHelpers)

module.exports = Foundation
