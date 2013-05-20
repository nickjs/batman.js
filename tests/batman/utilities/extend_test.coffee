QUnit.module "$extend",
  setup: ->
    @base = {x: "x"}

test "should copy properties from the source to the destination", ->
  deepEqual {x: "z", y: "y"}, $extend(@base, {x: "y"}, {y: "y"}, {x: "z"})

test "shouldn't affect the source objects", ->
  more = x: "y"
  $mixin @base, more
  deepEqual more, x: "y"
