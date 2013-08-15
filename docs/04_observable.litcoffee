# Batman.Observable

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
