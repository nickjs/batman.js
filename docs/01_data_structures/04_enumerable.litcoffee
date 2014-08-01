# /api/Data Structures/Batman.Enumerable

`Batman.Enumerable` is a mixin that defines methods available for every
enumerable type (`Batman.Set` and `Batman.Hash` being the main two).

Note that where the signature of the callback functions is defined, `element`
is the value of the current element being iterated over, and `value` is
`null`—except in the case of `Batman.Hash` where `element` is the key and
`value` is the value.

## Implementing your own `Batman.Enumerable`

To make these methods available for a new type, all you need to do is define
`forEach()` and `length`. Then, in your type, you can just `Batman.extend
@prototype, Batman.Enumerable` to copy the `Enumerable` methods onto your
prototype.

## ::.length : number

The number of elements.

## ::forEach(func)

Calls `func` once for each element.
`func` receives the arguments `(element, value, this)`

    test "forEach runs n times", ->
      set = new Batman.Set(['a', 'b'])
      count = 0
      set.forEach -> count++
      equal count, 2

## ::map(func[, context = Batman.container]) : Array

Calls `func` once for each element, and returns an array composed of the return
value at each iteration.  `func` receives the arguments `(element, value,
this)`

    test "forEach runs n times", ->
      set = new Batman.Set([1, 2])
      deepEqual [2, 3], set.map (x) -> x + 1

## ::mapToProperty(key : string) : Array

Returns an array composed of the property specified of each item.
`func` receives the arguments `(element, value, this)`

    test "mapToProperty pulls out the property specified", ->
      set = new Batman.Set([{key: 'a'}, {key: 'b'}])
      deepEqual ['a', 'b'], set.mapToProperty('key')

## ::every(func[, context = Batman.container]) : boolean

Calls `func` once for each element, and returns true if `func` returns true for
every iteration.  `func` receives the arguments `(element, value, this)`

    test "every is false when any element doesn't satisfy the selector function", ->
      set = new Batman.Set([true, false, true])
      equal false, set.every (x) -> x

## ::some(func[, context = Batman.container]) : boolean

Calls `func` once for each element, and returns true if `func` returns true for
any iteration.  `func` receives the arguments `(element, value, this)`

    test "some is true when any element satisfies the selector function", ->
      set = new Batman.Set([true, false, true])
      equal true, set.some (x) -> x


## ::reduce(func[, accumulator]) : Array

Calls `func` once for each element, accumulating the result as it goes along.
If you pass your own `accumulator` it will retain its initial value, otherwise
the first element will become the initial accumulator value.  `func` receives
the arguments `(accumulator, element, value, index, this)`

    test "reduce can implement a sum", ->
      set = new Batman.Set([1, 2, 3])
      equal 6, set.reduce (accumulator, x) -> accumulator + x


## ::filter(func) : Object

Creates a new instance of the current type, and adds every element for which
`func` returns true.  `func` receives the arguments `(element, value, this)`

    test "filter strips out the crud", ->
      set = new Batman.Set(['wheat', 'crud', 'grain'])
      deepEqual ['wheat', 'grain'], (set.filter (x) -> x != 'crud').toArray()

## ::find(func, ctx[=Batman.container])

Returns the first element of the `Enumberable` where `func` is true. `func` is called on `ctx` with `(element, value, this)`.

    test "find gets the first match", ->
      hash = new Batman.Hash(wheat: true, crud: false, grain: false)
      foundKey = hash.find (key, value) -> !value
      equal foundKey, "crud", "the found item is returned"

## ::count(func) : number

Returns the number of elements for which `func` returns true, or the total
number of elements if you don't pass a `func`.  `func` receives the arguments
`(element, value, this)`

    test "count counts", ->
      set = new Batman.Set([1, 2, 3])
      equal 3, set.count()
      equal 2, set.count (x) -> x > 1

## ::inGroupsOf(groupSize: number) : Array

Splits the enumerable into groups of up to `groupSize` and returns the items in an array of arrays.

  test "inGroupsOf returns an array of arrays", ->
    set = new Batman.Set(1,2,3,4,5,6,7,8)
    groups = set.inGroupsOf(3)
    equal 3, groups[0].length
    equal 3, groups[1].length
    equal 2, groups[2].length, "The last group might be smaller"
