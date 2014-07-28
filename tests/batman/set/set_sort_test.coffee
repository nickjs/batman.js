
assertSorted = (array, compareFunction) ->
  last = null
  for item, i in array
    if last
      ok compareFunction(last, item) < 1
    last = item

setSortSuite = ->
  test "new Batman.SetSort(set, key) constructs a sort on the set for that keypath", ->
    equal @authorNameSort.base, @base
    equal @authorNameSort.key, 'author.name'
    equal @authorNameSort.descending, no

  test "new Batman.SetSort(set, key, 'desc') constructs a reversed sort", ->
    reversedSort = new Batman.SetSort(@base, 'author.name', 'desc')
    equal reversedSort.base, @base
    equal reversedSort.key, 'author.name'
    equal reversedSort.descending, yes

  test "toArray() returns the sorted items", ->
    noName = Batman()
    anotherNoName = Batman()
    nullName = Batman
      author: Batman
        name: null
    naNName = Batman
      author: Batman
        name: NaN
    numberedName = Batman
      author: Batman
        name: 9
    anotherNumberedName = Batman
      author: Batman
        name: 80
    trueName = Batman
      author: Batman
        name: true
    falseName = Batman
      author: Batman
        name: false
    @base.add noName
    @base.add nullName
    @base.add anotherNoName
    @base.add anotherNumberedName
    @base.add naNName
    @base.add numberedName
    @base.add trueName
    @base.add falseName
    @base.remove @anotherByFred

    assertSorted(@authorNameSort.toArray(), Batman.SetSort::compare)

  test "forEach(iterator) and toArray() go in reverse if sort is descending", ->
    noName = Batman()
    nullName = Batman
      author: Batman
        name: null
    naNName = Batman
      author: Batman
        name: NaN
    numberedName = Batman
      author: Batman
        name: 9
    anotherNumberedName = Batman
      author: Batman
        name: 80
    trueName = Batman
      author: Batman
        name: true
    falseName = Batman
      author: Batman
        name: false
    @base.add noName
    @base.add nullName
    @base.add anotherNumberedName
    @base.add naNName
    @base.add numberedName
    @base.add trueName
    @base.add falseName
    @base.remove @anotherByFred

    descendingAuthorNameSort = new Batman.SetSort(@base, 'author.name', 'desc')
    sorted = descendingAuthorNameSort.toArray()
    assertSorted(sorted, (a,b) -> Batman.SetSort::compare(b,a))

    collector = []
    descendingAuthorNameSort.forEach (item) -> collector.push(item)
    deepEqual sorted, collector

  test "forEach(iterator) loops in the correct order", ->
    expect 4
    expected = [@byFred, @anotherByFred, @byMary, @byZeke]
    @authorNameSort.forEach (item, i) ->
      ok item is expected[i]

  test "get('length') returns the correct length", ->
    equal @authorNameSort.get('length'), 4

  test "toArray() returns the correct order", ->
    expected = [@byFred, @anotherByFred, @byMary, @byZeke]
    deepEqual @authorNameSort.toArray(), expected

setSortOnObservableSetSuite = ->
  test "get('length') returns the correct length when items are added to the underlying set", ->
    @base.add @byJill
    equal @authorNameSort.get('length'), 5

  test "get('length') returns the correct length when items are removed from the underlying set", ->
    @base.remove @byFred
    equal @authorNameSort.get('length'), 3

  test "get('length') returns the correct length when items are added to the set via the set sort proxy", ->
    @authorNameSort.add @byJill
    equal @authorNameSort.get('length'), 5

  test "get('length') returns the correct length when items are added to the set via the set sort proxy", ->
    @authorNameSort.remove @byFred
    equal @authorNameSort.get('length'), 3

  test "toArray() includes newly added items in the correct order", ->
    @base.add @byJill
    expected = ['Fred', 'Fred', 'Jill', 'Mary', 'Zeke']
    deepEqual @authorNameSort.mapToProperty('author.name'), expected

    @base.add @anotherByZeke
    expected = ['Fred', 'Fred', 'Jill', 'Mary', 'Zeke', 'Zeke']
    deepEqual @authorNameSort.mapToProperty('author.name'), expected

  test "toArray() does not include items which have been removed", ->
    @base.remove @anotherByFred
    expected = [@byFred, @byMary, @byZeke]
    equal @authorNameSort.toArray().length, 3
    deepEqual @authorNameSort.toArray(), expected

    @base.remove @byZeke
    expected = [@byFred, @byMary]
    equal @authorNameSort.toArray().length, 2
    deepEqual @authorNameSort.toArray(), expected

  test "setting a new value of the sorted property on one of the items triggers an update", ->
    switchedAuthorToBobs = @anotherByFred
    switchedAuthorToBobs.set('author', @bobs)
    expected = [switchedAuthorToBobs, @byFred, @byMary, @byZeke]
    deepEqual @authorNameSort.toArray(), expected

  test "setting a new value of the sorted property on an item which has been removed should not trigger an update", ->
    @base.remove @anotherByFred
    reIndex = spyOn(@authorNameSort, "_reIndex")

    @anotherByFred.set('author', @mary)

    equal reIndex.called, false
    expected = [@byFred, @byMary, @byZeke]
    deepEqual @authorNameSort.toArray(), expected

  test "adding a few new values to the set should never _reIndex()", ->
    @authorNameSort.remove @anotherByFred
    reIndex = spyOn(@authorNameSort, "_reIndex")

    @authorNameSort.add(@anotherByFred)
    equal reIndex.callCount, 0

    @authorNameSort.add(@byJill, @anotherByZeke)
    equal reIndex.callCount, 0

  test "stopObserving() forgets all observers", ->
    @authorNameSort.stopObserving()
    expected = [@byFred, @anotherByFred, @byMary, @byZeke]

    @base.add @byJill
    deepEqual @authorNameSort.toArray(), expected

    @base.remove @byZeke
    deepEqual @authorNameSort.toArray(), expected

    @byFred.set('author', @mary)
    deepEqual @authorNameSort.toArray(), expected

  test 'mappedTo returns a SetMapping', ->
    expected = ["Fred", "Mary", "Zeke"]
    mapping = @authorNameSort.mappedTo('author.name')
    equal mapping.get('length'), 3
    for name in expected
      ok mapping.has(name)
    @base.remove(@byMary)
    ok !mapping.has('Mary')
    @base.remove(@byFred, @anotherByFred)
    ok !mapping.has('Fred')
    @base.add(@byMary)
    ok mapping.has('Mary')

  test 'at(i) returns the item according to the sort', ->
    equal @authorNameSort.at(0).get('author.name'), "Fred"
    equal @authorNameSort.at(3).get('author.name'), "Zeke"
    @base.add(Batman(author: @bobs))
    equal @authorNameSort.at(0).get('author.name'), "Bobs"

