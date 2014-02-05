# /api/Data Structures/Batman.Object

`Batman.Object` is the superclass for virtually all objects in a Batman application. `Batman.Object` mixes in `Batman.Observable` and `Batman.EventEmitter` for things like `get`, `set`, `observe`, and `fire`, and then defines some more useful things for tying everything together.

## @accessor([keys...], objectOrFunction)

Accessors are used to create properties on a class, prototype, or instance which can be fetched, set, and unset. These properties can be static, computed as functions of the other properties on the object the accessor belongs to, or properties of any Batman object in the system. `accessor` is a Batman and old browser friendly version of ES5 `Object.defineProperty`.

The value of custom accessors can be observed just like any property. Accessors also track which other properties they rely on for computation, and recalculate eagerly when those other properties change. This way, when a source value is changed, any dependent accessors will automatically update any bindings to them with a new value. Accessors accomplish this feat by tracking `get` calls, so be sure to use `get` to retrieve properties on Batman Objects inside accessors so those properties can be tracked as dependencies. The property dependencies of an accessor are called "sources" in the Batman world.

Importantly, accessors are also inherited, so accessors defined anywhere in an object's prototype chain will be used. Following this, `@accessor` is meant to be used during the class definition of a class extending `Batman.Object`.

#### Arguments

`@accessor` can be called with zero, one, or many keys for the accessor to define. This has the following effects:

  * zero: create a `defaultAccessor`, which will be called when no other properties or accessors on an object match a keypath. This is similar to `method_missing` in Ruby or `#doesNotUnderstand` in Smalltalk.
  * one: create a `keyAccessor` at the given key, which will only be called when that key is gotten, set, or unset.
  * many: create `keyAccessors` for each given key, which will then be called whenever each one of the listed keys is gotten, set, or unset.

`@accessor` accepts as the last argument either an object with any combination of the `get`, `set`, and `unset` keys defined, or a function. Functions which implement the behaviour for those particular actions on the property should reside at these keys. `@accessor` also accepts a function as the last argument, which is a shorthand for specifying the `get` implementation for the accessor.

#### Uses

Accessors are a really useful addition to the world of JavaScript. You can now define transforms on simple properties which will automatically update when the properties they transform change: for example, you might want to truncate a potentially long piece of text to display a summary elsewhere, or you might want to capitalize or `encodeURIComponent` a value before putting it in the view or the current URL.

    test '@accessor can be called on a class to define how a property is calculated', ->
      class Post extends Batman.Object
        @accessor 'summary', -> @get('body').slice(0, 10) + "..."

      post = new Post(body: "Why Batman is Useful: A lengthy post on an important subject")
      equal post.get('summary'), "Why Batman..."

You can also use accessors to combine properties; the colloquial `fullName` example comes to mind, but all sorts of other complex logic can be abstracted away using the accessor pattern.

    test '@accessor can define a transform on several properties', ->
      class User extends Batman.Object
        @accessor 'fullName', -> @get('firstName') + " " + @get('lastName')

      tim = new User(firstName: "Tim", lastName: "Thomas")
      equal tim.get('fullName'), "Tim Thomas"
      tim.set('firstName', "Timmy")
      equal tim.get('fullName'), "Timmy Thomas"

Accessors can define custom `get`, `set`, and `unset` functions to support each operation on the property:

    test '@accessor can define the get, set, and unset methods for the property', ->
      class AbsoluteNumber extends Batman.Object
        @accessor 'value',
          get: -> @_value
          set: (_, value) -> @_value = Math.abs(value)
          unset: -> delete @_value

      number = new AbsoluteNumber(value: -10)
      equal number.get('value'), 10

Importantly, it is also safe to use branching, loops, or whatever logic you want in accessor bodies:

    test '@accessor can use arbitrary logic to define the value', ->
      class Player extends Batman.Object
        @accessor 'score', ->
          if @get('played')
            (@get('goals') * 2) + (@get('assists') * 1)
          else
            0

      rick = new Player(played: false, goals: 0, assists: 0)
      equal rick.get('score'), 0
      rick.set('played', true)
      equal rick.get('score'), 0
      rick.set('goals', 3)
      equal rick.get('score'), 6
      rick.set('assists', 1)
      equal rick.get('score'), 7

