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