fixtureSetup = ->
  @zeke = Batman name: 'Zeke'
  @mary = Batman name: 'Mary'
  @fred = Batman name: 'Fred'
  @jill = Batman name: 'Jill'
  @bobs = Batman name: 'Bobs'

  @byZeke = Batman author: @zeke
  @byMary = Batman author: @mary
  @byFred = Batman author: @fred, prop: "byFred"
  @anotherByFred = Batman author: @fred, prop: "anotherByFred"

  # not yet in the set:
  @byJill = Batman author: @jill
  @anotherByZeke = Batman author: @zeke

QUnit.module 'Batman.SetSort on a Batman.Set',
  setup: ->
    fixtureSetup.call(@)

    @base = new Batman.Set([@byMary, @byFred, @byZeke, @anotherByFred])
    @authorNameSort = new Batman.SetSort(@base, 'author.name')

setSortSuite()
setSortOnObservableSetSuite()

QUnit.module 'Batman.SetSort on a Batman.SimpleSet',
  setup: ->
    fixtureSetup.call(@)

    @base = new Batman.SimpleSet([@byMary, @byFred, @byZeke, @anotherByFred])
    @authorNameSort = new Batman.SetSort(@base, 'author.name')

setSortSuite()

QUnit.module 'Batman.SetSort specific methods'

test "toArray() returns the correct order when sorting on key which returns a function by calling the function", ->
  class Test
    constructor: (@name) ->
    getName: -> @name

  a = new Test('a')
  b = new Test('b')
  c = new Test('c')

  base = new Batman.Set([b, a, c])
  sorted = base.sortedBy('getName')
  deepEqual sorted.toArray(), [a, b, c]

test "toArray() returns the correct order when sorting on the 'valueOf' key to sort primitives", ->
  @base = new Batman.Set(['b', 'c', 'a'])
  sorted = @base.sortedBy('valueOf')
  deepEqual sorted.toArray(), ['a', 'b', 'c']

test "_indexOfItem returns the correct index", ->
  arr = [1, 3, 5, 6, 7, 8, 10]
  set = new Batman.Set(arr).sortedBy('')
  equal set._indexOfItem(4), -1
  equal arr[set._indexOfItem(1)], 1
  equal arr[set._indexOfItem(3)], 3
  equal arr[set._indexOfItem(5)], 5
  equal arr[set._indexOfItem(6)], 6
  equal arr[set._indexOfItem(7)], 7

  arr = [1, 2]
  set = new Batman.Set(arr).sortedBy('')
  equal arr[set._indexOfItem(1)], 1
  equal arr[set._indexOfItem(2)], 2

test "_indexOfItem returns the correct item for duplicate keys", ->
  arr = [a = {key: 1}, b = {key: 1}, c = {key: 1}, d = {key: 1}, e = {key: 1}]
  set = new Batman.Set(arr).sortedBy('key')

  equal arr[set._indexOfItem(a)], a
  equal arr[set._indexOfItem(b)], b
  equal arr[set._indexOfItem(c)], c
  equal arr[set._indexOfItem(d)], d
  equal arr[set._indexOfItem(e)], e

  arr = [a = {key: 0}, b = {key: 1}, c = {key: 1}, d = {key: 4}, e = {key: 5}]
  set = new Batman.Set(arr).sortedBy('key')

  equal arr[set._indexOfItem(a)], a
  equal arr[set._indexOfItem(b)], b
  equal arr[set._indexOfItem(c)], c
  equal arr[set._indexOfItem(d)], d
  equal arr[set._indexOfItem(e)], e

test "_indexOfItem calls _binarySearch", ->
  set = new Batman.Set([1, 2, 3]).sortedBy('')
  sinon.spy(Batman.SetSort, '_binarySearch')

  set._indexOfItem(1)
  ok Batman.SetSort._binarySearch.calledOnce
  Batman.SetSort._binarySearch.restore()

test "SetSort._binarySearch returns the correct indexes for inexact searches", ->
  arr = [1, 2, 3, 6, 7, 8, 10]
  equal arr[Batman.SetSort._binarySearch(arr, 5, Batman.SetSort::compare).index], 6
  equal arr[Batman.SetSort._binarySearch(arr, 9, Batman.SetSort::compare).index], 10
  equal Batman.SetSort._binarySearch(arr, 11, Batman.SetSort::compare).index, arr.length
