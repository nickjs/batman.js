# /api/App Internals/Batman.Dispatcher

`Batman.Dispatcher` infers routing information from other objects and uses it to dispatch controller actions. It extends `Batman.Object`.

Although it's rare to interact with a `Dispatcher` directly, every `Batman.App` has a dispatcher at `MyApp.get('dispatcher')` once it is running.

## ::constructor(app: App, routeMap: RouteMap) : Dispatcher

Returns a new `Batman.Dispatcher` for the `Batman.App` and `Batman.RouteMap`.

## ::dispatch(params, paramsMixin)

Uses `params` to infer a route, then mixes in `paramsMixin` and dispatches a `Batman.Route` with the mixed-in result.

If `routeForParams` returns a `Batman.Route`, the dispatcher updates

- `app.currentRoute` with the route
- `app.currentURL` with the pathname
- `app.currentParams` with the mixed-in params

and then dispatches the route.

Otherwise, it fires `error` on the `App` and redirects to `/404`.

## @canInferRoute(argument) : Boolean

Returns `true` if `argument` is a `Batman.Model` instance, a `Batman.Model` constructor, or a `Batman.AssociationProxy`. In these cases, it can be transformed into routable params by `Batman.Dispatcher.paramsFromArgument`.

## @paramsFromArgument(argument) : Object

If `@canInferRoute(argument)` is false, returns `argument` unchanged. If `argument` is a `Batman.Model` instance or a `Batman.AssociationProxy` instance, it will return an object like:

```coffeescript
{
  controller: "#{ClassNameForArgument}"
  action:     "show"
  id:         "#{argument.toParam()}"
}
```

If `argument` is a `Batman.Model` constructor, it will return an object like:

```coffeescript
{
  controller: "#{ClassNameForArgument}"
  action:     "index"
}
```

## ::%controllers : ControllerDirectory

Returns the [`ControllerDirectory`] for the `Dispatcher`

## ::routeForParams(argument) : Route

Runs `argument` through `Batman.Dispatcher.paramsFromArgument`, then returns the `Batman.Route` from the `Dispatcher`'s `routeMap`.

## ::pathForParams(argument) : String

Returns the stringified path from the `Batman.Route` for `argument`.

# /api/App Internals/Batman.Dispatcher/ControllerDirectory

`ControllerDirectory` extends `Batman.Object` and it is defined in the scope of `Batman.Dispatcher`. A `ControllerDirectory` instance looks up controller instances ([`Batman.Controller.sharedController`](/docs/api/batman.controller.html#class_accessor_sharedcontroller)) by their instance names:

```coffeescript
controllerDirectory.get('blogPosts') # => <BlogPostsController>
```

This functionality is implemented in `ControllerDirectory`'s [default accessor](/docs/api/controllerdirectory.html#default_accessor). You can access your app's controller directory at:

```coffeescript
MyApp.get('controllers') # => <ControllerDirectory>
```

## ::%__app : App

Returns the `Batman.App` passed to the constructor by `Batman.Dispatcher`.

## Default Accessor

A `ControllerDirectory`'s default accessor returns controller instances by looking them up on its `__app`. The key will be capitalized and interpolated into `#{key}Controller`:

```coffeescript
controllerDirectory.get('blogPosts') # => <BlogPostsController>
```

