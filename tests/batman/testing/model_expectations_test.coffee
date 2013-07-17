helpers = if typeof require is 'undefined' then window.testCaseHelper else require './test_case_helper'

QUnit.module "Batman.ModelExpectations",
  setup: ->
    @model = new Batman.Model
    @testCase = new Batman.ModelTestCase

asyncTest 'expectCreate passes if the model is created', 2, ->
  @model.unset('id')

  testFn = (validate) =>
    @testCase.expectCreate(@model)
    @model.save(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 2
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectCreate fails if the model is updated', 2, ->
  @model.set('id', 1)

  testFn = (validate) =>
    @testCase.expectCreate(@model)
    @model.save(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 2
    ok !okAssertions[0]
    QUnit.start()

asyncTest 'expectUpdate passes if the model is updated', 2, ->
  @model.set('id', 1)

  testFn = (validate) =>
    @testCase.expectUpdate(@model)
    @model.save(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 2
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectUpdate fails if the model is created', 2, ->
  @model.unset('id')

  testFn = (validate) =>
    @testCase.expectUpdate(@model)
    @model.save(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 2
    ok !okAssertions[0]
    QUnit.start()

asyncTest 'expectLoad passes if the model is loaded', 2, ->
  testFn = (validate) =>
    @testCase.expectLoad(Batman.Model)
    Batman.Model.load(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectFind passes if the model is searched for', 2, ->
  testFn = (validate) =>
    @testCase.expectFind(Batman.Model)
    Batman.Model.find(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'expectDestroy passes if the model is destroyed', 2, ->
  testFn = (validate) =>
    @testCase.expectDestroy(@model)
    @model.destroy(validate)

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()
