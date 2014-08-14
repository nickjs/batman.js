{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter} = window
helpers = window.viewHelpers

QUnit.module "Batman.Model belongsTo Associations",
  setup: ->
    namespace = @namespace = this
    class @Store extends Batman.Model
      @encode 'id', 'name'

    @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
      'stores1':
        name: "Store One"
        id: 1
      'stores2':
        name: "Store Two"
        id: 2
        product:
          id:3
          name:"JSON Product"
      'stores3':
        name: "Store Three"
        id: 3

    class @Collection extends Batman.Model
      @encode 'id', 'name'
    @collectionAdapter = createStorageAdapter @Collection, AsyncTestStorageAdapter

    class @Product extends Batman.Model
      @encode 'id', 'name'
      @belongsTo 'store', namespace: namespace
      @belongsTo 'collection', namespace: namespace
    @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
      'products1':
        name: "Product One"
        id: 1
        store_id: 1
      'products4':
        name: "Product One"
        id: 1
        store:
          name: "Store Three"
          id: 3
      'products5':
        name: "Product Five"
        id: 5
        store: null


asyncTest "belongsTo associations are loaded and custom url is used", 2, ->
  @Product._batman.get('associations').get('store').options.url = '/product/store'
  associationSpy = spyOn(@storeAdapter, 'perform')
  @Product.find 1, (err, product) =>
    throw err if err
    store = product.get 'store'
    delay ->
      equal associationSpy.lastCallArguments[2].recordUrl, '/product/store'
      equal associationSpy.callCount, 1

asyncTest "belongsTo associations are loaded via ID", 1, ->
  @Product.find 1, (err, product) =>
    throw err if err
    product.get('store').load (err, store) ->
      throw err if err
      equal store.get('id'), 1
      QUnit.start()

asyncTest "::load returns a promise that resolves with the record", 1, ->
  @Product.find 1, (err, product) =>
    throw err if err
    product.get('store').load()
      .then (store) ->
        equal store.get('id'), 1
      .then ->
        QUnit.start()

asyncTest "belongsTo associations are not loaded when autoload is off", 1, ->
  namespace = @
  class @Product extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', {namespace, autoload: false}

  productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
    'products1': {name: "Product One", id: 1, store_id: 1}

  @Product.find 1, (err, product) =>
    store = product.get 'store'
    delay ->
      ok !store.get('loaded'), "The store wasn't loaded automatically"

asyncTest "belongsTo associations with autoload is off put the record at the property when loaded", 3, ->
  namespace = @
  class @Product extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', {namespace, autoload: false}

  productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
    'products1': {name: "Product One", id: 1, store_id: 1}

  @Product.find 1, (err, product) =>
    product.get('store').load (err, store) =>
      throw err if err
      ok product.get('store.target') instanceof @Store
      ok product.get('store.loaded') == true
      equal product.get('lifecycle.state'), 'clean'
      QUnit.start()

asyncTest "belongsTo association proxies index the local loaded set when autoload is off", 3, ->
  namespace = @
  class @Product extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', {namespace, autoload: false}

  productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
    'products1': {name: "Product One", id: 1, store_id: 1}

  @Product.find 1, (err, product) =>
    store = product.get 'store'
    ok store instanceof Batman.BelongsToProxy
    ok !store.get('loaded')
    @Store.load (err) =>
      throw err if err
      store = product.get 'store'
      ok store instanceof Batman.BelongsToProxy, "it returns a proxy even after loaded"
      QUnit.start()

asyncTest "belongsTo associations are saved", 6, ->
  store = new @Store id: 1, name: 'Zellers'
  collection = new @Collection id: 2, name: 'Awesome Things'
  product = new @Product name: 'Gizmo'
  product.set 'store', store
  product.set 'collection', collection

  product.save (err, record) =>
    throw err if err
    equal record.get('store_id'), store.get('id')
    equal record.get('collection_id'), collection.get('id')
    storedJSON = @productAdapter.storage["products#{record.get('id')}"]
    deepEqual storedJSON, product.toJSON()

    store = record.get('store')
    equal storedJSON.store_id, 1
    equal storedJSON.collection_id, 2

    @Product.find record.get('id'), (err, product2) ->
      throw err if err
      deepEqual product2.toJSON(), storedJSON
      QUnit.start()

test "belongsTo associations don't encode their foreignKeys if not asked to", ->
  class Product extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', {namespace: @namespace, autoload: false, encodeForeignKey: false}

  @product = new Product(id: 1, name: "Chair", store_id: 1)
  deepEqual @product.toJSON(), {id: 1, name: "Chair"}

asyncTest "belongsTo associations decode null inline", ->
  @Product.find 5, (err, product) =>
    equal null, product.get('store.target')
    QUnit.start()

asyncTest "belongsTo parent models are added to the identity map", 1, ->
  @Product.find 4, (err, product) =>
    throw err if err
    equal @Store.get('loaded').length, 1
    QUnit.start()

asyncTest "belongsTo parent models are passed through the identity map", 2, ->
  @Store.find 3, (err, store) =>
    throw err if err
    @Product.find 4, (err, product) =>
      equal @Store.get('loaded').length, 1
      ok product.get('store') == store
      QUnit.start()

asyncTest "belongsTo yields the related model when toJSON is called", 1, ->
  @Product.find 1, (err, product) =>
    store = product.get('store')
    delay =>
      storeJSON = store.toJSON()
      # store will encode its product
      delete storeJSON.product

      deepEqual storeJSON, @storeAdapter.storage["stores1"]

