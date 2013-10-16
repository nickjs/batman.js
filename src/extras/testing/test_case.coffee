class Batman.TestCase extends Batman.Object
  class @Test
    constructor: (@name, @expected, @testFunction) ->

    run: (testCase) ->
      wrappedTest = sinon.test(@testFunction).bind(testCase)
      wrappedTest = testCase.expectationsWrapper(wrappedTest)
      wrappedTest = testCase.xhrWrapper(wrappedTest)

      QUnit.test(@name, @expected, wrappedTest)

  @test: (name, expected, testFunction) ->
    if typeof expected is 'function'
      testFunction = expected
      expected = null

    @tests ||= []
    @tests.push new @Test(name, expected, testFunction)

  constructor: ->
    @_expectations = {}

  runTests: ->
    QUnit.module @constructor.name,
      setup: @xhrWrapper(@setup.bind(this))
      teardown: @xhrWrapper(@teardown.bind(this))

    for desc, test of @constructor.tests
      test.run(this)

  setup: ->
  teardown: ->

  continue: ->
    QUnit.start()

  wait: ->
    QUnit.stop()

  assert: (assertion, message = 'was not true') ->
    QUnit.ok assertion, message

  assertEqual: (expected, actual, message) ->
    QUnit.ok @_areEquivalent(expected, actual), message or "Expected: #{expected} \nGot: #{actual}"

  assertNotEqual: (expected, actual, message) ->
    QUnit.ok !@_areEquivalent(expected, actual), message or "Expected and actual value matched: #{expected}"

  assertMatch: (expected, actual, message) ->
    QUnit.ok expected.test(actual), message or "Expected: #{expected} \nGot: #{actual}"

  assertNoMatch: (expected, actual, message) ->
    QUnit.ok !expected.test(actual), message or "Expected and actual value matched: #{expected}"

  assertDifference: (expressions, difference = 1, message, callback) ->
    if Batman.typeOf(expressions) != 'Array'
      expressions = [expressions]

    if arguments.length is 2
      callback = difference
      difference = 1
    else if arguments.length is 3
      callback = message
      message = null

    before = expressions.map (expression) ->
      eval expression

    callback()

    for e, i in expressions
      error = "#{e} didn't change by #{difference}"
      error = "#{message}.\n#{error}" if message
      @assertEqual before[i] + difference, eval(e), error

  assertNoDifference: (expressions, message, callback) ->
    if arguments.length is 2
      callback = message
      message = null

    @assertDifference expressions, 0, message, callback

  assertRaises: (expected, callback, message) ->
    QUnit.raises callback, expected, message

  addExpectation: (name) ->
    if @_expectations[name] then @_expectations[name]++ else @_expectations[name] = 1

  stubAccessor: (object, keypath, fn) ->
    sinon.sandbox.stub(object.property(keypath), 'getValue', fn)

  completeExpectation: (name) ->
    return if not @_expectations[name]
    QUnit.ok(true, "Completed #{name}")
    if @_expectations[name] is 1 then delete @_expectations[name] else @_expectations[name]--

  verifyExpectations: ->
    for key, count of @_expectations
      QUnit.ok(false, "Expectation #{key} did not callback #{count} time(s)")

  clearExpectations: -> @_expectations = {}

  expectationsWrapper: (fn) ->
    testCase = this

    return ->
      testCase.clearExpectations()
      results = fn.apply(this, arguments)
      testCase.verifyExpectations()
      return results

  xhrWrapper: (fn) ->
    return ->
      Batman.Request.setupMockedResponse()
      return fn.apply(this, arguments)

  assertGET: (url, params) ->
    @_assertXHR('GET', url, params)

  assertPOST: (url, params) ->
    @_assertXHR('POST', url, params)

  assertPUT: (url, params) ->
    @_assertXHR('PUT', url, params)

  assertDELETE: (url, params) ->
    @_assertXHR('DELETE', url, params)

  _assertXHR: (method, url, params) ->
    id = "#{method} to #{url}"
    @addExpectation(id)

    Batman.Request.addMockedResponse method, url, =>
      @completeExpectation(id)

      params ||= {}
      params.status ||= 200
      params.response ||= {}

      return params

  _unwrapStringOrNumber: (obj) ->
    return obj.valueOf() if obj instanceof Number || obj instanceof String
    obj

  # http://stackoverflow.com/a/6402977
  _areEquivalent: (a, b) ->
    a = @_unwrapStringOrNumber(a)
    b = @_unwrapStringOrNumber(b)

    return true if a == b
    return false if a == null || b == null || typeof (a) != typeof (b)

    if a instanceof Date
      return b instanceof Date && a.valueOf() == b.valueOf()
    if typeof (a) != "object"
      return a == b

    newA = a.areEquivalent_Eq_91_2_34 == undefined
    newB = b.areEquivalent_Eq_91_2_34 == undefined

    try
      if newA
        a.areEquivalent_Eq_91_2_34 = []
      else if a.areEquivalent_Eq_91_2_34.some((other) -> other == b)
        return true

      if newB
        b.areEquivalent_Eq_91_2_34 = []
      else if b.areEquivalent_Eq_91_2_34.some((other) -> other == a)
        return true

      a.areEquivalent_Eq_91_2_34.push(b)
      b.areEquivalent_Eq_91_2_34.push(a)

      tmp = {}
      for prop of a
        if prop != "areEquivalent_Eq_91_2_34"
          tmp[prop] = null

      for prop of b
        if prop != "areEquivalent_Eq_91_2_34"
          tmp[prop] = null

      for prop of tmp
        if !@_areEquivalent(a[prop], b[prop])
          return false

      return true
    finally
      delete a.areEquivalent_Eq_91_2_34 if newA
      delete b.areEquivalent_Eq_91_2_34 if newB

# Nicer messages for the command line runner
do ->
  originalPush = QUnit.push
  parseExpected = (exp) -> "\x1B[32m#{QUnit.jsDump.parse(exp)}\x1B[39m"
  parseActual   = (act) -> "\x1B[31m#{QUnit.jsDump.parse(act)}\x1B[39m"

  QUnit.push = (result, actual, expected, message) ->
    message ||= "#{parseExpected(expected)} expected but was #{parseActual(actual)}"
    originalPush.call(QUnit, result, actual, expected, message)
