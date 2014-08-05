# /api/App Components/Batman.Request

`Batman.Request` is an abstraction around XHR requests. It is in abstract class and is implemented by a [platform library](https://github.com/batmanjs/batman/tree/master/src/platform):

- [`batman.jquery`](/docs/api/batman.jquery.html): jQuery XHR
- [`batman.solo`](https://github.com/batmanjs/batman/blob/master/src/platform/solo.coffee): Reqwest.js

(Platform libraries also implement `Batman.DOM` functions.)

_This documentation includes test stubs, which are not part of normal usage of `Batman.Request`!_

## How to use Batman Request

`Batman.Request` is used internally by batman.js, but you can also use it whenever you need to make AJAX requests. To make a request, simply call `new Batman.Request` with your desired options:

    test "Send a simple Batman.Request", ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse( "GET", "http://batmanjs.org", ->{})

      new Batman.Request
        url: "http://batmanjs.org"
        success: (result) ->
          ok true
      # request is sent during the constructor

This is analagous to the `$.ajax(options)` function. Options include:

- [`url`](/docs/api/batman.request.html#prototype_accessor_url) : target URL
- [`method`](/docs/api/batman.request.html#prototype_accessor_method) : HTTP method
- [`data`](/docs/api/batman.request.html#prototype_accessor_data) : data object
- [`success`](/docs/api/batman.request.html#prototype_function_success) : success callback
- [`error`](/docs/api/batman.request.html#prototype_function_error) : error callback
- [`loading`](/docs/api/batman.request.html#prototype_function_loading) : before-send callback
- [`loaded`](/docs/api/batman.request.html#prototype_function_loaded) : after-complete callback
- [`autosend`](/docs/api/batman.request.html#prototype_prototype_autosend) : send as soon as initialized

Each option is described in detail below.

## Lifecycle events

Several lifecycle events are fired during `Batman.Request::send`:

- [`loading`](/docs/api/batman.request.html#prototype_function_loading) before a request
- [`success`](/docs/api/batman.request.html#prototype_function_success) after a successful request
- [`error`](/docs/api/batman.request.html#prototype_function_error) after an unsuccessful request
- [`loaded`](/docs/api/batman.request.html#prototype_function_loaded) after a completed request (successful or unsuccessful)

They can be handled by either:

- passing a handler to the constructor
- listening for the event

For example, both of these `success` callbacks are fired:

    test "Lifecycle events are fired and called", 2, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse( "GET", "http://batmanjs.org", ->{})

      request = new Batman.Request
        url: "http://batmanjs.org"
        autosend: false
        # a named handler passed to the constructor:
        success: (result) ->
          ok true
      # a listener on the request:
      request.on 'success', -> ok true

      request.send()

## Global Request Hooks

`Batman.Request` exposes two class accessors:

- [`pendingRequestCount`](/docs/api/batman.request.html#class_accessor_pendingrequestcount): the number of pending requests
- [`requestIsPending`](/docs/api/batman.request.html#class_accessor_requestispending): true if any request is pending

These global hooks can help display loading indicators, for example:

```coffeescript
Batman.Request.observe 'requestIsPending', (newValue, oldValue) ->
  if newValue
    # requestIsPending has become `true`
    App.displayLoadingIndicator()
  else
    App.hideLoadingIndicator()
```

## ::constructor(options) : Request

Returns a new `Batman.Request`, mixing in `options`. The request is sent immediately unless `autosend: false` is passed. `options` may include:

- `method`: HTTP method for the request
- `url`: URL for the request
- `data`: JS object, payload for the request
- `loading`, `success`, `error`, `loaded`: callback functions for those events.

## ::%url : String

Target for the request. If `autosend` was `false` in the constructor, setting `url` will cause the request to send.

## ::%method[="GET"] : String

The type of HTTP request to make (eg. `GET`, `POST`). `method` is uppercased by `Batman.Request`.

    test "method test", ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("POST", "http://batmanjs.org", -> response : { FOO: "BAR" })
      new Batman.Request
        url: "http://batmanjs.org"
        method: "post"
        data: { some: "data" }
        success: (response) ->
          ok true

## ::.autosend[=true] : Boolean

If true, the request will `send` as soon as it's constructed. If false, it will send as soon as `url` is set.

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

## ::%data : Object

Data to be sent to the server. It is converted to a query string, if not already a string. It's appended to the url for GET-requests.

## ::.contentType[="application/x-www-form-urlencoded"] : String

The content type to send.

    test "contentType default", ->
       req = new Batman.Request
       equal req.contentType, "application/x-www-form-urlencoded"

## ::.status : Number

The [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes). Only set after `error` or `success`.

An error status code will cause the `Request` to fire its error handler:

    test "An error status code triggers the error handler", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
      new Batman.Request
       url: "http://batmanjs.org"
       error: (xhr) ->
         equal 400, @status

## ::.response

The response object (parsed, if possible).

    test "Demonstrate the response object", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo" )
      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          equal "foo", JSON.parse(@response)

## ::.responseHeaders : Object

An object with the response headers

    test "responseHeaders", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> responseHeaders: { FOO: "bar" } )

      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          deepEqual @responseHeaders,{ FOO: "bar" }


## ::send([data: Object])

If `autosend` is `false`, this will initiate the request.  If `autosend` is `true`, `send` is called during the constructor.

`data` takes priority over `data` passed to the constructor.

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



## ::loading()

If defined, this function is called before `send` is called. The request will also fire `"loading"`.

    test "Demonstrate the loading event", 1, ->
      new Batman.Request
        url: "http://batmanjs.org"
        loading: ->
          ok true, "After send but before the request is made"

## ::loaded()

If defined, this function is fired after the request is complete (whether success or error). The request will also fire `"loaded"`.

    test "Demo the loaded event", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> {})
      new Batman.Request
        url: "http://batmanjs.org"
        loaded: ->
          ok true, "Loaded"

## ::error(xhr)

Fired when an error is detected.  `xhr` is the platform-defined XHR object with a property named `request` being the `Batman.Request` object. The request will also fire `"error"`.

    test "Demo the error event", 1, ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> status: 400)
      new Batman.Request
        url: "http://batmanjs.org"
        error: (xhr) ->
          ok true, "Error"

## ::success(response)

Fired when a successful request is completed. `response` is the body of the response. The request will also fire `"success"`.

    test "Demonstrate the success event", 1,  ->
      Batman.Request.setupMockedResponse()
      Batman.Request.addMockedResponse("GET", "http://batmanjs.org", -> response: "foo")
      new Batman.Request
        url: "http://batmanjs.org"
        success: (response) ->
          equal "foo", response

## @%pendingRequestCount : Number

The number of `Batman.Request`s that are pending (ie, instances that have fired `loading` but haven't fired `loaded` yet).

## @%requestIsPending : Boolean

Returns `true` if `pendingRequestCount` is greater than 0.