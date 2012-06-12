if typeof require isnt 'undefined'
  {restStorageTestSuite} = require('./rest_storage_helper')
else
  {restStorageTestSuite} = window

MockRequest = restStorageTestSuite.MockRequest

oldRequest = Batman.Request
oldExpectedForUrl = MockRequest.getExpectedForUrl

QUnit.module "Batman.RailsStorage"
  setup: ->
    MockRequest.getExpectedForUrl = (url) ->
      @expects[url.slice(0,-5)] || [] # cut off the .json so the fixtures from the test suite work fine

    Batman.Request = MockRequest
    MockRequest.reset()

    class @Store extends Batman.Model
      @encode 'id', 'name'
    @storeAdapter = new Batman.RailsStorage(@Store)
    @Store.persist @storeAdapter

    class @Product extends Batman.Model
      @encode 'id', 'name', 'cost'
    @productAdapter = new Batman.RailsStorage(@Product)
    @Product.persist @productAdapter

    @adapter = @productAdapter # for restStorageTestSuite

  teardown: ->
    Batman.Request = oldRequest
    MockRequest.getExpectedForUrl = oldExpectedForUrl

restStorageTestSuite.testOptionsGeneration('.json')
restStorageTestSuite()

asyncTest 'creating in storage: should callback with the record with errors on it if server side validation fails', ->
  MockRequest.expect
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
