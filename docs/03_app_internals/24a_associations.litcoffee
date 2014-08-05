# /api/App Internals/Batman.Association

`Batman.Association` is an abstract class that __does not__ extend `Batman.Object`. `Batman.Association`'s subclasses (eg, `Batman.HasManyAssociation`) provide backing for `Batman.Model` associations. You should rarely have to interact with them directly.

## ::constructor(@model, @label, options={}) : Association

- `@model` is the model which defined the association
- `@label` is the string name for the association

`options` may override any of `Batman.Association::defaultOptions`. You may also pass:

- `options.namespace` is where the related model will be found. Defaults to `Batman.currentApp`.
- `options.name` is the string class name of the related model. Associations provide default based on `@label`.
- `options.encoderKey` will be used for parsing and creating JSON
- `options.extend` will be mixed into the new `Batman.Association`
- Any association-specific options (see relevant association)

## ::getRelatedModel() : Model

Returns the _other_ model in this association (not the model where this association was defined, see `Batman.Association::model`).

## ::getFromAttributes(record)

Gets `@label` from `record`'s attributes.

## ::setIntoAttributes(record, value)

Sets `value` into `record`'s attributes as `@label`.

## ::inverse() : Association

Returns the inverse association for this association by:

- using the `inverseOf` option
- checking the related Model for a relation whose class is `@model`

## ::reset()

## ::encoder() : Function

Returns a function suitable for turning a record into JSON. Implemented by subclasses.

## ::decoder() : Function

Returns a function suitable for loading a record from JSON. Implemented by subclasses.

## ::apply(record : Batman.Model)

Called after `record` is saved to update associated records. Implemented by subclasses.

## ::getAccessor(association, model, label)

Applied to records to implement this association.  Implemented by subclasses.

## ::.isPolymorphic[=false] : Boolean

Polymorphic associations set this to `true`.

## ::.associationType[=''] : String

Used by `Batman.AssociationCurator` to store this association. Overriden by concrete association classes.

## ::.defaultOptions : Object

These options are passed to all associations unless overriden in the constructor. They are:

- `saveInline`: false
- `autoload`: false
- `nestUrl`: false
- `includeInTransaction`: true
- `encodeWithIndexes`: false

## ::.model : Model

`@model` is the model where this association was defined.


# /api/App Internals/Batman.Association/Batman.AssociationCurator

`Batman.AssociationCurator` extends `Batman.SimpleHash` and provides a storage mechanism for a `Batman.Model`'s associations. It's stored on the class's `@_batman.associations`.

## ::constructor(@model : Batman.Model) : AssociationCurator

Returns a new `Batman.AssociationCurator` for `@model`.

## ::add(association)

Adds `association` so it maybe found by type or by label.

## ::getByType(type: String) : SimpleSet

Returns a `Batman.SimpleSet` containing all associations of `type`. See `Batman.AssociationCurator.availableAssociations` for allowed types.

## ::getByLabel(label: String) : Association

Returns the `Batman.Association` named by `label`, if found.

## ::getAll() : SimpleSet

## ::reset()

Unsets all keys on the `AssociationCurator`.

## ::merge(others... : AssociationCurator) : AssociationCurator

Returns a new `Batman.AssociationCurator` containing this `AssociationCurator`'s contents and the contents of `others`.

## ::.model : Model

The model whose associations are stored in the `AssociationCurator`.

## @.availableAssociations[=["belongsTo", "hasOne", "hasMany"]]

These names are used to define the class functions for the `Batman.Model` association API.
