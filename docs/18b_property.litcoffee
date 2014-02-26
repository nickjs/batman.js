
# /api/Data Structures/Batman.Event/Batman.Property

`Batman.Property` extends `Batman.PropertyEvent` (which extends `Batman.Event`). `Batman.Property` is home to batman.js's powerful source tracking capabilities.

## Source Tracking by Batman.Property

When you define an `@accessor` on a `Batman.Object`, the accessor's `get` function is actually wrapped in source tracking by `Batman.Property`. Source tracking is implemented by a global source tracker stack, `SOURCE_TRACKER_STACK`, which is inside `Batman.Property`'s closure scope. The source tracker stack's members are arrays of source objects. For example:

```coffeescript
## SOURCE_TRACKER_STACK
[
  [<Batman.Property 1>, <Batman.Property 2>], # a set of sources
  [<Batman.Property 3>, <Batman.Property 4>], # another set of sources
  [ < ... > ]
]
```

Calling `get` signals to batman.js that a new source set may be added (via a variable inside `Batman.Property`'s closure scope, `SOURCE_TRACKER_STACK_VALID`). At the onset of a subsequent `get`:

- a new, empty source set is pushed to the global tracker if needed
- the property pushes itself to the current set of sources
- the `get` signals that a new source set may be added.

At the completion of each `get`:

- the last item of the global source tracker is popped off and stored as the `Property`'s `@sources`.

So, the global source tracker stack grows until a `get` doesn't depend on any other `Batman.Property` objects, then it starts to shrink. As it shrinks, each set of sources is attached to the `Property` which put it on the stack.

## ::constructor(base, key: String) : Property

Returns a new `Property` on `base` named `key`.

## ::.base

Returns `base` specified in the constructor. Represents the object the `Property` belongs to.

## ::.key

Returns the `key` specified in the constructor. Represents the name of property.

## @.defaultAccessor : Object

A JavaScript object implementing the [`Batman.Object.accessor`](/docs/api/batman.object_accessors.html) pattern by storing the value on the `Property` directly.

## @defaultAccessorForBase(base) : Object

Returns the `base`s `'defualtAccessor'` if present, otherwise returns `Batman.Property.defaultAccessor`.

## @accessorForBaseAndKey(base, key: String) :

Checks `base` and its ancestors for an accessor for `string` and returns it if found, otherwise returns `Batman.Property.defaultAccessor`.

## @forBaseAndKey(base, key: String) : Property

If `base.isObservable`, delegates to the object's `property` function to return a `Property` for key, otherwise returns a new `Batman.Keypath` for `base` and `key`.

## @wrapTrackingPrevention(block: Function) : Function

Creates a new function by wrapping `block` in _tracking prevention_ and returns it. When changes are wrapped in tracking prevention, they won't cause updates to other properties.

## @withoutTracking(block: Function)

Wraps `block` in tracking prevention and calls it.

## @registerSource(object)

If `object` is a `Batman.EventEmitter` or a `Batman.Property`, registers `object` in the current set in the global source tracker. Otherwise, it does nothing.

## @pushSourceTracker()

Adds a new set to the global source tracker.

## @popSourceTracker()

Gets the last set from the global source tracker.

## @pushDummySourceTracker()

Adds a dummy set to the global source tracker. Used for preventing source tracking.

## ::.cached[=false] : Boolean

Returns `true` if the value was retrieved from the accessor and the cache hasn't been busted.

## ::.value

Returns the value last retrieved from the accessor.

## ::.sources : Array

Returns the dependencies of the `Property`, set automatically by `updateSourcesFromTracker`. Each source maybe a `Batman.EventEmitter` (which responds to `on`/`off`), or a function (which is managed with `addHandler`/`removeHandler`).

## ::.isProperty[=true] : Boolean

Returns `true`.

## ::.isDead[=false] : Boolean

Returns `false` unless `die` was called on the `Property`.

## ::.isBatchingChanges[=false] : Boolean

If set to `true`, source changes won't cause the `Property` to `refresh` itself.

## ::registerAsMutableSource()

Registers the property as a source with `Batman.Property.registerSource`.

## ::isEqual(other: Property) : Boolean

Returns `true` if `other`'s `constructor`, `base`, and `key` match the `Property`'s `constructor`, `base`, and `key`.

## ::hashKey() : String

Returns a string representation of the `Property`.

## ::accessor() : Object

Returns the accessor object for the `Property` by using `Batman.Property.accessorForBaseAndKey` for the `Property`'s `base` and `key`.

## ::eachObserver(iterator: Function)

Calls `iterator(handler)` for each handler on the `Property` and each of its `Observable` ancestors.

## ::observers() : Array

Returns handlers from the `Property` and each of its `Observable` ancestors.

## ::hasObservers() : Boolean

Returns `true` if it has any observers.

## ::updateSourcesFromTracker()

Pops sources off the global tracker and replaces the `Property`'s current sources with the new ones, using `off`/`on` or `removeHandler`/`addHandler` as appropriate.

## ::getValue()

Registers itself as a mutable source, and if isn't cached,retrieves the value form the accessor and keeps other properties updated. Returns the retrieved value.

## ::isCachable() : Boolean

Returns `true` if the `Property.isFinal()` or if the `Property`'s accessor doesn't specify `cache: false`.

## ::isCached() : Boolean

Returns `true` if `isCachable()` and `cached` are `true`.

## ::isFinal() : Boolean

Returns `true` if the accessor specifies `final: true`.

## ::refresh()

Reloads the value from the accessor and, if the value has changed, fires itself with `value`, `previousValue`, `@key`. If the new value isn't undefined and `isFinal()` is true, it locks the value with `lockValue`.

_Note:_ For a `Batman.Keypath`, these two are not equivalent:

```
someObject.property('nestedObject.someNestedProperty').refresh()        # refreshes the Keypath on someObject
someObject.get('nestedObject').property('someNestedProperty').refresh() # refreshes the Property on nestedObject
```

## ::sourceChangeHandler() : Function

Returns the function to be called when any of the `Property`'s sources change. By default, this function implements several of `Batman.Property`'s features:

- the `Property` is refreshed when its sources change
- If `@isBatchingChanges`, the `Property` isn't refreshed
- If the `Property` `isIsolated`, it isn't refreshed
- Dead properties aren't updated

## ::valueFromAccessor()

Calls the accessor's `get` function with `base` and `key`, returning the result.

## ::setValue(value)

If the `Property`'s accessor has a `set` function, calls that function on `base` with `key` and `value`. This update is wrapped in source tracking, so other properties will be updated.

## ::unsetValue()

If the `Property`'s accessor has a `unset` function, calls that function on `base` with `key`. This update is wrapped in source tracking, so other properties will be updated.

## ::forget([handler: Function])

If `handler` is passed, removes `handler` from the `Property`'s handlers, otherwise removes all handlers from the `Property`.

## ::observeAndFire(handler: Function)

Adds `handler` to the `Property`'s handlers and fires it once. The handler will be called with `oldValue`, `newValue`, but for the first firing, `oldValue` and `newValue` are both the `Property`'s current value.

## ::observe(handler: Function) : Property

Adds `handler` to the `Property`'s handlers. The handler will be called with `oldValue`, `newValue`.

## ::observeOnce(handler: Function) : Property

Adds the `handler` to the `Property`'s handlers, but removes it after being fired once. The handler will be called with `oldValue`, `newValue`.

## ::lockValue()

Prevents changes to the `Property` by:
- removing handlers on the `Property`
- overriding `@getValue` to return the current value
- overriding `@setValue`, `@unsetValue`, `@refresh`, and `@observe` to be no-ops.

## ::die()

Kills the `Property` by removing handlers, unsetting itself, forgetting its `base` and setting `isDead = true`.

## ::isolate()

Isolates the `Property` from other properties. If the property is changed, it won't update its dependents until it's exposed. If its sources change, it won't refresh itself until it's exposed. `expose` must be called once for each time `isolate` is called, so if `isolate` is called twice, `expose` must be called twice.

## ::expose()

Exposes the `Property` to its dependents. If its sources have changed since it was isolated, it refreshes itself. Then, if its own value changed since it was isolated, it updates its dependents.

## ::isIsolated() : Boolean

Returns `true` if the `Property` if `isolate` has been called more times than `expose`.
