# /api/App Components/Batman.Navigator/Batman.PushStateNavigator

`Batman.PushStateNavigator` extends `Batman.Navigator` to use `pushState`. Batman.js uses `PushStateNavigator` by default, but it degrades gracefully to `Batman.HashbangNavigator` if it isn't supported. `PushStateNavigator` can be completely disabled through [configuration settings](/docs/configuration.html).


## @isSupported() : Boolean

Returns `true` if `window.history.pushState` is defined.

## ::startWatching()

Adds a listener to call `handleCurrentLocation` on `window.popstate`.

## ::stopWatching()

Removes the `handleCurrentLocation` listener on `window.popstate`.

## ::pushState(stateObject, title, path : String)

If `path` isn't the same as `window.location`'s path, passes `stateObject`, `title`, and `@linkTo(path)` to `window.pushState`.

## ::replaceState(stateObject, title, path : String)

If `path` isn't the same as `window.location`'s path, passes `stateObject`, `title`, and `@linkTo(path)` to `window.replaceState`.

## ::linkTo(url : String) : String

Returns a correct path by joining `url` and `Batman.config.pathToApp` with `Batman.Navigator.normalizePath`.

## ::pathFromLocation(location : Object)

Generates a correct app-specific path with `location`, removing `Batman.config.pathToApp`. `location` is an object like `window.location`.

## ::handleLocation(location : Object)

Dispatches the proper action. `location` is an object like `window.location`. `PushStateNavigator::handleLocation` also handles hashbang paths, in case someone pastes a hashbang URL.


