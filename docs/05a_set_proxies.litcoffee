# /api/Data Structures/Batman.Set/Batman.SetProxy

`Batman.SetProxy` provides a wrapper around a `Batman.Set` which delegates most methods and accessors to the base `Set`. `SetProxy` extends [`Batman.Object`](/docs/api/batman.object.html) and [`Batman.Enumerable`](/docs/api/batman.enumerable.html). To see `Batman.SetProxy` in action, see [`Batman.SetSort`](/docs/api/batman.setsort.html).

## ::constructor(base : Set) SetProxy

Returns a new `SetProxy` tracking `base`.

## Methods delegated to base

- `add`
- `insert`
- `insertWithIndexes`
- `remove`
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


# /api/Data Structures/Batman.Set/Batman.SetSort

`Batman.SetSort` is a [`Batman.SetProxy`](/docs/api/batman.setproxy.html) which sorts the members of its `base` by provided `key` and `order`. Through `SetProxy`, `SetSort` extends [`Batman.Object`](/docs/api/batman.object.html) and [`Batman.Enumerable`](/docs/api/batman.enumerable.html). `SetSort`s are generally derived from `Set`s. For example:

    test "SetSorts are sorted proxies of their Sets", ->
      batmobile = new Batman.Object(name: "Batmobile", wheelCount: 4)
      batcycle = new Batman.Object(name: "Batcycle", wheelCount: 2)
      vehicles = new Batman.Set(batmobile, batcycle)

      vehiclesByWheelCount1 = new Batman.SetSort(vehicles, 'wheelCount') # order defaults to 'asc'
      vehiclesByWheelCount2 = vehicles.sortedBy('wheelCount')
      vehiclesByWheelCount3 = vehicles.get('sortedBy.wheelCount')

      batcopter = new Batman.Object(name: "Batcopter", wheelCount: 0)
      vehicles.add(batcopter)

      for setSort in [vehiclesByWheelCount1, vehiclesByWheelCount2, vehiclesByWheelCount3]
        deepEqual setSort.mapToProperty('wheelCount'), [0, 2, 4]


## ::constructor(base : Set, key : String, order : ["asc"|"desc", default "asc"]) : SetSort

Returns a new `SetSort`, tracking `base` and ordering by `key` in the direction of `order`.

## ::.isSorted[= true]

Returns `true`.

## ::.key : String

Returns the used to sort members of the `SetSort`, as defined in the constructor.

## ::.descending

`true` if `"desc"` was passed to as `order` to the constructor, otherwise `false`. Descending `SetSort`s may also be made by getting `sortedByDescending` from a `Set`:

    test "get sortedByDescending creates a descending SetSort", ->
      batmobile = new Batman.Object(name: "Batmobile", wheelCount: 4)
      batcycle = new Batman.Object(name: "Batcycle", wheelCount: 2)
      vehicles = new Batman.Set(batmobile, batcycle)

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


