# /api/Data Structures/Batman.Object

`Batman.Object` is the superclass for virtually all objects in a batman.js application. `Batman.Object` mixes in:

- `Batman.Observable` for `get`, `set`, `observe` and others
- `Batman.EventEmitter` for `on`, `off`, `fire` and others

See [`Batman.Object Accessors`](/docs/api/batman.object_accessors.html) for a full description of `@accessor`, which defines properties on `Batman.Object`s.


## @accessor([keys...], objectOrFunction)

If `keys` is empty, defines a new default accessor for instances of the object, otherwise defines a new accessor on instances of the `Object` for `keys`.

`objectOrFunction` may be:

- An object with `get`, `set`, and/or `unset` keys whose values are functions which implement those operations.
- A function which will be treated as the `get` key of the accessor object.

## @classAccessor([keys...], objectOrFunction)

Follows the pattern of `Bamtan.Object.accessor`, but defines the accessor on the class (constructor) instead of on instances of the object.

    test '@classAccessor defines an accessor on the class', ->
      class WayneManor extends Batman.Object
        @classAccessor 'address', -> "123 Wayne Dr."

      equal WayneManor.get('address'), "123 Wayne Dr."
      # Wayne Manor burned down...
      equal (new WayneManor(isRebuilt: true)).constructor.get('address'), "123 Wayne Dr."

## @mixin(objects...) : prototype

Mixes in `objects` to the `Object`'s prototype. Keys from `objects` are applied with `set`. If any of `objects` has an `initialize` function, it will be called with the prototype being mixed into.

_Note_: `@mixin`, similar to `@accessor`, applies to all instances of a class. If you need to mix in to the class itself, look at `classMixin`. `@mixin` is intended for use during the class definition of a `Batman.Object` subclass.

    test '@mixin extends the prototype of a Batman.Object subclass', ->
      FishBehaviour =
        canBreatheUnderwater: true
      MammalBehaviour =
        initialize: ->
          @set('isMammal', true)
        canBreatheAboveWater: true

      class Platypus extends Batman.Object
        @mixin FishBehaviour, MammalBehaviour

      platypus = new Platypus
      ok platypus.get('isMammal'), "the initialize function is called with the target prototype"
      ok platypus.get('canBreatheAboveWater')
      ok platypus.get('canBreatheUnderwater')

## @classMixin(objects...) : this

`@classMixin` mixes `objects` into the class (constructor) in the same way that `@mixin` mixes into the prototype.

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

## @delegate(properties..., options)

Delegates `properties` to `options.to` by creating new accessors for `properties` which call `to.get(property)`. `options` must include a `to` Object.

## @singleton(singletonMethodName[="sharedInstance"])

Shorthand for [singleton classes](http://en.wikipedia.org/wiki/Singleton_pattern). Defines a class accessor `singletonMethodName` which returns the singleton instance.

## @wrapAccessor([keys...,] wrapperFunction: Function)

Defines a *wrap accessor* for the given keys. These accessors are intended to
extend an existing accessor or property by wrapping calls to `get`/`set`/`unset`.

`wrapperFunction` is called immediately, and should return an object with the
same format as an accessor definition. It is passed an object that represents
the original accessor being wrapped, called `core`.

Some trivial examples:

    test "@wrapAccessor can be used to extend get functionality", ->
      class Product extends Batman.Object
        @wrapAccessor 'title', (core) ->
          get: (key) -> 'Product ' + core.get.call(this, key) # Call the original get function.

      foo = new Product(title: 'Foo')
      equal foo.get('title'), 'Product Foo'

    test "@wrapAccessor can be used to extend set functionality", ->
      class Product extends Batman.Object
        @wrapAccessor 'title', (core) ->
          set: (key, value) ->
            core.set.call(this, key, value.toUpperCase()) # Call the original set function, with different arguments.

      foo = new Product(title: 'Product Foo')
      equal foo.get('title'), 'PRODUCT FOO'

Here's a real-world example of a fairly common use-case.
`Product` has a `handle`, which is the token used to identify the product in a
URL. If the user hasn't set a custom handle, then the handle should be generated
from the title. If they do set a custom handle, then changes to the title should
not affect the handle.

    test "@wrapAccessor implementation of generating resource handles", ->
      handleize = (value) -> value?.toLowerCase().replace(/\W+/g, '-')

      class Product extends Batman.Object
        @wrapAccessor 'handle', (core) ->
          get: -> core.get.apply(@, arguments) || handleize(@get('title'))

        @wrapAccessor 'title', (core) ->
          set: (key, value) ->
            if @get('handle') == handleize(@get('title'))
              @set('handle', handleize(value))

            core.set.call(this, key, value)

      foo = new Product(title: 'Product Foo!!')
      equal foo.get('handle'), 'product-foo-' # Handle is automatically set.

      foo.set('title', 'Product Bar')
      equal foo.get('handle'), 'product-bar' # Handle is automatically set again.

      foo.set('handle', 'custom-handle') # User defines a custom handle for this product...
      foo.set('title', 'Product Foo!!')
      equal foo.get('handle'), 'custom-handle' # so now it's not automatically set.

`@wrapAccessor` may be called with no keys to wrap *all* accessors.

## @wrapClassAccessor([keys...,] wrapperFunction: Function )

Like `@wrapAccessor`, but to wrap a class-level accessor.

## ::wrapAccessor([keys...,] wrapperFunction)

Like `@wrapAccessor`, but wraps an accessor on a single instance.

## ::constructor(objects...) : Object

Creates a new `Batman.Object` with properties from `objects`. If items in `objects` have the same keys, later values take precendence over earlier ones. Values are applied with `set`, so custom accessors are applied. The `Batman` namespace performs the same function.

    test 'Batman() function allows for handy creation of Batman.Objects', ->
      object = Batman(foo: 'bar')
      equal typeof object.get, 'function'

    test 'Batman.Object constructor function accepts multiple mixin arguments and later mixins take precedence.', ->
      song = Batman({length: 100, bpm: 120}, {bpm: 130})
      equal song.get('length'), 100
      equal song.get('bpm'), 130, "The property from the second object passed to the constructor overwrites that from the first."

## ::toJSON() : object

`toJSON` returns a vanilla JavaScript object representing this `Batman.Object`.

    test 'toJSON returns a vanilla JS object', ->
      object = Batman(foo: 'bar')
      deepEqual object.toJSON(), {foo: 'bar'}

## ::hashKey() : string

Returns a unique string identifying this `Batman.Object`.

## ::batchAccessorChanges(key, wrappedFunction)

Prevents accessor `key` from being recalculated while the `wrappedFunction` is called on the `Object`. After `wrappedFunction` is complete, the accessor will be recomputed. Returns the result of `wrappedFunction`.


## ::accessor([keys...], objectOrFunction)

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

## ::mixin(objects...) : this

Mixes `objects` into the `Object` instance. Keys from `objects` are applied with `set`. If any of `objects` has an `initialize` function, it will be called with the prototype being mixed into.


    test 'mixin on an instance applies the keys from the mixed in object to the instance', ->
      class Snake extends Batman.Object

      snake = new Snake()
      snake.mixin {canSlither: true}, {canHiss: true}
      ok snake.get('canSlither')
      ok snake.get('canHiss')
