if typeof require isnt 'undefined'
  {sharedStorageTestSuite} = require('./storage_adapter_helper')
else
  {sharedStorageTestSuite} = window

productJSON =
  product:
    name: 'test'
    id: 10

specialProductJSON =
  special_product:
    name: 'test'
    id: 10

class MockRequest extends MockClass
  @dataHasFileUploads: Batman.Request.dataHasFileUploads
  @expects = {}
  @reset: ->
    MockClass.reset.call(@)
    @expects = {}

  @expect: (request, response) ->
    responses = @expects[request.url] ||= []
    responses.push {request, response}

  CALLBACKS = ['success', 'loaded', 'loading', 'error']
  for key in CALLBACKS
    @chainedCallback key

  @getExpectedForUrl: (url) ->
    @expects[url] || []

  constructor: (requestOptions) ->
    super()
    requestOptions.autosend ?= true
    for key in CALLBACKS
      @[key](requestOptions[key]) if requestOptions[key]?
    @fireLoading()
    allExpected = @constructor.getExpectedForUrl(requestOptions.url)
    expected = allExpected.shift()
    @send = =>
      respond = =>
        if ! expected?
          @fireError {message: "Unrecognized mocked request!", request: @}
        else
          {request, response} = expected

          for k in ['method', 'data', 'contentType']
            if request[k]? && !QUnit.equiv(request[k], requestOptions[k])
              throw "Wrong #{k} for expected request! Expected #{request[k]}, got #{requestOptions[k]}."

          if response.error
            if typeof response.error is 'string'
              @fireError {message: response.error, request: @}
            else
              response.error.request = @
              @status = response.error.status
              @response = response.error.response
              @fireError response.error
          else
            @response = response
            @fireSuccess response
        @fireLoaded response

      if expected?.respondSynchronously
        respond()
      else
        setTimeout respond, 0

    if requestOptions.autosend
      @send()

  get: (k) ->
    throw "Can't get anything other than 'response' and 'status' on the Requests" unless k in ['response', 'status']
    @[k]

