# /api/App Components/Batman.View/Batman.View Bindings

Batman's view bindings are how data gets shown and collected from the user. They center on the notion of "bindings": that the view representation and the JavaScript land value are always guaranteed to be in sync, such that when one changes, the other will reflect it.

## How to use bindings

Bindings are declared as attributes on nodes under the `data` namespace. In practice, it looks like this:

```html
<div data-bind="name"></div>
```

This instantiates a binding on the `div` node which will update the node's `innerHTML` with the value found at the `name` keypath in the <a href="#batman-view-bindings-binding-contexts">current context</a>. Whenever the `name` key changes, the div's `innerHTML` will update to the new value.

Nodes can have multiple bindings:

```html
<p data-bind="body" data-showif="isPublished"></p>
```

or attribute bindings:

```html
<p data-bind-id="currentID"></p>
```

and bindings can be on inputs which the user can change:

```html
<input type="text" data-bind="title"></input>
```

When the `title` property changes on the JavaScript object this `input` is bound to, the `input`'s value will be updated. When the user types into the `input` (and `change` or `keyup` events are triggered), the `title` property in JavaScript land will be updated.

## Binding Keypaths

A `keypath` is the value of the HTML attribute a binding references. Importantly, keypaths can have multiple segments:

```html
<p data-bind="order.customer.name"></p>
```

The keypath in the above HTML is `order.customer.name`. When you create a binding to a keypath like this (with dots separating segments), the binding will update the HTML value when _any_ of those segments change. In the above example, this means the `p` tag's `innerHTML` will be updated when:

 1. the order changes,
 2. the order's customer changes,
 3. or the order's customer's name changes.

This is important because it means you can rely on a binding to "just work" when anything it depends on changes. If say you had a `<select>` on the page which changed the `order`'s `customer` property, bindings which bind to `order.customer.name` will update each time you change that select to reflect the new customer's name.

## Binding Contexts

All bindings render in a context. Binding contexts, known internally to Batman as `RenderContext`s, are objects which emulate the notion of variable scope in JavaScript code. When a controller action renders, it passes a context to the view consisting of itself, the `App`, and an object with a `window` key pointing to the host `window` object.

## Keypath Filters

Bindings can bind to filtered keypaths:

```html
<p data-bind="post.body | truncate 100"></p>
```

The above `<p>` will have 100 characters worth of the post's body. Whenever the post's body changes, it will be retruncated and the `<p>`'s `innerHTML` will be updated.

Filter chains can be arbitrarily long:

```html
<span data-bind="knight.title | prepend 'Sir' | append ', the honourable'."></span>
```

and filter chains can use other keypaths as arguments to the filters:

```html
<span data-bind="person.name | prepend ' ' | prepend person.title"></span>
```

The above `<span>`'s `innerHTML` will be updated whenever the person's name or title changes.

#### Two Way Bindings and Filters

Note that filtered keypaths cannot propagate DOM land changes because values can't always be "unfiltered". For example, if we bind an input to the truncated version of a string:

```html
<input data-bind="post.body | truncate 100"></input>
```

The `<input>`'s value can be updated when the `post.body` property changes but if a user types into this input field, they will edit the truncated body. If Batman updated the `post.body` property with the contents of the input, all characters which had been truncated will be lost to the nether. To avoid this loss of information and inconsistency, bindings to filtered keypaths will _only update from JavaScript land to HTML_, and never vice versa.

#### Available Keypath Filters

The following is a list of available keypaths that can be used with bindings. For a more complete description with accompanying examples see `Batman.View Filters`
 + `ceil` : Runs `Math.ceil` on input value.
 + `floor` : Runs `Math.floor` on input value.
 + `round` : Runs `Math.round` on input value.
 + `precision` : Runs `toPrecision()` on input value.
 + `fixed` : Runs `toFixed()` on input value.
 + `delimitNumber` : Adds comma delimiters to a number

## Keypath Literals

Keypaths also support a select few literals within them. Numbers, strings, and booleans can be passed as arguments to filters or used as the actual value of the keypath.

The following are all valid, albeit contrived, bindings:

```html
<!-- String literal used as an argument -->
<p data-bind="body | append ' ... '"></p>

<!-- Boolean literal used as an argument -->
<p data-showif="shouldShow | default true"></p>

<!-- Number literal used as an argument -->
<p data-bind="body | truncate 100"></p>

<!-- String literal used as the value -->
<p data-bind="'Hardcoded'"></p>

<!-- Boolean literal used as the value -->
<p data-showif="true"></p>
```

## data-bind

`data-bind` creates a two way binding between a property on a `Batman.Object` and an HTML element. Bindings created via `data-bind` will update the HTML element with the value of the JS land property as soon as they are created and each time the property changes after, and if the HTML element can be observed for changes, it will update the JS land property with the value from the HTML.

`data-bind` will change its behaviour depending on what kind of tag it is attached to:

 + `<input type="checkbox">`: the binding will edit the `checked` property of the checkbox and populate the keypath with a boolean.
 + `<input type="text">` and similar, `<textarea`>: the binding will edit the `value` property of the input and populate the keypath with the string found at `value`.
 + `<input type="file">`: the binding will _not_ edit the `value` property of the input, but it will update the keypath with a host `File` object or objects if the node has the `multiple` attribute.
 + `<select>`: the binding will edit the `selected` property of each `<option>` tag within the `<select>` matching the property at the keypath. If the `<select>` has the multiple attribute, the value at the keypath can be an array of selected `<option>` values. You can also use `data-bind-selected` bindings on the individual options to toggle option selectedness.
 + All other tags: the binding will edit the `innerHTML` property of the tag and will not populate the keypath.

`data-bind` can also be used to bind an attribute of a node to a JavaScript property. Since attributes can't be observed for changes, this is a one way binding which will never update the JavaScript land property. Specify which attribute to bind using the "double dash" syntax like so: `data-bind-attribute="some.keypath"`. For example, to bind the `placeholder` attribute of an input, use `data-bind-placeholder`.

```html
<input type="text" data-bind-placeholder="'Specify a subtitle for product ' | append product.name">
```

_Note_: `data-bind` will not update a JavaScript property if filters are used in the keypath.

## data-source

`data-source` creates a one way binding which propagates only changes from JavaScript land to the DOM, and never vice versa. `data-source` has the same semantics with regards to how it operates on different tags as `data-bind`, but it will only ever update the DOM and never the JavaScript land property.

For example, the HTML below will never update the `title` property on the product, even if the user changes it. Each time the `title` attribute changes from a `set` in JavaScript land, the value of the input will be updated to the new value of `title`, erasing any potential changes that have been made to the value of the input by the user.

```html
<input type="text" data-source="product.title">
```

_Note_: `data-source-attribute` is equivalent to `data-bind-attribute`, since the former is defined as never making JS land changes, and the latter is unable to.

## data-target

`data-target` creates a one way binding which propagates only changes from the DOM to JavaScript land, and never vice versa. `data-target` has the same semantics with regards to how it operates on different tags as `data-bind`, but it will never update the DOM even if the JavaScript land value changes.

_Note_: `data-target-attribute` is unavailable, because DOM changes to node attributes can't be monitored.


## data-showif / data-hideif

`data-showif` and `data-hideif` bind to keypaths and show or hide the node they appear on based on the truthiness of the result. `data-showif` will show a node if the given keypath evaluates to something truthy, and `data-hideif` will leave a node visible until its given keypath becomes truthy, at which point the node will be hidden. `data-showif` and `data-hideif` show and hide nodes by adding `display: none !important;` to the node's `style` attribute.

For example, if the HTML below is rendered where the keypath `product.published` evaluated to true, the `<button>` will be visible.

```html
<button data-showif="product.published">Unpublish Product</button>
```

This is the Batman equivalent of a templating language's `if` construct, where else branches are implemented using the opposite binding.

```html
<button data-showif="product.published">Unpublish Product</button>
<button data-hideif="product.published">Publish Product</button>
```

## data-addclass / data-removeclass

`data-addclass` and `data-removeclass` bindings can be used to conditionally add or remove a class from a node based on a boolean keypath. Specify the class to add using the "double dash" syntax; for example,`data-addclass-big="some.keypath"` on a node will add the "big" class to that node's classes if `some.keypath` is truthy. `data-removeclass` will remove a class (usually one which is present in the HTML) if the keypath passed to it is truthy.

