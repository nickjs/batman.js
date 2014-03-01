# /api/Data Structures/Batman.Object/Batman.EventEmitter

`EventEmitter` is a mixin which gives objects the ability to fire events and accept listeners for those events.

`EventEmitter` is mixed in to `Batman.Object` and `Batman.Object.prototype`, so all classes (contstructor, prototype and instance) that extend `Batman.Object` are also observable.

```coffeescript
alfred = new Batman.Object
alfred.on "breakfastWasPrepared", -> console.log("Breakfast is served, Master Wayne")
alfred.fire "breakfastWasPrepared"
# log: "Breakfast is served, Master Wayne"
```

## Batman.EventEmitter and Batman.Event

Explicitly creating new `Batman.Event`s is rarely needed because `Batman.EventEmitter` enables an object to create and manage its own events. This is primarly implemented  in `EventEmitter::event`, which returns the proper `Batman.Event` for a given `key`, using the `EventEmitter` as the `Event`'s base.

## ::.isEventEmitter[=true] : Boolean

Returns `true`. Shows that `EventEmitter` was mixed into the object.

## ::on(keys... : String, handler : Function)

Attaches `handler` to each event in `keys`. This function will be executed when one of the specified events is fired.

    test 'event handlers are added with `on`', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      ok dynamite.on 'detonate', -> results.push 'detonated'
      dynamite.fire 'detonate'
      equal results[0], 'detonated'

## ::off(keys... : String, handler : Function)

Removes `handler` from the events specified in `keys`. If `handler` is not provided, all handlers will be removed from the specified event keys.

    test 'event handlers are removed with off', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      handler = -> results.push 'This should not fire'
      dynamite.on 'detonate', handler
      dynamite.off 'detonate', handler
      dynamite.fire 'detonate'

      deepEqual results, []

    test 'If no `handler` is provided, off will remove all handlers from the specified events', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      handler = -> results.push 'This should not fire'
      anotherHandler = -> results.push 'Neither should this'
      dynamite.on 'detonate', handler
      dynamite.on 'detonate', anotherHandler
      dynamite.off 'detonate'
      dynamite.fire 'detonate'

      deepEqual results, []

## ::fire(key : String, arguments...)

Fires `key`, calling all handlers with `arguments`.

_Note_: Calling `fire` doesn't guarantee the event will fire since firing can be prevented with `prevent`.

    test 'event handlers are fired', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', (noise) -> results.push "detonated with noise #{noise}"
      dynamite.fire 'detonate', "BOOM!"
      equal results[0], "detonated with noise BOOM!"

## ::hasEvent(key : String) : boolean

Returns `true` if the `EventEmitter` has any handlers on `key`.

    test 'events can be tested for presence', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> log "detonated"
      ok dynamite.hasEvent('detonate')
      equal dynamite.hasEvent('click'), false

## ::once(key : String, handler : Function)

`handler` will be called on the first occurence of `key`, then removed.

    test 'handlers added using `once` are removed after they are fired', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.once 'detonate', -> results.push 'BOOM!'
      ok dynamite.hasEvent('detonate')
      dynamite.fire 'detonate'
      equal results[0], 'BOOM!'
      dynamite.fire 'detonate'
      equal results[1], undefined

## ::prevent(key : String) : EventEmitter

Prevents the event with name `key` from firing, even if `fire` is called. This is useful if you need to guarantee a precondition has been fulfilled before allowing event handlers to execute.

Undo event prevention with `allow` or `allowAndFire`.

_Note_: `prevent` can be called more than once to effectively "nest" preventions. `allow` or `allowAndFire` must be called the same number of times or more for events to fire once more.

    test 'events can be prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This shouldn't fire"
      dynamite.fire('detonate')
      equal results[0], undefined, "The event handler wasn't fired."

    test 'prevent returns the event emitter', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      equal dynamite, dynamite.prevent('detonate')

## ::allow(key : String) : EventEmitter

Allows the event with name `key` to fire after `prevent` has been called. `allow` will not fire the event when called.

_Note_: `prevent` can be called more than once to effectively "nest" preventions. `allow` or `allowAndFire` must be called the same number of times or more for events to fire once more.

    test 'events can be allowed after prevention', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This will only fire once"

      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'events must be allowed the same number of times they have been prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.prevent('detonate')
      dynamite.prevent('detonate')
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired, the prevent count is at 2."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler still wasn't fired, but the prevent count is now at 1."
      dynamite.allow('detonate')
      dynamite.fire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'allow returns the event emitter', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      equal dynamite, dynamite.allow('detonate')

## ::allowAndFire(key : String)

Allows the event `key` to fire and tries to fire it. `allowAndFire` may fail to fire the event if `prevent` has been called more times for this event than `allow` or `allowAndFire` have.

    test 'events can be allowed and fired after prevention', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      dynamite.fire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allowAndFire('detonate')
      equal results.length, 1, "The event handler was fired."

    test 'events must be allowed and fired the same number of times they have been prevented', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      dynamite.prevent('detonate')
      dynamite.allowAndFire('detonate')
      equal results.length, 0, "The event handler wasn't fired."
      dynamite.allowAndFire('detonate')
      equal results.length, 1, "The event handler was fired."


## ::event(key: String, createEvent[=true] : Boolean) : Event

Returns a `Batman.Event` with name `key` if one is present on the `EventEmitter` or its ancestors. If `createEvent` is true, a new event is created on the `EventEmitter` and returned.

## ::isPrevented(key : String) : Boolean

Returns `true` if the event `key` has been `prevent`ed more than it has been `allow`ed

    test 'isPrevented is true after prevent is called', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      equal dynamite.isPrevented('detonate'), true

    test 'isPrevented is false if all prevents have been nullified using `allow`', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> results.push "This will only fire once"
      dynamite.prevent('detonate')
      equal dynamite.isPrevented('detonate'), true
      dynamite.allow('detonate')
      equal dynamite.isPrevented('detonate'), false

## ::mutate(wrappedFunction : Function)

Prevents `"change"` events from firing while `wrappedFunction` is called on the `EventEmitter`. After `wrappedFunction` is complete, a `"change"` event is fired. Returns the result of `wrappedFunction`.

This can be useful when making multiple changes, and only want a single change event fired after the modifications are in place.

    test 'mutate fires a single change event, regardless of the logic in wrappedFunction', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'change', -> results.push 'Change event was fired'
      mutateFunction = ->
        dynamite.fire('change')
        dynamite.fire('change')
      dynamite.mutate(mutateFunction)
      equal results.length, 1

    test 'mutate returns the result of wrappedFunction', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'change', -> results.push 'Change event was fired'
      mutateFunction = -> 'BOOM!'
      mutateResult = dynamite.mutate(mutateFunction)
      equal mutateResult, 'BOOM!'

## ::mutation(wrappedFunction : Function) : Function

Returns a function that will call `wrappedFunction` and fire the `"change"` event when complete (if it is present).

_Note_: the returned function does not block the `"change"` event from firing due to the logic in `wrappedFunction`. To ignore/block `"change"` events, use `prevent('change')`.

    test 'mutation returns a function that wraps the provided wrappedFunction', ->
      class Person extends Batman.Model
        @resourceName: 'person'
        @encode 'name'
        @persist TestStorageAdapter, storage: []

        transform: @mutation ->
          @name = 'Batman'

      results = []
      verifyTransformation = ->
        equal @name, 'Batman'

      person = Person.findOrCreate({name: 'Bruce Wayne'})
      person.on 'change', verifyTransformation
      person.transform()

## ::registerAsMutableSource()

Registers the `EventEmitter` as a source on `Batman.Property`.
