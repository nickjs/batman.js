# Batman.Request
 Request is an abstraction around XHR requests.  It can be used with a variety of platforms, and is implemented in the platform layer files.

### Platform Request Implmentation Libraries:
  Depending on the platform library the underlying request implementation will change:

 - `batman.jquery.js`: jQuery XHR
 - `batman.solo.js`: Reqwest.js

 _note_ For the tests there are some mocked responses, in a normal non testing situation you would not use these

### How to use Batman Request

  Batman.Request can be used a variety of ways.  This is the underlying library that the `rest_storage_adapater` uses to communicate.

  In other cases where you want to communicate with a server that isn't your default storage_adapter you would use it like:
    
    test "Send a simple Batman.Request", ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse( "GET", "http://batmanjs.org", ->{})
      new Batman.Request
        url: "http://batmanjs.org"
        method: "GET"
        success: (result) ->
          ok true

### Lifecycle events
 There are a variety of lifecycle events that get fired in a `Request`.  Each of these are passed in as parameters in the options object in the `Request` constructor.

 1. `loading()`: fired before `send()` has been called.

    test "Demonstrate the loading event", 1, ->
       new Batman.Request
         url: "http:://batmanjs.org"
         loading: ->
           ok true, "After send but before the request is made"

 2. `loaded()`: fired after the request is complete

     test "Demo the loaded event", 1, ->
       Batman.Request.setupMockedResponse()
       Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> {})
       new Batman.Request
         url: "http://batmanjs.org"
         loaded: ->
           ok true, "Loaded"

 3. `error( xhr )`: fired when an error is detected,  `xhr` is the platform defined xhr object with a property named `request` being the `Batman.Request` object.

    test "Demo the error event", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
      new Batman.Request
        url: "http://batmanjs.org"
        error: (xhr) ->
          ok true, "Error"

 4. `success ( response )`: fired when a successful request has been made, `response` is the body of the request response.

    test "Demonstrate the success event", 1,  ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo")
      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          equal "foo", response

## .status
  The response status, only set after `error` or `success`

    test "Demo the error event", 1, ->
     Batman.Request.setupMockedResponse()
     Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
     new Batman.Request
       url: "http://batmanjs.org"
       error: (xhr) ->
         equal 400, @status

## .response
  The response object

    test "Demonstrate the response object", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo" )

      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          equal "foo", JSON.parse(@response)

## .responseHeaders : object
  An key/value object with the response headers

    test "responseHeaders", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> responseHeaders: { FOO: "bar" } )

      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          deepEqual @responseHeaders,{ FOO: "bar" }

## @Request(options : object)

  Constructs a new `Batman.Request` with the supplied options

  `options` description
  1. `url : String`: A string containing the URL to which the request is sent.  Mandatory
  2. `method : String`: The type of request to make eg. `GET`, `POST`.  Default is `GET`

    test "method test", ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("POST", "http://batmanjs.org", -> response : { FOO: "BAR" })
      new Batman.Request
        url: "http://batmanjs.org"
        method: "POST"
        data: { some: "data" }
        success: (response) ->
          ok true

  3. `data`: Data to be sent to the server. It is converted to a query string, if not already a string. It's appended to the url for GET-requests.
  4. `contentType`: the content type to send, defaults to `application/x-www-form-urlencoded`

    test "contentType default", ->
       req = new Batman.Request
       equal req.contentType, "application/x-www-form-urlencoded"

  5. `autosend`: controls whether the request will be sent automatically, deafults to `true`

    test "autosend test", ->
      response_sent = false
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> {} )
      req = new Batman.Request
        url: "http://batmanjs.org"
        autosend: false
        success: (response) ->
          response_sent = true
      ok !response_sent
      req.send()
      ok response_sent

  6. `username`: username for authentication
  7. `password`: password for authentication
  8. `type`: The type of data you're expecting from the server, defaults to `json`


## ::send([data])
  If `autosend` is `false`, this will initiate the request.  The data object passed in will take priority over the one specified in the `options` object

    test "request.send()", ->
      beforeResponse = (req, data) ->
        deepEqual data, { other: "thing" }
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> {beforeResponse: beforeResponse} )
      req = new Batman.Request
        url: "http://batmanjs.org"
        autosend: false
        data: { some: "data" }
      req.send( { other: "thing" } )
