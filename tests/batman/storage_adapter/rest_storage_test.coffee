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
