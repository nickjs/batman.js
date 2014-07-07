# /api/Extras/Batman.jQuery

The `batman.jquery` extra is an implementation library for `Batman.DOM` and `Batman.Request` that depends on [jQuery](http://jquery.com/). It is packaged with batman.js builds on the [downloads page](/downloads.html).

Besides implementing `Batman.DOM` and `Batman.Request`, it adds a `"$node"` accessor to `Batman.View`, which returns the jQuery selection for the view's `node`. For example:

```coffeescript
class MyApp.CustomView extends Batman.View
  viewDidAppear: ->
    @get("$node") # => returns a jQuery selection
```

## Batman.DOM Implementation

`batman.jquery` implements the necessary functions of `Batman.DOM`: `querySelectorAll`, `querySelector`, `setInnerHTML`, `destroyNode`, `containsNode`, `textContent`, `addEventListener` and `removeEventListener`.

## Batman.Request Implementation

`batman.jquery` implements `Batman.Request::send` to use the `jquery.ajax` function.

It adds a `xhr` property to completed requests which contains the [`jqXHR` object](http://api.jquery.com/Types/#jqXHR).
