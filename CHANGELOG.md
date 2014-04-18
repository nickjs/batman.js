Besides lots of bug fixes, documentation updates, etc, here some major changes:

- batman.js node package was removed
- added `cake build` and `cake build:dist` for compiling batman.js https://github.com/batmanjs/batman/pull/864

### Batman.Object
- `Batman.Object.delegate` was added https://github.com/batmanjs/batman/pull/830
- `@delegate` handles `set` and `unset` too https://github.com/batmanjs/batman/pull/982
- `@classDelegate` to delegate `classAccessor` https://github.com/batmanjs/batman/pull/1001

### Batman.Set
- `::toJSON` iterates over members and calls `toJSON` on them https://github.com/batmanjs/batman/pull/905

### Batman.Hash
- `::toJSON` iterates over members and calls `toJSON` on them https://github.com/batmanjs/batman/pull/905

### Batman.Model
- `AssociationSet::load` takes options and passes env https://github.com/batmanjs/batman/pull/825
- Added 401 Error to StorageAdapter https://github.com/batmanjs/batman/pull/860
- Added `onlyInteger` to Numeric Validator https://github.com/batmanjs/batman/pull/867
- `@belongsTo` keys always return `BelongsToProxy` https://github.com/batmanjs/batman/pull/891
- `@encode`'s `as` option can be a function https://github.com/batmanjs/batman/pull/863
- `::validate` fires `validated` if validation was successful https://github.com/batmanjs/batman/pull/943
- `@validate` allows `if` https://github.com/batmanjs/batman/pull/883
- `@validate` accepts `email: true` with EmailValidator https://github.com/batmanjs/batman/pull/940
- `::save` accepts `only` or `except` with keys https://github.com/batmanjs/batman/pull/951
- Added `@createMultipleFromJSON` https://github.com/batmanjs/batman/pull/981
- `@hasMany` doesn't coerce primary key integer-like strings to integers https://github.com/batmanjs/batman/pull/866
- Added `Model::transaction` and `Batman.TransactionAssociationSet` for editing records https://github.com/batmanjs/batman/pull/992
- Added `::reflectOnAllAssociations` and `::reflectOnAssociation` https://github.com/batmanjs/batman/pull/992
- Association `saveInline` defaults to false https://github.com/batmanjs/batman/pull/1028
- Calls to `Model.find` for the same ID are pipelined like `Model.load` https://github.com/batmanjs/batman/pull/1026 
- `validate associatedFields: true` pushes messages from associated records to this record https://github.com/batmanjs/batman/pull/995
- `AssociationSet::build(attrs)` creates a child record with `attrs` and adds it to the set https://github.com/batmanjs/batman/pull/995

### Batman.Controller
- default to current controller when redirecting https://github.com/batmanjs/batman/pull/999

### Batman.View
- `@filter` was added https://github.com/batmanjs/batman/pull/804
- Filters are available in subviews https://github.com/batmanjs/batman/pull/870
- `data-track` binding was added https://github.com/batmanjs/batman/pull/835
- Added `data-route="routes.root"` for routing to "/" https://github.com/batmanjs/batman/pull/865
- Views rendered from controllers will use `::source` unless overridden in `@render()` https://github.com/batmanjs/batman/pull/909
- InsertionBinding and ShowHideBinding use `fireAndCall` for lifecycle events https://github.com/batmanjs/batman/pull/931
- Added `data-deferif` https://github.com/batmanjs/batman/pull/925
- `data-bind-class` doesn't overwrite existing classes https://github.com/batmanjs/batman/pull/958
- Added filters `ceil`, `floor`, `round`, `precision`, `fixed` and `delimitNumber` https://github.com/batmanjs/batman/pull/954
- Added filters `lt`, `gt`, `lteq`, `gteq`, `eq`, and `neq` https://github.com/batmanjs/batman/pull/1009
- added `primaryInteractionEvent` & `primaryInteractionEventName` to allow use with touch https://github.com/batmanjs/batman/pull/880
- `@validate` `if` & `unless` take strings which are looked up on the record https://github.com/batmanjs/batman/pull/1012
- `AssociationSet::build` adds a child record with passed attributes https://github.com/batmanjs/batman/pull/994
- `@validate 'key', associatedFields: true` pushes messages from associated records to this record https://github.com/batmanjs/batman/pull/995

### Batman.I18N
- Translation filters fixed, `@useFallback` for cases of missing translations https://github.com/batmanjs/batman/pull/988

## 0.15.0 (September 4th, 2013)

Major changes:

