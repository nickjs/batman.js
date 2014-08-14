# /api/App Components/Batman.Model/Batman.Model Associations

Batman.js associations are modeled after [ActiveRecord Associations](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html). There are 3 types of assocations available on `Batman.Model`:

- [`hasMany`](/docs/api/batman.model_associations.html#class_function_hasmany)
- [`belongsTo`](/docs/api/batman.model_associations.html#class_function_belongsto)
- [`hasOne`](/docs/api/batman.model_associations.html#class_function_hasone)

Batman.js also supports [polymorphic associations](/docs/api/batman.model_associations.html#polymorphic_associations).

## Declaring Associations

To declare associations, use class functions in your model definition. Each function accepts a `label` and an `options` object.

For example, to describe the relationship between `ParentItem` and `ChildItem`:

```coffeescript
class App.ParentItem extends Batman.Model
  @hasMany 'child_items', inverseOf: 'parent_item', saveInline: true

class App.ChildItem extends Batman.Model
  @belongsTo 'parent_item', inverseOf: 'child_items', autoload: true
```

## Association Accessors

When you declare an association, you also create an accessor for the `label` you pass in the declaration. You can `get` and `set` that `label` to work with the association.

When you __`get`__ an association value, it returns a `Batman.AssociationSet` or a `Batman.AssociationProxy`. These objects help manage the association and provide transparent access to the actual records.

If you __`set`__ an association value, it will return the value which you assigned, not the proxy.

In the example above, we declared `ChildItem.belongsTo('parent_item')`. That means that you can use the `"parent_item"` accessor to get the related record:

```coffeescript
  child.get('parent_item.name') # => "Parent 1"
  otherParent = new App.ParentItem(name: "Parent 2")
  child.set('parent_item', otherParent)
```

We also declared `ParentItem.hasMany('child_items')`, so we can use the `"child_items"` accessor to access those records:

```coffeescript
  parent.get('child_items') # => Batman.AssociationSet
  parent.get('child_items.length') # => 1
  # add an item:
  newChild = new App.ChildItem(parent_item: parent)
  parent.get('child_items').add(child)
  parent.get('child_items.length') # => 2
```

## Specifying Related Classes

By default, each association converts its `label` to the appropriate class name and looks it up on `Batman.currentApp`. However, you can also specify the class's `name` and `namespace` by passing them as options.

If your model is defined somewhere other than `MyApp`, you should use the `namespace` option to show batman.js where the model can be found. For example, if your `User` model was defined on a namespace called `Admin`, you would pass that object to any associations that looked for `User`:

```coffeescript
class MyApp.Admin.User extends Batman.Model
  @hasMany 'assignments'
# ...
class MyApp.Assignment extends Batman.Model
  @belongsTo 'user', namespace: MyApp.Admin
```

If you create an association whose name differs from the class name of the related model, you should pass the class name as `name`. For example, if an `Assignment` belongs to an `owner`, which is a `User` record, you can declare it like this:

```coffeescript
class MyApp.Assignment extends Batman.Model
  @belongsTo 'owner', name: "User"
```

Now, batman.js will use `MyApp.User` for the `owner` association.

## Polymorphic Associations

Batman.js also supports [Rails-inspired polymorphic associations](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations). In a polymorphic association, a record may belong to records of _different types_. Instead of specifying a related model, you specify an "interface" for the association.

For example, a `Superpower` may belong to a `Hero` or a `Villain`. The interface is `"superpowerable"`:

```coffeescript
class App.Superpower extends Batman.Model
  @encode 'name'
  @belongsTo 'superpowerable', polymorphic: true

class App.Hero extends Batman.Model
  @hasMany 'superpowers', as: 'superpowerable', saveInline: true

class App.Villain extends Batman.Model
  @hasMany 'superpowers', as: 'superpowerable', saveInline: true
```

By default, attributes of the polymorphic association will be encoded according to the label. So, `hero.toJSON()` might return:

```javascript
{ id: 1,
  name: 'Superman',
  superpowers: [
    {id: 15, superpowerable_id: 1, superpowerable_type: 'hero', name: 'Super Strength'},
    {id: 16, superpowerable_id: 1, superpowerable_type: 'hero', name: 'Invincibility'},
  ]
}
```

## Inverse Associations

You can declare `inverseOf` in you associations to tell batman.js which foreign association to set on load. If the associated model has an association with the same name as the `inverseOf` value, it will be populated when data is loaded from storage. For example:

```coffeescript
class App.ParentItem extends Batman.Model
  @hasMany 'childItems', saveInline: true, inverseOf: 'parentItem'

class App.ChildItem extends Batman.Model
  @belongsTo 'parentItem', inverseOf: 'childItems'
```

would allow:

```coffeescript
App.ParentItem.find 1, (err, parent) ->
  children = parent.get('childItems')
  children.get('first.parentItem') == parent # => true

App.ChildItem.find 5, (err, childItem) ->
  childItem.get('parentItem').load (err, parent) ->
    parent.get('childItems').has(childItem) # => true
```


## @hasMany(label : string [, options : Object])

`@hasMany` expresses a one-to-many relationship on a `Batman.Model`.

`get`ting a `@hasMany` accessor returns a `Batman.AssociationSet` (or a `Batman.PolymorphicAssociationSet` of the association is polymorphic).

It accepts options:

Option | Default | Description
-- | -- | --
`name` | singularized, camelized `@label` | The class name for the associatiated model
`namespace` | `Batman.currentApp` | The object where the class is defined
`encoderKey` | `@label` | The JSON key for associated records' data
`saveInline` | `false` | If true, child records will be saved inline with their parent
`autoload` | `false` | If true, `parent.get("children")` will trigger a load operation with request param `parent_id`.
`url` |  model's collection URL | The URL where children can be loaded
`includeInTransaction` | `true` | If false, this association will be skipped when deep-copying the record.
`inverseOf` | | Names the corresponding relation on the associated model.
`extend` | `{}` | An object to be mixed into the `Batman.Association` object.
`primaryKey` | `"id"` | The primary key for the parent model
`foreignKey` | underscored `@model.resourceName` + `"_id"`] | The key on child records which contains the parent's primary key value
`encodeWithIndexes` | `false` | If true, children will be encoded as an Object instead of an Array.
`replaceFromJSON` | `true` | If false, objects which aren't found when loading JSON will be _left in_ the association set. Use this option if you will paginate through child records.
`as` | | Denotes a polymorphic association with the given name
`foreignTypeKey` | `"#{as}_type"` | The field where polymorphic children's class names will be stored

`encodeWithIndexes` provides a second option for serializing children wtih `saveInline`. If `ecnodeWithIndexes: true`, `@hasMany` children will be encoded as a JSON object with index keys instead of arrays. For example:

```javascript
{ id: 1,
  name: "As Seen on TV Warehouse",
  products: {
    "0": {id: 1, name: "Orange Glo"},
    "1": {name: "Oxyclean"}
  }
}
```

## @belongsTo(label : string [, options : Object])

`@belongsTo` expresses a one-to-one relationship on a `Batman.Model` when this model contains the foreign key (eg, `parent_id`). If the other model contains the foreign key, use `@hasOne` instead.

`@belongsTo` often expresses inverse of a `@hasMany` or `@hasOne` association. You can declare this with the [`inverseOf` option](/docs/api/batman.model_associations.html#inverse_associations) so that both sides of the association are loaded from JSON.

`get`ting a `@belongsTo` accessor returns a `Batman.BelongsToProxy` (or a `Batman.PolymorphicBelongsToProxy` if the association is polymorphic).

It accepts options:

Option | Default | Description
-- | -- | --
`name` | singularized, camelized `@label` | The class name for the associatiated model
`namespace` | `Batman.currentApp` | The object where the class is defined
`encoderKey` | `@label` | The JSON key for associated records' data
`saveInline` | `false` | If true, child records will be saved inline with their parent
`autoload` | `false` | If true, `parent.get("children")` will trigger a load operation with request param `parent_id`.
`nestUrl` | `false` | If true, the associated model will be passed to `@urlNestsUnder`
`url` |  associated model's URL, with the `foreignKey` value | The URL where the parent can be loaded
`includeInTransaction` | `true` | If false, this association will be skipped when deep-copying the record.
`inverseOf` | | Names the corresponding relation on the associated model.
`extend` | | An object to be mixed into the `Batman.Association` object.
`primaryKey` | `"id"` | The primary key for the parent model
`foreignKey` | `"#{@label}_id"` | The key on child records which contains the parent's primary key value
`encodeForeignKey` | `true` | If false, the foreign key will be excluded from the record's JSON.
`polymorphic` | | Denotes the association as polymorphic

## @hasOne(label : string [, options : Object])

`@hasOne` expresses a one-to-one relationship on a `Batman.Model` when this model contains the primary key (eg, `id`) and does not contain the foreign key. If this model contains the foreign key, use `@belongsTo` instead.

`get`ting a `@hasOne` accessor returns a `Batman.HasOneProxy`

It accepts options:

Option | Default | Description
-- | -- | --
`name` | camelized `@label` | The class name for the associatiated model
`namespace` | `Batman.currentApp` | The object where the class is defined
`encoderKey` | `@label` | The JSON key for associated records' data
`saveInline` | `false` | If true, child records will be saved inline with their parent
`autoload` | `false` | If true, `parent.get("child")` will trigger a load operation with request param `parent_id`.
`url` |  associated model's URL, with the `primaryKey` value | The UR where the child can be loaded
`includeInTransaction` | `true` | If false, this association will be skipped when deep-copying the record.
`inverseOf` | | Names the corresponding relation on the associated model.
`extend` |  |  An object to be mixed into the `Batman.Association` object.
`primaryKey` | `"id"` | The primary key for the parent model
`foreignKey` | underscored `@model.resourceName` + `"_id"` | The key on the child record which contains the parent's primary key value

