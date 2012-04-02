QUnit.module "Batman.SetComplement"
  setup: ->
    @left = new Batman.Set("a", "b", "c")
    @right = new Batman.Set("c", "d", "e")
    @complement = new Batman.SetComplement(@left, @right)

membersEqual = (set, members) ->
  deepEqual set.toArray().sort(), members.sort()
  equal set.get('length'), members.length
  equal set.length, members.length

test "complements should be empty if left set is empty", ->
  @left.clear() # one empty
  membersEqual @complement, []

test "complements should contain items present only in the left set", ->
  membersEqual @complement, ["a", "b"]

test "complements should observe additions to the left set and add the added item to themselves if not present in the right set", ->
  @left.add "f"
  membersEqual @complement, ["a", "b", "f"]

test "complements should observe additions to the right set and remove the added item from themselves", ->
  @right.add "a"
  membersEqual @complement, ["b"]

test "complements should observe removals from the left set and remove the removed item from themselves", ->
  @left.remove "a"
  membersEqual @complement, ["b"]

test "complements should observe removals from the right set and add the removed item to themselves if present in the left set", ->
  @right.remove "c"
  membersEqual @complement, ["a", "b", "c"]

  @right.remove "e"
  membersEqual @complement, ["a", "b", "c"]

test "complements should emit addition and removal events", ->
  @complement.on 'itemsWereAdded', addedSpy = createSpy()
  @complement.on 'itemsWereRemoved', removedSpy = createSpy()

  @left.add "f"
  deepEqual addedSpy.lastCallArguments, ['f']

  @left.remove "f"
  deepEqual removedSpy.lastCallArguments, ['f']

  @right.add "b"
  deepEqual removedSpy.lastCallArguments, ['b']

  @right.remove "b"
  deepEqual addedSpy.lastCallArguments, ['b']

test "complements should be chainable", ->
  @middle = new Batman.Set "b", "c"

  subcomplement = new Batman.SetComplement(@complement, @middle)
  membersEqual subcomplement, ["a"]

  @left.add "f"
  membersEqual subcomplement, ["a", "f"]

  @right.add "f"
  membersEqual subcomplement, ["a"]

  @middle.add "a"
  membersEqual subcomplement, []