asyncTest "belongsTo associations render", 1, ->
  @Product.find 1, (err, product) ->
    source = '<span data-bind="product.store.name"></span>'
    context = Batman(product: product)
    helpers.render source, context, (node) =>
      delay ->
        equal node[0].innerHTML, 'Store One'

asyncTest "belongsTo supports inline saving", 1, ->
  namespace = this
  class @InlineProduct extends Batman.Model
    @encode 'name'
    @belongsTo 'store', namespace: namespace, saveInline: true
    @belongsTo 'collection', namespace: namespace, saveInline: true
  storageAdapter = createStorageAdapter @InlineProduct, AsyncTestStorageAdapter

  product = new @InlineProduct name: "Inline Product"
  store = new @Store name: "Inline Store"
  collection = new @Collection name: "Inline Collection"
  product.set 'store', store
  product.set 'collection', collection

  product.save (err, record) =>
    deepEqual storageAdapter.storage["inline_products#{record.get('id')}"],
      name: "Inline Product"
      store: {name: "Inline Store"}
      collection: {name: "Inline Collection"}
    QUnit.start()

asyncTest "belongsTo supports custom foreign keys", 1, ->
  ns = @
  class Shirt extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', namespace: ns, foreignKey: 'shop_id'

  shirtAdapter = createStorageAdapter Shirt, AsyncTestStorageAdapter,
    'shirts1':
      id: 1
      name: 'Shirt One'
      shop_id: 1

  Shirt.find 1, (err, shirt) ->
    store = shirt.get('store')
    delay ->
      equal store.get('name'), 'Store One'

test "belongsTo supports custom proxy classes", 1, ->
  namespace = @
  class CoolBelongsToProxy extends Batman.BelongsToProxy
  class Shirt extends Batman.Model
    @encode 'id'
    @belongsTo 'store', namespace: namespace, extend: {proxyClass: CoolBelongsToProxy}

  shirt = new Shirt()
  ok shirt.get('store') instanceof CoolBelongsToProxy

QUnit.module "Batman.Model belongsTo Associations with inverseOf to a hasMany",
  setup: ->
    namespace = @namespace = this

    class @Order extends Batman.Model
      @encode 'id', 'name'
      @belongsTo 'customer', {namespace: namespace, inverseOf: 'orders'}

    @orderAdapter = createStorageAdapter @Order, AsyncTestStorageAdapter,
      'orders1':
        name: "Order One"
        id: 1
        customer:
          name: "Customer One"
          id: 1
      'orders2':
        name: "Order Two"
        id: 2
        customer:
          name: "Customer One"
          id: 1

    class @Customer extends Batman.Model
      @encode 'id', 'name'
      @hasMany 'orders', namespace: namespace

    @customerAdapter = createStorageAdapter @Customer, AsyncTestStorageAdapter,
      'customers1':
        name: "Customer One"
        id: 1

asyncTest "belongsTo sets the foreign key on itself so the parent relation SetIndex adds it, if the parent hasn't been loaded", 1, ->
  @Order.find 1, (err, order) =>
    throw err if err
    order.get('customer').load (err, customer) ->
      throw err if err
      ok customer.get('orders').has(order)
      QUnit.start()

asyncTest "belongsTo sets the foreign key on itself so the parent relation SetIndex adds it, if the parent has already been loaded", 1, ->
  @Customer.find 1, (err, customer) =>
    throw err if err
    @Order.find 1, (err, order) =>
      throw err if err
      customer = order.get('customer').load (err, customer) ->
        throw err if err
        ok customer.get('orders').has(order)
        QUnit.start()

asyncTest "belongsTo sets the foreign key on itself such that many loads are picked up by the parent", 3, ->
  @Customer.find 1, (err, customer) =>
    throw err if err
    @Order.find 1, (err, order) =>
      throw err if err
      equal customer.get('orders').length, 1
      @Order.find 2, (err, order) =>
        throw err if err
        equal customer.get('orders').length, 2
        equal @Customer.get('loaded').length, 1, 'Only one parent record should be created'
        QUnit.start()

QUnit.module "Batman.Model belongsTo Associations with inverseOf to a hasOne",
  setup: ->
    namespace = @

    class @Order extends Batman.Model
      @encode 'id', 'name'
      @belongsTo 'customer', {namespace: namespace, inverseOf: 'order'}

    @orderAdapter = createStorageAdapter @Order, AsyncTestStorageAdapter,
      'orders1':
        name: "Order One"
        id: 1
        customer:
          name: "Customer One"
          id: 1

    class @Customer extends Batman.Model
      @encode 'id', 'name'
      @hasOne 'order', {namespace: namespace}

    @customerAdapter = createStorageAdapter @Customer, AsyncTestStorageAdapter,
      'customers1':
        name: "Customer One"
        id: 1

asyncTest "belongsTo sets the inverse relation if the parent hasn't been loaded", 1, ->
  @Order.find 1, (err, order) =>
    throw err if err
    customer = order.get('customer')
    ok customer.get('order') == order
    QUnit.start()

asyncTest "belongsTo sets the inverse relation if the parent has already been loaded", 1, ->
  @Customer.find 1, (err, customer) =>
    throw err if err
    @Order.find 1, (err, order) =>
      throw err if err
      customer = order.get('customer')
      ok customer.get('order') == order
      QUnit.start()
