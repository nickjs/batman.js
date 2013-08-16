# Batman.Model Associations

There are 3 types of assocations available on `Batman.Model`: `hasMany`, `belongsTo`, and `hasOne`.

## Batman.AssocationProxy

Association accessors won't always return a `Batman.Set`. Generally they will return a `Batman.AssocationProxy` named after the association type,
such as `Batman.BelongsToAssociationProxy` or `Batman.HasManyAssociationProxy`.

`Batman.AssociationProxy` defines useful methods such as `@load`, `@toJSON`, `@loadFromLocal`. It also defines accessors such as `%loaded` and `%target`.

## Shared Options
All assocations have a common set of options, as well as specific options for each type of relationship.

##### `saveInline[= true] : boolean`
Whether we should save the child objects as part of the parent object's JSON

##### `autoload[= true] : boolean`
 Whether we should load the child objects when loading the parent object.

##### `nestUrl[= false] : boolean`
Whether the child models are persisted beneath the parent model's url structure.

##### `name : string`
The name of the child model for the association. (eg. App.Product)

##### `inverseOf : string`
The foreign association to set on load.

##### `encoderKey : string`
The key to encode and decode the assocation into/from JSON.

##### `namespace[= Batman.currentApp] : string`
The location of the model definition for the association.

##### `polymorphic[= false] : boolean`
Whether the association is polymorphic.

## @hasMany(label[, options])
`hasMany` assocations are used for expressing one-to-many relationships on a `Batman.Model`.

- `label : string`
- `options : Object`
  - `primaryKey : string`
  - `foreignKey : string`
  - `as : string`
    - the parent association name on child objects in a polymorphic association

## @hasOne(label[, options])
`hasOne` associations are used for expressing one-to-one relationships on a `Batman.Model`.

- `label : string`
- `options : Object`
  - `primaryKey : string`
  - `foreignKey : string`
  - `as : string`
    - the parent association name on child objects in a polymorphic association

## @belongsTo(label[, options])
`belongsTo` associatons are used for expressing one-to-one child relationships on a `Batman.Model`.

- `label : string`
- `options : Object`
  - `primaryKey : string`
  - `foreignKey : string`
  - `encodeForeignKey[= true] boolean`
    - whether to encode the foreignKey value when persisting the model