restStorageTestSuite = ->

  sharedStorageTestSuite(restStorageTestSuite.sharedSuiteHooks)

  test 'default options should be independent', ->
    otherAdapter = new @adapter.constructor(@Product)
    notEqual otherAdapter.defaultRequestOptions, @adapter.defaultRequestOptions

  asyncTest 'can readAll from JSON string', 3, ->
    MockRequest.expect
      url: '/products'
      method: 'GET'
    , JSON.stringify products: [ name: "test", cost: 20 ]

    @adapter.perform 'readAll', @Product, {}, (err, readProducts) ->
      throw err if err
      ok readProducts
      equal readProducts.length, 1
      equal readProducts[0]?.get("name"), "test"
      QUnit.start()

  asyncTest 'can readAll from JSON string representing just one object', 3, ->
    MockRequest.expect
      url: '/products'
      method: 'GET'
    , JSON.stringify product: {name: "test", cost: 20}

    @adapter.perform 'readAll', @Product, {}, (err, readProducts) ->
      throw err if err
      ok readProducts
      equal readProducts.length, 1
      equal readProducts[0]?.get("name"), "test"
      QUnit.start()

  asyncTest 'can readAll when the response returns synchronously', 3, ->
    MockRequest.expect
      url: '/products'
      method: 'GET'
      respondSynchronously: true
    , JSON.stringify products: [ name: "test", cost: 20 ]

    @adapter.perform 'readAll', @Product, {}, (err, readProducts) ->
      throw err if err
      ok readProducts
      equal readProducts.length, 1
      equal readProducts[0]?.get("name"), "test"
      QUnit.start()

  asyncTest 'updating in storage: should update the record with the response if it is different', 1, ->
    MockRequest.expect
      url: '/products/10'
      method: 'PUT'
    , product:
        id: 10
        name: "test"
        other_field: "another test"

    @Product.encode 'other_field'
    product = new @Product(name: "test", id: 10)
    @adapter.perform 'update', product, {}, (err, record) =>
      throw err if err
      equal record.get('other_field'), "another test"
      QUnit.start()

  asyncTest 'updating in storage: should not fail if no response comes back', 1, ->

    MockRequest.expect
      url: '/products/10'
      method: 'PUT'
    , ""

    product = new @Product(name: "test", id: 10)
    @adapter.perform 'update', product, {}, (err, record) =>
      throw err if err
      ok record
      QUnit.start()

  asyncTest 'creating in storage: response metadata should be available in the callbacks', ->
    product = new @Product(name: "test")
    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,
      product:
        name: 'test'
        id: 10
      someMetaData: 'foo'

    @adapter.perform 'create', product, {}, (err, record, env) =>
      throw err if err
      equal env.data.someMetaData, "foo"
      ok env.request instanceof Batman.Request
      QUnit.start()

  asyncTest 'reading from storage: response metadata should be available in the callbacks', ->
    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    ,
      product:
        name: 'test'
        id: 10
      someMetaData: 'foo'
    product = new @Product(name: "test", id: 10)

    @adapter.perform 'read', product, {}, (err, record, env) =>
      throw err if err
      equal env.data.someMetaData, "foo"
      ok env.request instanceof Batman.Request
      QUnit.start()

  asyncTest 'reading many from storage: response metadata should be available in the callbacks',  ->
    MockRequest.expect
        url: '/products'
        method: 'GET'
      ,
        someMetaData: "foo"
        products: [
          name: "testA"
          cost: 20
        ,
          name: "testB"
          cost: 10
        ]

    @adapter.perform 'readAll', @Product, {}, (err, readProducts, env) ->
      throw err if err
      equal env.data.someMetaData, "foo"
      ok env.request instanceof Batman.Request
      QUnit.start()

  asyncTest 'updating in storage: response metadata should be available in the callbacks', ->
    MockRequest.expect
      url: '/products/10'
      method: 'PUT'
    ,
      product:
        name: 'test'
        cost: 10
        id: 10
      someMetaData: "foo"

    product = new @Product(name: "test", id: 10, cost: 10)
    @adapter.perform 'update', product, {}, (err, updatedProduct, env) ->
      throw err if err
      equal env.data.someMetaData, "foo"
      ok env.request instanceof Batman.Request
      QUnit.start()

  asyncTest 'destroying in storage: it should not error if there is no content in the response', ->
    MockRequest.expect
      url: '/products/10'
      method: 'DELETE'
    , ''

    product = new @Product(name: "test 12", id: 10)

    @adapter.perform 'destroy', product, {}, (err, record, env) =>
      ok !err
      QUnit.start()

  asyncTest 'destroying in storage: response metadata should be available in the callbacks', ->
    MockRequest.expect
      url: '/products/10'
      method: 'DELETE'
    ,
      success: true
      someMetaData: 'foo'

    product = new @Product(name: "test 12", id: 10)

    @adapter.perform 'destroy', product, {}, (err, record, env) =>
      throw err if err
      equal env.data.someMetaData, "foo"
      ok env.request instanceof Batman.Request
      QUnit.start()

  asyncTest 'creating in storage: it should POST JSON instead of serialized parameters when configured to do so', ->
    @adapter.serializeAsForm = false

    MockRequest.expect
      url: '/products'
      method: 'POST'
      data: '{"product":{"name":"test"}}'
      contentType: 'application/json'
    , productJSON

    product = new @Product(name: "test")
    @adapter.perform 'create', product, {}, (err, record) =>
      throw err if err
      ok record
      QUnit.start()

  asyncTest 'custom REST actions on storage: it should send JSON instead of serialized parameters when configured to do so', ->
    @adapter.serializeAsForm = false
    product = new @Product(name: "test", id: 10)
    counter = 0
    for method in ['PUT', 'POST']
      MockRequest.expect
        url: '/products/10/extra'
        method: method
        data: '{"foo":"bar"}'
        contentType: 'application/json'
      , productJSON

      counter += 1
      @adapter.perform method.toLowerCase(), product, {action: 'extra', data: {foo: 'bar'}}, (err, record) =>
        throw err if err
        ok record
        QUnit.start() if --counter == 0

  asyncTest 'custom REST actions on storage: records should callback with the response', 4, ->
    product = new @Product(name: "test", id: 10)
    counter = 0
    for method in ['GET', 'POST', 'PUT', 'DELETE']
      MockRequest.expect
        url: '/products/10/extra'
        method: method
      , foo: 'bar'

      counter += 1
      @adapter.perform method.toLowerCase(), product, {action: 'extra'}, (err, response) ->
        throw err if err
        deepEqual response, {foo: 'bar'}
        QUnit.start() if --counter == 0

  asyncTest 'custom REST actions on storage: records should callback with the error if given', 4, ->
    product = new @Product(name: "test", id: 10)
    counter = 0
    for method in ['GET', 'POST', 'PUT', 'DELETE']
      MockRequest.expect
        url: '/products/10/extra'
        method: method
      , error: "Foo!"

      counter += 1
      @adapter.perform method.toLowerCase(), product, {action: 'extra'}, (err, response) ->
        ok err
        QUnit.start() if --counter == 0

  asyncTest 'custom REST actions on storage: models should callback with the response', 4, ->
    counter = 0
    for method in ['GET', 'POST', 'PUT', 'DELETE']
      MockRequest.expect
        url: '/products/extra'
        method: method
      , foo: 'bar'

      counter += 1
      @adapter.perform method.toLowerCase(), @Product, {action: 'extra'}, (err, response) ->
        throw err if err
        deepEqual response, {foo: 'bar'}
        QUnit.start() if --counter == 0

  asyncTest 'custom REST actions on storage: models should callback with the error if given', 4, ->
    counter = 0
    for method in ['GET', 'POST', 'PUT', 'DELETE']
      MockRequest.expect
        url: '/products/extra'
        method: method
      , error: "Foo!"

      counter += 1
      @adapter.perform method.toLowerCase(), @Product, {action: 'extra'}, (err, response) ->
        ok err
        QUnit.start() if --counter == 0

  asyncTest 'HTTP status codes results in appropriate errors', Object.keys(Batman.RestStorage._statusCodeErrors).length, ->
    counter = 0
    namespace = @
    for statusCode, errorClass of Batman.RestStorage._statusCodeErrors
      do (statusCode, errorClass) ->
        MockRequest.expect 
          url: '/products/10'
          method: 'GET'
        , error: 
          status: statusCode

        product = new namespace.Product(name: "test", id: 10)

        counter += 1
        namespace.adapter.perform 'read', product, {}, (err, record, env) =>
          ok err instanceof errorClass
          QUnit.start() if --counter == 0

  test "persisting a model with this adapter should add helpers for making gets, puts, posts, and deletes", ->
    @adapter.perform = perform = createSpy()

    @product = new @Product(name: "test", id: 10)

    @product.request 'duplicate', {method: 'GET'}, callback = (err, response) ->
    deepEqual perform.lastCallArguments.slice(0,3), ['get', @product, {method: 'GET', action: 'duplicate'}]
    equal typeof perform.lastCallArguments[3], 'function'

