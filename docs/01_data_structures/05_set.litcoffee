# /api/Data Structures/Batman.Set

A `Batman.Set` is an observable collection of _unique_ items. `Set` extends `Batman.Object` and mixes in much of its implementation from `Batman.SimpleSet`. `Set` also mixes in [`Batman.Enumerable`](/docs/api/batman.enumerable.html), which provides [many useful methods](/docs/api/batman.enumerable.html).

### SimpleSet vs Set

`SimpleSet` and `Set` are two distinct classes in batman.js:

- `SimpleSet` implements the basic set semantics, but it is *not* a `Batman.Object`, so it is not observable.
- `Set` is a `Batman.Object`, so it can be observed, and thus plays nicely with the rest of batman.js.

If you want an observable object, choose `Batman.Set`. Use a `Batman.SimpleSet` only when you don't need observers. In fact, if you don't need observers, consider using a native array, as iteration and membership checks will be faster!

## ::constructor(items: Array) : Set

Returns a new `Batman.Set` containing `items`.

    test 'new Set constructor can be called without arguments', ->
      set = new Batman.Set
      deepEqual set.toArray(), []

    test 'new Set constructor can be passed an Array of items to add to the set.', ->
      set = new Batman.Set(['a', 'b', 'c'])
      deepEqual set.toArray().sort(), ['a', 'b', 'c']

## ::%length : Number

Number of items in the `Set`. Always access it with `get`:

```coffeescript
mySet.get('length')
```

## ::has(item) : Boolean

Returns true if `item` is in the `Set`.

_Note_: Using `has(item)` in an accessor body will register base `Set` as a source of the property being calculated. @henever the `Set` changes, the property will be recalculated.

    test 'Set::has indicates if an item is a member of the set or not.', ->
      set = new Batman.Set(['a', 'b', 'c'])
      ok set.has('a')
      equal set.has('d'), false

    test 'Set::has registers the set as a source of an accessor', ->
      class Team extends Batman.Object
        constructor: ->
          @awards = new Batman.Set()

        @accessor 'bestEver?', -> @get('awards').has('Stanley Cup')

      result = null
      team = new Team
      team.observeAndFire 'bestEver?', (status) -> result = status
      team.get('awards').add 'Eastern Conference Champs'
      equal result, false
      team.get('awards').add 'Stanley Cup'
      equal result, true

## ::add(items...) : Array

Adds any `items` to the `Set` that aren't already in the `Set`. Returns `items` which were _actually added_. (If an item was already in the `Set`, it won't be returned).

If any items are added, `add` also fires the `itemsWereAdded` event with an array of added items.

    test 'Set::add adds an item to the set', ->
      set = new Batman.Set()
      equal set.has('a'), false
      deepEqual set.add('a'), ['a']
      equal set.has('a'), true

    test 'Set::add returns only the new items that weren\'t previously in the set', ->
      set = new Batman.Set(['a', 'b'])
      deepEqual set.add('b','c','d').sort(), ['c', 'd']
      deepEqual set.toArray().sort(), ['a', 'b', 'c', 'd']

    test 'Set::add fires the itemsWereAdded event with the items newly added to the set', ->
      results = null
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereAdded', (item) -> results = item)
      set.add('b','c','d')
      deepEqual results.sort(), ['c','d']

    test 'Set::add does not fire the itemsWereAdded event if the added items were already in the set.', ->
      results = undefined
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereAdded', (items) -> results = items)
      set.add('a', 'b')
      equal typeof results, 'undefined'

## ::addArray(items: Array) : Array

Just like `Batman.Set::add`, but takes an array of items.

## ::remove(items...) : Array

Removes `items` from the `Set` if they are present. Returns any items _actually removed_ from the `Set`. (If any of `items` weren't in the `Set`, they won't be returned.)

