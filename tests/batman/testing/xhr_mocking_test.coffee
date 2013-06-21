QUnit.module "Batman.XhrMocking",
  setup: ->
    @tester = new Batman.TestCase
    @tester.setup()

test 'assertGET will assert if the request GETs', ->
  message = "Did not expect exception when using correct URL"
  try
    @tester.assertGET '/fake.json', {response: "Hello World"}, =>
      new Batman.Request url: "/fake.json"

    ok true, message
  catch error
    ok false, message
    throw error

test 'should rise error if hit wrong URL', ->
  throws -> 
      @tester.assertGET '/fake.json', {response: "Hello World"}, => 
        new Batman.Request url: "/wrong-url.json"
    , /once \(never called\)/
    , "Expected exception when using incorrect URL"
