# /api/App Internals/Batman.Navigator

`Batman.Navigator` is an abstract class which maps URLs and `Batman.Dispatcher` actions. Batman.js provides two implementations out of the box: `Batman.PushStateNavigator` (default) and `Batman.HashbangNavigator` (enabled by a [configuration setting](/docs/configuration.html)).

It's uncommon to interact with a `Navigator` directly. Under the hood, each `Batman.App` has a `Navigator` at `MyApp.navigator` which is used for dispatching actions. This navigator is also set to `Batman.navigator`. Other uses include:

- `Batman.Navigator.normalizePath` is frequently used to join path segments
- `MyApp.navigator.linkTo` is used by `data-route` bindings
- `Batman.redirect` delegates to `MyApp.navigator.redirect`

`Batman.Navigator` does not extend `Batman.Object` so it is not observable and does not respond to `get`, `set`, or `@accessor`.

## Subclassing Batman.Navigator

A `Navigator` subclass must implement:

- `startWatching`: called inside a valid `start`
- `stopWatching`: called by `stop`
- `replaceState` : called by `::redirect` to replace the current history entry
- `pushState`: called by `::redirect` to create a new history entry
- `handleLocation`: called during routing

`Batman.PushStateNavigator` and `Batman.HashbangNavigator` both implement `Batman.Navigator`.

## ::constructor(app : Batman.App) : Navigator

Invoked by `Batman.App` via `Navigator.forApp` so that configurations are taken into account. `app` must return a `Batman.Dispatcher` from `app.get('dispatcher')`.

## ::start()

If `started` is false and `window` is defined, calls `startWatching` on the `Navigator`. If `Batman.currentApp` is defined (calling `MyApp.run` sets this value), it calls `handleCurrentLocation` on itself and fires `ready` on the `App`.

`start` is called automatically on `App.run`.

## ::stop()

Calls `stopWatching` and sets `started` to `false`. `stop` is called by `App.stop`.

## ::handleLocation(location : Object)

Gets path information from `location` and calls `dispatch`. `location` is an object like `window.location`.

## ::handleCurrentLocation()

Passes `window.location` to `handleLocation`.

## ::dispatch(params : Object)

Calls `dispatch` on the `Navigator`'s `Dispatcher`, controlling for the presence of a hashbang as needed.

## ::redirect(params : Object, replaceState[= false] : Boolean)

Redirects to a new path using `::replaceState` if `replaceState` is true, otherwise using `::pushState`. `params` may be:

- a string, which is treated as the target path (eg, `"/posts"`)
- a `Batman.Model` class, which redirects to "index" (eg, `Batman.redirect(MyApp.Post)` redirects to `"/posts"`)
- a `Batman.Model` instance, which redirects to "show" (eg, `Batman.redirect(thisPost)` redirects to `"/posts/#{thisPost.toParam()}"`)
- an object containing params:
  - `Batman.redirect({controller: "posts", action: "index"})` redirects to  `"/posts"`
  - `Batman.redirect({controller: "posts", action: "edit", id: 6})` redirects to `"/posts/6/edit"`

## ::normalizePath(segments...) : String

Normalizes the `/`s in `segments` into a valid path, returning `"/"` if segments is empty.

    test "normalizePath corrects and joins path segments", ->
      equal Batman.Navigator::normalizePath('villains', 4, 'edit'), '/villains/4/edit'
      equal Batman.Navigator::normalizePath('/villains/', '/4/', '/edit/'), '/villains/4/edit'
      equal Batman.Navigator::normalizePath('', ''), '/'

## ::.started : Boolean

Returns `true` if `start` was called or `false` if `stop` was called.

## @normalizePath(segments... : String) : String

Alias of [`::normalizePath`](/docs/api/batman.navigator.html#prototype_function_normalizepath).

## @forApp(app : Batman.App)

Returns a new instance of the class provided by `@defaultClass`.

## @defaultClass()

Returns `Batman.PushStateNavigator` or `Batman.HashbangNavigator` based on [`configuration`](/docs/configuration.html).
