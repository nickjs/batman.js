# /api/App Components/Batman.StorageAdapter/Batman.RestStorage

`Batman.RestStorage` connects `Batman.Model`s to a web server via [HTTP REST](https://en.wikipedia.org/wiki/Representational_state_transfer). `Batman.Request` is used to send AJAX requests.

Use `Batman.RestStorage` by passing it to `@persist` in a model definition:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RestStorage
```

`Batman.RestStorage` requires a platform implementation library for `Batman.Request`.


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
