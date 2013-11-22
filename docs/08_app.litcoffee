# Batman.App

`Batman.App` is the central object in any Batman application. It manages the routing table and the current URL parameters, as well as the initial start of the application. It should also be used as a namespace for models and views so that other objects can find them. Batman assumes that there will only ever be one `Batman.App` in use at once.

## Batman.currentApp

A Batman-wide reference to the currently running `Batman.App`.

## @run() : App

`App.run` is the central entry point for a Batman application. `@run` takes these steps to initialize a Batman application:

 1. Instantiate a `Dispatcher`, an internal object for mananging action dispatch to controllers.
 2. Instantiate a `Navigator`, an internal object for managing the URL via pushState or hashbangs.
 3. Instantiate the `layout` view according to the `layout` property on the `App`.
 4. Wait for the layout view to fire it's `ready` event.
 5. Start the first action dispatch by telling the `Navigator` to begin monitoring the URL.

_Note_: `@run` emits the `run` class event on the `App`, but not necessarily as soon as `@run` is called. Because the `layout` View renders asynchronously and may need to fetch other components, the `run` event can and often does fire long after `@run` is called. If you need to execute code as soon as the `App` has started running, add a listener to the `run` event on the `App` class. If you need to execute code as soon as the layout has rendered, you can use the `ready` event on the `App` class.

`@run` can be called before or on the `load` DOMEvent of the window. `@run` will return the App if the commencement was successful and complete, or `false` if the App must wait for the `layout` to render or if the `App` has already run.

#### starting an application with DOMEvents
```coffeescript
window.addEventListener 'load', ->
  MyApp.run()
```

#### starting an application with jQuery
```coffeescript
$ ->
  MyApp.run()
```

## @stop() : App

`@stop` stops the `App` it's called upon. The URL will stop being monitored and no more actions will be dispatched. In usual Batman development you shouldn't have to call this.

## @routes

`@routes` is a class level property referencing the root level `NamedRouteQuery` which allows for binding to routes on objects. See the [`data-route` binding](batman.view_bindings.html#data-route) for more information.

## @controllers

`@controllers` is a class level property containing the singleton `Batman.Controller` instances for each subclass in the application. This `controllers` directory puts these instances at the lowercase name of the controller. For example, the `TodosController` would be found at `controllers.todos`. `@controllers` ideally should never be bound to, but it is very useful for debugging in the console and other such workarounds.

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

## @layout

`@layout` is the base view of the entire view hierarchy. By default, it will parse any data-* attributes in the entire document, excluding any `data-yield`'s, when `App.run()` is called. Use `MyApp.layout = null` to disable the creation of this default view.

## @currentParams

`@currentParams` contains the URL parameters for the current request, including the path relative to the app's base path (`Batman.config.pathToApp`). Some interesting parts to look at: `@currentParams.controller`, `@currentParams.action`.

## @paramsManager
## @paramsPusher

## 'run' class event

The `run` class event is fired once the app has run. This indeterminately but often happens before the app's layout has finished rendering.

## 'ready' class event

The `ready` class event is fired once the app's layout is rendered.

# Batman.App Routing

The `Batman` routing DSL is similar to Rails 3's routing DSL. It is oriented around the notion of a resource:

## @route

`@route` defines a custom route and can be pointed to a controller action directly. For example:

```coffeescript
class window.Example extends Batman.App
  @route 'comments', 'pages#comments'

class Example.PagesController extends Batman.Controller
  comments: ->
```

Would result in `/comments` being added to the routing map, pointed to `PagesController#comments`.


## @resources(resourceName : String[, otherResourceNames... : String][, options : Object][, scopedCallback : Function])

`@resources` is modeled after the Rails routing `resources` method. It automatically defines some routes and matches them to controller actions. For example,

```coffeescript
class App extends Batman.App
  @resources 'pages'

class App.PagesController extends Batman.Controller
  index: ->
    # ...
  new: ->
    # ...
  show: (params) ->
    App.Page.find params.id, (err, page) ->
      @set('currentPage', page)
  edit: (params) ->
    App.Page.find params.id, (err, page) ->
      @set('currentPage', page)
```

Will set up these routes:

Path | Controller Action
-- | -- |
/pages | App.PagesController#index
/pages/new | App.PagesController#new
/pages/:id | App.PagesController#show
/pages/:id/edit | App.PagesController#edit

Note that unlike Rails, `destroy`, `update`, and `create` are not performed by controller actions in batman.js. Instead, call `save` or `destroy` on your records directly.
To access a generated route from within a view, use the [`data-route` binding](batman.view_bindings.html#data-route).

### Nested Resources

You may also nest resources, as in Rails:

```coffeescript
class App extends Batman.App
  @resources 'pages', ->
    @resources 'comments'
```

Will set up these routes for `App.Comment`:

Path | Controller Action
-- | -- |
/pages/:page_id/comments | App.CommentsController#index
/pages/:page_id/comments/new | App.CommentsController#new
/pages/:page_id/comments/:id | App.CommentsController#show
/pages/:page_id/comments/:id/edit | App.CommentsController#edit


## @member

`@member` defines a routable action you can call on a specific instance of a member of a collection resource. For example, if you have a collection of `Page` resources, and a user can post a comment on a specific page:

```coffeescript
class window.Example extends Batman.App
  @resources 'pages', ->
    @member 'comment'

class Example.PagesController extends Batman.Controller
  comment: (params) ->
```

Would result in `/pages/:id/comment` being added to the routing map, pointed to `PagesController#comment`.

## @collection

`@collection` is similar to `@member` in that it adds routable actions to a `@resources` set of routes. In this case the action would apply to the entire collection. For example, if you have a list of spam comments made across _all_ your `Page` resources:

```coffeescript
class window.Example extends Batman.App
  @resources 'pages', ->
    @collection 'spam_comments'

class Example.PagesController extends Batman.Controller
  comments: ->
```

Would result in `/pages/spam_comments` being added to the routing map, pointed to `PagesController#spam_comments`.

## @root

`@root` defines the root controller and action to be used when visiting the base application URL. For example:

```coffeescript
class window.Example extends Batman.App
  @root 'pages#index'

class Example.PagesController extends Batman.Controller
  index: ->
```

Would result in `/` being pointed to `PagesController#index`.

