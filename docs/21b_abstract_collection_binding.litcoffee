# /api/App Internals/Bindings/Batman.DOM.AbstractCollectionBinding

`Batman.DOM.AbstractCollectionBinding` is the parent class for all collection bindings. It extends `Batman.DOM.AbstractAttributeBinding`. To extend `Batman.DOM.AbstractCollectionBinding`, a child class __must__ define `handleArrayChanged`, which is called when the collection changes. The child class may define `handleItemsAdded`, `handleItemsRemoved`, and `handleItemMoved`, which will be bound to colleciton events.

Extended by:
- `Batman.DOM.ClassBinding`
- `Batman.DOM.IteratorBinding`
- `Batman.DOM.StyleBinding`

## ::.collection : Enumerable

The `Batman.Enumerable` (eg, `Batman.Hash`, `Batman.Set`) bound to this binding.

## ::dataChange(collection)

If `collection` is defined, either sets up bindings with `bindCollection`, or (if that returns `false`) calls `handleArrayChanged` with `collection`'s  items.

If `collection` isn't defined, it is treated as `[]`.

## ::bindCollection(newCollection) : Boolean

Sets up bindings between itself and the collection, setting `newCollection` as `@collection`. Returns `true` if bindings were initialized properly.

If `newCollection` is `@collection`, returns `true` without re-binding.

If the binding defines `@handleItemsAdded`, `@handleItemsRemoved` and `@handleItemMoved` __and_ `newCollection.isCollectionEventEmitter`, the binding will bind to collection event. Otherwise, it will bind to the collection's `toArray` property.

## ::unbindCollection()

Removes bindings between itself and its current collection

## ::handleArrayChanged()

Must be implemented by implementing classes to handle changes to `@collection`.

## ::die()

unbinds `@collection`, sets `@collection` to `null` and kills the binding.