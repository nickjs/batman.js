helpers = if typeof require is 'undefined' then window.testCaseHelper else require './test_case_helper'

QUnit.module "Batman.XhrMocking",
  setup: ->
    @testCase = new Batman.TestCase
    Batman.Request.setupMockedResponse()

test 'beforeResponse is called before the success event', ->
  successCallCount = 0

  Batman.Request.addMockedResponse 'GET', '/test', ->
    {status: 200, beforeResponse: -> QUnit.equal(successCallCount, 0)}

  req = new Batman.Request(url: '/test', method: 'GET', success: -> successCallCount++)
  req.send()

  QUnit.equal(successCallCount, 1)

test 'response should contain the expected parameters on success', ->
  validResponse = {absolutely: "valid"}
  Batman.Request.addMockedResponse 'GET', '/test', ->
    {status: 200, response: validResponse}

  new Batman.Request
    url: '/test'
    method: 'GET'
    success: (response) ->
      QUnit.equal(response, validResponse)

test 'response should contain the expected parameters on error', ->
  Batman.Request.addMockedResponse 'GET', '/test', ->
    {status: 500, response: "response", responseText: "responseText", somethingElse: "somethingElse"}

  new Batman.Request
    url: '/test'
    method: 'GET'
    error: (response) ->
      QUnit.equal(response.responseText, "responseText")
      QUnit.equal(response.response, "response")
      QUnit.equal(response.somethingElse, undefined)

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

asyncTest 'refuteGET will fail if a GET request is made', 2, ->
  testFn = (validate) =>
    @testCase.refuteGET '/fake.json'
    new Batman.Request(url: '/fake.json')
    validate()

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok !okAssertions[0]
    QUnit.start()

asyncTest 'refuteGET will pass if no GET request is made', 2, ->
  testFn = (validate) =>
    @testCase.refuteGET '/fake.json'
    validate()

  helpers.runTestCase @testCase, testFn, (okCount, okAssertions) ->
    equal okCount, 1
    ok okAssertions[0]
    QUnit.start()
