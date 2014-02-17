# /api/Data Structures/Batman.Event/Batman.Keypath

`Batman.Keypath` extends `Batman.Property`, adding the ability to track nested properies as defined with `"."`. Properties on `Batman.Object`s are `Keypath`s.

## ::constructor(base, key) : Keypath

Returns a new `Batman.Keypath` on `base`, tracking `key`.

## ::.segments : Array

`key` passed to the constructor, split on `"."`

## ::.depth : Number

The number of segments in `key` passed to the constructor.

## ::isCachable() : Boolean

Returns `true` if `depth` is greater than one, otherwise calls `super` (`Batman.Property::isCachable`).

## ::terminalProperty() : Keypath

Looks up items in `segments` and returns the `Keypath` for the `base` and `key` of the last item in `segments`. This property is the one that is actually `get` and `set` by the `Keypath`.

## ::valueFromAccessor()

Returns the value of the last property in `segments`.

## ::setValue(value)

Sets the value of the last property in `segments` and returns the value.

## ::unsetValue()

Unsets the value of the last property in `segments`.
