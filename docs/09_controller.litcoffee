# /api/App Components/Batman.Controller

All controllers in a batman.js app extend `Batman.Controller`. `Batman.Controller`s are responsible for executing _actions_ which fire off requests for model data, render views, or redirect to other actions in response to navigation state changes. `Batman.Controller` is inspired by [ActionController](http://guides.rubyonrails.org/action_controller_overview.html), a key component of Ruby on Rails.

## Controller Directory

`Batman.Controller`s are singletons and each controller's instance is available at [`@sharedController`](/docs/api/batman.controller.html#class_accessor_sharedcontroller). Controller instances are also available at `MyApp.get('controllers')`( the app's [`ControllerDirectory`](/docs/api/controllerdirectory.html)). You can get the controller instance by the part of its name before "Controller", downcased. For example:

```
Alfred.TodosController.get('sharedController') # => TodosController instance
Alfred.get('controllers.todos')                # => TodosController instance
```

## Actions

Each `Batman.Controller` declares functions which represent actions to be run on a particular page. Typically, these functions will fetch data or render views:

```coffeescript
class Alfred.TodosController extends Batman.Controller
  routingKey: 'todos'
  index: (params) ->
    @set('todos', Alfred.Todo.get('all'))
    # will automatically render Alfred.TodosIndexView with source `todos/index`

  show: (params) ->
    Alfred.Todo.find params.id, (err, record) ->
      throw err if err
      @set('todo', record)
    # will automatically render Alfred.TodosShowView with source `todos/show`
```

Actions are passed a `params` argument, which is an object containing URL parameters. Named route parameters (eg, `todos/:id`) and query string parameters (`?key=value`) are accessible in `params`.

## routingKey and Minification

Each `Batman.Controller` must have a `routingKey`, which is used by the batman.js router. It also makes the app minification-safe. You can set it inside the controller definition:

```coffeescript
class Alfred.TodosController extends Batman.Controller
  routingKey: 'todos'
```

An app will fail to run if a controller's `routingKey` is not defined. To disable this requirement, set `Batman.config.minificationErrors` to false.

## Error Handling