### Batman.Object
- Support Keypaths with `-` or `_` e7fb66681bc0d685a3a45b6ed74f0455d949fd2d
- Added `EventEmitter::off`

### Batman.Model
- Added Inclusion/Exclusion validators 114fb3b6fb8ffaed7389663611334eb073ed2b46
- Added `encoderKey` option for associations c6f24a9984891dfb2164417812f22cbcaaf3432e

### Batman.Controller
- Remove viewContext a784bd3f6b9776aca99cb32ce01eefb693c1cab9
- Use `Batman.LifecycleEvents` for before/after filters  950607e91d5546078394a1f531e2a4d633108d2a

### Batman.View
- Big breaking changes: `data-mixin` removed.
- Remove mixins 997c7b9063837e7ba147ddf94a0a0f2d634350b0
- Optimize IteratorBinding 5eecbe7b7aec101d629e9ba77fb2d483936de466
- `data-style` for binding to specific CSS properties 0c23ef6ff6de6c259cb7ca6fb51e7502e35be188
- disable View cache 0b5c8f9f3e1f3b55d1569b0fccad57ce5a6d3f85
- Support multiple classes with `data-addclass` adf963a581e4942a72f7b7b6e3892ab0d5afc845
- Added `lookupKeypath`, `setKeypath` and `targetForKeypath` for context lookups
- `viewPrefix` config renamed to `pathToHTML`
- default path for HTML templates switched from `/views` to `/html`
- `ViewStore` renamed to `HTMLStore`. Renamed its functions "view" -> "HTML" also.

### Batman.App
- Removed `App.require`-related code bf59e2b180f1a72c7ad73f127d2e81247d519064

### Batman.TestCase
- XHR assertions fcd428c8e0b7a50b6892673ed672f5d16bda08ec
- Added `stubAccessor` bdf5e03c2b8871db53c1ee0c9f5006d6fda70740

### Batman.Set
- `toArray` registers the base as a source 7c17daf041c569ba8b0609bb06d6e58ddcd2bc90

### Batman.Rails
- Added: CRSF Token support 635463b458d8417d152d4211d0b079d5bb513183
- Added: `encodeTimestamps` 7056f43d88c7ddb950b94a7401e7d4f242b266ad
- Config `pathToHTML` defaults to `/assets/batman/html`

### Other
- Added `Batman.Enumerable::count` f53e99025d2a5e437263510ca1c15fa734e7afe9
- Added `Batman.LifecycleEvents` 97ad1a98fc1b2c0b288e2e66768b3aaa4b717a46
- Use LitCoffee docs 35287a20f594c8e8bca9f05de1bb8e0d73b21a6f
- Removed Batman cli tools 798884cece6e7000c8ab8dd4d5a33d00c503aeb6
- Config `pathPrefix` renamed to `pathToApp`


Lots of other bug fixes and performance improvements! See all at https://github.com/batmanjs/batman/compare/v0.14.1...v0.15.0

## 0.14.1 (Febrary 15th, 2013)

Forgot to bump a version number to fix the version number test.

## 0.14.0 (February 14th, 2013)

https://github.com/Shopify/batman/compare/v0.13.0...master


## APP
- Added: `App.shouldAllowEvent.[event]`. Callbacks in this hash will be called whenever the corresponding `data-event` is fired from anywhere within the app. Return false to prevent app-level propagation. For example:
```coffeescript
class MyApp extends Batman.App
  @shouldAllowEvent.click = (event) ->
    return false
```
- Fix: Prevent additional history items from being created if the users navigates to the page they are already on.
- Fix: Nested resource routing names.
- Deprecated: App loader utilities: `App.controller`, `App.model`, `App.view`, `App.require`. Batman does not care how you load your code, as long as it's loaded before calling `App.run`.

## MODELS
- Added: Substantially better for support for polymorphic associations.
- Added: Configure custom URL's for associations. Typically used for resources whose backends aren't quite as RESTful as they should be.
- Added: A server response of 422 will result in the response being parsed as an error and the response's data being used injected into `errors`.
- Added: A server response of 409 will result in a `RecordExistsError`.
- Added: `NumericValidator` can now compare for equality.
- Added: `Batman.Model._mapIdentities` to map many items and then add them to the set all at once.
- Performance: `Batman.Model.loadWithOptions` uses `mapIdentities` instead of `mapIdentity`.
- Change: Model instance methods are no longer bound to themselves. If you're passing model methods as callbacks make sure you bind them manually!
- Fix: Respect sorted order in `SetSort::find`.
- Fix: Respect sorted order of `SetSort::merge`.

