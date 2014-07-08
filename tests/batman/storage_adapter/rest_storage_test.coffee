helpers = window.restStorageHelpers

oldRequest = Batman.Request

QUnit.module "Batman.RestStorage",
  setup: ->
    Batman.Request = helpers.MockRequest
    helpers.MockRequest.reset()

    class @Product extends Batman.Model
      @encode 'name', 'cost'
    @adapter = new Batman.RestStorage(@Product)
    @Product.persist @adapter

  teardown: ->
    Batman.Request = oldRequest

helpers.testOptionsGeneration()
helpers.run()


QUnit.module 'Batman.Model.urlNestsUnder for deep nesting',
  setup: ->
    class @Product extends Batman.Model
      @persist Batman.RestStorage
      @urlNestsUnder ['shop', 'manufacturer'], 'order'

test 'urlNestsUnder should deeply nest collection URLs', 1, ->
  equal @Product.url(data: shop_id: 1, manufacturer_id: 2), 'shops/1/manufacturers/2/products'

test 'urlNestsUnder should not deeply nest collection URLs if one of deep nesting parents is missing', 1, ->
  equal @Product.url(data: shop_id: 1, order_id: 1), 'orders/1/products'

test 'urlNestsUnder should deeply nest record URLs', 1, ->
  product = new @Product(id:1, shop_id: 2, manufacturer_id: 3)
  equal product.url(), 'shops/2/manufacturers/3/products/1'

test 'urlNestsUnder should not deeply nest record URLs if one of the deep nesting parents is missing', 1, ->
  product = new @Product(id:1, shop_id: 1, order_id: 2)
  equal product.url(), 'orders/2/products/1'

test 'urlNestsUnder allows no nesting for records', ->
  product = new @Product(id: 6)
  equal product.url(), 'products/6'

test 'urlNestsUnder allows no nesting for collection', ->
  equal @Product.url(), 'products'
