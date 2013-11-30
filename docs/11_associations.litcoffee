# Batman.Model Associations

There are 3 types of assocations available on `Batman.Model`: [`hasMany`](/docs/api/batman.model_associations.html#class_function_hasmany), [`belongsTo`](/docs/api/batman.model_associations.html#class_function_belongsto), and [`hasOne`](/docs/api/batman.model_associations.html#class_function_hasone). They're modeled after [ActiveRecord Associations](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html). Batman also supports polymorphic associations through the use of [polymorphic-specific options](/docs/api/batman.model_associations.html#polymorphic_association_options).

To add associations to your models, declare them in your model definition. Association functions take a label (string) and options (Object). The label names the association and is used to provide smart defaults for several options. All available options are [detailed below](/docs/api/batman.model_associations.html#association_options).

For example:

```coffeescript
class App.ParentItem extends Batman.Model
  @hasMany 'childItems', inverseOf: 'parentItem', encoderKey: 'children'

class App.ChildItem extends Batman.Model
  @belongsTo 'parentItem', inverseOf: 'childItem'
```

Then, associated records will be available via accessors:

```coffeescript
  parent = new App.ParentItem
  child = new App.ChildItem

  child.set('parentItem', parent)
  child.get('parentItem') # => parent
```

or,

```coffeescript
  parent = new App.ParentItem
  child = new App.ChildItem
  secondChild = new App.ChildItem
  parent.get('childItems').add(child)
  parent.get('childItems').add(secondChild)
  parent.get('childItems') # => Batman.AssociationSet
  parent.get('childItems.length') # => 2
```

## @hasMany(label : string [, options : Object])
`hasMany` expresses a one-to-many relationship on a `Batman.Model`.

## @hasOne(label : string [, options : Object])
`hasOne` expresses a one-to-one relationship on a `Batman.Model` when this model contains the primary key (eg, `id`) and does not contain the foreign key. If this model contains the foreign key, use `belongsTo` instead.

## @belongsTo(label : string [, options : Object])
`belongsTo` expresses a one-to-one relationship on a `Batman.Model` when this model contains the foreign key (eg, `parent_id`). If the other model contains the foreign key, use `hasOne` instead.

## Batman.AssocationProxy

Association accessors won't always return a `Batman.AssociationSet` or `Batman.Model`. Generally they will return a `Batman.AssocationProxy` named after the association type,
such as `Batman.BelongsToAssociationProxy` or `Batman.HasOneAssociationProxy`.


## ::load(callback : Function)
Called to load the associated record from storage, setting it as  [`target`](/docs/api/batman.model_associations.html#prototype_accessor_target). If a callback is passed, it is called with two arguments: any error and the loaded record. Also, when this function finishes, it sets [`loaded`](/docs/api/batman.model_associations.html#prototype_accessor_loaded) to `true` and fires `loaded` on the record.

## ::toJSON() : Object
Returns JSON for the target record, if the [`target`](/docs/api/batman.model_associations.html#prototype_accessor_target) is present.

## ::%target
The associated record. Getting `target` does not implicitly call `load` on the association.

## ::%loaded
`true` or `false`, Whether or not the record has been loaded from storage.

## ::fetchFromLocal() : Model
This method is called by [`load`](/docs/api/batman.model_associations.html#prototype_function_load) to fetch the [`target`](/docs/api/batman.model_associations.html#prototype_accessor_target) record. If this method returns a falsy value, then [`fetchFromRemote`](/docs/api/batman.model_associations.html#prototype_function_fetchfromremote) is called.  `Batman.AssocationProxy` subclasses must implement this method.

## ::fetchFromRemote() : Model
If [`fetchFromLocal`](/docs/api/batman.model_associations.html#prototype_function_fetchfromlocal) returns a falsy value, this method is called by [`load`](/docs/api/batman.model_associations.html#prototype_function_load) to fetch the [`target`](/docs/api/batman.model_associations.html#prototype_accessor_target) record. `Batman.AssocationProxy` subclasses must implement this method.


## Association Options
All assocations have a common set of options, as well as specific options for each type of relationship.

##### `primaryKey[= "id"] : string`
The primary key for the association.

##### `foreignKey[= "#{label}_id"] : string`
The foreign key for the association.

##### `saveInline[= true] : boolean`
If true, this model's attributes will be included in the associated model's JSON. This means that when an associated record is saved, this record's attributes will be included in the JSON.

##### `autoload[= true] : boolean`
If `true`, Batman will automatically call `load` when the associated records are accessed. This is useful in view bindings, where binding to the associated records will automatically cause them to be loaded.

##### `nestUrl[= false] : boolean`
If `true`, this model's URL will be nested under the associated model:

```coffeescript
class App.ChildItem extends Batman.Model
  @belongsTo 'parentItem', nestUrl: true

# ...

child = new ChildItem(parent_id: 1, id: 5)
child.url() # => 'parent_items/1/child_items/5'
```

`nestUrl` only applies if the model is persisted with `Batman.RestStorage` (or a subclass).

##### `name : string`
By default, Batman checks for a model with this singular, camel-case name of association's `label` attached to `Batman.currentApp`. If the associated model is different from that, use `name` (and/or `namespace` to specify it.

```coffeescript
class App.ChildItem extends Batman.Model
  @belongsTo 'parentItem' # automatically finds App.ParentItem
  @belongsTo 'alternativeParentItem', name: 'ParentItem' # also finds App.ParentItem
```

##### `inverseOf : string`
The foreign association to set on load. If the associated model has an association with the same name as the `inverseOf` value, it will be populated when data is loaded from storage. For example:

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

##### `encoderKey[= label] : string`
Key where attributes for associated records will be found.

```coffeescript
class App.ParentItem extends Batman.Model
  @hasMany 'childItems', encoderKey: 'children'
```

will correctly decode this JSON:

```javascript
{id: 1, children: [{ id: 5, parent_id: 1 }, {id: 6, parent_id: 1}]}
```

It will also encode the `childItems` as `children` (unless `saveInline` is set to `false`).

##### `namespace[= Batman.currentApp] : string`
Batman expects to find a model with the given `name` on `Batman.currentApp`. If your model is defined elsewhere, use `namespace` to specify where the model is defined.

```coffeescript
class App.Admin.Person extends Batman.Model
  @belongsTo 'organization', namespace: App.Admin # finds App.Admin.Organization instead of App.Organization
```

## Polymorphic Association Options
Batman also supports [polymorphic associations](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations). For example:

```coffeescript
class App.Superpower extends Batman.Model
  @encode 'name'
  @belongsTo 'superpowerable', polymorphic: true

class App.Hero extends Batman.Model
  @hasMany 'superpowers', as: 'superpowerable', polymorphic: true

class App.Villain extends Batman.Model
  @hasMany 'superpowers', as: 'superpowerable', polymorphic: true
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

##### `polymorphic[= false] : boolean`
Whether the association is [polymorphic](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations).

##### `as : string`
Specifies the name of the polymorphic interface.

##### `foreignTypeKey[= "#{label}_type"] : string`
Specifies the field which contains the `type` for a polymorphic record.

##### `encodeForeignTypeKey[=true] : boolean`
Specifies whether the `foreignTypeKey` should be included in the JSON of the record.
