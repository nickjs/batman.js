# /api/Data Structures/Batman.StateMachine

`Batman.StateMachine` implements the [finite-state machine](http://en.wikipedia.org/wiki/Finite-state_machine) model. In batman.js, it is used to track a record's lifecycle. To use `Batman.StateMachine`, extend it and define a transition table with `@transitions`. For example:

    test 'StateMachine defines valid transitions', ->
      class BatsuitStateMachine extends Batman.StateMachine
        @transitions
          removeSuit:
            from: ['wearingPants', 'wearingShoes']
            to: 'unsuited'
          putOnPants:
            from: ['unsuited']
            to: 'wearingPants'
          putOnShoes:
            from: ['wearingPants']
            to: 'wearingShoes'

      ok BatsuitStateMachine::putOnShoes, "Transition names are prototype functions"

      batsuit = new BatsuitStateMachine('unsuited')
      equal batsuit.get('state'), 'unsuited', "It starts with the provided state"
      equal batsuit.get('isUnsuited'), true, "State names are accessors with 'is'"
      equal batsuit.get('isWearingShoes'), false, "State names are accessors with 'is'"

      equal batsuit.putOnPants(), true, "Successful transitions return true"

      batsuit = new BatsuitStateMachine('unsuited')
      equal batsuit.putOnShoes(), false, "Don't put on your shoes before putting on your pants!"

## ::constructor(startState : String) : StateMachine

Returns a new `StateMachine` in state `startState`.

## @transitions(transitionTable : object)

Defines the transition table for the `StateMachine`. Each key-value pair of `transitionTable` defines an input event for the `StateMachine`. It should have the form:

```coffeescript
class StateMachineSubclass extends Batman.StateMachine
  @transitions
    inputEvent:
      from: ["startingState", "otherStartingState"] # any number of valid starting states
      to: "endingState"
```

For each input event in `transitionTable`, prototype function `inputEvent` is created. Given `StateMachine` instance `stateMachineInstance`, calling `stateMachineInstance.inputEvent()` tries to transition from `stateMachineInstance`'s current state to the `to` state defined in `transitionTable`. The transition is successful if `stateMachineInstance.state` is a member of `inputEvent`'s `from` states in `transitionTable`. It returns `true` if the transition was successful, otherwise it returns false. For example:

```coffeescript
stateMachineInstance = new StateMachineSubclass('startingState')
stateMachineInstance.get('state') # => 'startingState'
stateMachineInstance.inputEvent() # => true
stateMachineInstance.get('state') # => 'endingState'
stateMachineInstance.inputEvent() # => false, because 'endingState' not in ['startingState', 'otherStartingState']
```

 `StateMachine` doesn't automatically throw [`StateMachine.InvalidTransitionError`](/docs/api/batman.statemachine.invalidtransitionerror.html)s.

For each state defined in `from` and `to`, an `"is#{capitalize(state)}"` accessor is available on the `StateMachine` which returns `true`, `false`, or `undefined`. For example:

```coffeescript
stateMachineInstance.get('state')              # => 'endingState'
stateMachineInstance.get('isEndingState')      # => true
stateMachineInstance.get('isStartingState')    # => false
stateMachineInstance.get('isUnspecifiedState') # => undefined
```

## ::.transitionTable : object

Returns a representation of the `StateMachine`'s transition table. For example, an instance of `BatsuitStateMachine` above would return:

```coffeescript
removeSuit:
  wearingPants: "unsuited"
  wearingShoes: "unsuited"
putOnPants:
  unsuited: "wearingPants"
putOnShoes:
  wearingPants: "wearingShoes"
```

## ::%state

Returns the current state of the `StateMachine`.

# /api/Data Structures/Batman.StateMachine/Batman.StateMachine.InvalidTransitionError

`Batman.StateMachine.InvalidTransitionError` should be thrown when a state machine makes an invalid transition. [`Batman.StateMachine`](/docs/api/batman.statemachine.html) doesn't throw these errors automatically, but applications of the `StateMachine` may throw them. For example [`Batman.Model`](/docs/api/batman.model.html) throws an `InvalidTransitionError` when `save` is called on a deleted record.

## ::constructor(errorMessage : String) : InvalidTransitionError

Returns a new `Batman.StateMachine.InvalidTransitionError` with message `errorMessage`.

# /api/Data Structures/Batman.StateMachine/Batman.DelegatingStateMachine

`Batman.DelegatingStateMachine` adds a simple feature to [`Batman.StateMachine`](/docs/api/batman.statemachine.html). `DelegatingStateMachine` is initalized with a `base` object and when an event is fired on `DelegatingStateMachine`, it fires the same event on the `base`. For an example of `DelegatingStateMachine`, see `Batman.Model.InstanceLifecycleStateMachine` in the [batman.js source](https://github.com/batmanjs/batman/blob/master/src/model/model.coffee#L228).

## ::constructor(startState : String, base : Batman.Object) : DelegatingStateMachine

Returns a new `Batman.DelegatingStateMachine` in state `startState` and delegating to `base`.

## ::fire(eventName : String)

Fires `event` on the `DelegatingStateMachine` and on the `base`.