The outer span in the HTML below will have an "error" class when the `product.errors.length` keypath evaluates to anything other than 0, since 0 is falsy and other numbers are truthy.

```html
<p data-addclass-error="product.errors.length">
  This product has <span data-bind="product.errors.length"></span> errors.
</p>
```

## data-foreach

`data-foreach` is used to loop over an iterable object in Batman views. `data-foreach` duplicates the node it occurs on for each item in the collection found at the keypath given to it, and renders each duplicated node with that node's object from the collection by putting it in the context under a name passed to it using the "double dash" syntax.

The `<option>` node below will be duplicated for each item in the `Set` at the `products` keypath.

```html
<select>
  <option data-foreach-product="products" data-bind="product.name"></option>
</select>
```

Batman will execute the `data-foreach` binding before the `data-bind` on the `<option>` node, which means that the `data-bind` will be processed for each duplicated node with each separate Product in the `products` Set in scope for each separate node. If there were say 3 Products in the `products` set, the HTML would look similar to this once rendered:

```html
<select>
  <option data-bind="product.name">Product A</option>
  <option data-bind="product.name">Product B</option>
  <option data-bind="product.name">Product C</option>
  <!-- end products -->
</select>
```

`data-foreach` can be used to iterate over `Batman.Set`s, and most often should be, because it observes any Sets and will update the DOM with new nodes if items are added to the set, or remove nodes from the DOM if their corresponding nodes are removed from the set. `data-foreach`, like every other binding, is keypath aware, such that if the `Set` instance at the keypath changes, or any previous segment of the keypath changes, `data-foreach` will remove all the nodes currently in the DOM, and add new nodes for each new item in the incoming `Set`.

Sometimes you'll need to add some custom logic to the iteration nodes. For example, a custom `viewDidAppear` handler so you can know whenever a new iteration node appears in the DOM. You can do this by specifying a custom subclass of `Batman.IterationView`.

```html
<ul>
  <li data-foreach-product="products" data-view="ProductIterationView">
    <span data-bind="product.name"></span>
  </li>
</ul>
```

```coffeescript
class MyApp.ProductIterationView extends Batman.IterationView
  viewDidAppear: ->
    $(@get('node')).draggable()
```


_Note_: `data-foreach` expects to find an iterable object at the keypath given to it, and will emit a warning if it finds `undefined`.

_Note_: `data-foreach` expects the passed enumerable to be unique. It creates a map of nodes to items, so every node needs to be able to reference exactly one object. If you simply have a set of values that you're iterating over, you should wrap your values in objects, e.g. `[{value: true}, {value: true}]`.

## data-formfor

`data-formfor` creates a special addition to the context stack to represent an object under edit within a form. Usually this object is a model. Using the double dash syntax, the name for the model to reside under can be specified.

==== Automatic Validation Display

`data-formfor` also has some handy functionality for displaying the result of validating the object under edit in the form. This will only be enabled if the object has an `errors` Set, like `Batman.Models` do.

If a tag matching the relative selector `.errors` is found, it will populate this element with a list of the errors found during validation on the object. The selector for the errors container can be changed by adding a `data-errors-list` attribute with the value of the selector to the form with the `data-formfor` binding on it, or editing `Batman.DOM.FormBinding::defaultErrorsListSelector`.

If value bindings are made using `data-bind` to attributes on the model within the form, automatic `data-addclass-error` bindings will be added to the elements on which the `data-bind` occurs to add the "error" class when the model has errors on the attribute which `data-bind` binds to.

In the HTML below, an automatic `data-addclass-error` will be added to the `<input>` which activates when the `product` model has validation errors on the `name` attribute.

```html
<form data-formfor-product="currentProduct">
  <input type="text" data-bind="product.name"></input>
</form>
```

The class which gets automatically added to inputs binding to invalid attributes can be customized by editing `Batman.DOM.FormBinding::errorClass`.

## data-context

`data-context` bindings add the object found at the key to the context stack, optionally under a key using the double dash syntax.

For example, if a `product` object exists in the current context, the `data-context` binding below will expose its attributes at the root level of the context:

```html
<div data-context="product">
  <span data-bind="name"></span>
  <span data-bind="cost"></span>
</div>
```

Contexts added to the stack can also be scoped under a key using `data-context-`:

