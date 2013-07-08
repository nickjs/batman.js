
assertSorted = (array, compareFunction) ->
  last = null
  for item, i in array
    if last
      ok compareFunction(last, item) < 1
    last = item

class Random
  A:48271
  M: 2147483647
  Q: @::M / @::A
  R: @::M % @::A
  oneOverM: 1.0 / @::M

  constructor: (@min = 0, @max = 1, @seed) ->
    unless @seed?
      d = new Date()
      @seed = 2345678901 + (d.getSeconds() * 0xFFFFFF) + (d.getMinutes() * 0xFFFF)

    @delta = @max - @min

  next: ->
    hi = @seed / @Q
    lo = @seed % @Q
    test = @A * lo - @R * hi
    if test > 0
      @seed = test
    else
      @seed = test + @M

    next = @seed * @oneOverM
    Math.round(@delta * next + @min)


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

  test "toArray() returns the correct order when sorting on key which returns a function by calling the function", ->
    class Test
      constructor: (@name) ->
      getName: -> @name

    a = new Test('a')
    b = new Test('b')
    c = new Test('c')

    base = new Batman.Set(b, a, c)
    sorted = base.sortedBy('getName')
    deepEqual sorted.toArray(), [a, b, c]

  test "toArray() returns the correct order when sorting on the 'valueOf' key to sort primitives", ->
    @base = new Batman.Set('b', 'c', 'a')
    sorted = @base.sortedBy('valueOf')
    deepEqual sorted.toArray(), ['a', 'b', 'c']

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

  test "binarySearch", ->
    arr = [1, 1, 3, 5, 6, 6, 7, 8, 8, 10]
    equal binarySearch(arr, 4, Batman.SetSort::compare), -1
    equal arr[binarySearch(arr, 1, Batman.SetSort::compare)], 1
    equal arr[binarySearch(arr, 3, Batman.SetSort::compare)], 3
    equal arr[binarySearch(arr, 5, Batman.SetSort::compare)], 5
    equal arr[binarySearch(arr, 6, Batman.SetSort::compare)], 6
    equal arr[binarySearch(arr, 7, Batman.SetSort::compare)], 7

    arr = [1, 2]
    equal arr[binarySearch(arr, 1, Batman.SetSort::compare)], 1
    equal arr[binarySearch(arr, 2, Batman.SetSort::compare)], 2

    arr = [1, 2, 3, 5, 6, 7]
    equal binarySearch(arr, 8, Batman.SetSort::compare, false), 6
    arr.splice(6, 0, 8)
    deepEqual arr, [1, 2, 3, 5, 6, 7, 8]

  test "wtf", ->
    # letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g']
    # generator = new Random(0, letters.length, 123123)

    # window.current = 0
    # window.old = 0

    # a = []
    # for i in [0...1000]
    #   a.push Batman(foo: (letters[generator.next()] for j in [0..6]).join(''))

    # set = new Batman.SetSort(qq = new Batman.Set(), 'foo')
    # set.old = true

    # t1 = performance.now()
    # qq.add a...
    # current = performance.now() - t1

    # vv = new Batman.SetSort(cc = new Batman.Set(), 'foo')
    # vv.old = false

    # vv.on 'itemsWereAddedAtPositions', (items) ->
    #   console.log items

    # t1 = performance.now()
    # cc.add a...
    # old = performance.now() - t1

    # ok current < old

    # console.log current, old

    set = new Batman.SetSort(new Batman.Set(b = {foo: 'b'}, c = {foo: 'c'}, a = {foo: 'a'}), 'foo')
    set.on 'itemsWereAdded', -> 
      console.log 'itemsWereAdded'
    set.on 'itemsWereRemoved', -> 
      console.log 'itemsWereRemoved'
    set.on 'itemsWereAddedAtPositions', -> 
      console.log 'itemsWereAddedAtPositions'
    set.on 'itemsWereRemovedFromPositions', -> 
      console.log 'itemsWereRemovedFromPositions'
    deepEqual set.toArray(), [a, b, c]
    set.remove(a)
    deepEqual set.toArray(), [b, c]
    set.remove(c)
    deepEqual set.toArray(), [b]
    set.add(a)
    deepEqual set.toArray(), [a, b]

  test "toArray() includes newly added items in the correct order", ->
    # @base.add @byJill
    # expected = [@byFred, @anotherByFred, @byJill, @byMary, @byZeke]
    # deepEqual @authorNameSort.toArray(), expected

    # @base.add @anotherByZeke
    # expected = [@byFred, @anotherByFred, @byJill, @byMary, @byZeke, @anotherByZeke]
    # deepEqual @authorNameSort.toArray(), expected
    foo = new Batman.SetSort(new Batman.Set, 'key')
    foo.logging = true
    foo.add(Batman key: 'c')
    a = []
    foo.forEach (e) -> a.push e.key
    console.log a
    foo.add(Batman key: 'b')
    a = []
    foo.forEach (e) -> a.push e.key
    console.log a
    foo.add(Batman key: 'a')
    a = []
    foo.forEach (e) -> a.push e.key
    console.log a
    foo.add(Batman key: 'zz')
    a = []
    foo.forEach (e) -> a.push e.key
    console.log a
    expected = ['a', 'b', 'c', 'zz']
    foo.forEach (a, i) ->
      equal a.key, expected[i]

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
    switchedAuthorToMary = @anotherByFred
    switchedAuthorToMary.set('author', @mary)
    expected = [@byFred, @byMary, switchedAuthorToMary, @byZeke]
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

fixtureSetup = ->
  @zeke = Batman name: 'Zeke'
  @mary = Batman name: 'Mary'
  @fred = Batman name: 'Fred'
  @jill = Batman name: 'Jill'

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

    @base = new Batman.Set(@byMary, @byFred, @byZeke, @anotherByFred)
    @authorNameSort = new Batman.SetSort(@base, 'author.name')

setSortSuite()
setSortOnObservableSetSuite()

QUnit.module 'Batman.SetSort on a Batman.SimpleSet',
  setup: ->
    fixtureSetup.call(@)

    @base = new Batman.SimpleSet(@byMary, @byFred, @byZeke, @anotherByFred)
    @authorNameSort = new Batman.SetSort(@base, 'author.name')

setSortSuite()