#### Caveats

Accessors are extremely useful, but keep these items in mind when using them:

 1. Accessors should be pure functions so they are predictable and can be cached.

Batman automatically memoizes the return value of accessors, and will not re-execute the body until one of the accessor's sources changes. If you need the accessor to recalculate every time the property is gotten, pass `false` for the `cache` option in the accessor descriptor object (the last argument to the `@accessor` function).

    test "@accessor usually caches results", ->
      counter = 0
      class Example extends Batman.Object
        @accessor 'cachedCounter', -> ++counter
        @accessor 'notCachedCounter',
          get: -> ++counter
          cache: false

      example = new Example()
      equal example.get('cachedCounter'), 1
      equal example.get('cachedCounter'), 1
      equal example.get('cachedCounter'), 1, "The second and third calls do not execute the function"
      equal example.get('notCachedCounter'), 2
      equal example.get('notCachedCounter'), 3, "Passing cache: false does re-execute the function"
      equal example.get('cachedCounter'), 1

 2. Accessors _must_ use `get` to access properties they use for computation

Batman tracks an accessor's sources by adding a global hook to all `get`s done, so if you don't use `get` to access properties on objects, Batman can't know that that property is a source of the property your accessor defines, so it can't recompute that property when the source property changes. All properties on `Batman.Object` should be accessed using `get` and `set` whether or not the code occurs in an accessor body, but it is critical to do so in accessors so the sources of the accessor can be tracked.

 3. Accessors can create memory leaks or performance bottlenecks

If you return a brand new object, say by merging a number of `Batman.Set`s or doing any sort of major and complete re-computation, you run the risk of creating performance problems. This is because accessors can be called frequently and unpredictably, as they are recomputed every time one of their sources changes and for every call to `set`. Instead of recomputing expensive things every time the accessor is called, try to use objects which do smart re-computation using observers. Practically, this translates to using things like `new SetUnion(@get('setA'), @get('setB'))` instead of `@get('setA').merge(@get('setB'))` in an accessor body, since `SetUnion` will observe its constituents and update itself when they change, instead of the `merge` resulting in the accessor recomputing every time `setA` or `setB` changed.

## @classAccessor([keys...], objectOrFunction)

`classAccessor` defines an accessor on the class: `get`s and `set`s done to the class will use the accessor definition as an implementation. `@accessor` called on a class will define an accessor for all instances of that class, whereas `@classAccessor` defines accessors on the class object itself. See `@accessor` for the details surrounding accessors.

    test '@classAccessor defines an accessor on the class', ->
      class SingletonDooDad extends Batman.Object
        @classAccessor 'instance', -> new @()

      instance = SingletonDooDad.get('instance')      # "classAccessor defines accessors for gets done on the class its self"
      ok SingletonDooDad.get('instance') == instance  # "A second get returns the same instance"

## @mixin(objects...) : prototype

`@mixin` is a handy function for mixing in `object`s to a class' prototype. `@mixin` is implemented on top of the Batman level `mixin` helper, which means that keys from incoming `objects` will be applied using `set`, and any `initialize` functions on the `objects` will be called with the prototype being mixed into. Returns the prototype being mixed into.

_Note_: `@mixin`, similar to `@accessor`, applies to all instances of a class. If you need to mix in to the class itself, look at `classMixin`. `@mixin` is intended for use during the class definition of a `Batman.Object` subclass.

    test '@mixin extends the prototype of a Batman.Object subclass', ->
      FishBehaviour = {canBreathUnderwater: true}
      MammalBehaviour = {canBreathAboveWater: true}
      class Platypus extends Batman.Object
        @mixin FishBehaviour, MammalBehaviour

      platypus = new Platypus
      ok platypus.get('canBreathAboveWater')
      ok platypus.get('canBreathUnderwater')

## @classMixin(objects...) : this

`@classMixin` allows mixing in objects to a class during that class' definition. See `@mixin` for information about the arguments passed to mixin, but note that `@classMixin` applies to the class object itself, and `@mixin` applies to all instances of the class. Returns the class being mixed into.

    test '@classMixin extends the Batman.Object subclass', ->
      Singleton =
        initialze: (subject) ->
          subject.accessor 'instance', -> new subject

      class Highlander extends Batman.Object
        @classMixin Singleton

      instance = Highlander.get('instance')
      ok instance == Highlander.get('instance'), "There can only be one."

