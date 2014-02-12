# /api/App Components/Batman.View

`Batman.View`s connect a batman.js app to the DOM. This includes rendering HTML, handling DOM events, and maintaining view bindings. `Batman.View` extends `Batman.Object`. When subclassing `Batman.View`, you can create reusable UI components by defining attributes of the new view:

- [`::source`](/docs/api/batman.view.html#prototype_accessor_source) or [`::html`](/docs/api/batman.view.html#prototype_accessor_html) define the view's HTML.
- [`@option`](/docs/api/batman.view.html#class_function_option) adds context-based initialization options.
- [`@filter`](/docs/api/batman.view.html#class_function_filter) adds custom view filters.
- [Lifecycle hooks](/docs/views.html) fire when the view is loaded, rendered, or destroyed.

For more information about views, see [the guide](/docs/views.html).

## Accessors and Event Handlers

[View bindings](/docs/api/batman.view_bindings.html) have access to the views they're rendered by, so custom views are a great place to define view-specific accessors and event handlers. Then, you can connect them to your HTML with view bindings. For example, define a view:

```coffeescript
class CoffeeView extends Batman.View
  @accessor 'coffeeOfTheDay', -> "Guatemalan"
  drinkCoffee: -> alert("Yum!!")
```

then apply it to some HTML:

```html
<div data-view='CoffeeView'>
  <span data-bind='coffeeOfTheDay'></span>
  <button data-event-click='drinkCoffee'> Take a sip! </button>
<div>
```

Data bindings look for keys on their closest views first, so these bindings will be handled by `CoffeeView`. If the HTML inside a custom view will always be the same, you can use [`::source`](/docs/api/batman.view.html#prototype_accessor_source) or [`::html`](/docs/api/batman.view.html#prototype_accessor_html) to define it.

## ::constructor(options = {}) : Batman.View

Returns a new `Batman.View`. Since `Batman.View` extends `Batman.Object`, all `options` are mixed in to the new instance. Use this to override `html`, `node`, `superview`, `parentNode`, and/or your custom data.

## ::lookupKeypath(keypath : String)

Traverses up the view tree searching for `keypath` and returns the first
result or `undefined` if no match is found. The path it takes is:

current view → chain of superviews → layout view → active controller → app →
window

    test 'lookupKeypath returns the value if defined on the view or on an ancestor', ->
      superview = new Batman.View(cat: 'Meowie')
      subview = new Batman.View(superview: superview, dog: 'Fido')
      equal 'Fido', subview.lookupKeypath('dog'), "finds an accessor on itself"
      equal 'Meowie', subview.lookupKeypath('cat'), "finds an accessor on its superview"
      equal undefined, subview.lookupKeypath('bogusKeypath'), "returns undefined if the keypath isn't defined"

If used in an accessor, `keypath` is registered as source and will be correctly bound. `lookupKeypath` is used by [view bindings](/docs/api/batman.view_bindings.html) to get data.

## ::setKeypath(keypath, value)

Traverses the view tree searching for the specified keypath and sets the value
on the nearest ancestor which defines it. If no ancestor view defines the given
keypath, it will be set on the nearest ancestor which is not a
backing view.

`setKeypath` is used by [view bindings](/docs/api/batman.view_bindings.html) to set data.

    test 'setKeypath sets the value if defined on the view or on an ancestor', ->
      superview = new Batman.View(cat: 'Meowie')
      subview = new Batman.View(superview: superview, dog: 'Fido')
      subview.setKeypath('cat', 'Mittens')
      equal 'Mittens', superview.get('cat'), "updates an accessor on its superview"
      subview.setKeypath('dog', 'Lassie')
      equal 'Lassie', subview.get('dog'), "updates an accessor on itself"

    test 'setKeypath sets the value on the nearest non-backing view when not defined anywhere', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)
      backingView = new Batman.BackingView(superview: view)

      backingView.setKeypath('animal', 'cat')
      equal 'cat', view.get('animal')

## ::%node : Node

Returns the DOM node that this view encapsulates.

Accessing `node` will load and parse the template if it isn't already
loaded.

    test 'node parses the template', ->
      view = new Batman.View(html: '<div>cat</div>')

      node = view.get('node')
      equal 'cat', node.firstChild.innerHTML

You can also access a view's `node` in its methods, for example, activating jQuery plugins:

```
class App.SearchBarView extends Batman.View
  viewDidAppear: ->
    $node = $(@get('node'))
    $node.typeahead() # <= whatever jQuery plugin you want!
```
## ::%source : String

This string will be used to fetch a view's HTML, relative to [`Batman.config.pathToHTML`](/docs/configuration.html).
You don't need to add `.html` to this string -- it will be added automatically.

Inside a controller action, batman.js provides a default source based on the
contoller's [`routingKey`](/docs/api/batman.controller.html#routingkey_and_minification) and the [controller action](/docs/api/batman.controller.html#actions).

You can set `source` in the class definition:

```
class App.HeaderNavigationView extends Batman.View
  source: 'layout/_header'
```

Or when calling `@render()` inside a controller action:

```
class App.PostsController extends Batman.Controller
  show: ->
    @set('post', new App.Post)
    if @get('post.isAlternative')
      @render(source: "posts/alternative_new")
    else
      @render() # defaults to 'posts/new'
```

## ::%html : String

The HTML source for the view's template. Setting this will parse the template
and build bindings automatically, but it will not be inserted into the DOM
until the view is added to a superview. You can specify a view's HTML when you define the class:

```
class App.SearchBarView extends Batman.View
  html: "<input type='text' placeholder='Enter a search term' />"
```

If you don't explicitly set `html` but you do set `source`, then getting `html`
will automatically fetch the template source from the local template store.

    test 'setting a source loads the correct template', ->
      Batman.View.store.set('/animals', '<div>cat</div>')
      view = new Batman.View(source: '/animals')

      node = view.get('node')
      equal 'cat', node.firstChild.innerHTML

## @filter(label : string, filter : function)

Defines a custom [view filter](/docs/api/batman.view_filters.html) for use within the `View`.

`filter` will be invoked with the pre-filter `value` and any arguments passed to the view filter. For example:

```coffeescript
class App.MultiplierView extends Batman.View
  @filter 'multiplyBy', (value, multiplier) -> value * multiplier
```

would handle:

```html
<div data-view='MultiplierView' data-context-amount='100'>
  <span data-bind='amount | multiplyBy 6'>
    <!-- would render to "600" -->
  </span>
</div>
```

_Note_: If the `View`'s HTML is loaded before the view is instantiated, this filter won't have been defined yet and batman.js will throw an error. Avoid this by defining your custom filter at app-level or by defining the `View`'s HTML with [`::source`](/docs/api/batman.view.html#prototype_accessor_source) or [`::html`](/docs/api/batman.view.html#prototype_accessor_html).

## @option(keys...)

Defines a custom option for the `View`. `@option` allows you to initialize your view with data from its context. For example:

```coffeescript
class App.MultiplierView extends Batman.View
  @option 'amount', 'multiplier'
  @accessor 'finalAmount', -> @get('amount') * @get('multiplier')
```

```html
<div data-view='MultiplierView' data-view-amount='10' data-view-multiplier='8'>
  <span data-bind='finalAmount'>
    <!-- would render to "80" !-->
  </span>
</div>
```

Options passed with `data-view-#{option}` may also be keypaths. Keypath changes will be tracked by the view.

## ::.superview : Batman.View

Returns the view's superview. Every view except an app's `LayoutView` has a superview.

## ::.subviews : Batman.Set

The set of direct children of this `View`. Since it's a [`Batman.Set`](/docs/api/batman.set.html), you can operate directly on this set and batman.js will automatically keep the DOM in sync.

Adding to a view's subviews will automatically update the tree and parse
the template and bindings. If the superview is in the DOM, this will
insert the current view's node into the DOM.

    test 'adding to a superview parses bindings', ->
      superview = new Batman.View()
      view = new Batman.View(html: '<div data-bind="animal"></div>', animal: 'cat')

      superview.subviews.add(view)
      equal 'cat', view.get('node').firstChild.innerHTML

Removing from a view's subviews will automatically remove the subview from
the DOM.

    test 'removing from the current superview removes the node from the DOM', ->
      superview = new Batman.View(html: '', parentNode: document.body)
      superview.get('node')
      view = new Batman.View(html: '', superview: superview)

      ok Batman.DOM.containsNode(superview.get('node'), view.get('node'))

      superview.subviews.remove(view)
      ok not Batman.DOM.containsNode(superview.get('node'), view.get('node'))

## ::removeFromSuperview()

Removes this view from its parent (and from the DOM), without killing it.

    test 'removing from the current superview removes the node from the DOM', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)

      view.removeFromSuperview()
      ok not superview.subviews.has(view)

## ::die()

Kills this view, which renders it to forever unusable. This has the
following implications:

- The view is removed from its superview
- The view's node is removed from the DOM
- The view's bindings are destroyed
- The view's current subviews are killed

      test 'die kills the view', ->
        superview = new Batman.View()
        view = new Batman.View(superview: superview)

        view.die()
        equal true, view.isDead
        equal 0, superview.subviews.length


## ::.isDead : boolean

True if the view has been killed, false otherwise.

## ::destroySubviews()

Kills every subview of this view.

    test 'destroySubviews kills all subviews', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: superview)

      superview.destroySubviews()
      ok one.isDead
      ok two.isDead


## ::propagateToSubviews(eventOrKey : string, value : Object)

If `value` is defined, set `eventOrKey` to `value` on the entire subtree.
Otherwise, fire `eventOrKey` on the entire subtree.

    test 'propagateToSubviews propagates events', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: one)

      superview.on 'eventName', superSpy = createSpy()
      one.on 'eventName', oneSpy = createSpy()
      two.on 'eventName', twoSpy = createSpy()

      superview.propagateToSubviews('eventName')

      equal 1, superSpy.callCount
      equal 1, oneSpy.callCount
      equal 1, twoSpy.callCount

    test 'propagateToSubviews propagates keys', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: one)

      superview.propagateToSubviews('key', 'value')

      equal superview.get('key'), 'value'
      equal one.get('key'), 'value'
      equal two.get('key'), 'value'

## @viewForNode(node, climbTree = true) : Batman.View

Finds the view acting as the current context for a node — i.e. perform the
reverse mapping of the view tree to the DOM. If you pass `false` for
`climbTree`, it won't traverse up the DOM, and will return `undefined` unless
the node is the view's root.
