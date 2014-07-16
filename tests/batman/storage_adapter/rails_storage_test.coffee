helpers = window.restStorageHelpers

oldRequest = Batman.Request
oldExpectedForUrl = helpers.MockRequest.getExpectedForUrl

QUnit.module "Batman.RailsStorage",
  setup: ->
    helpers.MockRequest.getExpectedForUrl = (url) ->
      @expects[url.slice(0,-5)] || [] # cut off the .json so the fixtures from the test suite work fine

    Batman.Request = helpers.MockRequest
    helpers.MockRequest.reset()

    class @Store extends Batman.Model
      @encode 'id', 'name'
    @storeAdapter = new Batman.RailsStorage(@Store)
    @Store.persist @storeAdapter

    class @Product extends Batman.Model
      @encode 'id', 'name', 'cost'
    @productAdapter = new Batman.RailsStorage(@Product)
    @Product.persist @productAdapter

    @adapter = @productAdapter # for restStorageHelpers

  teardown: ->
    Batman.Request = oldRequest
    helpers.MockRequest.getExpectedForUrl = oldExpectedForUrl

helpers.testOptionsGeneration('.json')
helpers.run()

asyncTest 'creating in storage: should callback with the record with errors on it if server side validation fails', ->
  helpers.MockRequest.expect
    url: '/products'
    method: 'POST'
  , error:
      status: 422
      response: JSON.stringify
        name: ["can't be test", "must be valid"]

  product = new @Product(name: "test")
  @productAdapter.perform 'create', product, {}, (err, record) =>
    ok err instanceof Batman.ErrorsSet
    ok record
    equal record.get('errors').length, 2
    QUnit.start()

asyncTest 'creating in storage: should callback with the record with errors on it if server side validation fails in recent versions of Rails', ->
  helpers.MockRequest.expect
    url: '/products'
    method: 'POST'
  , error:
      status: 422
      response: JSON.stringify
        errors:
          name: ["can't be test", "must be valid"]

  product = new @Product(name: "test")
  @productAdapter.perform 'create', product, {}, (err, record) =>
    ok err instanceof Batman.ErrorsSet
    ok record
    equal record.get('errors').length, 2
    QUnit.start()

asyncTest 'hasMany encodesNestedAttributesFor uses {key}_attributes and removes _destroy', 4, ->
  @Store.hasMany('products', saveInline: true, autoload: false, namespace: @)
  @Store.encodesNestedAttributesFor('products')
  store = new @Store(name: "Goodburger")
  burger = store.get('products').build(name: "The Goodburger")
  fries = store.get('products').build(name: "French Fries")


  JSONResponse = store.toJSON()

  helpers.MockRequest.expect
    url: "/stores"
    method: "POST"
  , success: JSONResponse

  helpers.MockRequest.expect
    url: "/stores/1"
    method: "PUT"
  , success: JSONResponse

  @storeAdapter.before 'create', (env, next) =>
    storeJSON = env.options.data.store
    ok storeJSON.products_attributes, "The _attributes key is added"
    ok !storeJSON.products, "The original key is removed"
    deepEqual storeJSON.products_attributes[0], {store_id: undefined, name: "The Goodburger"}, "the child is serialized"
    next()

  store.save (e, r) =>
    throw e if e
    store.set('id', 1)
    fries.set("_destroy", 1)
    store.save =>
      throw e if e
      ok !store.get('products').has(fries), "_destroy items are removed"
      QUnit.start()

asyncTest 'hasOne encodesNestedAttributesFor uses {key}_attributes and removes _destroy', 4, ->
  @Store.hasOne('product', saveInline: true, autoload: false, namespace: @)
  @Store.encodesNestedAttributesFor('product')
  store = new @Store(name: "Goodburger")
  burger = new @Product(name: "The Goodburger")
  store.set('product', burger)

  JSONResponse = store.toJSON()

  helpers.MockRequest.expect
    url: "/stores"
    method: "POST"
  , success: JSONResponse

  helpers.MockRequest.expect
    url: "/stores/1"
    method: "PUT"
  , success: JSONResponse

  @storeAdapter.before 'create', (env, next) =>
    storeJSON = env.options.data.store
    ok storeJSON.product_attributes, "The _attributes key is added"
    ok !storeJSON.product, "The original key is removed"
    deepEqual storeJSON.product_attributes, {store_id: undefined, name: "The Goodburger"}, "the child is serialized"
    next()

  store.save (e, r) =>
    throw e if e
    store.set('id', 1)
    burger.set("_destroy", 1)
    store.save =>
      throw e if e
      ok !store.get('product.target'), "_destroy items are removed"
      QUnit.start()

asyncTest 'encodesNestedAttributesFor works with serializeAsForm is false', 4, ->
  @Store.hasMany('products', saveInline: true, autoload: false, namespace: @)
  @Store.encodesNestedAttributesFor('products')
  @storeAdapter.serializeAsForm = false

  store = new @Store(name: "Goodburger")
  burger = store.get('products').build(name: "The Goodburger")
  fries = store.get('products').build(name: "French Fries")


  JSONResponse = store.toJSON()

  helpers.MockRequest.expect
    url: "/stores"
    method: "POST"
  , success: JSONResponse

  helpers.MockRequest.expect
    url: "/stores/1"
    method: "PUT"
  , success: JSONResponse

  @storeAdapter.before 'create', (env, next) =>
    storeJSON = JSON.parse(env.options.data).store
    ok storeJSON.products_attributes, "The _attributes key is added"
    ok !storeJSON.products, "The original key is removed"
    # store_id is undefined, so JSON.stringify omits it
    deepEqual storeJSON.products_attributes[0], {name: "The Goodburger"}, "the child is serialized"
    next()

  store.save (e, r) =>
    throw e if e
    store.set('id', 1)
    fries.set("_destroy", 1)
    store.save =>
      throw e if e
      ok !store.get('products').has(fries), "_destroy items are removed"
      QUnit.start()