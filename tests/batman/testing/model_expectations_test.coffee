testExpectations = (testCase, testFn, cb) ->
  args = []
  sinon.stub(QUnit, 'ok', -> args.push(arguments))

  validate = ->
    sandbox.restore()
    QUnit.ok.restore()
    cb(args.length, args.map((arg) -> arg[0]))

  sandbox = sinon.sandbox.create(injectInto: testCase, properties: ['stub', 'mock', 'spy'])
  testFn(validate)

QUnit.module "Batman.ModelExpectations",
  setup: ->
    @model = new Batman.Model

asyncTest 'expectCreate passes if the model is created', 2, ->
  @model.unset('id')

  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectCreate(@model)
    @model.save(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectCreate fails if the model is updated', 2, ->
  @model.set('id', 1)

  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectCreate(@model)
    @model.save(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok !okAssertions[0]
    QUnit.start()

asyncTest 'expectUpdate passes if the model is updated', 2, ->
  @model.set('id', 1)

  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectUpdate(@model)
    @model.save(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectUpdate fails if the model is created', 2, ->
  @model.unset('id')

  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectUpdate(@model)
    @model.save(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok !okAssertions[0]
    QUnit.start()

asyncTest 'expectLoad passes if the model is loaded', 2, ->
  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectLoad(Batman.Model)
    Batman.Model.load(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectFind passes if the model is searched for', 2, ->
  testCase = new Batman.ModelTestCase
  testFn = (validate) =>
    testCase.expectFind(Batman.Model)
    Batman.Model.find(validate)

  testExpectations testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()
