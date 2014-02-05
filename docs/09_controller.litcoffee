# /api/App Components/Batman.Controller

`Batman.Controller` is the base class from which all an application's controllers should descend from. `Batman.Controller`s are responsible for executing _actions_ which fire off requests for model data, render views, or redirect to other actions in response to navigation state changes.

## Controller Directory

`Batman.Controller`s are singletons which means each controller in your application is instantiated exactly once. The instance of each controller is available on the class at the `@sharedController` property, or within a `ControllerDirectory` on the `Application` class. See `Batman.Application.controllers`.

## Actions

Each `Batman.Controller` should have a number of instance level functions which can fetch the data needed and often render a view (or views) to display that data. These functions can be declared in typical CoffeeScript fashion like so:

```example
  class Alfred extends Batman.App
    @root "todos#index"

  class Alfred.TodosController extends Batman.Controller
    index: (params) ->
    show: (params) ->
```

Each action function receives the parameters from the dispatcher which are pulled out of the navigated-to URL. This includes both named route parameters (`/:foo` style) as well as arbitrary query parameters (`?foo=bar` style).

## routingKey and Minification

For functionality like contextual redirects and automatic view source and class inference, Batman needs to know the name of all your `Controller` subclasses. The usual way to do this is by using `Function::name` which Batman will use in development, but this is often mangled in minified production environments. For this reason, Batman will error out on boot if a `Controller` subclass' `routingKey` is not defined on the prototype. The `routingKey` is a `String` which remains unmangled after minification and thus allows Batman to continue using the aforementioned features. To disable this requirement (if you know your code won't ever be minified), set `Batman.config.minificationErrors` to false.

## ::render([options : [Object|boolean]])

`render` is used to control the rendering of the currently executed action. Passing `false` will prevent the current action from implicitly rendering the view. Passing an `options` object allows the default `view`, `source`, `viewClass` or `yield` block to be overridden, all of which are optional. If no parameters are passed to options, it will manually trigger the render function, rather than waiting for it to be implicitly called at the end of the action.

_Note_: For more information on yield blocks, see Controller::.defaultRenderYield

    class TestController extends Batman.Controller
      routingKey: 'test'

      nonVisibleAction: ->
        @render(false)

      customSource: ->
        @render(source: 'errors/404')

      customYield: ->
        @render(into: 'not-main')

      delayedRender: ->
        setTimeout (-> @render()), 1000
        @render(false)

## @beforeAction([options : [string|Object],] filter : [string|Function])

`@beforeAction` allows controllers to declare that a function should be executed before the body of an action during action execution. `@beforeAction` optionally accepts some options representing which action(s) to execute the filter before, and then a string naming a function or function proper to execute.

The `options` argument can take three forms to imply different things:

 1. `undefined`: implies that this filter function should be executed before all actions.
 2. a String: implies that this filter function should be executed before the action named by the string.
 3. an Object: implies that this filter function should be executed before the actions named by an Array at the `only` key in the options object, or before all actions excluding those named by an Array at the `except` key in the options object.

If any `beforeAction` filter returns `false` or calls [`@redirect`](/docs/api/batman.controller.html#prototype_function_redirect), the controller action won't be executed.

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

`@afterAction` allows controllers to declare that a function should be run after the action body and all operations have completed during action execution. Functions declared by `@afterAction` will thus be run after the code of the action body and also after any redirects or renders have taken place and completed. `@afterAction` optionally accepts some options representing which action(s) to execute the filter after, and then a string naming a function or function proper to execute. See `Batman.Controller.beforeAction` for documentation on the structure of the options.

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

`executeAction` will run the `action` specified, running all `@beforeAction` and `@afterAction` filters that match that endpoint. Optionally, `params` can be passed into the new action for processing. If no params are passed, it will default to the params of the current action.

    test "executeAction will run the called action", ->
      result = null

      class TestController extends Batman.Controller
        routingKey: "test"
        show: (params) ->
          result = params.id
          @render false
        other: ->
          @executeAction("show", {id: 4})

      controller = TestController.get("sharedController")
      controller.dispatch "other"
      equal result, 4

    test "executeAction will run all @beforeAction and @afterAction filters", ->
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

`autoScrollToHash` is a boolean property on the instance level of a controller describing whether or not the controller should automatically scroll the browser window to the element with ID equal to the `hash` parameter. This behaviour emulates the native behaviour of the same nature, but is implemented in Batman so the functionality works after each dispatch (instead of each page refresh) and when Batman is using hash bang routing. `autoScrollToHash` is true by default.

## ::.defaultRenderYield[= 'main'] : string

`defaultRenderYield` is a `string` representing which yield a controller should automatically render into if no yield is mentioned explicitly. `defaultRenderYield` is `'main'` normally, which means calls to `@render()` or actions which rely on the implicit rendering render their views into the `main` yield (and end up wherever `data-yield="main"` is found in your HTML).
