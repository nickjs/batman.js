# /api/Data Structures/Batman.Object/Batman.Observable

`Batman.Observable` is a mixin which gives objects the ability to notify subscribers to changes on its properties.

`Batman.Observable` is mixed in to `Batman.Object` and `Batman.Object.prototype`, so all classes (contstructor, prototype and instance) that extend `Batman.Object` are also observable.

```coffeescript
gotham = new Batman.Object(isCrisis: false)

# set up an observer:
gotham.observe "isCrisis", (newValue, oldValue) ->
  if newValue is true
    console.log("Activate the Batsignal!")
  if newValue is false
    console.log("All is well")

gotham.get('isCrisis')        # => false
gotham.set('isCrisis', true)  # => true
# in the log: "Activate the Batsignal!"
gotham.set('isCrisis', false) # => false
# in the log: "All is well"
```

## ::.isObservable[= true] : Boolean

Returns `true`. Shows that `Observable` was mixed into the object.

## ::get(keypath: String)

Retrieves the value at `keypath` on an object.

    test "get retrieves properties on Batman.Objects", ->
      song = new Batman.Object
        length: 340
        artist: new Batman.Object
          name: "Harry"
      equal song.get("length"), 340, "but `get` works"
      equal song.get("artist.name"), "Harry", "retrieves nested properties"

    test "get retrieves properties o when . doesn't", ->
      song = new Batman.Model(length: 340)
      equal song.length, undefined, "dot-notation doesn't work"
      equal song.get('length'), 340, "get works"

__Note:__ `get` must be used for retrieving properties from `Batman.Object`s. Under the hood, batman.js uses `get`, `set`, and `unset` for dependency calculation and data binding.

## ::set(keypath: String, newValue) : newValue

Stores `newValue` at `keypath` on  the object.

_Note_: Custom setters can mutate the value during setting, so the value which was passed to `set` and `set`'s return value are not guaranteed to be identical.

    test "set stores properties on Batman.Objects", ->
      song = new Batman.Object
        length: 340
        artist: new Batman.Object
          name: "Harry"
      equal song.get("length"), 340
      equal song.set("length", 1000), 1000, "`set` returns the value"
      equal song.get("length"), 1000, "the new value is set on the object"
      equal song.set("artist.name", "Nick"), "Nick"
      equal song.get("artist.name"), "Nick", "The nested keypath returns the new value"
      artist = song.get('artist')
      equal artist.get("name"), "Nick", "Value was set on the nested object."

__Note:__ `set` must be used for updating properties on `Batman.Object`s. Under the hood, batman.js uses `get`, `set`, and `unset` for dependency calculation and data binding.

## ::unset(keypath: String) : value

Removes the value at `keypath`, leaving it `undefined`.

Although the default `unset` implementation is roughly equivalent to `set(keypath, undefined)`, some accessors may reimplement `unset` for their own purposes. Always use `unset` to clear a property.

    test "unset removes properties on Batman.Objects", ->
      song = new Batman.Object
        length: 340
        artist: new Batman.Object
          name: "Harry"
      equal song.get("length"), 340
      equal song.unset("length"), 340, "`unset` returns the value"
      equal song.get("length"), undefined, "the property is undefined"
      equal song.unset("artist.name"), "Harry"
      equal song.get("artist.name"), undefined
      artist = song.get('artist')
      equal artist.get("name"), undefined, "Value was unset on the nested object."

__Note:__ `unset` must be used for clearing properties on `Batman.Object`s. Under the hood, batman.js uses `get`, `set`, and `unset` for dependency calculation and data binding.

## ::getOrSet(keypath: String, valueFunction: Function) : value

If the value at `keypath` is falsey, calls `valueFunction` and sets returned value at `keypath`. Returns the value of the property after the operation, whether it has changed or not. Roughly equivalent to the `||=` operator.

    test "getOrSet sets the property if it falsey", ->
      song = new Batman.Object({length: 340, bpm: 120})
      equal song.getOrSet("length", -> 500), 340, "it returns an existing value at `keypath`"
      equal song.get("length"), 340, "it doesn't override truthy values"
      equal song.getOrSet("artist", -> "Elvis"), "Elvis", "returns a new value at keypath"
      equal song.get("artist"), "Elvis", "it overrides falsey values"

## ::observe(keypath: String, observerCallback: Function) : Observable

Adds `observerCallback` as a handler to call when the value of `get(keypath)` changes.

`observerCallback` is invoked with `newValue, oldValue`, whenever the value at `keypath` changes.

Returns the `Observable`.

    test "observe attaches handlers which get called upon change", ->
      result = null
      song = new Batman.Object
        length: 340
        artist: new Batman.Object
          name: "Harry"
      song.observe "length", (newValue, oldValue) -> result = [newValue, oldValue]
      equal song.set("length", 200), 200
      deepEqual result, [200, 340], "observe tracks keypaths"
      equal song.set("length", 300), 300
      deepEqual result, [300, 200], "observe tracks keypaths continuously"
      song.observe "artist.name", (newName, oldName) ->
        result = [newName, oldName]
      newArtist = new Batman.Object({name: "James"})
      song.set "artist", newArtist
      deepEqual result, ["James", "Harry"], "The observer fired when the 'artist' segment of the keypath changed."


## ::forget([keypath: String[, observerCallback: Function]]) : Observable

If `observerCallback` and `keypath` are given, `observerCallback` is removed from the observers on `keypath`. If only `keypath` is given, all observers on that key are removed. If no `keypath` is given, all observers on all keys are removed.

Returns the `Observable`.

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

## ::observeAndFire(keypath: String, observerCallback: Function) : Observable

Adds `observerCallback` as an observer to `keypath` and fires it immediately with the current value at `keypath`.

_Note_: During the initial synchronous firing of `observerCallback`, `newValue` and `oldValue` will be the same: the current value of the property. The old value was not cached and is therefore unavailable. If your observer needs the old value of the property, you must attach it before the `set` on the property happens.

    test "observeAndFire calls the observer upon attaching it with the currentValue of the property", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      song.observeAndFire "length", (newValue, oldValue) -> result = [newValue, oldValue]
      deepEqual result, [340, 340]
      equal song.set("length", 300), 300
      deepEqual result, [300, 340]

## ::observeOnce(keypath: String, observerCallback: Function)

Like `Observable::observe`, except that after `observerCallback` has been called once, it will remove itself from the observers on `keypath`.

    test "observeOnce only calls observerCallback when key is modified for the first time", ->
      result = null
      song = new Batman.Object({length: 340, bpm: 120})
      song.observeOnce "length", (newValue, oldValue) -> result = [newValue, oldValue]
      equal song.set("length", 200), 200
      deepEqual result, [200, 340]
      equal song.set("length", 300), 300
      deepEqual result, [200, 340], "The observer was not fired for the second update"

