helpers = if typeof require is 'undefined' then window.testCaseHelper else require './test_case_helper'

QUnit.module "Batman.XhrMocking",
  setup: ->
    @testCase = new Batman.TestCase
    @testCase.xhrSetup()

test 'beforeResponse is called before the success event', ->
  successCallCount = 0

  @testCase.setMockedResponse '/test', 'GET', ->
    {status: 200, beforeResponse: -> QUnit.equal(successCallCount, 0)}

  req = new Batman.Request(url: '/test', method: 'GET', success: -> successCallCount++)
  req.send()

  QUnit.equal(successCallCount, 1)

asyncTest 'assertGET will pass if the if a GET request is made', 2, ->
  testFn = (validate) =>
    @testCase.assertGET '/fake.json', {response: "{}"}
    new Batman.Request(url: '/fake.json')
    validate()

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()

asyncTest 'assertGET will fail if the if a POST request is made', 2, ->
  testFn = (validate) =>
    @testCase.assertGET '/fake.json', {response: "{}"}
    new Batman.Request(url: '/fake.json', method: 'POST')
    validate()

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok !okAssertions[0]
    QUnit.start()
