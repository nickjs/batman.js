# /api/Data Structures/Batman.BinarySetOperation

`Batman.BinarySetOperation` extends `Batman.Set` and tracks _two_ `Batman.Set`s and updates its contents whenever an item is added to or removed from either set. `Batman.BinarySetOperation` is an abstract class. It is extended by `Batman.SetUnion`, `Batman.SetIntersection`, and `Batman.SetComplement`.

## ::constructor(left: Set, right: Set) : BinarySetOperation

Returns a new `BinarySetOperation` between `left` and `right`.

## ::merge(others... : Set) : Set

Returns a new `Batman.Set` with the contents of the `BinarySetOperation` plus the contents of `others`.

## ::filter(func: Function) : Set

Executes `func(item)` for each item in the `BinarySetOperation` and returns a new `Batman.Set` with items where `func(item)` returned a truthy value.

## ::.left : Set

Returns the first `Batman.Set` passed to the constructor.

## ::.right : Set

Returns the second `Batman.Set` passed to the constructor.


# /api/Data Structures/Batman.BinarySetOperation/Batman.SetUnion

`Batman.SetUnion` extends `Batman.BinarySetOperation`. It implements a [union operation](http://en.wikipedia.org/wiki/Union_%28set_theory%29): the `SetUnion` contains members found in _either set_ passed to the constructor, without duplicates.

Since `Batman.SetUnion` is a subclass of `Batman.Set`, you can use it just like a `Batman.Set`.

    test 'SetUnion contains the union of two sets', ->
      left = new Batman.Set([1, 2, 3])
      right = new Batman.Set([3, 4, 5])
      operation = new Batman.SetUnion(left, right)
      ok operation.has(1), 'has items from the left set'
      ok operation.has(4), 'has items from the right set'
      ok operation.has(3), 'has items from both sets'


# /api/Data Structures/Batman.BinarySetOperation/Batman.SetIntersection

`Batman.SetIntersection` extends `Batman.BinarySetOperation`. It implements an [intersection operation](http://en.wikipedia.org/wiki/Intersection_%28set_theory%29): it contains members of _both sets_ passed to its constructor without duplicates.

Since `Batman.SetIntersection` is a subclass of `Batman.Set`, you can use it just like a `Batman.Set`.

    test 'SetIntersection contains the intersection of two sets', ->
      left = new Batman.Set([1, 2, 3])
      right = new Batman.Set([3, 4, 5])
      operation = new Batman.SetIntersection(left, right)
      ok !operation.has(1), 'doesnt have items from the left set only'
      ok !operation.has(4), 'doesnt have items from the right set only'
      ok operation.has(3), 'has items from both sets'

# /api/Data Structures/Batman.BinarySetOperation/Batman.SetComplement

`Batman.SetComplement` extends `Batman.BinarySetOperation`. It implements a [complement operation](http://en.wikipedia.org/wiki/Complement_%28set_theory%29): it contains the members of _`left`_ which aren't in _`right`_.

Since `Batman.SetComplement` is a subclass of `Batman.Set`, you can use it just like a `Batman.Set`.

    test 'SetComplement contains the complement of two sets', ->
      left = new Batman.Set([1, 2, 3])
      right = new Batman.Set([3, 4, 5])
      operation = new Batman.SetComplement(left, right)
      ok operation.has(1), 'has items from the left set only'
      ok !operation.has(4), 'doesnt have items from the right set only'
      ok !operation.has(3), 'doesnt have items from both sets'
