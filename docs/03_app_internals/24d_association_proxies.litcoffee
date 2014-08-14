# /api/App Internals/Batman.AssociationProxy

`Batman.AssociationProxy` extends `Batman.Proxy`. It's an abstract class. To implement it, a class must define:

- `::fetchFromLocal`
- `::fetchFromRemote`

These functions are used by `::fetch` to find the associated record.

## ::constructor(@assciation, @model) : AssocationProxy

Returns a new proxy, but doesn't set `target` because that's set by `::fetch`.

## ::toJSON()

Delegates to `target`, if present.

## ::save()

Delegates to `target`, if present.

## ::transaction()

Delegates to `target`, if present.

## ::validate()

Delegates to `target`, if present.

## ::destroy()

Delegates to `target`, if present.

## ::load([callback]) : Promise

Fetches the record and caches it as `target`. It passes `(err, target)` to `callback`.

The returned `Promise` resolves with the loaded record or rejects with any error that occured.

## ::loadFromLocal()

Returns `target` if it can fetch it locally.

## ::fetch([callback]) : Promise

Fetches the record by trying `fetchFromLocal` then `fetchFromRemote`. Passes `(err, record)` to `callback`.

The returned `Promise` resolves with the fetched record or rejects with any error that occured.

## ::%loaded : Boolean

Set to `true` when batman.js determines that the `target` has been loaded.

## ::%target : Model

Returns the target by calling `fetchFromLocal`.

# /api/App Internals/Batman.AssociationProxy/Batman.BelongsToProxy

`Batman.BelongsToProxy` extends `Batman.AssociationProxy`. It is the return value of `@belongsTo` associations' `get` accessors.

## ::%foreignValue

Returns the value for `@assocation.foreignKey` for `@model`.

## ::fetchFromLocal() : Model

Looks up `foreignValue` in `@association.setIndex()`.

## ::fetchFromRemote(callback)

Loads the record from storage using:

- `foreignValue` and the primary key
- `@association.options.recordUrl` if it was passed

# /api/App Internals/Batman.AssociationProxy/Batman.HasOneProxy

`Batman.HasOneProxy` extends `Batman.AssociationProxy`. It is the return value of `@hasOne` associations' `get` accessors.

## ::%primaryValue

Gets the value of `@association.primaryKey` from `@model`

## ::fetchFromLocal() : Model

Looks up `primaryValue` on `@association.setIndex()`

## ::fetchFromRemote(callback)

Loads the record from storage using:

- `primaryValue` as a request parameter
- `@assocation.options.url` as the request URL, if provided

It expects the URL to return an array of records. The first one will be treated as the related record for this association.

Passes `(err, record)` to `callback`.

# /api/App Internals/Batman.AssociationProxy/Batman.PolymorphicBelongsToProxy

`Batman.PolymorphicBelongsToProxy` extends `Batman.BelongsToProxy`. It is the return value of `@belongsTo as "..."` associations.

## ::%foreignTypeValue

Gets `@association.foreignTypeKey` from `@model`.

## ::fetchFromLocal() : Model

Looks up a record using `foreignValue` and `foreignTypeValue`.

## ::fetchFromRemote(callback)

Loads the record from storage using:

- `@assocations.options.url` as the URL, if provided.

Passes `(err, record)` to `callback`.
