# /api/App Components/Batman.App

`Batman.App` manages routing and action dispatching, as well as the initial start of the application. It is also the namespace for all `Batman.Model`s, `Batman.Controller`s, and `Batman.View`s. Only one `Batman.App` can be running on a page.

A batman.js application extends `Batman.App`. It is never instantiated and it is started by calling `run`.

```coffeescript
class @MyApp extends Batman.App
  @root 'blogPosts#index'

  @on 'run', -> alert("Welcome to my blog!")

class MyApp.BlogPostsController extends Batman.Controller
  index: -> @set('blogPosts', MyApp.BlogPost.get('all'))

class MyApp.BlogPost extends Batman.Model
  # model definition ...

MyApp.run()
```

See [`Batman.App` routing](/docs/api/batman.app_routing.html) for information about batman.js routing.

## @%current : App

The currently-running `Batman.App`. Also available at `Batman.currentApp`.

## @run()

Initializes the `Batman.App` class by:

- Closing any already-running apps
- Creates its [`dispatcher`](/docs/api/batman.app.html#class_accessor_navigator) and [`navigator`](/docs/api/batman.app.html#class_accessor_navigator) and starts the navigator.
- Instantiating the `layout` view according to the `layout` property on the `App`
- Emitting `run`

`@run` can be called before or on the `load` DOMEvent of the window.

```coffeescript
# JavaScript:
window.addEventListener 'load', ->
  MyApp.run()
# or jQuery:
$ ->
  MyApp.run()
```

## @stop() : App

Stops the `App`. The URL will stop being monitored and no more actions will be dispatched. You generally shouldn't have to call this.

## @%routes : NamedRouteQuery

Returns the `Batman.NamedRouteQuery` which allows for binding to routes on objects. See the [`data-route` binding](batman.view_bindings.html#data-route) for more information.

## @%controllers : ControllerDirectory

Returns the `Batman.ControllerDirectory` for application. `Batman.Controller` instances are accessible at the lowercase name of the controller. For example, the `TodosController` would be found at `controllers.todos`.

    test "App.controllers references a directory of controller instances", ->
      class Alfred extends Batman.App
      class Alfred.TodosController extends Batman.Controller
      controller = Alfred.get('controllers.todos')
      equal Batman._functionName(controller.constructor), "TodosController"

    test "Multi-word controller names have a lowercase first letter", ->
      class Alfred extends Batman.App
      class Alfred.ReminderEmailsController extends Batman.Controller
      controller = Alfred.get('controllers.reminderEmails')
      equal Batman._functionName(controller.constructor), "ReminderEmailsController"

_Note:_ `@controllers` should not be observed, but it is very useful for debugging.

## @.layout

`@layout` is the base view of the entire view hierarchy. By default, it will parse any `data-*` attributes in the entire document, excluding any `data-yield`'s, when `App.run()` is called. Use `MyApp.layout = null` to disable the creation of this default view.

## @%currentURL : String

The request path relative to `Batman.config.pathToApp`, including query string.

## @%currentParams : Hash

Returns the URL parameters for the current request, including the path relative to the app's base path (`Batman.config.pathToApp`). It includes named parameters (eg `id` from `/items/:id`), query string parameters (eg `key` of `?key=value`).

## @%currentRoute : ControllerActionRoute

The `Batman.ControllerActionRoute` for the current route, which exposes routing information such as `controller` and `action`.

## @%navigator : Navigator

The `App`'s `Batman.Navigator` instance.

## @%dispatcher : Dispatcher
## @%routeMap : RouteMap
## @%routeMapBuilder : RouteMapBuilder
## @paramsManager : ParamsReplacer
## @paramsPusher : ParamsPusher

## 'run' class event

`run` is fired after a successful `run`.

## 'ready' class event

`ready` is fired after the app's layout is rendered.
