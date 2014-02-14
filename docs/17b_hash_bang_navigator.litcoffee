# /api/App Components/Batman.Navigator/Batman.HashbangNavigator

`Batman.HashbangNavigator` extends `Batman.Navigator` to use hashbang routing. Batman.js uses `PushStateNavigator` by default, but it degrades gracefully to `Batman.HashbangNavigator` if it isn't supported. `PushStateNavigator` can be completely disabled through [configuration settings](/docs/configuration.html).

## ::.hashPrefix[= "#!"] : String

Used for parsing and building new paths.

## ::startWatching()

If `window.onhashchange` is defined, sets up a listener to call `handleHashChange` on `window.hashchange`. Otherwise, sets up an interval to call `detectHashChange` every 100 ms.

## ::stopWatching()

If `window.onhashchange` is defined, removes the listener on `window.hashchange`. Otherwise, removes the interval to call `detectHashChange`.

## ::handleHashChange()

Calls `handleCurrentLocation` unless `ignoreHashChange` has been set to true.

## ::detectHashChange()

Used if `window.onhashchange` isn't defined to determine whether the hash has changed since last time it was called.

## ::pushState(stateObject, title, path)

If `linkTo(path)` is a new path, sets `window.location.hash` to the new path.

## ::replaceState(stateObject, title, path)

If `linkTo(path)` is a new path, generates a new path and passes it to `window.location.replace`.d

## ::.ignoreHashChange : Boolean

Set to `true` by `::pushState` and `::replaceState` to avoid handling the current location twice.

## ::linkTo(url : String) : String

Joins `url` with `@hashPrefix`.

## ::pathFromLocation(location : Object) : string

Removes `hashPrefix` from `location.hash`. `location` is an object like `window.location`.

## ::handleLocation(location : object)

Calls `dispatch`, controlling for pushState URLs that may have been requested.