restStorageTestSuite.testOptionsGeneration = (urlSuffix = '') ->
  test 'string record urls should be gotten in the options', 1, ->
    product = new @Product
    product.url = '/some/url'
    url = @adapter.urlForRecord product, {}
    equal url, "/some/url#{urlSuffix}"

  test 'function record urls should be executed in the options', 1, ->
    product = new @Product
    product.url = -> '/some/url'
    url = @adapter.urlForRecord product, {}
    equal url, "/some/url#{urlSuffix}"

  test 'absent record urls should be defaulted in the options', 1, ->
    product = new @Product(id: 1)
    url = @adapter.urlForRecord product, {}
    equal url, "/products/1#{urlSuffix}"

  test 'function record urls should be given the options for the storage operation', 1, ->
    product = new @Product
    opts = {foo: true}
    product.url = (passedOpts) ->
      equal passedOpts, opts
      '/some/url'
    @adapter.urlForRecord product, {options: opts}

  test 'string model urls should be gotten in the options', 1, ->
    @Product.url = '/some/url'
    url = @adapter.urlForCollection @Product, {}
    equal url, "/some/url#{urlSuffix}"

  test 'function model urls should be executed in the options', 1, ->
    @Product.url = -> '/some/url'
    url = @adapter.urlForCollection @Product, {}
    equal url, "/some/url#{urlSuffix}"

  test 'absent model urls should be defaulted in the options', 1, ->
    url = @adapter.urlForCollection @Product, {}
    equal url, "/products#{urlSuffix}"

  test 'absent model urls should have the urlPrefix added if present', 1, ->
    @Product.urlPrefix = "/admin"
    url = @adapter.urlForCollection @Product, {}
    equal url, "/admin/products#{urlSuffix}"

  test 'function model urls should be given the options for the storage operation', 1, ->
    opts = {foo: true}
    @Product.url = (passedOpts) ->
      equal passedOpts, opts
      '/some/url'
    @adapter.urlForCollection @Product, {options: opts}

  test 'custom collection urls should be used if present', 1, ->
    url = @adapter.urlForCollection @Product, {options: { collectionUrl: '/foo/bars' }}
    equal url, "/foo/bars#{urlSuffix}"

  test 'custom collection urls should evaluate function if present and is a function', 1, ->
    url = @adapter.urlForCollection @Product, {options: { collectionUrl: -> '/foo/bars' }}
    equal url, "/foo/bars#{urlSuffix}"

  test 'custom collection urls should not affect record urls if present', 1, ->
    product = new @Product {id: 1}
    url = @adapter.urlForRecord product, {options: { collectionUrl: '/foo/bars' }}
    equal url, "/products/1#{urlSuffix}"

  test 'custom record urls should be used if present', 1, ->
    product = new @Product {id: 1}
    url = @adapter.urlForRecord product, {options: { recordUrl: '/foos/1' }}
    equal url, "/foos/1#{urlSuffix}"

  test 'custom record urls should evaluate function if present and is a function', 1, ->
    product = new @Product {id: 1}
    url = @adapter.urlForRecord product, {options: { recordUrl: -> "/foos/#{@get('id')}" }}
    equal url, "/foos/1#{urlSuffix}"

  test 'custom record urls should not affect collection urls if present', 1, ->
    url = @adapter.urlForCollection @Product, {options: { recordUrl: '/foos/1' }}
    equal url, "/products#{urlSuffix}"

  test 'records should take a urlPrefix option', 1, ->
    product = new @Product
    product.url = 'some/url'
    product.urlPrefix = '/admin'
    url = @adapter.urlForRecord product, {}
    equal url, "/admin/some/url#{urlSuffix}"

  test 'records should take a urlSuffix option', 1, ->
    product = new @Product
    product.url = '/some/url'
    product.urlSuffix = '.foo'
    url = @adapter.urlForRecord product, {}
    equal url, "/some/url.foo#{urlSuffix}"

  test 'models should be able to specify a urlPrefix', 1, ->
    @Product.url = 'some/url'
    @Product.urlPrefix = '/admin'
    url = @adapter.urlForCollection @Product, {}
    equal url, "/admin/some/url#{urlSuffix}"

  test 'models should be able to specify a urlSuffix', 1, ->
    @Product.url = '/some/url'
    @Product.urlSuffix = '.foo'
    url = @adapter.urlForCollection @Product, {}
    equal url, "/some/url.foo#{urlSuffix}"

  test 'absolute urls starting with a / should not have the url prefix applied', 1, ->
    product = new @Product
    product.url = '/some/url'
    product.urlPrefix = '/admin'
    url = @adapter.urlForRecord product, {}
    equal url, "/some/url#{urlSuffix}"

  test 'nonstandard actions can be passed to models without url functions defined', 1, ->
    product = new @Product(id: 1)
    url = @adapter.urlForRecord product, {options: {action: 'duplicate'}}
    equal url, "/products/1/duplicate#{urlSuffix}"

  test 'nonstandard actions can be passed to models with url functions defined', 1, ->
    product = new @Product(id: 1)
    product.url = '/some/url'
    url = @adapter.urlForRecord product, {options: {action: 'duplicate'}}
    equal url, "/some/url/duplicate#{urlSuffix}"

  test 'nonstandard actions can be passed to records without url functions defined', 1, ->
    url = @adapter.urlForCollection @Product, {options: {action: 'subset'}}
    equal url, "/products/subset#{urlSuffix}"

  test 'nonstandard actions can be passed to records with url functions defined', 1, ->
    @Product.url = '/some/url'
    url = @adapter.urlForCollection @Product, {options: {action: 'subset'}}
    equal url, "/some/url/subset#{urlSuffix}"

