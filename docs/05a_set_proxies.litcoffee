# /api/Data Structures/Batman.Set/Batman.SetProxy

`Batman.SetProxy` provides a wrapper around a `Batman.Set` which delegates most methods and accessors to the base `Set`. `SetProxy` extends [`Batman.Object`](/docs/api/batman.object.html) and [`Batman.Enumerable`](/docs/api/batman.enumerable.html). To see `Batman.SetProxy` in action, see [`Batman.SetSort`](/docs/api/batman.setsort.html).

## ::constructor(base : Set) SetProxy

Returns a new `SetProxy` tracking `base`.

## Methods delegated to base

- `add`
- `addArray`
- `insert`
- `insertWithIndexes`
- `remove`
= `removeArray`
- `removeWithIndexes`
- `at`
- `find`
- `clear`
- `has`
- `merge`
- `replace`
- `filter`
- `toArray`
- `isEmpty`
- `indexedBy`
- `indexedByUnique`
- `sortedBy`
- `mappedTo`

## Accessors delegated to base

- `first`
- `last`
- `isEmpty`
- `toArray`
- `length`
- `indexedBy`
- `indexedByUnique`
- `sortedBy`
- `sortedByDescending`
- `mappedTo`

# /api/Data Structures/Batman.Set/Batman.SetSort

`Batman.SetSort` is a [`Batman.SetProxy`](/docs/api/batman.setproxy.html) which sorts the members of its `base` by provided `key` and `order`. Through `SetProxy`, `SetSort` extends [`Batman.Object`](/docs/api/batman.object.html) and [`Batman.Enumerable`](/docs/api/batman.enumerable.html). `SetSort`s are generally derived from `Set`s. For example:

    test "SetSorts are sorted proxies of their Sets", ->
      batmobile = new Batman.Object(name: "Batmobile", wheelCount: 4)
      batcycle = new Batman.Object(name: "Batcycle", wheelCount: 2)
      vehicles = new Batman.Set([batmobile, batcycle])

      vehiclesByWheelCount1 = new Batman.SetSort(vehicles, 'wheelCount') # order defaults to 'asc'
      vehiclesByWheelCount2 = vehicles.sortedBy('wheelCount')
      vehiclesByWheelCount3 = vehicles.get('sortedBy.wheelCount')

      batcopter = new Batman.Object(name: "Batcopter", wheelCount: 0)
      vehicles.add(batcopter)

      for setSort in [vehiclesByWheelCount1, vehiclesByWheelCount2, vehiclesByWheelCount3]
        deepEqual setSort.mapToProperty('wheelCount'), [0, 2, 4]

### Using a Batman.SetSort

`Batman.SetSort` is batman.js's ordered collection data structure. `Batman.Set` _does not_ have a specific order, but a `Batman.SetSort` does.

