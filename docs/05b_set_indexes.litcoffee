# /api/Data Structures/Batman.Set/Batman.SetIndex

`Batman.SetIndex` is a grouped collection of items derived from a [`Batman.Set`](/docs/api/batman.set.html) filled with [`Batman.Object`](/docs/api/batman.object.html)s. It extends `Batman.Object` and [`Batman.Enumerable`](/docs/api/batman.enumerable.html), so it inherits methods from them, too. In short, a `SetIndex` tracks its base `Set` and contains "buckets" of items from that `Set`, grouped by the provided key.

    test 'SetIndex groups items by values', ->
      batarang = new Batman.Object(name: "Batarang", type: "ranged")
      fists = new Batman.Object(name: "Fists", type: "melee")

      weapons = new Batman.Set(batarang, fists)
      # Three ways to create a SetIndex:
      weaponsByType1 = weapons.indexedBy('type')
      weaponsByType2 = weapons.get('indexedBy.type')
      weaponsByType3 = new Batman.SetIndex(weapons, 'type')

      # additions to the base Set are tracked by the SetIndex
      grappleGun = new Batman.Object(name: "Grapple Gun", type: "ranged")
      weapons.add(grappleGun)

      for setIndex in [weaponsByType1, weaponsByType2, weaponsByType3]
        equal setIndex.get('ranged').get('length'), 2
        equal setIndex.get('melee').get('length'), 1
        deepEqual setIndex.get('ranged').mapToProperty('name'), ["Batarang", "Grapple Gun"]
        deepEqual setIndex.toArray(), ["ranged", "melee"]

### Using a Batman.SetIndex

`Batman.SetIndex` is batman.js's way of grouping `Batman.Set`s. A `SetIndex` is like a hash of `Set`s. When you `get` a value from it, the `SetIndex` returns a `Set` of matching members.

Since a `SetIndex` is a proxy of a `Set`, the easiest way to make one is to use [`Set::indexedBy`](/docs/api/batman.set.html#prototype_function_indexedby):

```coffeescript
weaponIndex = weapons.indexedBy('type')
```

`weaponIndex` is a `SetIndex`. To find matches for a `type`, use `get`:

```coffeescript
meleeWeapons = weaponIndex.get('melee')
```

`meleeWeapons` is a `Batman.Set` containing items where `type = "melee"`.

You can also make `SetIndex`es in view bindings:

```html
<ul>
  <li data-foreach-meleeweapon='weapons.indexedBy.type.melee'>
    <!-- will render items where type="melee" -->
  </li>
</ul>
```

`SetIndex`es are __observable__ proxies of their underlying `Set`s. So, when the `Set` is changed (ie, items are added, removed, or modified):

- The `SetIndex` is automatically updated by batman.js
- Any view bindings or accessors depending on the `SetIndex` are updated

## ::constructor(base : Set, key : String ) : SetIndex

A `SetIndex` is made with a `base` and a `key`. Items in the `base` set will be grouped according to their value for `key`. The resulting `SetIndex` observes its `base`, so any items added to the `base` are also added (and indexed) in the `SetIndex`

## ::get(value : String) : Set

Returns a `Batman.Set` of items whose indexed `key` matches `value`. It returns an empty set if no items match `value`, but if any matching items are added to the `base` set, they will also be added to this set.

## ::toArray() : Array

Returns an array with the distinct values of `key` provided to the constructor.

## ::forEach(func)

Calls `func(key, group)` for each group in the SetIndex.

# /api/Data Structures/Batman.Set/Batman.UniqueSetIndex

`Batman.UniqueSetIndex` extends [`SetIndex`](/docs/api/batman.setindex.html) but adds a new consideration: its index contains _first matching item_ for each value of the `key` (rather than all matching items).

    test 'UniqueSetIndex takes the first matching item', ->
      batarang = new Batman.Object(name: "Batarang", type: "ranged")
      fists = new Batman.Object(name: "Fists", type: "melee")

      weapons = new Batman.Set(batarang,  fists)

      # Three ways to make a UniqueSetIndex:
      weaponsByUniqueType1 = weapons.indexedByUnique('type')
      weaponsByUniqueType2 = weapons.get('indexedByUnique.type')
      weaponsByUniqueType3 = new Batman.UniqueSetIndex(weapons, 'type')

      # additions to the base Set are tracked by the SetIndex
      grappleGun = new Batman.Object(name: "Grapple Gun", type: "ranged")
      weapons.add(grappleGun)

      for uniqueSetIndex in [weaponsByUniqueType1, weaponsByUniqueType2, weaponsByUniqueType3]
        equal uniqueSetIndex.get('ranged').get('name'), "Batarang"
        equal uniqueSetIndex.get('melee').get('name'), "Fists"

### Using a Batman.UniqueSetIndex

`Batman.UniqueSetIndex` is batman.js's way of finding unique items in a `Batman.Set`. A `UniqueSetIndex` is like a hash: when you `get` a value from it,it returns the _first_ matching member.

Since a `UniqueSetIndex` is a proxy of a `Set`, the easiest way to make one is to use [`Set::indexedByUnique`](/docs/api/batman.set.html#prototype_function_indexedbyunique):

```coffeescript
weaponsByName = weapons.indexedByUnique('name')
```

`weaponsByName` is a `UniqueSetIndex`. To find a member by `name`, use `get`:

```coffeescript
batarang = weaponsByName.get('Batarang')
```

`batarang` is the first item where `name = "Batarang"`.

You can also make `UniqueSetIndex`es in view bindings:

```html
<div data-context-batarang='weapons.indexedByUnique.name.Batarang'>
  <!-- `batarang` tracks `weapons` and will render the first item with name="Batarang"-->
</div>
```

`SetIndex`es are __observable__ proxies of their underlying `Set`s. So, when the `Set` is changed (ie, items are added, removed, or modified):

- The `SetIndex` is automatically updated by batman.js
- Any view bindings or accessors depending on the `SetIndex` are updated

__If an item is not found__, the `UniqueSetIndex` is still tracked as a source. Later, if a matching item is added, bindings and accessors will be updated with the new value.

## ::get(value : String) : Object

Returns the first matching member whose indexed `key` is equal to `value`.