`Batman.Controller` has a built-in structure for handling errors that occur during controller actions. Inside a controller definition, you can map errors to handlers using `@catchError`. Then, you can wrap a storage operation callback with `@errorHandler` to have any errors caught by the defined handlers. If you use `@errorHandler`, errors without declared handlers will be thrown (since they aren't passed to the callback).

```coffeescript
class Alfred.TodosController extends Batman.Controller
  routingKey: 'todos'
  # declare a handler with `@catchError`:
  @catchError Batman.StorageAdapter.NotFoundError, with: 'render404'

  show: (params) ->
    # wrap your storage operation in `@errorHandler`
    App.Todo.find params.id, @errorHandler (record, env) =>
      @set('todo', record)

  # error is passed to the handler
  render404: (error) -> @render(source: "errors/404")
```

Usually, you want to declare error handlers in `MyApp.ApplicationController`, then extend `MyApp.ApplicationController` in your other controllers:

```coffeescript
class Alfred.ApplicationController extends Batman.Controller
  @catchError Batman.StorageAdapter.NotFoundError, with: 'render404'
  # etc...

class Alfred.TodosController extends Alfred.ApplicationController
  # will use ApplicationController's handlers for @errorHandler
```

For a full list of storage errors, see [`Batman.StorageAdapter` Errors](/docs/api/batman.storageadapter_errors.html).

## ::render([options : [Object|boolean]])

`render` is used to control the rendering of the current action. Unless specified otherwise, `Batman.Controller` actions render automatically.

Passing `false` will prevent the current action from rendering the view.

```coffeescript
class Alfred.TodosController extends Batman.Controller
  actionWithNoRender: ->
    @render(false) # no view will be rendered

  actionWithDelayedRender: ->
    setTimeout (-> @render()), 1000 # view rendered after 1 second
    @render(false)
```

By passing an `options` object, you may override the default `view`, `source`, `viewClass` or `yield` block.

```coffeescript
class Alfred.TodosController extends Batman.Controller
  actionWithCustomSource: ->
    @render(source: 'errors/404')

  actionWithCustomYield: ->
    @render(into: 'not-main')
```

For more information on yield blocks, see [`Controller::.defaultRenderYield`](/docs/api/batman.controller.html#prototype_property_defaultrenderyield).

## @beforeAction([options : [string|Object],] filter : [string|Function])

Declares that a function should be executed should be executed before this controller's actions. If any `beforeAction` filter returns `false` or calls [`@redirect`](/docs/api/batman.controller.html#prototype_function_redirect), the controller action won't be executed. `@beforeAction` accepts:

-  `options` representing which action(s) to execute the filter before (optional)
-  `filter`, either a string naming a function _or_ a function to execute.

The `options` argument can take three forms:

1. `undefined`: this filter should be executed before all actions.
2. `String`: this filter should be executed before the action named by the string.
3. `Object`: this filter should be executed before the actions named by an Array at the `only` key in the options object, or before all actions excluding those named by an Array at the `except` key in the options object.

<!-- tests -->

    test "@beforeAction allows declaration of filters to execute before an action", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: "test"
        @beforeAction only: "index", -> results.push "before!"
        index: ->
          results.push "action!"
          @render false

      controller = TestController.get("sharedController")
      controller.dispatch "index"
      equal results[0], "before!"
      equal results[1], "action!"

    test "@beforeAction allows declaration of named filters to execute before an action", ->
      class TodoController extends Batman.Controller
        routingKey: "test"
        @beforeAction only: "show", "fetchTodo"
        fetchTodo: -> @set("todo", {isDone: true})
        show: ->
          @render false

      controller = TodoController.get("sharedController")
      controller.dispatch "show"
      deepEqual controller.get("todo"), {isDone: true}

    test "@beforeAction allows whitelisting or blacklisting filters to execute before an action", ->
      class TodoController extends Batman.Controller
        routingKey: "test"
        @beforeAction only: ["show", "edit"], "fetchTodo"
        @beforeAction except: ["index"], "prepareNewTodo"
        fetchTodo: -> @set "todo", {isDone: true}
        prepareNewTodo: -> @set "newTodo", {isDone: false}
        index: -> @render false
        show: -> @render false

      controller = TodoController.get("sharedController")
      controller.dispatch "show"
      deepEqual controller.get("todo"), {isDone: true}
      deepEqual controller.get("newTodo"), {isDone: false}

    test "@beforeAction allows declaration of filters to execute before all actions", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: "test"
        @beforeAction -> results.push "before!"
        index: ->
          results.push "action!"
          @render false

      controller = TestController.get("sharedController")
      controller.dispatch "index"
      equal results[0], "before!"
      equal results[1], "action!"

## @afterAction([options : [string|Object],] filter : [string|Function])

Declares that a function should be executed after this controller's actions (and after any `render` or `redirect`s). `@afterAction` accepts `options` and `filter` (see [`@beforeAction`](/docs/api/batman.controller.html#class_function_beforeaction)).

    test "@afterAction allows declaration of filters to execute after an action", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: "test"
        @afterAction only: "index", -> results.push "after!"
        index: ->
          results.push "action!"
          @render false

      controller = TestController.get("sharedController")
      controller.dispatch "index"
      equal results[0], "action!"
      equal results[1], "after!"

    test "@afterAction allows declaration of named filters to execute after an action", ->
      result = null

      class TodoController extends Batman.Controller
        routingKey: "test"
        @afterAction only: "create", "notify"
        notify: -> result = "Todo created successfully."
        create: -> @render false

      controller = TodoController.get("sharedController")
      controller.dispatch "create"
      equal result, "Todo created successfully."

    test "@afterAction allows whitelisting or blacklisting filters to execute after an action", ->
      result = null

      class TodoController extends Batman.Controller
        routingKey: "test"
        @afterAction only: ["create", "update"], "notify"
        index: -> @render false
        create: -> @render false
        notify: -> result = "Todo created successfully."

      controller = TodoController.get("sharedController")
      controller.dispatch "index"
      equal result, null
      controller.dispatch "create"
      equal result, "Todo created successfully."

    test "@afterAction allows declaration of filters to execute after all actions", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: "test"
        @afterAction -> results.push "after!"
        index: ->
          results.push "action!"
          @render false

      controller = TestController.get("sharedController")
      controller.dispatch "index"
      equal results[0], "action!"
      equal results[1], "after!"

## ::executeAction(action: string[, params: Object])

Runs the `action` specified, including all applicable `@beforeAction`s and `@afterAction`s. Optionally, `params` can be passed into the new action for processing. If no params are passed, it will default to the params of the current action.

    test "executeAction will run the action and all @beforeAction and @afterAction filters", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: "test"
        @beforeAction only: "index", -> results.push "before!"
        @afterAction only: "index", -> results.push "after!"
        index: ->
          results.push "action!"
          @render false
        other: ->
          @executeAction("index")

      controller = TestController.get("sharedController")
      controller.dispatch "other"
      deepEqual results, ["before!", "action!", "after!"]

## ::redirect(options: [string|Object])

Properly handles the controller filter chain and loads a new page with [`Batman.redirect`](/docs/api/batman.html#class_function_redirect). See [`Batman.redirect`](/docs/api/batman.html#class_function_redirect) for allowed `options`. If `options` is an object, the current controller will be added as the object's `controller` attribute (if it isn't already present), so calling `@redirect({action: "show", id: itemId})` is equivalent to calling `@redirect({action: 'show', id: itemId, controller: 'items'})`.

## ::scrollToHash([hash: string])

`scrollToHash` emulates the native scrolling behaviour of the browser by allowing the URL to link to a specific ID on the page. The code will look for an element with a matching ID to `hash` if it is provided otherwise using the `#` parameter in the URL. If an element is found, the page will scroll to the matching element.

## ::.autoScrollToHash[= true] : boolean

Specifies if the controller should automatically scroll to the element with ID equal to the `hash` parameter. This behaviour emulates the native behaviour of the same nature, but is implemented in Batman so the functionality works after each dispatch (instead of each page refresh) and when Batman is using hash bang routing.

## ::.defaultRenderYield[= 'main'] : string

`defaultRenderYield` specifies which yield (see [`data-yield`](/docs/api/batman.view_bindings.html#data-yield)) a controller should automatically render into if no yield is declared.

## @%sharedController : Controller

The singleton instance of the `Controller`.

## @catchError(errorClasses..., {with : [String|Array]})

Declares that errors which are `instanceof` any of `errorClasses` should be handled by `with` when using [`@errorHandler`](/docs/api/batman.controller.html#class_function_errorhandler). `with` is the name of a prototype function (or an array of names) which will be invoked with the error. See ["Error Handling"](/docs/api/batman.controller.html#error_handling).

## @errorHandler(callback)

Wraps a storage action, passing the first argument (`error`) to error handlers declared with [`@catchError`](/docs/api/batman.controller.html#class_function_catcherror). Callback should take arguments `result, env` (`error` is not present because it was passed to error handlers). See ["Error Handling"](/docs/api/batman.controller.html#error_handling).