Since a `SetSort` is a proxy of a `Set`, the easiest way to make one is to use [`Set::sortedBy`](/docs/api/batman.set.html#prototype_function_sortedby):

```coffeescript
sortedVehicles = vehicles.sortedBy('wheelcount')
```

You can also make `SetSort`s in view bindings:

```html
<ul>
  <li data-foreach-vehicle='vehicles.sortedBy.wheelcount'>
    <!-- will render vehicles ordered by wheelcount -->
  </li>
</ul>
```

`SetSort`s are __observable__ proxies of their underlying `Set`s. So, when the `Set` is changed (ie, items are added, removed, or modified):

- The `SetSort` is automatically updated by batman.js
- Any view bindings or accessors depending on the `SetSort` are updated


## ::constructor(base : Set, key : String, order : ["asc"|"desc", default "asc"]) : SetSort

Returns a new `SetSort`, tracking `base` and ordering by `key` in the direction of `order`.

## ::.isSorted[= true]

Returns `true`.

## ::.key : String

Returns the key used to sort members of the `SetSort`, as defined in the constructor.

## ::.descending

`true` if `"desc"` was passed to as `order` to the constructor, otherwise `false`. Descending `SetSort`s may also be made by getting `sortedByDescending` from a `Set`:

    test "get sortedByDescending creates a descending SetSort", ->
      batmobile = new Batman.Object(name: "Batmobile", wheelCount: 4)
      batcycle = new Batman.Object(name: "Batcycle", wheelCount: 2)
      vehicles = new Batman.Set([batmobile, batcycle])

      vehiclesByWheelCountDescending1 = new Batman.SetSort(vehicles, 'wheelCount', 'desc')
      vehiclesByWheelCountDescending2 = vehicles.get('sortedByDescending.wheelCount')

      for descendingSetSort in [vehiclesByWheelCountDescending1, vehiclesByWheelCountDescending2]
        equal descendingSetSort.descending, true
        deepEqual descendingSetSort.mapToProperty('wheelCount'), [4, 2]

## ::find(func : Function)

Returns the first item from the `SetSort` for which `func(item)` returns a truthy value.

## ::forEach(func : Function)

Calls `func(item)` for each item in the `SetSort`.

## ::toArray() : Array

Returns a sorted array representation of the `SetSort`'s contents.

## ::at(idx)

Returns the item at `idx` in the `SetSort`.

## ::%at

An accessor for `::at`. You can use like:

```coffeescript
setSort.get('at.0')       # => first; OR
setSort.get('at').get(1)  # => second
```

## ::merge(other : Set) : SetSort

Returns a new `SetSort` whose items are the union of this `SetSort` and `other`. It will have the same `key` and `order` as the starting `SetSort`.

## ::compare(a, b) : Number

Returns:

- `-1` if `a` has higher precedence than `b`
- `0` if `a` and `b` have equal precedence or if precedence can't be determined
- `1` if `b` has higher precedence than `a`

Precedence is determined by testing for `undefined`, `null`, `false`, `true`, `NaN`, `a < b` and `a > b`. Please see [the source](https://github.com/batmanjs/batman/blob/master/src/set/set_sort.coffee#L91) for implementation details.

Since `::compareElements` delegates to `::compare`, you can acheive custom sorting by overriding `::compare` in a `SetSort` subclass.

## ::compareElements(a, b) : Number

Used by `SetSort` to compare its elements when sorting. Like `::compare`, it returns `-1`, `0`, or `1`. To arrive at this value, it:

- tries `a.get(@key)` (where `@key` is the `SetSort`s key)
- if the resulting value is a function, calls `resultingFunction(a)`
- calls `resultingValue.valueOf()`
- repeats the process for `b`
- delegates to `::compare` to compare the resulting values
- inverts the value if `::.descending`

By following this process, it provides sort values for `Batman.Object`s `a` and `b` according to `@key`.

# /api/Data Structures/Batman.Set/Batman.SetMapping

`Batman.SetMapping` extends `Batman.Set`. A `Batman.SetMapping` tracks a base Set and contains the _unique_ values for a given property for each member of the base Set. It can be created with `Batman.Set::mappedTo`:

    test "mappedTo creates a new Batman.SetMapping", ->
      batmobile = new Batman.Object(name: "Batmobile", wheelCount: 4)
      batcycle = new Batman.Object(name: "Batcycle", wheelCount: 2)
      vehicles = new Batman.Set([batmobile, batcycle])

      vehicleNames = vehicles.mappedTo("name")
      ok vehicleNames.constructor is Batman.SetMapping

It contains the values for the `key` passed to `mappedTo`:

      ok vehicleNames.has('Batmobile')
      ok vehicleNames.has('Batcycle')

When an item is added to or removed from the base `Batman.Set`, its corresponding value is added to or removed from the `Batman.SetMapping`:

      batwing = new Batman.Object(name: "Batwing", wheelcount: 0)
      vehicles.add(batwing)
      ok vehicleNames.has("Batwing")
      vehicles.remove(batmobile)
      ok !vehicleNames.has("Batmobile")

Like a `Batman.SetSort`, it tracks the properties of objects in the base set. So, when one of the values changes, the set mapping is updated:

      batwing.set('name', 'Batcopter')
      ok vehicleNames.has('Batcopter')

A `Batman.SetMapping` can't have duplicates:

      deepEqual vehicleNames.toArray(), ["Batcycle", "Batcopter"]
      batwing.set('name', 'Batcycle')
      deepEqual vehicleNames.toArray(), ["Batcycle"]

`Batman.SetMapping` extends `Batman.Set`, so see the `Batman.Set` API docs for more information.

### Using a Batman.SetMapping

`Batman.SetMapping` is like an observable version of [`Enumerable.mapToProperty`](/docs/api/batman.enumerable.html#prototype_function_maptoproperty). It performs a `get` on each member of the base `Set` and holds _unique_ resulting values.

Since a `SetMapping` is a proxy of a `Set`, the easiest way to make one is to use [`Set::mappedTo`](/docs/api/batman.set.html#prototype_function_mappedto):

```coffeescript
vehicleNames = vehicles.mappedTo('wheelcount')
```

You can also make `SetMapping`s in view bindings:

```html
<ul>
  <li data-foreach-vehiclename='vehicles.mappedTo.name'>
    <!-- will render unique vehicle names -->
  </li>
</ul>
```

`SetMappings`s are __observable__ proxies of their underlying `Set`s. So, when the `Set` is changed (ie, items are added, removed, or modified):

- The `SetMapping` is automatically updated by batman.js
- Any view bindings or accessors depending on the `SetMapping` are updated

## ::constructor(base : Set, key : String) : SetMapping

Returns a new `Batman.SetMapping` tracking `key` on the members of `base`.

## ::.base : Set

The `Batman.Set` being tracked by the `SetMapping`.

## ::.key : String

The property being observed on members of `base`.