## @observeAll(key, callback : function) : prototype

`@observeAll` extends the `Batman.Object` implementation of `Batman.Observable` with the ability to observe all instances of the class (and subclasses). Observers attached with `@observeAll` function exactly as if they were attached to the object directly. Returns the prototype of the class.

_Note_: `@observeAll` is intended to be used during the class definition for a `Batman.Object` subclass, but it can be called after the class has been defined as a function on the class. It supports being called after instances of the class have been instantiated as well.

    test "@observeAll attaches handlers which get called upon change", ->
      results = []
      class Song extends Batman.Object
        @observeAll 'length', (newValue, oldValue) -> results.push newValue

      song = new Song({length: 340, bpm: 120})
      equal song.set('length', 200), 200
      deepEqual results[1], 200

    test "@observeAll can attach handlers after instance instantiation", ->
      results = []
      class Song extends Batman.Object

      song = new Song({length: 340, bpm: 120})
      equal song.set('length', 360), 360
      deepEqual results[0], undefined
      Song.observeAll 'length', (newValue, oldValue) -> results.push newValue
      equal song.set('length', 200), 200
      deepEqual results[0], 200

## constructor(objects...)

To create a new `Batman.Object`, the `Batman.Object` constructor can be used, or, the `Batman` namespace is also a utility function for creating Batman objects. Each object passed in to the constructor will have all its properties applied to the new `Batman.Object` using `get` and `set`, so any custom getters or setters will be respected. Objects passed in last will have precedence over objects passed in first in the event that they share the same keys. The property `copy` from these objects is shallow.

    test 'Batman() function allows for handy creation of Batman.Objects', ->
      object = Batman(foo: 'bar')
      equal typeof object.get, 'function'

    test 'Batman.Object constructor function accepts multiple mixin arguments and later mixins take precedence.', ->
      song = Batman({length: 100, bpm: 120}, {bpm: 130})
      equal song.get('length'), 100
      equal song.get('bpm'), 130, "The property from the second object passed to the constructor overwrites that from the first."

## toJSON() : object

`toJSON` returns a vanilla JavaScript object representing this `Batman.Object`.

    test 'toJSON returns a vanilla JS object', ->
      object = Batman(foo: 'bar')
      deepEqual object.toJSON(), {foo: 'bar'}

## hashKey() : string

`hashKey` returns a unique string identifying this particular `Batman.Object`. No two `Batman.Object`s will have the same `hashKey`. Feel free to override the implmentation of this function on your objects if you have a better hashing scheme for a domain object of yours.

## batchAccessorChanges(key, wrappedFunction) : string

Prevents accessor from being recalculated while the specified function is called. Only after `wrappedFunction` is complete will the accessor be recomputed. Returns the result of `wrappedFunction`.

This can be useful when making multiple changes, and only want a single change event fired after the modifications are in place.

## accessor([keys...], objectOrFunction)

`accessor` defines an accessor on one instance of an object instead of on all instances like the class level `@accessor`. See `@accessor` for the details surrounding accessors.

    test 'accessor can be called on an instance of Batman.Object to define an accessor just on that instance', ->
      class Post extends Batman.Object
        @accessor 'summary', -> @get('body').slice(0, 10) + "..."

      post = new Post(body: "Why Batman is Useful: A lengthy post on an important subject")
      equal post.get('summary'), "Why Batman..."
      post.accessor('longSummary', -> @get('body').slice(0, 20) + "...")  # "Instance level accessor defines accessors just for that instance"
      equal post.get('longSummary'), "Why Batman is Useful..."

    test 'defining an accessor on an instance does not affect the other instances', ->
      class Post extends Batman.Object

      post = new Post(body: "Why Batman is Useful: A lengthy post on an important subject")
      otherPost = new Post(body: "Why State Machines Are Useful: Another lengthy post")
      post.accessor 'longSummary', -> @get('body').slice(0, 20) + "..."
      equal post.get('longSummary'), "Why Batman is Useful..."
      equal otherPost.get('longSummary'), undefined

