{TestStorageAdapter} = if typeof require isnt 'undefined' then require './model_helper' else window

QUnit.module "Batman.Model",
  setup: ->
    class @Product extends Batman.Model

test "constructors should always be called with new", ->
  Product = @Product
  raises (-> product = Product()),
    (message) -> ok message; true

  Namespace = Product: Product
  raises (-> product = Namespace.Product()),
    (message) -> ok message; true

  product = new Namespace.Product()
  ok product instanceof Product

test "properties can be stored", ->
  product = new @Product
  product.set('foo', 'bar')
  equal product.get('foo'), 'bar'

test "falsey properties can be stored", ->
  product = new @Product
  product.set('foo', false)
  equal product.get('foo'), false

test "primary key is undefined on new models", ->
  product = new @Product
  ok product.isNew()
  ok product.get('isNew')
  equal typeof product.get('id'), 'undefined'

test "primary key is 'id' by default", ->
  product = new @Product(id: 10)
  equal product.get('id'), 10

test "integer string ids should be coerced into integers", 1, ->
  product = new @Product(id: "1234")
  strictEqual product.get('id'), 1234

test "non-integer string ids should not be coerced", 1, ->
  product = new @Product(id: "123d")
  strictEqual product.get('id'), "123d"

test "updateAttributes will update a model's attributes", ->
  product = new @Product(id: 10)
  product.updateAttributes {name: "foobar", id: 20}
  equal product.get('id'), 20
  equal product.get('name'), "foobar"

test "updateAttributes will returns the updated record", ->
  product = new @Product(id: 10)
  equal product, product.updateAttributes {name: "foobar", id: 20}

test "createFromJSON will create a record using encoders", ->
  @Product.encode 'name', 'id'

  product = @Product.createFromJSON(name: 'Test', id: 1, description: '  ')
  ok product instanceof @Product
  equal product.get('id'), 1
  equal product.get('name'), 'Test'
  equal product.get('description'), undefined

test "createFromJSON leaves the record clean", ->
  @Product.encode 'name', 'id'

  product = @Product.createFromJSON(name: 'Test', id: 1, description: '  ')
  equal product.get('lifecycle.state'), 'clean'
  equal product.get('dirtyKeys').length, 0

test "createFromJSON will return an existing instance if in the identity map", ->
  @Product.encode 'name', 'id'

  product = @Product.createFromJSON(name: 'Test', id: 1, description: '  ')

  otherProduct = @Product.createFromJSON(id: 1)
  strictEqual product, otherProduct

test "primary key can be changed by setting primary key on the model class", ->
  @Product.set 'primaryKey', 'uuid'
  product = new @Product(uuid: "abc123")
  equal product.get('id'), 'abc123'

test 'the \'lifecycle.state\' key should be bindable', ->
  p = new @Product()
  equal p.get('lifecycle.state'), "clean"

  p.observe 'lifecycle.state', spy = createSpy()
  p.set('unrelatedkey', 'silly')
  ok spy.called

test 'bindable isDirty should correctly reflect an object\`s dirtiness', ->
  p = new @Product()
  equal p.get('lifecycle.state'), 'clean'
  ok !p.get('isDirty')
  p.set('waffle', 'tasty')
  equal p.get('lifecycle.state'), 'dirty'
  ok p.get('isDirty')

test 'the instantiated storage adapter should be returned when persisting', ->
  returned = false
  class StorageAdapter extends Batman.StorageAdapter
    isTestStorageAdapter: true

  class Product extends Batman.Model
    returned = @persist StorageAdapter

  ok returned.isTestStorageAdapter

test 'options passed to persist should be mixed in to the storage adapter once instantiated', ->
  returned = false
  class StorageAdapter extends Batman.StorageAdapter
    isTestStorageAdapter: true

  class Product extends Batman.Model
     @persist StorageAdapter, {foo: 'bar'}, {corge: 'corge'}

  equal Product.storageAdapter().foo, 'bar'
  equal Product.storageAdapter().corge, 'corge'

  class Order extends Batman.Model
  adapter = new StorageAdapter(Order)
  Order.persist adapter, {baz: 'qux'}
  equal adapter.baz, 'qux'

test "get('resourceName') should use the class level resourceName property", ->
  class Product extends Batman.Model
    @resourceName: 'foobar'

  equal Product.get('resourceName'), 'foobar'

test "get('resourceName') should use the prototype level resourceName property", ->
  oldError = Batman.developer
  Batman.developer.error = createSpy()

  class Product extends Batman.Model
    resourceName: 'foobar'

  equal Product.get('resourceName'), 'foobar'
  Batman.developer.error = oldError

test "get('resourceName') should use the function name failing all else", ->
  class Product extends Batman.Model
  equal Product.get('resourceName'), 'product'

QUnit.module "Batman.Model class clearing",
  setup: ->
    class @Product extends Batman.Model
      @encode 'name', 'cost'

    @adapter = new TestStorageAdapter(@Product)
    @adapter.storage =
      'products1': {name: "One", cost: 10, id:1}

    @Product.persist @adapter

asyncTest 'clearing the model should remove instances from the identity map', ->
  @Product.load =>
    equal @Product.get('loaded.length'), 1
    @Product.clear()
    equal @Product.get('loaded.length'), 0
    QUnit.start()

asyncTest 'model will reload data from storage after clear', ->
  @Product.find 1, (e, p) =>
    equal p.get('cost'), 10
    @adapter.storage =
      'products1': {name: "One", cost: 20, id:1}
    @Product.clear()
    p.load (e, p) =>
      equal p.get('cost'), 20
      QUnit.start()

test "class promise accessors will be recalculated after clear", ->
  i = 0
  @Product.classAccessor 'promise', promise: (deliver) -> deliver(null, i++)
  equal @Product.get('promise'), 0
  @Product.clear()
  equal @Product.get('promise'), 1

QUnit.module 'Batman.Model.urlNestsUnder',
  setup: ->
    class @Product extends Batman.Model
      @persist Batman.RestStorage
      @urlNestsUnder 'shop', 'manufacturer'

test 'urlNestsUnder should nest collection URLs', 1, ->
  equal @Product.url(data: shop_id: 1), 'shops/1/products'

test 'urlNestsUnder should nest collection URLs under secondary parents if present', 1, ->
  equal @Product.url(data: manufacturer_id: 1), 'manufacturers/1/products'

test 'urlNestsUnder should nest collection URLs under the first available parent', 1, ->
  equal @Product.url(data: manufacturer_id: 1, shop_id: 2), 'shops/2/products'

test 'urlNestsUnder should nest record URLs', 1, ->
  product = new @Product(id: 1, shop_id: 2)
  equal product.url(), 'shops/2/products/1'

test 'urlNestsUnder should nest new record URLs', 1, ->
  product = new @Product(shop_id: 1)
  equal product.url(), 'shops/1/products'

test 'urlNestsUnder should nest record URLs under secondary parents if present', 1, ->
  product = new @Product(id:1, manufacturer_id: 2)
  equal product.url(), 'manufacturers/2/products/1'

test 'urlNestsUnder should nest record URLs under the first available parent', 1, ->
  product = new @Product(id:1, shop_id: 2, manufacturer_id: 3)
  equal product.url(), 'shops/2/products/1'
