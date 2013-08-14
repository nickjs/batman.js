# Batman Request
 Request is an abstraction around XHR requests.  It can be used with a variety of platforms, and is implemented the platform layer files.

## Platform Request Implmentation Libraries:
  Depending on the platform library the underlying request implementation will change:

 - `batman.jquery.js`: jQuery XHR
 - `batman.node.js`: "querystring" and "url"
 - `batman.solo.js`: Reqwest.js

 _note_ For the tests there are some mocked responses, in a normal non testing situation you would not use these

## How to use Batman Request

  Batman.Request can be used a variety of ways.  This is the underlying library that the `rest_storage_adapater` uses to communicate.

  In other cases where you want to communicate with a server that isn't your default storage_adapter you would use it like:

    asyncTest "Send a simple Batman.Request", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse( "GET", "http://batmanjs.org")
      stop()
      req = new Batman.Request
        url: "http://batmanjs.org"
        method: "GET"
        success: (result) ->
          start()
          ok true
      req.send()

## Lifecycle events
 There are a variety of lifecycle events that get fired in a `Request`.  Each of these are passed in as parameters in the options object in the `Request` constructor.

 1. `loading()`: fired before `send()` has been called.  Anaglous to the jQuery `beforeSend`
```
    asyncTest "Demonstrate the loading event", 1, ->
       stop()
       req = new Batman.Request
         url: "http:://batmanjs.org"
         loading: ->
           start()
           ok true, "After send but before the request is made"
        req.send()
```

 2. `loaded()`: fired after the request is complete, Anaglous to the jQuery `complete`
 ```
     asyncTest "Demo the loaded event", 1, ->
       Batman.Request.setupMockedResponse()
       Batman.Request.addMockedResponse("GET", "http://batman.js.org", -> )
       stop()
       req = new Batman.Request
         url: "http://batmanjs.org"
         loaded: ->
           start()
           ok true, "Loaded"
       req.send()
```
 3. `error( xhr )`: fired when an error is detected,  `xhr` is the `XMLHttpRequest` object with `request` being the `Batman.Request` object.
```
   asyncTest "Demo the error event", 1, ->
     Batman.Request.setupMockedResponse()
     Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
     stop()
     req = new Batman.Request
       url: "http://batmanjs.org"
       error: (xhr) ->
         start()
         ok true, "Error"
```
 4. `success ( response )`: fired when a successful request has been made, `response` is the body of the request response.
```
   Batman.Request.setupMockedResponse()
   Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo")
    asyncTest "Demonstrate the loading event", 1, ->
       stop()
       req = new Batman.Request
         url: "http:://batmanjs.org"
         success: (response) ->
           start()
           equal "foo", response
        req.send()
```
## Request::status
  The response status, only set after `error` or `success`
```
   asyncTest "Demo the error event", 1, ->
     Batman.Request.setupMockedResponse()
     Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
     stop()
     req = new Batman.Request
       url: "http://batmanjs.org"
       error: (xhr) ->
         start()
         equal 400, req.status
```
## Request::response
  The response object
```
    Batman.Request.setupMockedResponse()
    Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo")
    asyncTest "Demonstrate the loading event", 1, ->
       stop()
       req = new Batman.Request
         url: "http:://batmanjs.org"
         success: (response) ->
           start()
           equal "foo, req.response
        req.send()
```
## Request::responseHeaders : PlainObject
  An key/value object with the response headers
```
    Batman.Request.setupMockedResponse()
    Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> responseHeaders: { FOO: "bar" } )
    asyncTest "responseHeaders", 1, ->
      stop()
      req = new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
        start()
        deep_equals { FOO: "bar"}, req.responseHeaders
      req.send()
```
## Request( options : PlainObject )

  Constructs a new `Batman.Request` with the supplied options

  `options` description
  1. `url : String`: A string containing the URL to which the request is sent.  Mandatory
  2. `method : String`: The type of request to make eg. `GET`, `POST`.  Default is `GET`
  3. `data`: Data to be sent to the server. It is converted to a query string, if not already a string. It's appended to the url for GET-requests.
  4. `contentType`: the content type to send, defaults to `application/x-www-form-urlencoded`
  5. `autosend`: controls whether the request will be sent automatically, deafults to `true`
  6. `username`: username for authentication
  7. `password`: password for authentication
  8. `type`: The type of data you're expecting from the server, defaults to `json`

