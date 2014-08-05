# /api/App Internals/Batman.Association/Batman.SingularAssociation

`Batman.SingularAssociation` extends `Batman.Association`.

## ::constructor(@model, @label, options={}) : SingularAssociation

Adds default options:

- `namespace`: `Batman.currentApp`
- `name`: camelized `@label`

## ::getAccessor(association, model, label)

Checks for the associated record in this record's attributes. Otherwise returns a proxy. Loads the associated record if `options.autoload`.

## ::setIndex() : UniqueAssociationSetIndex

Returns a `Batman.UniqueAssociationSetIndex` based on `indexRelatedModelOn` which is suitable for finding the associated record in its loaded set.

## ::associationProxy(association)

Returns a suitable proxy object for `association`.

## ::.indexRelatedModelOn

Implemented by subclasses to be used in `setIndex`.

## ::.isSingular[=true]

Identifies the `SingularAssociation`.

# /api/App Internals/Batman.Association/Batman.BelongsToAssociation

`Batman.BelongsToAssociation` extends `Batman.SingularAssociation` and provides backing to associations declared with `@belongsTo` in model definitions.


## ::constructor(model, label, options)

Returns a `Batman.PolymorphicBelongsToAssociation` if `options.polymorphic` is true.

## ::encoder() : Function

Returns a function that serializes a record by calling `toJSON` on it.

## ::decoder() : Function

Returns a function that loads a record by:

- using `createFromJSON` to instantiate the record
- if the inverse is a `Batman.HasManyAssociation`, setting the foreignKey from the parent record
- if the inverse is something else (eg, `Batman.HasOneAssociation`), setting the parent's `inverse.label` to this record.
- setting the record's `association.label` to the parent record

## ::apply(record)

Update's `record`'s foreignKey to the associated record's primaryKey.

## ::.defaultOptions

- `saveInline`: false
- `autoload`: true
- `encodeForeignKey`: true

## ::.proxyClass[=Batman.BelongsToProxy]

Returned by a `belongsTo` get accessor.

## ::.associationType[='belongsTo']

Used by `Batman.AssociationCurator` to store this association.

## ::.indexRelatedModelOn[='primaryKey']

Used to create a `Batman.UniqueAssociationSetIndex` to locate the associated record.

# /api/App Internals/Batman.Association/Batman.HasOneAssociation

`Batman.HasOneAssociation` extends `Batman.SingularAssociation` and backs associations declared with `@hasOne` in model definitions.

## ::constructor(model, label, options) : HasOneAssociation

Provides default options:

- `primaryKey`: "id"
- `foreignKey`: underscored `@model.resourceName` + `_id`

## ::apply(baseSaveError, base)

Called after `base` is saved. If there's no `baseSaveError`, updates the related record's foreign key to `base`'s primary key.

## ::encoder() : Function

Returns a function that serializes the record if `options.saveInline` is true.

## ::decoder() : Function

Returns a function that creates a related record from JSON and sets its `inverseOf`.

## ::.associationType[='hasOne']

Used by `Batman.AssociationCurator` to store the association.

## ::.proxyClass[=Batman.HasOneProxy]

Sometimes returned by a `hasOne` get accessor.

## ::.indexRelatedModelOn[='foreignKey']

Used to create a `Batman.UniqueAssociationSetIndex` to locate the associated record.

# /api/App Internals/Batman.Association/Batman.PolymorphicBelongsToAssociation

`Batman.PolymorphicBelongsToAssociation` extends `Batman.BelongsToAssociation` and backs associations declared with `@belongsTo "...", polymorphic: true`.

## ::constructor(model, label, options) : PolymorphicBelongsToAssociation

Calls `super`, then encodes the `foreignTypeKey` if option `encodeForeignTypeKey` was true.

## ::apply(base)

Extends `Batman.BelongsToAssociation::apply` by also updating `base`'s property for `foreignTypeKey`.

## ::getAccessor(association, model, label)

Returns either a record from attributes or a proxy. Loads the proxy if the autoload option was true.

## ::url(recordOptions) : String

Returns a suitable URL for the association.

## ::getRelatedModelForType(type)

Tries to find a model in the association's scope with `type` or camelized `type`.

## ::setIndexForType(type) : PolymorphicUniqueAssociationSetIndex

Returns a set index to find the associated record for `type`.

## ::.typeIndices : Object

A cache of `Batman.PolymorphicUniqueAssociationSetIndex`es for this association.

## ::inverseForType(type) : Association

Looks up the inverse association for `type` by using `@options.inverseOf` or checking all associations on the return value of`getRelatedModelForType` for `type`.

## ::decoder() : Function

Returns a function that loads a record from JSON, taking into account the `foreignTypeKey`.


## ::.isPolymorphic[=true]

Labels this association as polymorphic.

## ::.proxyClass[=Batman.PolymorphicBelongsToProxy]

Returned when the associated record isn't found in attributes.

## ::.defaultOptions

Extends `Batman.BelongsToAssociation`'s  default options and adds:

- `encodeForeignTypeKey`: true

## ::.getRelatedModel[=false]
## ::.setIndex[=false]
## ::.inverse[=false]