## VIEWS
- Change: Moved the `Batman.ViewStore`'s `fetchFromRemote` and `prefix` properties to `Batman.config` and rename them to `fetchRemoteViews` and `viewPrefix`.
- Fix: `Batman.DOM.setStyleProperty` will respect `!important` in all browsers.
- Fix: Don't intercept middle-click events.

## BINDINGS
- Change: Rename `Binding` to `ValueBinding`.
- Fix: Biding to the correct option when loading a `<select>` element. If the data is null when the binding is created, we bind to an option with an empty string.
- Fix: Parsing keypaths that begin with numbers.
- Added: The ability for bindings within subviews to update their values that have been added to the context via `data-bind`.
- Deprecated: `data-confirm` event attribute.

## FILTERS
- Fix: The prepend and append filters don't prepend/append undefined to the string if the value is undefined. `data-bind="undefinedValue | append 'my string'"` now returns `my string` and not `undefinedmy string`.

## ACCESSORS
- Change: Promise accessors return the result of their promise function, such that promises which return valueA and asynchronously deliver valueB retune the delivered valueB instead of the returned valueA.
- Change: Class promise accessors are now be recalculated after calling clear, e.g. `Product.clear()`.
- Added: `Batman.Object::_resetPromise`.

## GLOBAL
- Added: A deprecation mechanism. Putting `Batman.developer.deprecated` inside a function will log a warning in the console in development mode.
- Fix: Some cases where `clearImmediate` would break IE.
- Fix: IE7 inability to access a character from a string using the index `[]` notation.
- Fix: Support all symbols with unescapeHTML. e100aca
- Fix: Bug in reduce where the reduction function returning undefined caused undesirable return values.
- Fix: Bug when using arrays of models as the keys of a `Batman.Hash`.
- Fix: Ensure that `add` is only called once when multiple items are added to a `SetSort` at the same time.

## PERFORMANCE & TESTING
- Performance: Fight off hoardes of DOM memory leaks.
- Performance: Speed up `Batman.SimpleSet` iteration.
- Performance: Speed up `Batman.Property` iteration when firing some observers.
- Performance: Added Two levels of caching for `_batman` ansestors.
- Performance: Use arrays instead of sets in hot functions.
- Performance: Remove splats in hot functions.
- Performance: Avoid creating `EventEmitter` events when not necessary.
- Fix: Watson and Tiller integration.

## 0.13.1 (September 13th, 2012)

Patch Release

