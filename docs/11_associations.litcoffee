# Batman.Model Associations

There are 3 types of assocations available on `Batman.Model`: `hasMany`, `belongsTo`, and `hasOne`. They're modeled after [ActiveRecord Associations](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html). To add associations to your models, declare the associations in your model definition:

```coffeescript
class App.ParentItem extends Batman.Model
  @hasMany 'childItems', saveInline: true

class App.ChildItem extends Batman.Model
  @belongsTo 'parentItem'
```

Then, associated records will be available via accessors:

```coffeescript
  parent = new App.ParentItem
  child = new App.ChildItem

  child.set('parentItem', parent)
  child.get('parentItem') # => parent
```

```coffeescript
  parent = new App.ParentItem
  child = new App.ChildItem
  secondChild = new App.ChildItem
  parent.get('childItems').add(child)
  parent.get('childItems').add(secondChild)
  parent.get('childItems') # => Batman.AssociationSet
  parent.get('childItems.length') # => 2
```

## Batman.AssocationProxy

Association accessors won't always return a `Batman.AssociationSet` or `Batman.Model`. Generally they will return a `Batman.AssocationProxy` named after the association type,
such as `Batman.BelongsToAssociationProxy` or `Batman.HasOneAssociationProxy`.


## ::load(callback : Function)
Called to load the associated record from storage, setting it as  [`target`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_accessor_target). If a callback is passed, it is called with two arguments: any error and the loaded record. Also, when this function finishes, it sets [`loaded`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_accessor_loaded) to `true` and fires `loaded` on the record.

## ::toJSON() : Object
Returns JSON for the target record, if the [`target`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_accessor_target) is present.

## ::%target
The associated record. Getting `target` does not implicitly call `load` on the association.

## ::%loaded
`true` or `false`, Whether or not the record has been loaded from storage.

## ::fetchFromLocal() : Model
This method is called by [`load`](/docs/api/batman.model_associations.html#prototype_function_load) to fetch the [`target`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_accessor_target) record. If this method returns a falsy value, then [`fetchFromRemote`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_function_fetchfromremote) is called.  `Batman.AssocationProxy` subclasses must implement this method.

## ::fetchFromRemote() : Model
If [`fetchFromLocal`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_function_fetchfromlocal) returns a falsy value, this method is called by [`load`](/docs/api/batman.model_associations.html#prototype_function_load) to fetch the [`target`](http://localhost:4000/docs/api/batman.model_associations.html#prototype_accessor_target) record. `Batman.AssocationProxy` subclasses must implement this method.


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