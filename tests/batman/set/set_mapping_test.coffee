QUnit.module 'Batman.SetMapping',
  setup: ->
    @alphabet = new Batman.Object({name: "alphabet"})
    @digits = new Batman.Object({name: "digits"})

    @letterA = new Batman.Object({type: "letter", value: "A", system: @alphabet})
    @letterB = new Batman.Object({type: "letter", value: "B", system: @alphabet})
    @letterNull = new Batman.Object({type: "letter", value: null, system: @alphabet})
    @number1 = new Batman.Object({type: "number", value: 1, system: @digits})
    @set = new Batman.Set(@letterA, @letterB, @letterNull, @number1)
    @mappedToValue = @set.mappedTo("value")

test "setMapping contains the unique property values of the given key", ->
  deepEqual @mappedToValue.toArray(), ["A", "B", null, 1]

test "setMapping is updated when values are changed", ->
  @letterNull.set('value', "Z")
  deepEqual @mappedToValue.toArray(), ["A", "B", 1, "Z"]

test "setMapping doesn't allow duplicates", ->
  @letterNull.set('value', "A")
  deepEqual @mappedToValue.toArray(), ["A", "B", 1]
  @letterNull.set('value', null)
  @letterA.set('value', null)
  deepEqual @mappedToValue.toArray(), ["B", 1, null]

test "setMapping is updated when items are added to and removed from the base", ->
  letterC = new Batman.Object(type: "letter", value: "C")
  eventsFired = 0
  itemsAdded = 0
  itemsRemoved = 0
  @mappedToValue.on 'itemsWereAdded', (items) ->
    itemsAdded += items.length
    eventsFired += 1
  @mappedToValue.on 'itemsWereRemoved', (items) ->
    eventsFired += 1
    itemsRemoved += items.length

  @set.add(letterC)
  equal eventsFired, 1
  equal itemsAdded, 1
  equal itemsRemoved, 0
  equal @mappedToValue.get('length'), 5

  @set.remove(letterC)
  equal eventsFired, 2
  equal itemsAdded, 1
  equal itemsRemoved, 1
  equal @mappedToValue.get('length'), 4

test "setMapping takes nested keypath", ->
  mappedToSystemName = @set.mappedTo('system.name')
  deepEqual mappedToSystemName.toArray(), ["alphabet", "digits"]

  @alphabet.set('name', 'romaji')
  deepEqual mappedToSystemName.toArray(), ["digits", "romaji"]

test "setMapping does normal set stuff", ->
  equal @mappedToValue.get('first'), "A"
  ok @mappedToValue.has(1)
  ok !@mappedToValue.has(900)

test "setMapping works with other set derivatives", ->
  mappedToSystem = @set.mappedTo('system')
  equal mappedToSystem.indexedByUnique("name").get("digits"), @digits
  equal mappedToSystem.get("sortedByDescending.name").get('first'), @digits

test "setMapping implements Batman.Enumerable on the mapped values", ->
  ok @mappedToValue.some((v) -> v is "A")
  equal @mappedToValue.find((v) -> v is "B"), "B"
  equal @mappedToValue.count((v) -> typeof v is "string"), 2