If any items were removed, the `Set` fires the `itemsWereRemoved` event with an array of removed items.

    test 'Set::remove removes an item from the set', ->
      set = new Batman.Set(['a'])
      equal set.has('a'), true
      deepEqual set.remove('a'), ['a']
      equal set.has('a'), false

    test 'Set::remove returns only the new items that were previously in the set', ->
      set = new Batman.Set(['a', 'b'])
      deepEqual set.remove('b','c','d').sort(), ['b']
      deepEqual set.toArray(), ['a']

    test 'Set::remove fires the itemsWereRemoved event with the items removed to the set', ->
      results = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> results = items)
      set.remove('b','c')
      deepEqual results.sort(), ['b','c']

    test 'Set::remove does not fire the itemsWereRemoved event if the removed items were not already members of the set.', ->
      results = undefined
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereRemoved', (items) -> results = items)
      set.remove('c', 'd')
      equal typeof results, 'undefined'

## ::removeArray(items: Array) : Array

Just like `Batman.Set::remove`, but takes an array of items.

## ::find(testFunction : Function) : Object

Returns the first item for which `testFunction` returns a truthy value. It returns `undefined` if no item returns a truthy value.

_Note_: `find` returns the _first_ matching item, but a `Set` does not have a specified order. If two items would pass `testFunction`, either one may be returned.

    test 'Set::find returns the first item for which the test function passes', ->
      set = new Batman.Set([1, 2, 3])
      equal set.find((x) -> x % 2 == 0), 2

    test 'Set::find returns undefined if no items pass the test function', ->
      set = new Batman.Set([1, 2, 3])
      equal typeof set.find((x) -> x > 5), 'undefined'

## ::forEach(iteratorFunction : Function[, context: Object]) : undefined

Calls `iteratorFunction` for each item in the set, passing the item as the first argument. If `context` is passed, it will be `@` inside `iteratorFuction`.

_Note_: `Set::forEach` is not ordered. Consider `Batman.SetSort` if you need sorted iteration.

_Note_: `Set::forEach` registers the `Set` as a source of the property being calculated. Whenever the `Set` changes, the property will be recalculated. If you modify members of `Set` inside an accessor function, you may trigger unexpected loops.

    test 'Set::forEach iterates over each item in the set', ->
      sum = 0
      set = new Batman.Set([1,2,3])
      set.forEach (x) -> sum += x
      equal sum, 6

    test 'Set::forEach iterates over each item in the set optionally in the provided context', ->
      context = {sum: 0}
      set = new Batman.Set([1,2,3])
      set.forEach((x) ->
        @sum += x
      , context)
      equal context.sum, 6

    test 'Set::forEach registers the set as a source if called in an accessor body', ->
      class Team extends Batman.Object
        constructor: ->
          @players = new Batman.Set()
        @accessor 'willWinTheCup?', ->
          sedinCount = 0
          @players.forEach (player) ->
            sedinCount++ if player.split(' ')[1] == 'Sedin'
          sedinCount >= 2

      result = null
      team = new Team()
      team.observeAndFire 'willWinTheCup?', (status) -> result = status
      equal team.get('willWinTheCup?'), false
      team.get('players').add 'Henrik Sedin'
      equal result, false
      team.get('players').add 'Daniel Sedin'
      equal result, true

## ::isEmpty() : Boolean

Returns `true` if the `Set` has no members.

_Note_: Using `Set::isEmpty` in an accessor body will register `isEmpty` as a source of the property being calculated, so that whenever the `Set` changes, the property will be recalculated.

    test 'Set::isEmpty returns true if the set has no items', ->
      set = new Batman.Set()
      ok set.isEmpty()
      set.add('a')
      equal set.isEmpty(), false

    test 'Set::isEmpty registers the set as a source of an accessor', ->
      class Team extends Batman.Object
        constructor: ->
          @games = new Batman.Set()
        @accessor 'seasonStarted?', -> !@games.isEmpty()

      team = new Team
      equal team.get('seasonStarted?'), false
      team.get('games').add({win: true})
      equal team.get('seasonStarted?'), true

## ::%isEmpty : Boolean

Accessor for `Set::isEmpty`.

## ::clear() : Array

Removes all items from the `Set`, returning an array of all removed items. If any items were removed, the `Set`   will fire the `itemsWereRemoved` event with an array of removed items.

_Note_: Set order is not defined, so the array of removed items is unordered.

    test 'Set::clear empties the set', ->
      set = new Batman.Set(['a', 'b', 'c'])
      equal set.isEmpty(), false
      deepEqual set.clear().sort(), ['a', 'b', 'c']
      ok set.isEmpty()

    test 'Set::clear fires the itemsWereRemoved event with all the items in the set', ->
      result = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> result = items)
      set.clear()
      deepEqual result.sort(), ['a', 'b', 'c']