```html
<div data-context-currentProduct="product">
  <span data-bind="currentProduct"></span>
  <span data-bind="currentProduct"></span>
</div>
```

This is a useful mechanism for passing local variables to partial views.

## data-event

`data-event` bindings add DOM event listeners to the nodes they exist on which call the function found at the passed keypath. `data-event` bindings use the double dash syntax to specify the name of the event to listen for.

In the HTML below, if the keypath `controller.nextAction` resolves to a function, that function will be executed each time the `<button>` element is clicked.

```html
<button data-event-click="controller.nextAction"></button>
```

Functions which `data-event` calls will be passed the node and the `DOMEvent` object: `(node, event) ->`.

`data-event` supports the following types of events formally and should "do the right thing" when attached to elements which fire these events:

 + click
 + doubleclick
 + change
 + submit

If the event name used doesn't match the above events, the event name used will just fall through and be passed to `window.addEventListener`.

## data-route

`data-route` bindings are used to dispatch a new controller action upon the clicking of the node they bind to. `data-route` expects to find either a string or a `NamedRouteQuery` at the keypath passed to it. With this route, it will add an event handler to the `click` action of the element which dispatches the route and prevents the default action of the DOMEvent. `data-route` will also populate the `href` attribute if it occurs on an `<a>` tag so that other functions like "Copy Link Address" and Alt+Click continue to work on the link.

The first way to use `data-route` is by passing it a string, which can be built using filters or an accessor, but the preferred way is to use the `NamedRouteQuery`. These objects are generated for you by starting keypaths at the `App.routes` property. All `Batman.App`s have a `routes` property which holds a nested list of all the routes, which you descend into by passing various key segments and objects. Since the `App` object is present in the default context stack, `data-route` keypaths can just start with `routes`.

For example, assume the following routes definition in the current `Batman.App`:

```coffeescript
class Alfred extends Batman.App
  @resources 'todos'
```

This means that routes like `/todos` and `/todos/:id` exist. To route to the collection action, use the plural name of the resource:

```html
<a data-route="routes.todos"></a>
```

To route to an individual todo things get a bit more complicated. If we have a Todo model with ID# `42` in the context as `todo`, use the `get` filter shorthand on the `NamedRouteQuery` returned by `routes.todos` to generate a member route:

```html
<a data-route="routes.todos[todo]"></a>
```

Underneath, this is calling `Alfred.get('routes.todos').get(todo)`; the todo object is being passed as a key to the `NamedRouteQuery`, which knows how to generate a member route when given a record. The above HTML when rendered will look like this:

```html
<a data-route="routes.todos[todo]" href="/todos/42"></a>
```

This syntax can be extended to nested routes. If we have nested routes, we can use chained gets to generated nested routes

```coffeescript
class Tracker extends Batman.App
  @resources 'villains', ->
    @resources 'crimes'
```

Routes for collection and member crimes should look like `/villains/:villain_id/crimes` and `/villains/:villain_id/crimes/:id` respectively. Assuming the presence of a `villain` and a `crime` in the context, chained `get`s on `NamedRouteQuery`s achieve this:

```html
<!-- Collection of crimes for a particular villain -->
<a data-route="routes.villains[villain].crimes"></a>
<!-- One crime of a particular villain -->
<a data-route="routes.villains[villain].crimes[crime]"></a>
```

_Note_: `data-route` bindings route only to internal dispatch, and not external links. Use a regular `<a>` tag to link away from the application.

## data-route-params

Adds the provided keypath or literal value to the route provided to `data-route`. For example:

```html
<a data-route='routes.villians.new' data-route-params='"mastermind=true"'>Mastermind</a>
```

will route to `/villians/new?mastermind=true` and

```
<a data-route='routes.villians.new' data-route-params='otherRouteParams'>Other</a>
```

will look up `otherRouteParams` and append it to `/villains/new`, adding a `?` if necessary.

## data-view

`data-view` bindings attach custom `Batman.View` instances or instantiate custom `View` subclasses to / on a node. `data-view` expects either a `Batman.View` instance or subclass at the keypath passed to it. If an instance is passed, it will `set` the `node` property of the view to the node the `data-view` occurs on. If a class is passed, that class will be instantiated with the context the `data-view` binding executed in and with the node it occurred upon. See `Batman.View` for more information on custom Views and their uses.

