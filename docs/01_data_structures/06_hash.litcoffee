# /api/Data Structures/Batman.Hash

`Batman.Hash` is an observable [`Batman.Object`](/docs/api/batman.object.html) wrapper around `Batman.SimpleHash`. `Hash` also extends [`Batman.Enumerable`](/docs/api/batman.enumerable.html), which provides [many useful methods](/docs/api/batman.enumerable.html).

`Batman.Hash` is a great choice when you need an iterable, observable key-value store.

### Hash, SimpleHash, and Object

`Hash` brings in methods from [`Batman.Object`](/docs/api/batman.object.html) and `Batman.SimpleHash` and provides some new methods of its own.
From `Object`, `Hash` gains:

- observable properties and accessors (eg, [`::observe`](docs/api/batman.object.html#prototype_function_observe) and [`@accessor`](/docs/api/batman.object.html#class_function_accessor))
- observable mutation events (`itemsWereAdded`, `itemsWereChanged`, `itemsWereRemoved`)

From `SimpleHash`, `Hash` gains:

- all methods on [`Batman.Enumerable`](/docs/api/batman.enumerable.html)
- basic key-value storage, as described below
- serialization via [`toObject`](/docs/api/batman.hash.html#prototype_function_toobject) and [`toJSON`](/docs/api/batman.hash.html#prototype_function_tojson) as described below

`SimpleHash` methods take precedence over `Object` methods inside `Hash`. For example, `Hash::toJSON` is inherited from `SimpleHash`, not `Object`. By default, `get` and `set` affect key-value pairs in the `Hash`. You can override this by defining your own accessors.

## ::constructor(obj: Object) : Hash

Creates a new `Hash` with the key-value pairs in `obj`.

## get, set, unset, and @accessor

By default, `get`, `set` and `unset` change values in the `Hash`'s storage. If you define your own accessors with `@accessor`, `get` and `set` for that key will be handled by the custom accessor.

    test 'custom accessors take precedence over Hash storage', ->
      class CustomHash extends Batman.Hash
        @accessor 'timesTwo',
          set: (key, value) -> @_customValue = value
          get: -> @_customValue * 2

      customHash = new CustomHash
      customHash.set('normalKey',  'value')
      customHash.set('timesTwo',  4)
      equal customHash.get('normalKey'), 'value', "The default accessor is used"
      equal customHash.get('timesTwo'), 8, "The custom accessor is used"
      equal customHash.hasKey('timesTwo'), false, "The custom accessor doesn't use hash storage"

## ::keys() : Array

Returns an array of the keys in the `Hash`.

## ::isEmpty() : Boolean

Returns true if the `Hash`'s length is 0.

## ::toArray() : Array

Returns an array of keys in the `Hash`.

## ::forEach(func : Function)

Calls `func(key, value)` for each pair in the `Hash`.

## ::hasKey(testKey : String ) : Boolean

Returns `true` if `testKey` exists on the `Hash`.

## ::clear() : Array

Unsets all keys, then fires an `itemsWereRemoved` event with the removed keys and values. It returns all values that were in the `Hash`.

## ::merge(hashes... : Hash) : Hash

Creates a __new `Hash`__ by merging pairs from `hashes` into the `Hash` and returns the merged result.

## ::update(obj: Object)

For each key-value pair in `obj`, the keys in the `Hash` are updated with the provided values.

- If any of the keys in `obj` were not in the `Hash` before, an `itemsWereAdded` event is fired with the new keys and new values.
- If any of the keys in `obj` were already present in the `Hash`, an `itemsWereChanged` event is fired with the other keys, their new values (from `obj`) and their previous values.

## ::replace(obj: Object)

The key-value pairs in `Hash` are completely replaced with those in `obj`.

- If there were any keys in `obj` that weren't previously in the `Hash`, an `itemsWereAdded` event is fired with the new keys and their values.
- If any keys were present in the `Hash` but weren't present in `obj` then those keys are unset on `Hash` and an `itemsWereRemoved` event is fired with the removed keys and their values.
- If any keys were present in the `Hash` and in `obj`, then an `itemsWereChanged` event is fired with those keys, their previous values and their new values.

## ::toObject() : Object

Returns a plain JavaScript Object with the contents of the `Hash`.

## ::toJSON() : Object

Returns a plain JavaScript Object, like `toObject`, but calls `toJSON` on the each value, if it has a `toJSON` method.