restStorageTestSuite.sharedSuiteHooks =
  'creating in storage: should succeed if the record doesn\'t already exist': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

  'creating in storage: should fail if the record does already exist': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,
      error: "Product already exists!"

  "creating in storage: should create a primary key if the record doesn't already have one": ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

  "creating in storage: should encode data before saving it": ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,
    product:
      name: 'TEST'
      id: 10

  'reading from storage: should callback with the record if the record has been created': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    , productJSON

  'reading from storage: should callback with the record if the record has been created and the record is an instance of a subclass': ->
    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , specialProductJSON

    MockRequest.expect
      url: '/special_products/10'
      method: 'GET'
    , specialProductJSON

  'reading from storage: should keep records of a class and records of a subclass separate': ->
    superJSON =
      product:
        name: 'test super'
        id: 10

    subJSON =
      special_product:
        name: 'test sub'
        id: 10

    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , subJSON

    MockRequest.expect
      url: '/products'
      method: 'POST'
    , superJSON

    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    , superJSON

    MockRequest.expect
      url: '/special_products/10'
      method: 'GET'
    , subJSON

  'reading from storage: should callback with decoded data after reading it': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,
      product:
        id: 10
        name: 'test 8'

    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    ,
      product:
        id: 10
        name: 'test 8'

  'reading from storage: should callback with an error if the record hasn\'t been created': ->
    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    , error: 'specified record doesn\'t exist'

  'reading many from storage: should callback with the records if they exist': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , product:
        name: "testA"
        cost: 20

    MockRequest.expect
      url: '/products'
      method: 'POST'
    , product:
        name: "testB"
        cost: 10

    MockRequest.expect
      url: '/products'
      method: 'GET'
    , products: [
        name: "testA"
        cost: 20
      ,
        name: "testB"
        cost: 10
      ]

  'reading many from storage: should callback with subclass records if they exist': ->
    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , special_product:
        name: "testA"
        cost: 20

    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , special_product:
        name: "testB"
        cost: 10

    MockRequest.expect
      url: '/special_products'
      method: 'GET'
    , special_products: [
        name: "testA"
        cost: 20
      ,
        name: "testB"
        cost: 10
      ]

  'reading many from storage: should callback with the decoded records if they exist': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,product:
        name: "testA"
        cost: 20

    MockRequest.expect
      url: '/products'
      method: 'POST'
    , product:
        name: "testB"
        cost: 10

    MockRequest.expect
      url: '/products'
      method: 'GET'
    , products: [
        name: "testA"
        cost: 20
      ,
        name: "testB"
        cost: 10
      ]

  'reading many from storage: when given options should callback with the records if they exist': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    ,product:
        name: "testA"
        cost: 10

    MockRequest.expect
      url: '/products'
      method: 'POST'
    , product:
        name: "testB"
        cost: 10

    MockRequest.expect {
      url: '/products'
      method: 'GET'
      data:
        cost: 10
    }, {
      products: [
        name: "testA"
        cost: 20
      ,
        name: "testB"
        cost: 10
      ]
    }

  'reading many from storage: should callback with an empty array if no records exist': ->
    MockRequest.expect
      url: '/products'
      method: 'GET'
    , products: []

  'updating in storage: should callback with the record if it exists': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

    MockRequest.expect
      url: '/products/10'
      method: 'PUT'
    , product:
        name: 'test'
        cost: 10
        id: 10

    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    , product:
        name: 'test'
        cost: 10
        id: 10

  'updating in storage: should callback with the subclass record if it exists': ->
    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , specialProductJSON

    MockRequest.expect
      url: '/special_products/10'
      method: 'PUT'
    , special_product:
        name: 'test'
        cost: 10
        id: 10

    MockRequest.expect
      url: '/special_products/10'
      method: 'GET'
    , special_product:
        name: 'test'
        cost: 10
        id: 10

  'updating in storage: should callback with an error if the record hasn\'t been created': ->

  'destroying in storage: should succeed if the record exists': ->
    MockRequest.expect
      url: '/products'
      method: 'POST'
    , productJSON

    MockRequest.expect
      url: '/products/10'
      method: 'DELETE'
    , success: true

    MockRequest.expect
      url: '/products/10'
      method: 'GET'
    , error: 'specified product couldn\'t be found!'

  'destroying in storage: should succeed if the subclass record exists': ->
    MockRequest.expect
      url: '/special_products'
      method: 'POST'
    , specialProductJSON

    MockRequest.expect
      url: '/special_products/10'
      method: 'DELETE'
    , success: true

    MockRequest.expect
      url: '/special_products/10'
      method: 'GET'
    , error: 'specified product couldn\'t be found!'

  'destroying in storage: should callback with an error if the record hasn\'t been created': ->

restStorageTestSuite.MockRequest = MockRequest

if typeof exports is 'undefined'
  window.restStorageTestSuite = restStorageTestSuite
else
  exports.restStorageTestSuite = restStorageTestSuite