## mixin(objects...) : this

`mixin` extends the object it's called on with the passed `objects` using the `Batman.mixin` helper. Returns the object it's called upon.

_Note_: Since the `Batman.mixin` helper is used, mixin functionality like using `set` to apply properties and calling `initialize` functions is included in the instance level `mixin` function.

    test 'mixin on an instance applies the keys from the mixed in object to the instance', ->
      class Snake extends Batman.Object

      snake = new Snake()
      snake.mixin {canSlither: true}, {canHiss: true}
      ok snake.get('canSlither')
      ok snake.get('canHiss')

# /api/Data Structures/Batman.Object/Batman.Observable

`Batman.Observable` is a mixin which gives objects the ability to notify subscribers to changes on its properties. `Observable` also adds functionality for observing _keypaths_: arbitrarily deeply nested properties on objects. All `Batman.Object`s, their subclasses and instances are observable by default.

## ::.isObservable[= true] : boolean

`isObservable` will return `true` when the current object is able to be observed, or `false` if it is not.

## ::get(keypath: string) : value

Retrieves the value at a `key` on an object. Accepts keypaths.

_Note_: `get` must be used for property access on any object in `Batman`'s world. This is so that Batman can implement neat things like automatic dependency calculation for computed properties, property caching where it is safe, and smart storage mechanisms. With Batman, you must use `get` instead of the regular `.` for property access.

    test "get retrieves properties on Batman objects", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.get("length"), 340
      equal song.get("bpm"), 120

    test "get retrieves properties on nested Batman objects using keypaths", ->
      post = new Batman.Object
        text: "Hello World!"
        author: new Batman.Object
          name: "Harry"
      equal post.get("author.name"), "Harry"

    test "get retrieves properties on Batman objects when . property access doesn't", ->
      song = new Batman.Model({length: 340, bpm: 120})
      equal typeof song.length, "undefined"
      equal song.get("length"), 340

## ::set(keypath: string, newValue) : newValue

Stores the `value` at a `key` on an object. Accepts keypaths. Returns the new value of the property.

_Note_: Once more, `set` must be used for property mutation on all objects in the `Batman` world. This is again so that Batman can implement useful functionality like cache busting, eager recalculation of computed properties, and smarter storage.

_Note_: Custom setters can mutate the value during setting, so the value which was passed to `set` and `set`'s return value are not guaranteed to be identical.

    test "set stores properties on batman objects.", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.get("length"), 340
      equal song.set("length", 1000), 1000
      equal song.get("length"), 1000

    test "set stores properties on nested Batman objects using keypaths", ->
      author = new Batman.Object
        name: "Harry"
      post = new Batman.Object
        text: "Hello World!"
        author: author
      equal post.set("author.name", "Nick"), "Nick"
      equal author.get("name"), "Nick", "The value was set on the nested object."

    test "set is incompatible with '.' property mutation", ->
      song = new Batman.Model({length: 340, bpm: 120})
      equal song.get("length"), 340
      equal song.length = 1000, 1000
      equal song.get("length"), 340, "The song length reported by Batman is unchanged because set wasn't used to change the value."

## ::unset(keypath: string) : value

Removes the value at the given `keypath`, leaving it `undefined`. Accepts keypaths. Returns the value the property had before unsetting.

`unset` is roughly equivalent to `set(keypath, undefined)`, however, custom properties can define a nonstandard `unset` function, so it is best to use `unset` instead of `set(keypath, undefined)` wherever possible.

    test "unset removes the property on Batman objects", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.get("length"), 340
      equal song.unset("length"), 340
      equal song.get("length"), undefined, "The value is unset."

    test "unset removes the property at a keypath", ->
      author = new Batman.Object
        name: "Harry"
      post = new Batman.Object
        text: "Hello World!"
        author: author
      equal post.unset("author.name"), "Harry"
      equal author.get("name"), undefined, "The value was unset on the nested object."

## ::getOrSet(keypath: string, valueFunction: Function) : value

