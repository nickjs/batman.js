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
