# Batman.Object

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