Bug Fixes

 - Make the prepend and append filters use the empty string if passed undefined (#543)
 - Fix a bug with InsertionBinding throwing DOM exceptions if the bound keypath changed from a falsy value to another falsy value. (#512)
 - Fix a bug with the solo build throwing errors on load due to a missing semicolon with reqwest. (#552)

## 0.13.0 (September 11th, 2012)

Major Release

Breaking Changes:

 - Removed top level DOM helpers from the `Batman` namespace and moved them to the `Batman.DOM` namespace. The moved helpers are `setInnerHTML`, `propagateBindingEvent`, `propagateBindingEvents`, `trackBinding`, `onParseExit`, `forgetParseExit`, `setStyleProperty`, `destroyNode`, `removeOrDestroyNode`, `insertBefore`, `addEventListener`, `removeEventListener`, `hasAddEventListener`, `preventDefault`, `stopPropagation`, and `appendChild`.
 - Moved the DOM helpers which could be expressed using platform specific code into the platform adapters. This means that `Batman.DOM.setInnerHTML` will use `jQuery.fn.html` when using the jQuery platform adapter and the old implemention when using `solo`. Affected helpers are `querySelector`, `querySelectorAll`, `appendChild`, `removeNode`, `destroyNode`, and `setInnerHTML`,
 - Removed support for daemonizing the `batman` server tool.

Features

 - Add `Controller::handleError()`, `Controller::errorHandler()`, and `Controller.catchError` for regstering error handlers and wrapping callbacks to automatically handle errors coming back from async operations.
 - Remove `Model.lifecycle` (`Model::lifecycle` still exists) and switched to `loading` and `loaded` events instead so that multiple loads can occur at the same time.
 - Formalize error objects returned from `RestStorage`. eg, `UnprocessableEntityError` comes back from a `422` response. These error objects also have reference to the `env` for the operation as well as the `request`.
 - Allow `Model.persist` to take more than one object to mixin to the storage adapter.
 - Add `record.get('isDirty')` as a shortcut to check if a model is in the dirty state.

Bug Fixes

 - Make `hasMany` associations use the same sets before and after a record has an ID. (#537)
 - Make `belongsTo` associations replace the `proxy` object in the parent's property after the association is loaded.
 - Make `IteratorBinding` recover gracefully when the bound collection returns undefined for `toArray`.
 - Fix a bug in `EventBinding` where proxied values could cause non existant event handlers to fire causing browser errors.
 - Fix routing bugs surrounding regexp indexes in IE8.
 - Made `EventBinding`s not interfere with control or command clicks instead of calling the handler regardless of what modifier keys were pressed.
 - Fix underscoring in route names for nested member and collection routes. (#547)
 - Made filters which can't operate on null not operate on null.

## 0.12.0 (August 23rd, 2012)

Major Release

Breaking Changes:

 - Switch the interpretation of `Model.url` and `Model::url` to respect absolute and relative routes, and only in the case of relative routes prepend the `urlPrefix`.
 - Ensure that lifecycle events happen on models before validation takes place.

Features:

 - Add `Model.createFromJSON` as a shortcut for booting models from JSON and sticking them in the identity map
 - Add the `as` option to `Model.encode` which allows serialization into a key other than the key mentioned in `encode`
 - Add Rails style optional route segments with `()`
 - Add a `trim` filter
 - Give most validations the `allowBlank` option to force them to pass if the value is undefined or the empty string
 - Add an `AssociatedValidator` added by calling `Model.validate 'name', associated: true`
 - Make Controllers stop executing the rest of the action when a redirect occurs in a beforeFilter.
 - Add a `Proxy` class for proxying an object
 - Allow `EventEmitter::on` to take more than one key to attach a handler to

Bugfixes:

 - Fix a bug where radio buttons didn't quite work properly if their `value` HTML attributes were strings (#500)
 - Fix a bug where views would render when given a node regardless if their source was present or not. (#501)
 - Fix a bug with the pluralize filter not working correctly when passed "0" (#520)
 - Switch to not changing the URL in the address bar on 404s. (#524)
 - Fix a bug where redirecting during an existing redirect sequence would cause the oldest instead of the newest path to end up in the URL bar. (#536)
 - Ensure that lifecycle events happen on models before validation takes place.

## 0.11.2 (July 17th, 2012)

Really Minor Release

 - Add the association `extend` option to allow mixing in an object to an association Rails style

## 0.11.1 (July 11th, 2012)

Minor Release

 - Add Batman.DOM.querySelector and Batman.DOM.querySelectorAll helpers to wrap whatever methods are available for doing such things
 - Add the `key` an observer is on to the arguments passed to the observe
 - Switch the `or` filter to be a real boolean ||
 - Make the inferred view class a Controller checks for when rendering play nice with nested routing keys
 - Add the `encodeForeignKey` option to belongs to associations to allow disabling of the foreign key encoding.

Bugfixes:

 - Fix a race condition surrounding data-defineview sometimes causing views to be fetched from the server (#476)
 - Make autogenerated route names match the rest of the named routes generated (using . instead of CamelCaseing)
 - Fix Controller to allow operations to take place after an action without issue
 - Make the `default` filter check for both blank strings or non existing values
 - Fix model dirty tracking to really keep track of the clean value (#482)
 - Mark `AssociationSet`s as loaded if their parent is a new record and that parent is saved

## 0.11.0 (June 25th, 2012)

Minor Release (but it changes major node versions)

 - Improve `$setImmediate` performance on node
 - Remove the "bind to an object full of keys pointing to keypaths" functionality from `StyleBinding` due to complexity and underuse.
 - Add `Hash.meta.toArray` accessors and enumerability
 - Make `RestStorage` respect URLs passed to it in options, say, from `Model.Request`
 - Add `SetComplement` for getting a set of items in one set but not another. This *complements* SetIntersect and SetUnion quite nicely if you ask me.
 - Make `Set` use a user land quality test for membership checks. This means two objects which aren't `===` can define `isEqual` to return true and only one will end up in a `Set`.
 - Ensure records can save successfully after failing validation once before.
 - Rename `Object._objectID` to `Object._batmanID`
 - Remove `Batman.Request::cancel` and the extra `setImmediate` required for its implementation.
 - Add `data-insertif` and `data-removeif` bindings which downright remove nodes from the DOM instead of CSS'ing them away.
 - Make the automatic application of resource URLs on the server to Models no longer automatic and instead an option on the association macro
 - Add special behaviour for `params['#']` in controller actions to scroll to an element with that ID if it exists
 - Make Controller after filters run truely after the action's operations have completed. This is to say after render and DOM insertion.
 - Make `URI` mutable and add a `toString` to get back the URI string.
 - Allow view classes to declare they aren't cacheable.
 - Add a regexp validator accessible with `@validates 'foo', pattern: /foo/`
 - Give `ValidationError`s a `fullMessage` accessor which does the i18n stuff.
 - Add the `humanize` helper to `Batman.helpers` and to `Batman.Filters`

Bugfixes:

 - Prevent unloaded but autoloading associations from autoloading during encoding.
 - Fix dirtyKey tracking when the value is set to `null` or `undefined` after having an initial value.
 - Properly propagate changes into JS land when text is pasted into inputs when supported by browsers.
 - Make `currentURL`, `currentRoute` and `currentParams` available during beforeFilters.
 - Fix the generators to a) work and b) generate more modern code.
 - Fix a bug in the `HasManyAssociation` decoder which could result in duplicate entries being added to the identity map when nested associations were decoded.

## 0.10.0 (May 30th, 2012)

Major Release

 - Refactor StateMachine class to be its own class with transitions, callbacks, and predicates
 - Reimplement the Model lifecycle as a StateMachine residing at .get('lifecycle')
 - Implement load pipelining to multiplex multiple `load` calls to the same outgoing request if a second call is issued while a first is pending
 - Add the `@option` class macro to Views to allow the declaration of `data-view-myargument="keypath"` argument passing to custom views
 - Make the Model `@encode` macro use the default unit function for the absent options if only an `encode` or `decode` option is passed.
 - Make `@urlNestsUnder` allow multiple levels of nesting
 - Add a `RenderCache` clas which will cache major views rendered by `Controller::render`
 - Make `Controller` use previously rendered views from the `RenderCache` instead of rendering new ones
 - Remove the ability for views to be "container nodes". Views now have one root node always.
 - Make View insertion and removal indempotent, including with regards to yields. This means that if a view is removed from the DOM, it will retract nodes yielded elsewhere, and when reinserted, it will reinsert those yields into contentfors.
 - Add `View::inInDOM()` to ask a view if it is currently in the DOM or not, which indicates if it is safe to destroy.
 - Add behaviour to `SelectBinding` to update the JS land value with the first selected option if no JS land value was present.
 - Add `SetIndex#forEach` for looping over sets corresponding to particular values.
 - Add `Controller#executeAction` for executing other actions within a parent action
 - Add `Enumerable#inGroupsOf` for getting an enumerable partitioned into groups of a particular length
 - Make `Batman.helpers.pluralize` act more like the Rails version and not include the count when called in JS land.
 - Expose `RestStorageAdapter`'s environment allowing access to the meta information surrounding a request.
 - Move `Paginator` into an extra so people not using don't pay the filesize penalty
 - Remove unimplemented ability to have multiple storage adapters on Models.
 - Add `get`, `put`, `post`, and `delete` actions to `RestStorage` for doing "non-standard" requests while still using the nice request adapter pipeline
 - Add `Model.request` for sending nonstandard requests instead of having to use raw `Batman.Request`s
 - Add ability for `NamedRouteQuery` to accept arguments which aren't full objects and are the value of the params. "data-route='routes.customers[1]' instead of "data-route='routes.customers[customer]'"
 - Add the `$extend` helper, which is a lightweight `$mixin` which doesn't use `set`.
 - Add ability to not include the count in the `pluralize` helper
 - Add minification saftey warnings and the requirement for `resourceName` to be defined on Model subclasses and `routingKey` to be defined on Controller subclasses
 - Add the `isNew` accessor to Models
 - Add a Batman.URI class
 - Add node v0.7 compatibility and remove v0.4 compatibility
 - Unified params serialization to use `Batman.URI.paramsFromQuery`
 - Let the implicit `@render` call in controller actions be configurable via `Controller::defaultRenderYield`
 - Add `observeOnce` for observing a property change and then immediately removing the observer after the first time it fires.

Meta

 - Update QUnit to `1.5`
 - Updated to CoffeeScript `1.3.2`
 - Updated Alfred example to the TodoMVC version
 - Break out classes into seperate files compiled by snockets.

Bugfixes:

 - Fix serialization of null to end up as null in JSON or absent in post bodies (#364, #365)
 - Fix filter argument parsing to support string literals and object literals in more cases (#373)
 - Make select bindings more cautious about updating the JS land property on first bind (#377, #378)
 - Fix click event propagation around `RouteBindings`
 - Make `NamedRouteQuery` not loudly error with undefined params.
 - Fix `Model.get('all')` to always load even if other `load`s have occurred already (#401)
 - Stop Model operations from adding erroneous sources to enclosing accessors. (#406)
 - Fix Request sending in IE8 when the `File` object doesn't exist.
 - Fix a bug where filter args could be carried over between executions (#438)
 - Fix file uploads using jQuery
 - Ensure filters receive undefined for absent arguments

## 0.9.0 (April 1, 2012)

Really Major Release

 - Add node v0.6.x support
 - Add documentation.
 - Benchmarking suite added
 - Add `Batman.SessionStorage` storage adapter for using the `sessionStorage` host object
 - Make `<select>` bindings populate JS land values if an option has the selected attribute.
 - Add `data-view` bindings for instantiating custom `Batman.View` subclasses
 - Add support for closure compiler
 - Add AMD loader support
 - Add JS implementation of ActiveSupport::Inflector for pluralization and ordinalization
 - Pass the RenderContext to event handlers called by data-event bindings.
 - Add support for string data in batman.solo and batman.node
 - Make `view.set('node')` work like one might expect (deffering rendering until the node is present)
 - Add `Model.clear` for busting the identity map.
 - Add `Batman.Property.withoutTracking` helper for swallowing dependencies in accessor bodies
 - Add `SetUnion` and `SetIntersection`
 - Add `withArguments` filter for currying arguments to event handlers
 - Add decoding of ISO-8601 dates to `RailsStorage`, optionally with timezones
 - Add `FileBinding` for binding <input type="file">
 - Swtich data-route bindings into real bindings and add a named route query syntax (routes)
 - Ensure bindings with filters become simple one way JS -> DOM bindings, since we can't always unfilter
 - Add `Enumerable.mapToProperty` for fetching a single property of a bunch of items in a collection
 - Formalize data-formfor bindings to have handy functionality like adding error classes to inputs bound to invalid fields and adding a list of errors to the form if an element with a .errors class exists
 - Major routing system refactor to support nested resources declarations and the named routes syntax
 - Add `replace` filter
 - Add `Set.find(f)` which returns the first item in the set for which `f(item)` is truthy
 - Add binding content escaping, and thus the `escape` and `raw` filters
 - Make `AssociationSets` fire a `loaded` event
 - Refactor the `RenderContext` stack into a proper tree with one root node to limit memory usage
 - Add ability to give false as the value of encode or decode when adding encoders to omit that half of the process
 - Add polymorphic belongsTo and hasMany associations
 - Add @promiseAccessor for easy wrapping of asynchronous operations into eventually defined accessors
 - Add `Batman.View.event('appear')`, `beforeAppear`, `disappear`, and `beforeDisapper` which will fire as views enter and exit the dom
 - Reimplement Hash storage mechanism for greater speed and less memory usage
 - Reimplement Set storage mechanism for greater speed and less memory usage. Note: this changes set iteration order.
 - Reimplement event storage mechanism for similar speed and less memory usage
 - Add wrapAccessor macro for redefinining accessors in terms of their old implementations
 - Add `urlNestsUnder` macro to `Model` for easy definiton of nested backend routes
 - Add `EventEmitter::once` for attaching handlers which autoremove themselves
 - Add `Batman.getPath` for doing recursive gets on properties without encoding the key seperator

Bugfixes:

 - Process bindings in a consistent order (#204)
 - Ensure attribute bindings bind undefined as the empty string (#245)
 - Ensure RestStorage passes the proper Content-type on POST and PUT operations.
 - Make `data-target` bind immediately and populate the JS land value at that time
 - Fix bugs surrounding replacing classes with spaces (#305, #361)
 - Ensure encoding and decoding respect custom primary keys
 - Fix a slew of bugs surrounding associations to custom primary keys
 - Fix textarea bindings to set the value across all browsers
 - Add proper bindings for HTML5 inputs like type=search, type=tel, and so on
 - Ensure event handlers on yielded content are not destroyed during yielding
 - Ensure showif bindings work regardless of the node's initial CSS (#261)
 - Support controllers named AppController (#326)
 - Ensure model classes don't inherit parent class state (#340)
 - Ensure `SetSort` properly propagates length property (#355)
 - Ensure non-existent models don't get added to the identity map (#366)
 - Ensure data-route bindings stop event propagation (#369)

## 0.8.0 (November 22, 2011)

Major Release

 - Add `Batman.StateHistory` for pushState navigation support
 - View source html can be prefetched via `View.viewSourceCache.prefetch`
 - Major refactoring of view bindings into class based hierarchy
 - Add `data-defineview` to allow view sources to be declared inline
 - Add Association support to Model via `Model.hasOne`, `Model.hasMany`, `Model.belongsTo`
 - Add smart AssociationProxy objects which support reloading
 - Add support for loading associations with inline JSON
 - Add support for `?` and `!` in property names and keypaths
 - Store the current `params` on the `Batman.currentApp` for introspection.
 - Add `ParamsReplacer` and `ParamsPusher` as smart objects which when set, update the global params, pushState or replaceState, and redirect.
 - Add `Hash::update`, `Hash::replace`, and `Set::update`
 - Add `Set::indexedByUnique`
 - Add `Batman.contains` for membership testing and accompanying `has` filter
 - Add support for JSONP requests in `batman.solo`
 - Add `final` property support to optimize observing properties which will never change
 - Add `Batman.version`
 - Add support for customizable render targets in `Controller::render`

Bugfixes:

 - `Hash::clear` now fires observers for cleared keys
 - Properties are no longer retained if they aren't being observed to reduce memory usage
 - `IteratorBinding` can have its sibling node changed without erroring
 - Filter arguments can be keypaths which start on or descend through POJOs
 - `data-context` now correctly only takes effect for its child nodes
 - `data-event-*` has a catchall to attach event listeners for any event
 - Made `Batman.data` work in IE7
 - Made `Batman.Model` properly inherit storage adapters
 - Made `data-bind-style` bindings camelize keys
 - Fixed major memory leaks around Bindings never being garbage collected via Batman.data
 - Made `Renderer::stop` work if called before the renderer started
 - Stop mixing `Observable` into `window` to error earlier when accidental sets and gets are done on `window`
 - Fix memory leaks around View instances never being garbage collected
 - Fix memory leaks around IteratorBinding instances growing with time
 - Fix memory leaks around SetIndex observing all items forever
 - Fix sets on POJOs from keypaths
 - Fix `batman.solo` to properly encode GET params
 - Fix `Model::toJSON` and `Model::fromJSON` to)deal with falsey values like any other
 - Remove ability for `View` instances to have either `context` or `contexts`, and unify on `context`.
 - Fix error thrown if the `main` yield didn't exist
 - Made the extras files requirable in node
 - Fix an invalid data bug when receiving large responses using `batman.node`
 - Fix JSON de-serialization when receiving collection responses using `batman.node`
 - Fix support for non numeric model IDs
 - Fix `data-partial` and `data-yield` to stop introducing superfluous divs.

## 0.7.5 (October 25, 2011)

Major Maintenance Release

  - pagination through `Batman.Paginator` and `Batman.ModelPaginator`
  - nested resources routes
  - unknown params passed to `urlFor` will be appended to the query string
  - `App.layout` accepts a class name which will automatically instantiate that class upon load
  - `Controller::render` accepts an `into` option, which lets you render into a yield other than `main`
  - `yield/contentFor/replace` are now animatable through `show/hide`
  - `interpolate` filter
  - pleasant reminders if you seem to have forgotten some encoders
  - removing nodes will destroy all their bindings
  - `Batman.setImmediate` for fast stack popping

Bugfixes:

  - `App.ready` is now a oneShot event
  - `App.controller/model/view` are now only available in development
  - `data-foreach` (through Iterator) is now entirely deferred
  - better support for `input type='file'`
  - sets within gets don't register sources
  - fixes several memory leaks
  - better view html caching

## 0.7.0 (October 12, 2011)

Major Maintenance Release

  - added extras folder
  - start of i18n features
  - overhauled event system, which properties are now clients of (requires code changes)
  - `Property::isolate` and `Property::expose` will prevent a property from firing dependent observers
  - `data-contentFor` will now append its content to its `data-yield`
  - `data-replace` will replace the content of its `data-yield`
  - descending SetSorts
  - `Batman.App` fires a `loaded` event when all dependencies are loaded
  - `Batman.App.currentRoute` property for observing
  - allow `controller#action` syntax in `data-route`

Bugfixes:

  - use persistent tree structure for RenderContext
  - keep track of bindings and listeners with Batman.data
  - correctly free bindings and listeners
  - coerce string IDs into integers when possible in models
  - accessors are memoized
  - suppress developer warnings in tests
  - don't match non `data-*` attributes
  - fix `data-bind-style`

## 0.6.1 (September 27, 2011)

Maintenance Release

  - added `Batman.Enumerable`
  - added support for multi-select boxes
  - added batman.rails.coffee, a new adapter for use within Rails
  - added developer namespace for easy debugging (it gets stripped out in building)
  - one way bindings have been changed to `data-source` and `data-target` to avoid ambiguity
  - added `data-bind` support for `input type='file'`
  - added `data-event-doubleclick`
  - added `length` filter
  - added `trim` helper
  - `Controller.resources` creates a `new` route instead of `destroy`
  - `Model.find` will always return the shared record instance. you can then bind to this and when the data comes in from the storage adapter, your instance will be updated
  - added `Model::findOrCreate`
  - added `Model::updateAttributes`
  - allow storage adapters to specific their namespace with `storageKey`
  - storage adapter filter callbacks take errors
  - added `App.ready` event that fires once the layout is ready in the DOM
  - normalize `status`/`statusCode` in `Batman.Request`
  - hashes now have meta objects to non-obtrusively bind metadata like `length`
  - the `property` keyword is no longer reserved

Bugfixes:

  - `Controller.afterFilter` was missing
  - hash history uses `Batman.DOM.addEventListener`
  - routes such as `data-route="Model/new"` will route correctly
  - fix `Batman.DOM.removeEventListener` so it doesn't depend on document
  - fire `rendered` event after all children have been rendered
  - model methods can be used as event handlers
  - animation methods called with node as context
  - `data-event` works within the binding system
  - simpler model identity mapper
  - `SortableSet::clear` invalidates sort indices
  - IE: doesn't have Function.prototype.name (move things into $functionName)
  - IE: doesn't support `isSameNode`
  - IE: doesn't support `removeEventListener` (use `detachEvent` instead)
  - IE: fix $typeOf for undefined objects
  - IE: event dispatching fixes
  - IE: include json2.js in the tests

## 0.6.0 (September 13, 2011)

Major Maintenance Release

  - added `Batman.Accessible`, a simple object wrapper around an accessor
  - added `Batman.SetSort` for getting a sorted version of a set which automatically watches the source set and propagates changes
  - added `Batman.SetIndex` for getting a filtered version of a set which automatically watches the source set and propagates changes
  - added after filters to `Batman.Controller`
  - moved `Batman.Model` attributes into an attributes hash to avoid namespace collisions with model state.
  - added `Batman.data` for safely attaching JS objects to DOM nodes
  - added support for many `[]` style gets in filters
  - added asymmetric bindings (`data-read` and `data-write`)
  - ensured Batman objects are instantiated using `new` (#65)
  - added support for radio button `value` bindings (#81)
  - added `Batman.Encoders` to store built in encoders, and added `Batman.Encoders.RailsDate`
  - added `status` to `Batman.Request`, normalizing XHR object's `status`/`statusCode`
  - added proper parameter serialization to the `batman.solo` platform adapter

Bugfixes:

  - fixed `batman server` options (`batman -b server` works as expected)
  - fixed binding to `submit` events on forms (#6)
  - fixed Renderer's ready events to fire when all child renderers have returned (#13)
  - fixed textarea value bindings to work as expected (#20)
  - made bindings to undefined populate their nodes with an empty string instead of "undefined" (#21)
  - made `data-foreach`, `data-formfor`, `data-context`, and `data-mixin` all work as expected when the collection/object being bound changes (#22)
  - fixed `LocalStorage`'s primaryKey generation (#27)
  - made `Request` send the proper content type (#35)
  - made the current application always appear on the context stack (#46, #48)

  - made `@render false` prevent render on a controller action (#50)
  - made `data-foreach` work with cleared sets and many additions/removals (#52, #56, #67)
  - made empty bindings work (#54)
  - made `Set`s not leak attributes when given items to add in the constructor (#66)
  - prevented `@redirect` from entering a redirect loop when using `hashchange` events (#70)
  - made `showif` and `hideif` bindings play nice with inline elements (#71)
  - made jQuery record serialization work with `RestStorage` (#80)
  - made `Model.get('all')` implicitly load (#85)
  - fixed binding to `state` on models (#95)
  - made `Hash` accept keys containing "." (#98)

## 0.5.1 (August 25, 2011)

Maintenance Release

  - `batman server` is now `batman serve` (or still `batman s`)
  - Configure the hostname for the server with -h
  - CI support with [Travis](http://travis-ci.org/#!/Shopify/batman)

Bugfixes:

  - RestStorage uses correct HTTP methods and contentType
  - Some improvements for `batman new`, more coming in 0.5.2
  - DOM manipulation performance improvement

Known issues:

  - Apps generated with `batman new` are somewhat broken
  - Generators allow too many non-alphanumeric characters

## 0.5.0 (August 23, 2011)

Initial Release

Known issues:

  - Inflector support is naive
  - Code is too big
  - Performance hasn't been investigated
  - Filters don't support async results
  - Model error handling is callback based

Missing features:

  - Model assosciations
  - Model scopes
  - Model pagination
  - Push server
  - Documentation
