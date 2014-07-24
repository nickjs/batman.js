{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = window
helpers = window.viewHelpers

QUnit.module "Batman.Model hasMany Associations",
  setup: ->
    Batman.currentApp = null
    namespace = @namespace = {}

    namespace.Store = class @Store extends Batman.Model
      @encode 'id', 'name'
      @hasMany 'products', namespace: namespace, saveInline: true
      @hasMany 'stringyProducts', namespace: namespace, saveInline: true

    @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
      stores1:
        name: "Store One"
        id: 1

    namespace.StringyProduct = class @StringyProduct extends Batman.Model
      coerceIntegerPrimaryKey: false
      @encode 'id' # they're gonna be integer-y strings: "1", "2", etc
      @encode 'price'
      @belongsTo 'store', namespace: namespace, inverseOf: "stringyProducts"

    @stringyProductsAdapter = createStorageAdapter @StringyProduct, AsyncTestStorageAdapter,
      stringy_product1:
        store_id: 1
        id: "1"
        price: 55
      stringy_product2:
        store_id: 1
        id: "2"
        price: 60
      stringy_product3:
        store_id: 1
        id: "15"
        price: 65

    namespace.Product = class @Product extends Batman.Model
      @encode 'id', 'name'
      @belongsTo 'store', namespace: namespace
      @hasMany 'productVariants', namespace: namespace, saveInline: true, encodeWithIndexes: true

    @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
      products1:
        name: "Product One"
        id: 1
        store_id: 1
        productVariants: [{
          id:3
          price:50
          product_id:1
        },{
          id:4
          price:60
          product_id:1
        }]
      products2:
        name: "Product Two"
        id: 2
        store_id: 1
        productVariants: [{
          id:1
          price:50
          product_id:2
        },{
          id:2
          price:60
          product_id:2
        }]
      products3:
        name: "Product Three"
        id: 3
        store_id: 1
        productVariants: [{
          id:5
          price:50
          product_id:3
        },{
          id:6
          price:60
          product_id:3
        }]

    namespace.ProductVariant = class @ProductVariant extends Batman.Model
      @encode 'id', 'price'
      @belongsTo 'product', namespace: namespace

    @variantsAdapter = createStorageAdapter @ProductVariant, AsyncTestStorageAdapter,
      product_variants1:
        id:1
        price:50
        product_id:2
      product_variants2:
        id:2
        price:60
        product_id:2
      product_variants3:
        id:3
        price:50
        product_id:1
      product_variants4:
        id:4
        price:60
        product_id:1
      product_variants5:
        id:5
        price:50
        product_id:3
      product_variants6:
        id:6
        price:60
        product_id:3

asyncTest "::build returns a new child with foreignKey set and attrs mixed in ", 3 , ->
  @Store.find 1, (err, store) ->
    throw err if err?
    store.get('products')
    delay =>
      newProduct = store.get('products').build(name: "Product X")
      equal newProduct.constructor.name, "Product"
      equal newProduct.get('store_id'), 1
      equal newProduct.get('name'), "Product X"

asyncTest "::build adds the child to the set", 2, ->
  @Store.find 1, (err, store) ->
    store.get('products')
    delay =>
      equal store.get('products.length'), 3
      store.get('products').build(name: "Product Y")
      equal store.get('products.length'), 4

asyncTest "::build uses currentApp if no namespace was passed", ->
  Batman.currentApp = @
  @Store.find 1, (err, store) ->
    store.reflectOnAssociation("products").options.namespace = null
    store.get('products')
    delay =>
      newProduct = store.get('products').build(name: "Product X")
      equal newProduct.get('store_id'), 1
      Batman.currentApp = null

asyncTest "::%parentRecord returns the parent record", 1, ->
  @Store.find 1, (err, store) ->
    products = store.get('products')
    delay =>
      parent = products.get('parentRecord')
      ok parent is store

asyncTest "hasMany associations are loaded and custom url is used", 2, ->
  @Store._batman.get('associations').get('products').options.url = "/stores/1/products"
  associationSpy = spyOn(@productAdapter, 'perform')

  @Store.find 1, (err, store) =>
    products = store.get 'products'
    delay ->
      equal associationSpy.lastCallArguments[2].collectionUrl, '/stores/1/products'
      equal associationSpy.callCount, 1

asyncTest "hasMany associations are loaded and custom url function has the parent's context", 3, ->
  @Store._batman.get('associations').get('products').options.url = -> "/stores/#{@get('id')}/products"

  associationSpy = spyOn(@productAdapter, 'perform')

  @Store.find 1, (err, store) =>
    products = store.get 'products'
    delay ->
      equal typeof associationSpy.lastCallArguments[2].collectionUrl, 'function'
      ok associationSpy.lastCallArguments[2].urlContext is store
      equal associationSpy.callCount, 1

asyncTest "hasMany associations are loaded", 4, ->
  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get 'products'
    delay =>
      products.forEach (product) => ok product instanceof @Product
      deepEqual products.map((x) -> x.get('id')), [1,2,3]

asyncTest "AssociationSet fires loaded event and sets loaded accessor", 2, ->
  @Store.find 1, (err, store) ->
    equal store.get('products').get('loaded'), false
    store.get('products').on 'loaded', ->
      equal store.get('products').get('loaded'), true
      QUnit.start()

asyncTest "AssociationSet becomes loaded when a new record is saved", 2, ->
  store = new @Store(name: "Test")

  equal store.get('products').get('loaded'), false
  store.save =>
    equal store.get('products').get('loaded'), true
    QUnit.start()

test "AssociationSet becomes loaded when the parent record is decoded", 1, ->
  product = new @Product
  product.fromJSON
    name: "Product One"
    id: 1
    store_id: 1
    productVariants: [
      {id:3, price:50,product_id:1},
      {id:4, price:60, product_id:1}
    ]
  variants = product.get 'productVariants'
  ok variants.get('loaded')

asyncTest "AssociationSet does not become loaded when an existing record is saved and the response includes no information about the association", 2, ->
  namespace = @
  namespace.Store = class @Store extends Batman.Model
    @encode 'id', 'name'
    @hasMany 'products', namespace: namespace, autoload: false

  @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
    stores1:
      name: "Store One"
      id: 1

  @Store.find 1, (err, store) ->
    equal store.get('products').get('loaded'), false
    store.save (err, store) ->
      equal store.get('products').get('loaded'), false
      QUnit.start()

asyncTest "AssociationSet:mappedTo returns a SetMapping", ->
  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get 'products'
    delay =>
      productIds = products.get('mappedTo.id')
      deepEqual productIds.toArray(), [1,2,3]

asyncTest "hasMany associations are loaded using encoders", 1, ->
  @Product.encode 'name',
    encode: (x) -> x
    decode: (x) -> x.toUpperCase()

  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get 'products'
    delay ->
      deepEqual products.map((x) -> x.get('name')), ["PRODUCT ONE", "PRODUCT TWO", "PRODUCT THREE"]

asyncTest "associations loaded via encoders index the child record loaded set", 2, ->
  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get 'products'
    delay =>
      equal products.length, 3
      @Product.createFromJSON(id: 100, name: 'New!', store_id: 1)
      equal products.length, 4

asyncTest "embedded hasMany associations are loaded using encoders", 1, ->
  @ProductVariant.encode 'price',
    encode: (x) -> x
    decode: (x) -> x * 100

  @Product.find 3, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    deepEqual variants.map((x) -> x.get('price')), [5000, 6000]
    QUnit.start()

asyncTest "embedded associations loaded via encoders index the child record loaded set", 3, ->
  @Product.find 2, (err, product) =>
    throw err if err
    variants = product.get 'productVariants'
    equal variants.length, 2
    variant = @ProductVariant.createFromJSON(id: 100, price: 20.99, product_id: 2)
    equal variants.length, 3
    @ProductVariant.get('loaded').remove(variant)
    equal variants.length, 2
    QUnit.start()

test "embedded associations loaded via encoders index the child record loaded set when the parent is decoded all at once", 2, ->
  product = new @Product
  product.fromJSON
    name: "Product One"
    id: 1
    store_id: 1
    productVariants: [
      {id:3, price:50,product_id:1},
      {id:4, price:60, product_id:1}
    ]
  variants = product.get 'productVariants'
  equal variants.length, 2
  @ProductVariant.createFromJSON(id: 100, price: 20.99, product_id: 1)
  equal variants.length, 3

asyncTest "hasMany associations are not loaded when autoload is false", 1, ->
  ns = @namespace
  class Store extends Batman.Model
    @encode 'id', 'name'
    @hasMany 'products', {namespace: ns, autoload: false}

  storeAdapter = createStorageAdapter Store, AsyncTestStorageAdapter,
    stores1:
      name: "Store One"
      id: 1

  Store.find 1, (err, store) =>
    throw err if err
    products = store.get 'products'
    delay =>
      equal products.length, 0

asyncTest "hasMany associations can be reloaded", 8, ->
  loadSpy = spyOn(@Product, 'loadWithOptions')
  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get('products')
    ok !products.loaded
    setTimeout =>
      ok products.loaded
      equal loadSpy.callCount, 1

      products.load (err, products) =>
        throw err if err
        equal loadSpy.callCount, 2
        products.forEach (product) => ok product instanceof @Product
        deepEqual products.map((x) -> x.get('id')), [1,2,3]
        QUnit.start()
    , ASYNC_TEST_DELAY

asyncTest "hasMany associations are saved via the parent model", 6, ->
  store = new @Store name: 'Zellers'
  product1 = new @Product name: 'Gizmo'
  product2 = new @Product name: 'Gadget'
  store.set 'products', new Batman.Set([product1, product2])

  storeSaveSpy = spyOn store, 'save'
  store.save (err, record) =>
    throw err if err
    equal storeSaveSpy.callCount, 1
    equal product1.get('store_id'), record.get('id')
    equal product2.get('store_id'), record.get('id')

    @Store.find record.get('id'), (err, store2) =>
      throw err if err
      storedJSON = @storeAdapter.storage["stores#{record.get('id')}"]
      deepEqual store2.toJSON(), storedJSON
      sorter = generateSorterOnProperty('name')

      ok storedJSON.products instanceof Array, "hasMany serializes to Array by default"
      deepEqual sorter(storedJSON.products), sorter([
        {name: "Gizmo", store_id: record.get('id'), productVariants: {}}
        {name: "Gadget", store_id: record.get('id'), productVariants: {}}
      ])
      QUnit.start()

asyncTest "hasMany associations are saved via the child model", 2, ->
  @Store.find 1, (err, store) =>
    throw err if err
    product = new @Product name: 'Gizmo'
    product.set 'store', store
    product.save (err, savedProduct) ->
      equal savedProduct.get('store_id'), store.get('id')
      products = store.get('products')
      ok products.has(savedProduct)
      QUnit.start()

asyncTest "hasMany association can be loaded from JSON data", 14, ->
  @Product.find 3, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    ok variants instanceof Batman.AssociationSet
    equal variants.length, 2

    variant5 = variants.toArray()[0]
    ok variant5 instanceof @ProductVariant
    equal variant5.get('id'), 5
    equal variant5.get('price'), 50
    equal variant5.get('product_id'), 3
    proxiedProduct = variant5.get('product')
    equal proxiedProduct.get('id'), product.get('id')
    equal proxiedProduct.get('name'), product.get('name')

    variant6 = variants.toArray()[1]
    ok variant6 instanceof @ProductVariant
    equal variant6.get('id'), 6
    equal variant6.get('price'), 60
    equal variant6.get('product_id'), 3
    proxiedProduct = variant6.get('product')
    equal proxiedProduct.get('id'), product.get('id')
    equal proxiedProduct.get('name'), product.get('name')

    QUnit.start()

asyncTest "hasMany associations loaded from JSON data should not do an implicit remote fetch", 3, ->
  variantLoadSpy = spyOn @variantsAdapter, 'readAll'

  @Product.find 3, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    ok variants instanceof Batman.AssociationSet
    delay =>
      equal variants.length, 2
      equal variantLoadSpy.callCount, 0

asyncTest "hasMany associations loaded from JSON should be reloadable", 2, ->
  @Product.find 3, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    ok variants instanceof Batman.AssociationSet
    variants.load (err, newVariants) =>
      throw err if err
      equal newVariants.length, 2
      QUnit.start()

asyncTest "hasMany associations loaded from JSON should index the loaded set like normal associations", 3, ->
  @Product.find 3, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    ok variants instanceof Batman.AssociationSet
    equal variants.get('length'), 2
    variant = new @ProductVariant(product_id: 3, name: "Test Variant")
    variant.save (err) ->
      throw err if err
      equal variants.get('length'), 3
      QUnit.start()

asyncTest "hasMany child models are added to the identity map", 2, ->
  equal @ProductVariant.get('loaded').length, 0
  @Product.find 3, (err, product) =>
    equal @ProductVariant.get('loaded').length, 2
    QUnit.start()

asyncTest "unsaved hasMany models should accept associated children", 2, ->
  product = new @Product
  variants = product.get('productVariants')
  delay =>
    equal variants.length, 0
    variant = new @ProductVariant
    variants.add variant
    equal variants.length, 1

asyncTest "unsaved hasMany models should save their associated children", 4, ->
  product = new @Product(name: "Hello!")
  variants = product.get('productVariants')
  variant = new @ProductVariant(price: 100)
  variants.add variant

  # Mock out what a realbackend would do: assign ids to the child records
  # The TestStorageAdapter is smart enough to do this for the parent, but not the children.
  @productAdapter.create = (record, options, callback) ->
    id = @_setRecordID(record)
    if id
      @storage[@storageKey(record) + id] = record.toJSON()
      record.fromJSON
        id: id
        productVariants: [{
          product_id: id
          price: 100
          id: 11
        }]
      callback(undefined, record)
    else
      callback(new Error("Couldn't get record primary key."))

  product.save (err, product) =>
    throw err if err
    storedJSON = @productAdapter.storage["products#{product.get('id')}"]
    deepEqual storedJSON,
      id: 11
      name: "Hello!"
      productVariants:{
        '0': {price: 100, product_id: product.get('id')}
      }

    ok !product.isNew()
    ok !variant.isNew()
    equal variant.get('product_id'), product.get('id')
    QUnit.start()

asyncTest "unsaved hasMany models should reflect their associated children after save", 3, ->
  product = new @Product(name: "Hello!")
  variants = product.get('productVariants')
  variant = new @ProductVariant(price: 100)
  variants.add variant

  # Mock out what a realbackend would do: assign ids to the child records
  # The TestStorageAdapter is smart enough to do this for the parent, but not the children.
  @productAdapter.create = (record, options, callback) ->
    id = @_setRecordID(record)
    if id
      @storage[@storageKey(record) + id] = record.toJSON()
      record.fromJSON
        id: id
        productVariants: [{
          product_id: id
          price: 100
          id: 11
        }]
      callback(undefined, record)
    else
      callback(new Error("Couldn't get record primary key."))

  product.save (err, product) =>
    throw err if err
    equal product.get('productVariants.length'), 1, "the product has the variant"
    ok product.get('productVariants').has(variant)
    equal variants.get('length'), 1, "the variant set has the variant"
    QUnit.start()

asyncTest "saved hasMany models who's related records have been removed should serialize the association as empty to notify the backend", ->
  @Product.find 3, (err, product) =>
    throw err if err
    ok product.get('productVariants').length
    product.get('productVariants').forEach (variant) ->
      variant.set('product_id', 10)

    equal product.get('productVariants').length, 0
    product.save (err) =>
      throw err if err
      deepEqual @productAdapter.storage['products3'], {id: 3, name: "Product Three", store_id: 1, productVariants: {}}
      QUnit.start()

asyncTest "unsaved hasMany models should decode their child records based on ID", ->
  @ProductVariant.load (err, variants) =>
    product = new @Product

    five = variants[0]
    six = variants[1]

    # decode with the variants out of order
    product.fromJSON
      name: "Product Three"
      id: 3
      store_id: 1
      productVariants: [{
        id:6
        price:60
        product_id:3
      },{
        id:5
        price:50
        product_id:3
      }]

    equal product.get('productVariants.length'), 2
    deepEqual product.get('productVariants').mapToProperty('id').sort(), [5,6]
    equal five.get('price'), 50
    equal six.get('price'), 60
    QUnit.start()

asyncTest "unsaved hasMany models should decode their existing child records based on ID", ->
  @ProductVariant.load (err, variants) =>
    product = new @Product
    for variant in variants when variant.get('id') in [5,6]
      product.get('productVariants').add(variant)

    five = product.get('productVariants').indexedByUnique('id').get(5)
    six = product.get('productVariants').indexedByUnique('id').get(6)

    # decode with the variants out of order
    product.fromJSON
      name: "Product Three"
      id: 3
      store_id: 1
      productVariants: [{
        id:6
        price:60
        product_id:3
      },{
        id:5
        price:50
        product_id:3
      }]

    equal product.get('productVariants.length'), 2
    deepEqual product.get('productVariants').mapToProperty('id').sort(), [5,6]
    equal five.get('price'), 50
    equal six.get('price'), 60
    QUnit.start()

asyncTest "saved hasMany models should decode their child records based on ID", ->
  @Product.find 3, (err, product) =>
    throw err if err

    five = product.get('productVariants').indexedByUnique('id').get(5)
    six = product.get('productVariants').indexedByUnique('id').get(6)

    # decode with the variants out of order
    product.fromJSON
      name: "Product Three"
      id: 3
      store_id: 1
      productVariants: [{
        id:6
        price:60
        product_id:3
      },{
        id:5
        price:50
        product_id:3
      }]

    equal product.get('productVariants.length'), 2
    deepEqual product.get('productVariants').mapToProperty('id').sort(), [5,6]
    equal five.get('price'), 50
    equal six.get('price'), 60
    QUnit.start()

asyncTest "integer-ish, string `id` doesn't cause the same items to be loaded twice", 5, ->
  @Store.find 1, (err, store) ->
    throw err if err
    sp = store.get("stringyProducts")
    delay ->
      equal sp.length, 3
      storeJSON = store.toJSON() # get those stringyProduct ids as strings
      stringIds = (prod.id for idx, prod of storeJSON.stringyProducts)
      strictEqual stringIds[0] , "1"
      strictEqual stringIds[1] , "2"
      strictEqual stringIds[2] , "15"
      store.fromJSON(storeJSON)
      delay ->
        deepEqual sp.length, 3

asyncTest "hasMany adds new related model instances to its set", ->
  @Store.find 1, (err, store) =>
    throw err if err
    addedProduct = new @Product(name: 'Product Four', store_id: store.get('id'))
    addedProduct.save (err, savedProduct) =>
      ok store.get('products').has(savedProduct)
      QUnit.start()

asyncTest "hasMany removes destroyed related model instances from its set", ->
  @Store.find 1, (err, store) =>
    throw err if err
    store.get('products').load (err, products) ->
      throw err if err
      destroyedProduct = products.toArray()[0]
      destroyedProduct.destroy (err) ->
        throw err if err
        ok !store.get('products').has(destroyedProduct)
        QUnit.start()

asyncTest "hasMany loads records for each parent instance", 2, ->
  @storeAdapter.storage["stores2"] =
    name: "Store Two"
    id: 2
  @productAdapter.storage["products4"] =
    name: "Product Four"
    id: 4
    store_id: 2

  @Store.find 1, (err, store) =>
    throw err if err
    products = store.get('products')
    setTimeout =>
      equal products.length, 3
      @Store.find 2, (err, store2) =>
        throw err if err
        products2 = store2.get('products')
        delay =>
          equal products2.length, 1
    , ASYNC_TEST_DELAY

asyncTest "hasMany loads after an instance of the related model is saved locally", 2, ->
  product = new @Product
    name: "Local product"
    store_id: 1

  product.save (err, savedProduct) =>
    throw err if err
    @Store.find 1, (err, store) ->
      throw err if err
      products = store.get('products')
      ok products.has(savedProduct)
      delay ->
        equal products.length, 4

asyncTest "hasMany supports custom foreign keys", 1, ->
  namespace = @
  class Shop extends Batman.Model
    @encode 'id', 'name'
    @hasMany 'products', {namespace: namespace, foreignKey: 'store_id'}

  shopAdapter = createStorageAdapter Shop, AsyncTestStorageAdapter,
    'shops1':
      id: 1
      name: 'Shop One'

  Shop.find 1, (err, shop) ->
    products = shop.get('products')
    delay ->
      equal products.length, 3

test "hasMany removes items that aren't in the json anymore", ->

  product = new @Product
  product.fromJSON({
      name: "Product Three"
      id: 3
      store_id: 1
      productVariants: [
        {id:6, price:60, product_id:3},
        {id:5, price:50, product_id:3}
      ]
    })

  equal product.get('productVariants.length'), 2, "it starts with 2"

  product.fromJSON({
      name: "Product Three"
      id: 3
      store_id: 1
      productVariants: [
        {id:6, price:60, product_id:3}
      ]
    })

  equal product.get('productVariants.length'), 1, "when it finds fewer in the json, the extras are removed"

test "hasMany supports custom proxy classes", 1, ->
  namespace = @
  class CoolAssociationSet extends Batman.AssociationSet
  class Shop extends Batman.Model
    @encode 'id'
    @hasMany 'products', {namespace: namespace, extend: {proxyClass: CoolAssociationSet}}

  shop = new Shop()
  ok shop.get('products') instanceof CoolAssociationSet

asyncTest "regression test: identity mapping works", ->
  @ProductVariant.load (err, variants) =>
    originalIDs = variants.map (v) -> v.get('id')
    @Product.load (err, products) =>
      currentIDs = variants.map (v) -> v.get('id')
      deepEqual currentIDs, originalIDs
      deepEqual @ProductVariant.get('loaded').mapToProperty('id').sort(), [1,2,3,4,5,6]
      QUnit.start()

QUnit.module "Batman.Model hasMany Associations with inverse of",
  setup: ->
    namespace = {}

    namespace.Product = class @Product extends Batman.Model
      @encode 'id', 'name'
      @hasMany 'productVariants', {namespace: namespace, inverseOf: 'product'}

    @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
      products1:
        name: "Product One"
        id: 1
        productVariants: [{
          id:5
          price:50
        },{
          id:6
          price:60
        }]

    namespace.ProductVariant = class @ProductVariant extends Batman.Model
      @encode 'price'
      @belongsTo 'product', namespace: namespace

    @variantsAdapter = createStorageAdapter @ProductVariant, AsyncTestStorageAdapter,
      product_variants5:
        id:5
        price:50
      product_variants6:
        id:6
        price:60

asyncTest "::build sets the inverse relation", 1 , ->
  @ProductVariant.load (err, variants) =>
    @Product.find 1, (err, product) =>
      throw err if err
      product.get('productVariants')
      delay ->
        newProductVariant = product.get('productVariants').build()
        ok newProductVariant.get('product') is product

asyncTest "hasMany sets the foreign key on the inverse relation if the children haven't been loaded", 3, ->
  @Product.find 1, (err, product) =>
    throw err if err
    variants = product.get('productVariants')
    delay ->
      variants = variants.toArray()
      equal variants.length, 2
      ok variants[0].get('product') == product
      ok variants[1].get('product') == product

asyncTest "hasMany sets the foreign key on the inverse relation if the children have already been loaded", 3, ->
  @ProductVariant.load (err, variants) =>
    throw err if err
    @Product.find 1, (err, product) =>
      throw err if err
      variants = product.get('productVariants')
      delay ->
        variants = variants.toArray()
        equal variants.length, 2
        ok variants[0].get('product') == product
        ok variants[1].get('product') == product

asyncTest "hasMany sets the foreign key on the inverse relation of children without dirtying them", 1, ->
  @Product.find 1, (err, product) =>
    throw err if err
    ok not product.get('productVariants.first.isDirty')
    QUnit.start()