## ::replace(collection : Enumerable) : Array

Removes all items from `Set`, then adds all the items found in `collection`. The `collection` must have a `toArray` function which returns an array representation of the collection. Returns the array of items added.

`replace` will fire the `itemsWereRemoved` event once with all the items in the set, and then the `itemsWereAdded` event once with the items from the incoming collection.

    test 'Set::replace empties the set and then adds items from a different collection', ->
      set = new Batman.Set(['a', 'b', 'c'])
      secondSet = new Batman.Set(['d', 'e', 'f'])
      set.replace(secondSet)
      deepEqual set.toArray().sort(), ['d', 'e', 'f']

    test 'Set::replace fires the itemsWereRemoved event with all the items in the set', ->
      result = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> result = items)
      set.replace(new Batman.SimpleSet())
      deepEqual result.sort(), ['a', 'b', 'c']

    test 'Set::replace fires the itemsWereAdded event with all the items in the incoming set', ->
      result = null
      set = new Batman.Set()
      set.on('itemsWereAdded', (items) -> result = items)
      set.replace(new Batman.SimpleSet(['a', 'b', 'c']))
      deepEqual result.sort(), ['a', 'b', 'c']

## ::toArray() : Array

Returns an _unordered_ array of the `Set`'s  members.

_Note_: Using `Set::toArray` in an accessor will register the `Set` as a source of the property being calculated, so that whenever the `Set` changes, the property will be recalculated.

    test 'Set::toArray returns an array representation of the set', ->
      set = new Batman.Set()
      deepEqual set.toArray(), []
      set.add('a', 'b', 'c')
      deepEqual set.toArray().sort(), ['a', 'b', 'c']


## ::%toArray : Array

Accessor for `Set::toArray`. Whenever items are added or removed on the set, the `toArray` property will change. This is the mechanism by which batman.js's view bindings get notified of collection updates.

    test 'observers on the toArray property fire when the set changes', ->
      results = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.observe('toArray', (newArray) -> results = newArray.sort())
      deepEqual set.add('d'), ['d']
      deepEqual results, ['a', 'b', 'c', 'd']
      deepEqual set.remove('b'), ['b']
      deepEqual results, ['a', 'c', 'd']

## ::merge(collections... : Enumerable) : Set

Combines the `Set` and `collections` into a new `Set` and returns it. `collection` must implement `forEach`.

`Set::merge` is non-destructive: the `Set` won't be affected.

_Note_: Be careful about using `merge` within accessors. It registers the `Set` as a source, meaning the O(n * m) merge will occur again each time, and return an entirely new `Set` instance. If the previously returned `Set` instance is retained after recalculation, this is a __big memory leak__. Instead of merging in accessors, try to use a `Batman.SetUnion` or a `Batman.SetIntersection`.

    test 'Set::merge returns a new set with the items of the original set and the passed set', ->
      abc = new Batman.Set(['a', 'b', 'c'])
      def = new Batman.Set(['d', 'e', 'f'])
      equal Batman.typeOf(set = abc.merge(def)), 'Object'
      deepEqual set.toArray().sort(), ['a', 'b', 'c', 'd', 'e', 'f']

## ::indexedBy(key : String) : SetIndex

Returns a `Batman.SetIndex` based on the `Set`, grouping by `key`. This is batman.js's way of grouping `Set`s. See the `Batman.SetIndex` documentation for more information about using `Batman.SetIndex`es.

The `Batman.SetIndex` tracks the `Set` and its members (in case their value for `key` changes).

    test 'Set::indexedBy returns a new SetIndex with the items bucketed by the value of the key', ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green'), Batman(colour: 'blue')])
      index = set.indexedBy('colour')
      ok index.get('blue') instanceof Batman.Set
      equal index.get('blue').get('length'), 2
      equal index.get('green').get('length'), 1


## ::%indexedBy

Accessor for `Set::indexedBy`. `mySet.get('indexedBy.myKey')` returns the same result as  `mySet.indexedBy('myKey')`. This is convenient in view bindings:


```html
<ul>
  <li data-foreach-colorgroup='collection.indexedBy.color'>
    <!-- colorgroup is a SetIndex for collection, by color -->
  </li>
</ul>
```

    test "Set::get('indexedBy.someKey') returns a new SetIndex for 'someKey'", ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.get('indexedBy.colour')
      equal index.get('blue').get('length'), 1

## ::indexedByUnique(key : String) : UniqueSetIndex

Returns a `Batman.UniqueSetIndex` based on `Set`, indexed by `key`. See the `Batman.UniqueSetIndex` documentation for more information.

The `Batman.UniqueSetIndex` tracks the `Set` and its members (in case their value for `key` changes).

    test 'Set::indexedByUnique returns a new UniqueSetIndex with the items hashed by the value of the key', ->
      greenItem = Batman(colour: 'green')
      blueItem = Batman(colour: 'blue')
      set = new Batman.Set([greenItem, blueItem])
      index = set.indexedByUnique('colour')
      ok blueItem == index.get('blue')
      ok greenItem == index.get('green')
      equal undefined, index.get('red')

## ::%indexedByUnique

Accessor for `Set::indexedByUnique`. `mySet.get('indexedByUnique.myUniqueKey')` returns the same result as  `mySet.indexedByUnique('myUniqueKey')`.

    test "Set::get('indexedByUnique.someKey') returns a new UniqueSetIndex for 'someKey'", ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.get('indexedByUnique.colour')
      equal 'blue', index.get('blue').get('colour')

## ::sortedBy(key: String, order="asc") : SetSort

Returns a `Batman.SetSort` based on the `Set`, sorted by `key` in `order`. This is batman.js's way of sorting `Batman.Set`s. See the `Batman.SetSort` documentation for more information.

`order` may be `"asc"` or `"desc"`.

The `Batman.SetSort` tracks the `Set` and its members (in case their value for `key` changes).

    test 'Set::sortedBy returns a new SetSort who can be iterated in the sorted order of the value of the key on each item', ->
      set = new Batman.Set([Batman(place: 3, name: 'Harry'), Batman(place: 1, name: 'Tom'), Batman(place: 2, name: 'Camilo')])
      sort = set.sortedBy('place')
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Tom', 'Camilo', 'Harry']

## ::%sortedBy

Accessor for `Set::sortedBy`. `mySet.get('sortedBy.myKey')` returns the same result as  `mySet.sortedBy('myKey')`.  This is very convenient in view bindings:

```html
<h1> Rankings: </h1>
<ul>
  <li data-foreach-player='players.sortedBy.rank'>
    <!-- players are rendered in order -->
  <li>
</ul>
```

    test "Set::get('sortedBy.someKey') returns a new SetSort on 'someKey'", ->
      set = new Batman.Set([Batman(place: 3, name: 'Harry'), Batman(place: 1, name: 'Tom'), Batman(place: 2, name: 'Camilo')])

      sort = set.get('sortedBy.place')
      equal 'Harry', sort.get('toArray')[2].get('name')

## ::%sortedByDescending

Like `Set::%sortedBy`, but returns a descending `Batman.SetSort`. `mySet.get('sortedByDescending.myKey')` returns the same result as  `mySet.sortedBy('myKey', "desc")`.

## ::mappedTo(key : String) : SetMapping

Returns a `Batman.SetMapping` on the `Set`, for values of `key`. A `Batman.SetMapping` is an observable `map` result. See the documentation for `Batman.SetMapping` for more information.

    test 'Set::mappedTo(key) returns SetMapping on `key`', ->
      set = new Batman.Set([
        Batman(place: 3, name: 'Harry'),
        Batman(place: 1, name: 'Tom'),
        Batman(place: 2, name: 'Camilo')
      ])
      mapping = set.mappedTo('place')
      deepEqual mapping.toArray(), [3,1,2]

## ::%mappedTo

Accessor for `Set::mappedTo`. `mySet.get('mappedTo.myKey')` returns the same result as  `mySet.mappedTo('myKey')`.

    test 'set.get("mappedTo.key") returns SetMapping on `key`', ->
      set = new Batman.Set([
        Batman(place: 3, name: 'Harry'),
        Batman(place: 1, name: 'Tom'),
        Batman(place: 2, name: 'Camilo')
      ])
      mapping = set.get('mappedTo.place')
      deepEqual mapping.toArray(), [3,1,2]
