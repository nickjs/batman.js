# /api/App Internals/Bindings

Batman.js bindings are created when a `Batman.View` passes itself to the `Batman.BindingParser` constructor. When initialized, the `Batman.BindingParser` pulls out `data-` attributes from the view's HTML and uses them to instantiate new bindings.

# /api/App Internals/Bindings/Batman.DOM.AbstractBinding

`Batman.DOM.AbstractBinding` is the parent class for all batman.js view bindings. It extends `Batman.Object`.

Extended by:
- `Batman.DOM.AbstractAttributeBinding`
- `DebuggerBinding`
- `Batman.DOM.AbstractCollectionBinding`
- `Batman.DOM.DeferredRenderBinding`
- `Batman.DOM.FileBinding`
- `Batman.DOM.InsertionBinding`
- `Batman.DOM.RadioBinding`
- `Batman.DOM.RouteBinding`
- `Batman.DOM.SelectBinding`
- `Batman.DOM.ShowHideBinding`
- `Batman.DOM.ValueBinding`
- `Batman.DOM.ViewBinding`
- `Batman.DOM.ViewArgumentBinding`

## ::constructor(definition: Object) : AbstractBinding

The binding gets some of its attributes from `definition`:

- `@node`
- `@keyPath`
- `@view`
- `@onlyObserve`
- `@skipParseFilter`

And performs some setup:

- `parseFilter` unless `@skipParseFilter`
- `setupBackingView` if `@backWithView` is a view class
- `bind` if `@bindImmediately`

## ::%unfilteredValue

The value of the binding before filters are applied, determined by its `@value` literal or by looking up `@key` against `@view` with `View::lookupKeypath`.

## ::%filteredValue

The result of `unfilteredValue` passed through `@filterFunctions` with `@filterArguments`.

## ::.filterFunctions : Array

An array of functions idenitified by the binding's filters.

## ::.filterArguments : Array

An array of argument arrays for each function in `@filterFunctions`.

## ::.bindImmediately[=true] : Boolean

If `true`, bindings are initialized during the constructor. A `Batman.DOM.AbstractBinding` subclass may define this as `false` and call `bind` in its own implementation.

## ::.shouldSet[=true] : Boolean

Used by the binding to avoid multiple `set`s while updating.

## ::.isInputBinding[=false] : Boolean

Set to `true` by bindings that take user input.

## ::.onlyObserve[='all'] : String

Defines what values the binding observes. Must be in `['data', 'node', 'all', 'none']`.

## ::.skipParseFilter[=false] : Boolean

If `true`, `parseFilter` is skipped during initialization.

## ::.node

The node that this binding is defined on.

## ::.keyPath : String

The string passed to the binding, including all filters.

## ::.view : View

The `Batman.View` that rendered this binding.

## ::.backingView : View

The `Batman.View` initialized as a backing view for this binding, if one was initialized.

## ::.superview : View

Points to `@view` if a backing view was set up.

## ::.key

The first argument passed to the binding, if the first argument was a keypath.

## ::%value

The first argument passed to the binding, if the first argument was a literal value.

## ::isTwoWay() : Boolean

Returns `true` if the only argument to the binding is a keypath (`@key`) and there are no filters. In this case, batman.js can update the keypath value when the DOM changes.

## ::bind()

Adds the `Binding` to `@view`'s `bindings` and sets up observers on DOM and/JavaScript objects based on `@onlyObserve`, firing the observers once.

## ::die()

Kills the binding by forgeting all observers, `die`-ing all properties, and nullifying the binding's `@node`, `@keyPath`, `@view`, `@backingView`, and `@superview`

## ::parseFilter()

Parses the binding's `@keyPath`, including:
- populating `@filterFunctions` and `@filterArguments`
- setting `@key` or `@value`

## ::parseSegment(segment: String) : Array

Parses binding argument(s), returning an array of usable JavaScript values. If a keypath was found, it is sent back in an object like:

```javascript
{ _keypath: "keyPathString"}
```

It returns an array so that it can handle comma-separated arguments, eg those passed to the `withArguments` filter.

## ::setupBackingView(viewClass, viewOptions) : View

Sets up a new instance of `viewClass` with `viewOptions` as the binding's `@backingView`, if `@backingView` isn't already defined.

If `viewClass` isn't defined, `Batman.BackingView` is used.

# /api/App Internals/Bindings/Batman.DOM.AbstractAttributeBinding

`Batman.DOM.AbstractAttributeBinding` is the parent class for all bindings defined with "double-dash" syntax, ie `data-#{name}-#{attr}="value"`. It extends `Batman.DOM.AbstractBinding`.

Extended by:
- `Batman.DOM.AttributeBinidng`
- `Batman.DOM.ContextBinding`
- `Batman.DOM.ClickTrackingBinding`
- `Batman.DOM.ViewTrackingBinding`

## ::constructor: (defintion)

Sets `@attr` and calls `super`.

## ::.attr : String

The `attr` value parsed from: `data-#{name}-#{attr}="value"`