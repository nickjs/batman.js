# /api/App Internals/Batman.AssociationSet

`Batman.AssociationSet` is the return value of a `@hasMany` assocation. It extends `Batman.SetSort`. When constructed, it creates a new `Batman.Set`, then sorts it by `_batmanID`.

Since `Batman.AssociationSet` extends `Batman.SetIndex`, you can use any of `Batman.SetIndex`'s methods, too.

## ::constructor(@foreignKeyValue, @association) : AssociationSet

Creates a new `Batman.Set` to be `@base` and uses `_batmanID` as `@key`.

## ::%loaded[=false]

Set to `true` by `markAsLoaded`.

## ::load(options, callback)

Loads records by:

- using `@foreignKeyValue` as a request param
- using `@association.options.url` as the request URL, if present
- mixing in `options` as the request's data

Then, calls `markAsLoaded` and fires the callback with `(err, @, env)`.

## ::markAsLoaded()

Sets `loaded` to true and fires `loaded`.

## ::%parentRecord : Model

Returns the parent record for `@foreignKeyValue`.

## ::build(attrs={}) : Model

Builds a child record with `attrs` (mixing in `@foreignKeyValue` and `inverseOf`, if possible) and adds it to the `AssociationSet`.

# /api/App Internals/Batman.AssociationSet/Batman.AssociationSetIndex

`Batman.AssocationSetIndex` extends `Batman.SetIndex` and is used internally to find records by its `@key`.

## ::constructor(@assocation, key) : AssociationSetIndex

Indexes `@association`'s related model's loaded set by `key`.

# /api/App Internals/Batman.AssociationSet/Batman.UniqueAssociationSetIndex

`Batman.UniqueAssociationSetIndex` extends `Batman.UniqueSetIndex` and is used internally to find one record by it's `@key`

## ::constructor(@assocation, key) : UniqueAssociationSetIndex

Unique-indexes `@association`'s related model's loaded set by `key`.

# /api/App Internals/Batman.AssociationSet/Batman.PolymorphicAssociationSet

`Batman.PolymorphicAssociationSet` extends `Batman.AssocationSet`. It's the return value of a `@hasMany as: '...'` assocation.

## ::constructor(@foreignKeyValue, @foreignTypeKeyValue, @association) : PolymorphicAssociationSet

Sends `@foreignKeyValue` and `@assocation` to the superclass constuctor.

## ::load(options, callback)

Loads records from storage using:

- `@assocation.options.url` as the request URL, if it's provided
- `@foreignKeyValue` and `@foreignTypeKeyValue` as request params
- Mixing `options` in the request data

Then invokes `callback` with `(err, @, env)`.

# /api/App Internals/Batman.AssociationSet/Batman.PolymorphicAssociationSetIndex

`Batman.PolymorphicAssociationSetIndex` extends `Batman.SetIndex`. It is used internally by polymorphic associations.

When items are added and removed from `Batman.PolymorphicAssociationSetIndex`es, they are ignored unless their  `foreignTypeKey` value is the index's `@type`.

## ::constructor(@association, @type, key)

Indexes `@association`'s related model's loaded set by `key`.

# /api/App Internals/Batman.AssociationSet/Batman.PolymorphicUniqueAssociationSetIndex

`Batman.PolymorphicUniqueAssociationSetIndex` extends `Batman.UniqueSetIndex`.

## ::constructor(@association, @type, key)

Finds the model for `type`, then unique-indexes that model's loaded set by `key`.
