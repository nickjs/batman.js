# /api/App Components/Batman.StorageAdapter/Batman.RestStorage

`Batman.RestStorage` connects `Batman.Model`s to a web server via [HTTP REST](https://en.wikipedia.org/wiki/Representational_state_transfer). `Batman.Request` is used to send AJAX requests.

Use `Batman.RestStorage` by passing it to `@persist` in a model definition:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RestStorage
```

`Batman.RestStorage` requires a platform implementation library for `Batman.Request`.

## Using Custom URLs with Batman.RestStorage

There are many ways to customize the URLs for records and collections that are persisted with `Batman.RestStorage`.

For __collections__, you can define `@url` as a string _or_ function in the model definition:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RestStorage
  @url: "/api/v1/my_models"

class MyApp.OtherModel extends Batman.Model
  @persist Batman.RestStorage
  @url: (options) ->  "/api/v1/other_models"
```

See also [`@urlNestsUnder`](/docs/api/batman.reststorage.html#class_function_urlnestsunder) for nested URL helpers.

You can also specify a URL at load-time. For example:

```coffeescript
MyApp.MyModel.load {url: "/my_models/latest"}, (err, records) -> # ...
```

For __records__, you can also specify a prototype property `url` in the model definition:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RestStorage
  url: "/api/v1/my_models" # `/:id` will be added by Batman.RestStorage

class MyApp.OtherModel extends Batman.Model
  @persist Batman.RestStorage
  url: ->  "/api/v1/other_models" # `/:id` will be added by Batman.RestStorage
```

You can also specify a URL on a record instance. For example:

```coffeescript
myRecord = new MyApp.MyModel
myRecord.url = "/special/endpoint"
myRecord.save() # will use `/special/endpoint`
```

You can also specify a URL at operation-time. For example:

```coffeescript
myRecord = new MyApp.MyModel
myRecord.save {url: "/special/endpoint"}, (err, record) -> # ...
```

[`@urlNestsUnder`](/docs/api/batman.reststorage.html#class_function_urlnestsunder) also generates nested URLs for records.

## ::.serializeAsForm[= true] : Boolean

By default, `Batman.RestStorage` sends data as `'application/x-www-form-urlencoded'`. To send as `'application/json'`, pass `serializeAsForm: false` to `@persist`:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RestStorage, serializeAsForm: false
```

## ::urlForCollection(model, env) : String

Returns a collection URL for `model` by checking:

- `env.options.collectionUrl`
- `model.url` (can be defined as a string or function, see "Model Mixin" below)
- `model.storageKey`
- `model.resourceName`

## ::urlForRecord(record, env) : String

Returns a URL for `record` by checking:

- `env.options.recordUrl`
- `record.url` (can be defined as a string or function, see "Model Mixin" below)
- `urlForCollection` plus `/:id`

## Model Mixin

These functions are added to models that are persisted with `Batman.RestStorage`.

## @urlNestsUnder(nestings...)

Nest the given model under one or more other resources. A `nesting` can be:

- a string resource name
- an array of resource names

A resource name normally corresponds to a model attribute with the same name suffixed with `_id`. If it is an array, it defines a deeply nested resource.

The order of the nestings define the precedence, which means the __first__ nesting where all necessary `_id` attributes are present is used to produce the url. If none of nestings can be satisfied, it falls back to the default url.

    test 'defining url nesting', ->
      class Product extends Batman.Model
        @persist Batman.RestStorage
        @urlNestsUnder ['shop', 'manufacturer'], 'order'

      equal Product.url(data: shop_id: 1, manufacturer_id: 2), 'shops/1/manufacturers/2/products'
      equal (new Product(shop_id: 1, manufacturer_id: 2, id: 3)).url(), 'shops/1/manufacturers/2/products/3'
      equal Product.url(data: shop_id: 1, order_id: 2), 'orders/2/products'
      equal (new Product(shop_id: 1, order_id: 2, id: 3)).url(), 'orders/2/products/3'
      equal Product.url(data: shop_id: 1), 'products'
      equal (new Product(shop_id: 1, id: 2)).url(), 'products/2'

## @url(options) : String

Returns the URL for model. `options` are the options passed to the storage operation which triggered the call. You can also override `@url` as a string.

## ::url() : String

Returns the URL for the record. You can also override `::url` as a string on the prototype or on specific instances.