_Note_: `data-view` bindings will bind to the passed keypath until it exists, that is to say until the value of it is not `undefined`. After the `View` has been set up, the `data-view` binding will remove itself and stop observing the keypath.

## data-partial

`data-partial` pulls in a partial template and renders it in the current context of the node the `data-partial` occurs in. `data-partial` expects the name of the view to render in the value of the HTML attribute. __Warning__: This value is not a keypath. The HTML attribute's value is interpreted as a string, and the template which resides at that view path will be rendered.

If we have this HTML at `views/villains/_stub.html` in our app:

```html
<span data-bind="villain.name"></span>
```

and in `views/villains/show.html` we have this HTML:

```html
<h1>A villain!</h1>
<div data-partial="villains/_stub"></div>
```

the contents of the `stub` partial will be inserted and rendered in the `<div>` above.

## data-defineview
`data-defineview` specifies that the content of the node defines the template for a particular view.

The binding value should be a regular view path, i.e. "#{resource_name}/#{controller_action}". For example:

```html
<div data-defineview="crimes/index">
  <ul class="crimes">
    <li class="crime" data-foreach-crime="crimes">
      <span data-bind="crime.name" data-addclass-heinous="crime.heinous" />
    </li>
  </ul>
</div>
```

will be used by the `CrimesController`'s  `index` action.


## data-renderif / data-deferif

`data-renderif` (and `data-deferif`) defers parsing of a node's child bindings until its keypath updates to true (or false, respectively). Note that this does not prevent the node from being inserted into the DOM. These bindings should generally be combined with a `data-showif` or `data-insertif` to prevent it from being visible until it is ready.

Deferring rendering can help prevent portions of the page updating many times while data is being loaded. It can also allow you to prevent features that are not yet ready from being used.

## data-yield

`data-yield` specifies that this node should be a render target for any view renderings that specify they should be rendered into a yield with this name. For example, `data-yield="myYieldNode"` can be rendered into by using `new Batman.View(contentFor: 'myYieldNode')`. The special case of `data-yield="main"` will be the render target for any view rendered by a controller action. This can mean the implicit render that happens by default at the end of a controller action or by explicitly calling `@render` inside a controller.

You can also specify a render target inside your HTML using `data-contentfor`.

```html
<div data-yield="main"></div>
```

## data-contentfor

`data-contentfor` specifies that the content of this node should be rendered into a `yield` with the corresponding name.

```html
<div data-contentfor="header"><h1 data-bind="title"></h1></div>
<div data-yield="header"></div>
```

# /api/App Components/Batman.View/Batman.View Filters

Batman filters are evaluated from left to right, with the output of each filter being injected into the next. This allows you to form filter chains for display purposes. Accessor caching does not apply to filter chains. If any component of the chain changes, the entire chain will be recalculated for each binding in the template.

## ceil(value) : string

The `ceil` filter will run `Math.ceil` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | ceil"></span>
```

## floor(value) : string

The `floor` filter will run `Math.floor` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | floor"></span>
```

## round(value) : string

The `round` filter will run `Math.round` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | round"></span>
```

## percision(value, toPlace) : string

The `precision` filter will run `toPrecision()` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | precision"></span>
<span data-bind="someValue | precision 3"></span>
```

## fixed(value, toPlace) : string