Assigns the `keypath` to the result of calling `valueFunction` if `keypath` is currently falsey. Returns the value of the property after the operation, whether it has changed or not. Equivalent to CoffeeScript's `||=` operator.

    test "getOrSet doesn't set the property if it exists", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.getOrSet("length", -> 500), 340
      equal song.get("length"), 340

    test "getOrSet sets the property if it is falsey", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.getOrSet("artist", -> "Elvis"), "Elvis"
      equal song.get("artist"), "Elvis"

## ::observe(key: string, observerCallback: Function) : this

Adds a handler to call when the value of the property at the `key` changes upon `set`ting. Accepts keypaths.

`observe` is the very core of Batman's usefulness. As long as `set` is used everywhere to do property mutation, any object can be observed for changes to its properties. This is critical to the concept of bindings, which Batman uses for its views.

The `observerCallback` gets called with the arguments `newValue, oldValue`, whenever the `key` changes.

Returns the object `observe` was called upon.

    test "observe attaches handlers which get called upon change", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      song.observe "length", (newValue, oldValue) -> result = [newValue, oldValue]
      equal song.set("length", 200), 200
      deepEqual result, [200, 340]
      equal song.set("length", 300), 300
      deepEqual result, [300, 200]


_Note_: `observe` works excellently on keypaths. If you attach a handler to a "deep" keypath, it will fire when any segment of the keypath changes, passing in the new value at the end of the keypath.

    test "observe attaches handlers which get called upon change", ->
      result = null
      author = new Batman.Object
        name: "Harry"
      post = new Batman.Object
        text: "Hello World!"
        author: author
      post.observe "author.name", (newName, oldName) ->
        result = [newName, oldName]
      newAuthor = new Batman.Object({name: "James"})
      post.set "author", newAuthor
      deepEqual result, ["James", "Harry"], "The observer fired when the 'author' segment of the keypath changed."

## ::observeAndFire(key: string, observerCallback: Function) : this

Adds the `observerCallback` as an observer to `key`, and fires it immediately. Accepts the exact same arguments and follows the same semantics as `Observable::observe`, but the observer is fired with the current value of the keypath it observes synchronously during the call to `observeAndFire`.

_Note_: During the initial synchronous firing of the `callback`, the `newValue` and `oldValue` arguments will be the same value: the current value of the property. This is because the old value of the property is not cached and therefore unavailable. If your observer needs the old value of the property, you must attach it before the `set` on the property happens.

    test "observeAndFire calls the observer upon attaching it with the currentValue of the property", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      song.observeAndFire "length", (newValue, oldValue) -> result = [newValue, oldValue]
      deepEqual result, [340, 340]
      equal song.set("length", 300), 300
      deepEqual result, [300, 340]

## ::observeOnce(key: string, observerCallback: Function)

Behaves the same way as `Observable::observe`, except that once `observerCallback` has been executed for the first time, it will remove itself as an observer to `key`.

    test "observeOnce only calls observerCallback when key is modified for the first time", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      song.observeOnce "length", (newValue, oldValue) -> result = [newValue, oldValue]
      equal song.set("length", 200), 200
      deepEqual result, [200, 340]
      equal song.set("length", 300), 300
      deepEqual result, [200, 340], "The observer was not fired for the second update"

## ::forget([key: string[, observerCallback: Function]]) : this

If `observerCallback` and `key` are given, that observer is removed from the observers on `key`. If only a `key` is given, all observers on that key are removed. If no `key` is given, all observers on all keys are removed. Accepts keypaths.

