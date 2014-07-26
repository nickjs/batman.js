# Batman.config

`Batman.config` is a namespace for global batman.js settings. The affect all apps running on the page. Set these values before defining your app. For example:

```coffeescript
Batman.config.pathToHTML = '/templates'
Batman.config.usePushState = false

class MyApp extends Batman.App
  # ...
```

## @pathToApp[="/"]

Use this if your batman.js app is loaded from a path other than `/`. For example, if you load your app at `/app`, you'd use:

```coffeescript
  Batman.config.pathToApp = '/app'
```

Any generated routes will be then be prefixed with `/app`.

## @pathToHTML[="/html"`]

If the app hasn't already loaded the HTML to render a view, it will request the HTML with an AJAX request. `pathToHTML` is used as the prefix for these requests.

The `Batman.rails` extra sets `Batman.config.pathToHTML= '/assets/batman/html'`.

## @fetchRemoteHTML[=true]

batman.js automatically fetches a view's HTML if it hasn't been loaded yet. If `fetchRemoteHTML` is false, an error will be thrown instead.

## @usePushState[=true]

Set to `false` to use batman.js's hashbang navigator instead of the (default) `pushState` navigator. Note: the `pushState` navigator automatically degrades to the hashbang navigator if not supported by the browser.

## @protectFromCSRF[=false]

Used by `Batman.rails`. If `protectFromCSRF` is true, batman.js sends CSRF token as a request header (`X-CSRF-Token`). batman.js uses `metaNameForCSRFToken` to find the correct meta tag.

The `Batman.rails` extra sets `Batman.config.protectFromCSRF = true`, but you must set it yourself if you're using Rails-style CSRF tokens _without_ the `Batman.rails` extra.

## @metaNameForCSRFToken[="csrf-token"]

If `protectFromCSRF` is true, the contents of the meta tag with this name will be used as the CSRF token. This default is set in the `Batman.rails` extra.

## @cacheViews[=false]

If set to true, batman.js will cache `Batman.View` instances between `render` calls. View caching is opt-in [while its implementation is finalized](https://github.com/batmanjs/batman/issues/805).