The `fixed` filter will run `toFixed()` on the input value. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | fixed"></span>
<span data-bind="someValue | fixed 3"></span>
```

## delimitNumber(value) : string

The `delimitNumber` filter will comma delimit a 'number'. Value can be either a `string` or `integer`

```html
<span data-bind="someValue | delimitNumber"></span>
```

## raw(value) : string

The `raw` filter renders the unescaped value.

```html
<span data-bind="someHTMLyString | raw"></span>
```

## get(value, key) : value

Calls the get function on the input value with the specified key. Can be used with `Batman.Accessible` and `Batman.TerminalAccessible`:

```html
<span data-bind="accessibleFunction | get 'item'"></span>
```

## value[key] : value

Shorthand for the `get` filter.

## equals(left, right) : boolean

Checks if left content is equal to right content:

```html
<span data-showif="title | equals 'Batman Views'"></span>
```

## not(value) : boolean

Inverts the truthiness of the input value:

```html
<span data-hideif="title | equals 'Batman Views' | not | and action | equals 'show'"></span>
```

## matches(value, string) : boolean

Tests a string against the input value:

```html
<span data-showif="title | matches 'Bat'"></span>
```

## truncate(value, length, end = '...') : string

Limits the length of output to the specified length and appends the specified text if over the limit:

```html
<span data-bind="page.title | truncate 5, '…'"></span>
```
Would result in:
```html
<span data-bind="page.title | truncate 5, '…'">About…</span>
```

## default(value, defaultValue) : value

Provides a default value if the keypath is falsy:

```html
<input type="text" data-bind="page.title | default 'About Us'"></input>
```

## prepend(value, string) : string

Prepends the string to the input value:

```html
<span data-bind-class="page.tag | prepend 'ico-'"></span>
```
If page.tag is 'about' this would result in:
```html
<span data-bind-class="page.tag | prepend 'ico-'" class="ico-about"></span>
```

## append(value, string) : string

Appends the string to the input value:

```html
<span data-bind-class="page.tag | append '-ico'"></span>
```
If page.tag is 'about' this would result in:
```html
<span data-bind-class="page.tag | append '-ico'" class="about-ico"></span>
```

## replace(value, searchString, replaceString[, flags]) : string

Replaces content in the input value matching the `searchString` with the `replaceString` value:

```html
<span data-bind="page.title | replace 'html', 'HTML'"></span>
```

## downcase(value) : string

Downcases the input value:

```html
<span data-bind="page.title | downcase"></span>
```

## upcase(value) : string

Upcases the input value:

```html
<span data-bind="page.title | upcase"></span>
```

## pluralize(value, count) : string

Pluralizes the input value based on the patterns specified in `Batman.helpers.inflector` and the count provided:

```coffeescript
( ->
  @singular /(analysis)$/i, '$1'
  @singular /(analy)ses$/i, '$1sis'
).call(Batman.helpers.inflector)
```

```html
<span data-bind="'analysis' | pluralize page.comments.count"></span>
```

## humanize(string) : string

Takes a string and makes it human readable, for example 'an_underscored_string' would become 'An underscored string'.

```html
<span data-bind="'about_us_page' | humanize"></span>
```
Would result in:
```html
<span data-bind="'about_us_page' | humanize">About us page</span>
```

## join(value, separator = '') : string

Joins an `array` of values into a single string:

```html
<span data-bind="page.comments | map 'title' | join ', '"></span>
```

## sort(value) : value

Sorts an `array` using the default comparison:

```html
<span data-foreach-comment="page.comments | sort" data-bind="comment.title"><span>
```

## map(iterable) : value

Maps the specified keypath from an `array` of objects:

```html
<span data-foreach-author="page.comments | map 'author'" data-bind="author"><span>
```

## has(iterable, item) : boolean

Calls the `iterable`'s `has` function to check for the existence of the specified `item`.

```coffeescript
class Sample.FirstController extends Batman.Controller
  index: ->
    @set('things', new Batman.Set('thing1', 'thing2'))
```

```html
<input type="checkbox" data-bind-checked="things | has 'thing1'"></input>
```
If you were to dispatch `first#index`:
```html
<input type="checkbox" data-bind-checked="things | has 'thing1'" checked="true"></input>
```

## first(iterable) : value

Returns the first value from an `array`:

```html
<span data-context-firstComment="page.comments | first"></span>
```

## meta(value, keypath) : value

## interpolate(string, valuesObject) : string

Allows you to use string interpolation:

```html
<span data-bind="'The page title is %{title}%' | interpolate {'title': 'page.title'}"></span>
```

## withArguments(function, curriedArguments...) : function

Ensures that the function is called with the supplied arguments in addition to the arguments it would normally be called with. This is a form of currying. The argument order will be the curried arguments (those passed to withArguments) first, then the regular arguments. In the case of a click event, the regular arguments are node, event, view.

```coffeescript
class Sample.CloseWindowView extends Batman.View
  html: '<span data-event-click="closeWindow | withArguments true"></span>'

  closeWindow: (actuallyClose) ->
    window.close() if actuallyClose
```

```html
<div data-view="CloseWindowView"></div>
```

## escape(value) : string

Escapes HTML in the input value:

```html
<textarea data-bind="page.body_html | escape"></textarea>
```