Returns the object on which `forget` was called.

    test "forget removes an observer from a key if the key and the observer are given", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      observer = (newValue, oldValue) -> result = [newValue, oldValue]
      song.observe "length", observer
      equal song.set("length", 200), 200
      deepEqual result, [200, 340]
      song.forget "length", observer
      equal song.set("length", 300), 300
      deepEqual result, [200, 340], "The logged values haven't changed because the observer hasn't fired again."

    test "forget removes all observers from a key if only the key is given", ->
      results = []
      song = new Batman.Object({length: 340, bpm: 120})
      observerA = ((newValue, oldValue) -> results.push [newValue, oldValue])
      observerB = ((newValue, oldValue) -> results.push [newValue, oldValue])
      song.observe "length", observerA
      song.observe "length", observerB
      equal song.set("length", 200), 200
      equal results.length, 2, "Both length observers fired."
      song.forget("length")
      equal song.set("length", 300), 300
      equal results.length, 2, "Nothing more has been added because neither observer fired."

    test "forget removes all observers from all keys if no key is given", ->
      results = []
      song = new Batman.Object({length: 340, bpm: 120})
      observerA = ((newValue, oldValue) -> results.push [newValue, oldValue])
      observerB = ((newValue, oldValue) -> results.push [newValue, oldValue])
      song.observe "length", observerA
      song.observe "bpm", observerB
      equal song.set("length", 200), 200
      equal results.length, 1, "The length observer fired."
      song.forget()
      equal song.set("length", 300), 300
      equal song.set("bpm", 130), 130
      equal results.length, 1, "Nothing more has been logged because neither observer fired."


# /api/Data Structures/Batman.Object/Batman.EventEmitter

`EventEmitter` is a mixin which can be applied to any object to give it the ability to fire events and accept listeners for those events. All `Batman.Object`s, their subclasses and instances are `EventEmitter`s by default.

## ::on(keys... : [string|Array], handler : Function)

Attaches a function `handler` to each event in the provided `keys` collection. This function will be executed when one of the specified events is fired.

    test 'event handlers are added with `on`', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      ok dynamite.on 'detonate', -> results.push 'detonated'
      dynamite.fire 'detonate'
      equal results[0], 'detonated'

## ::off(keys... : [string|Array], handler : Function)

Removes the `handler` function from the events specified in `keys`. If `handler` is not provided, all handlers will be removed from the specified event keys.

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

## ::fire(key : string, arguments... : Array)

Calls all previously attached handlers on the event with name `key`. All handlers will receive the passed `arguments`.

_Note_: Calling `fire` doesn't guarantee the event will fire since firing can be prevented with `prevent`.

    test 'event handlers are fired', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', (noise) -> results.push "detonated with noise #{noise}"
      dynamite.fire 'detonate', "BOOM!"
      equal results[0], "detonated with noise BOOM!"

## ::hasEvent(key : string) : boolean

Asks if the `EventEmitter` has an event with the given `key`.

    test 'events can be tested for presence', ->
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.on 'detonate', -> log "detonated"
      ok dynamite.hasEvent('detonate')
      equal dynamite.hasEvent('click'), false

## ::once(key : string, handler : Function)

Allows the specified handler to be fired only once before it is removed

    test 'handlers added using `once` are removed after they are fired', ->
      results = []
      dynamite = Batman.mixin {}, Batman.EventEmitter
      dynamite.once 'detonate', -> results.push 'BOOM!'
      ok dynamite.hasEvent('detonate')
      dynamite.fire 'detonate'
      equal results[0], 'BOOM!'
      dynamite.fire 'detonate'
      equal results[1], undefined

## ::prevent(key : string) : EventEmitter

Prevents the event with name `key` from firing, even if `fire` is called. This is useful if you need to guarantee a precondition has been fulfilled before allowing event handlers to execute. Returns the event emitting object.

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

## ::allow(key : string) : EventEmitter

Allows the event with name `key` to fire, after `prevent` had been called. `allow` will not fire the event when called, regardless of whether or not the event can now be fired or if an attempt to fire it was made while the event was prevented. Returns the event emitting object.

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

## ::allowAndFire(key : string)

Allows the event with name `key` to fire once more, and tries to fire it. `allowAndFire` may fail to fire the event if `prevent` has been called more times for this event than `allow` or `allowAndFire` have.

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

## ::isPrevented(key : string) : boolean

Asks if the specified event is currently being prevented from firing

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

Prevents change events from firing while the specified function is called. Only after `wrappedFunction` is complete will the `change` event be fired. Returns the result of `wrappedFunction`.

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

## ::mutation(wrappedFunction : Function)

A helper method that returns a function that will call `wrappedFunction` and fires the change event when complete (if it is present).

_Note_: the returned function does not block the change event from firing due to the logic in `wrappedFunction`. To ignore/block change events, use `prevent('change')`.

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


## ::.isEventEmitter

Always true. Useful for testing whether a specific object instance uses the EventEmitter mixin.
