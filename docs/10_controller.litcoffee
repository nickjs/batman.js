# Batman.Controller

`Batman.Controller` is the base class from which all an application's controllers should descend from. `Batman.Controllers` are responsible for executing _actions_ which fire off requests for model data, render views, or redirect to other actions in response to navigation state changes.

## Controller Directory

`Batman.Controller`s are singletons which means each controller in your application is instantiated exactly once. The instance of each controller is available on the class at the `@sharedContoller` property, or within a `ControllerDirectory` on the `Application` class. See `Batman.Application.controllers`.

## Actions

Each `Batman.Controller` should have a number of instance level functions which can fetch the data needed and often render a view (or views) to display that data. These functions can be declared in typical CoffeeScript fashion like so:

```coffeescript
class Alfred.TodosController

  index: (params) ->

  show: (params) ->
```

Each action function receives the parameters from the dispatcher which are pulled out of the navigated-to URL. This includes both named route parameters (`/:foo` style) as well as arbitrary query paramters (`?foo=bar` style).

## `routingKey` and Minification

For functionality like contextual redirects and automatic view source and class inference, Batman needs to know the name of all your `Controller` subclasses. The usual way to do this is by using `Function::name` which Batman will use in development, but this is often mangled in minified production environments. For this reason, Batman will error out on boot if a `Controller` subclass' `routingKey` is not defined on the prototype. The `routingKey` is a `String` which remains unmangled after minification and thus allows Batman to continue using the aforementioned features. To disable this requirement (if you know your code won't ever be minified), set `Batman.config.minificationErrors` to false.

## @beforeAction([options : [String|Object]], filter : [String|Function])

`@beforeAction` allows controllers to declare that a function should be executed before the body of an action during action execution. `@beforeAction` optionally accepts some options representing which action(s) to execute the filter before, and then a string naming a function or function proper to execute.

The `options` argument can take three forms to imply different things:

 1. `undefined`: implies that this filter function should be executed before all actions.
 2. a String: implies that this filter function should be executed before the action named by the string.
 3. an Object: implies that this filter function should be executed before the actions named by an Array at the `only` key in the options object, or before all actions excluding those named by an Array at the `except` key in the options object.

    test "@beforeAction allows declaration of filters to execute before an action", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: 'test'
        @beforeAction only: 'index', -> results.push 'before!'
        index: ->
          results.push 'action!'
          @render false

      controller = TestController.get('sharedController')
      controller.dispatch 'index'
      equal results[0], 'before!'
      equal results[1], 'action!'

    test "@beforeAction allows declaration of named filters to execute before an action", ->
      class TodoController extends Batman.Controller
        routingKey: 'test'
        @beforeAction only: 'show', 'fetchTodo'
        fetchTodo: -> @set 'todo', {isDone: true}
        show: ->
          @render false

      controller = TodoController.get('sharedController')
      controller.dispatch 'show'
      deepEqual controller.get('todo'), {isDone: true}

    test "@beforeAction allows whitelisting or blacklisting filters to execute before an action", ->
      class TodoController extends Batman.Controller
        routingKey: 'test'
        @beforeAction only: ['show', 'edit'], 'fetchTodo'
        @beforeAction except: ['index'], 'prepareNewTodo'
        fetchTodo: -> @set 'todo', {isDone: true}
        prepareNewTodo: -> @set 'newTodo', {isDone: false}
        index: -> @render false
        show: -> @render false

      controller = TodoController.get('sharedController')
      controller.dispatch 'show'
      deepEqual controller.get('todo'), {isDone: true}
      deepEqual controller.get('newTodo'), {isDone: false}

    test "@beforeAction allows declaration of filters to execute before all actions", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: 'test'
        @beforeAction -> results.push 'before!'
        index: ->
          results.push 'action!'
          @render false

      controller = TestController.get('sharedController')
      controller.dispatch 'index'
      equal results[0], 'before!'
      equal results[1], 'action!'

## @afterAction([options : [String|Object]], filter : [String|Function])

`@afterAction` allows controllers to declare that a function should be run after the action body and all operations have completed during action execution. Functions declared by `@afterAction` will thus be run after the code of the action body and also after any redirects or renders have taken place and completed. `@beforeAction` optionally accepts some options representing which action(s) to execute the filter before, and then a string naming a function or function proper to execute. See `Batman.Controller.beforeAction` for documentation on the structure of the options.

    test "@afterAction allows declaration of filters to execute before an action", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: 'test'
        @afterAction only: 'index', -> results.push 'after!'
        index: ->
          results.push 'action!'
          @render false

      controller = TestController.get('sharedController')
      controller.dispatch 'index'
      equal results[0], 'action!'
      equal results[1], 'after!'

    test "@afterAction allows declaration of named filters to execute before an action", ->
      result = null

      class TodoController extends Batman.Controller
        routingKey: 'test'
        @afterAction only: 'create', 'notify'
        create: -> @render false
        notify: -> result = "Todo created successfully."

      controller = TodoController.get('sharedController')
      controller.dispatch 'create'
      equal result, 'Todo created successfully.'

    test "@afterAction allows whitelisting or blacklisting filters to execute before an action", ->
      result = null

      class TodoController extends Batman.Controller
        routingKey: 'test'
        @afterAction {only: ['create', 'update']}, 'notify'
        index: -> @render false
        create: -> @render false
        notify: -> result = "Todo created successfully."

      controller = TodoController.get('sharedController')
      controller.dispatch 'index'
      equal result, null
      controller.dispatch 'create'
      equal result, 'Todo created successfully.'

    test "@afterAction allows declaration of filters to execute before all actions", ->
      results = []

      class TestController extends Batman.Controller
        routingKey: 'test'
        @afterAction -> results.push 'after!'
        index: ->
          results.push 'action!'
          @render false

      controller = TestController.get('sharedController')
      controller.dispatch 'index'
      equal results[0], 'action!'
      equal results[1], 'after!'

## autoScrollToHash[= true] : boolean

`autoScrollToHash` is a boolean property on the instance level of a controller describing whether or not the controller should automatically scroll the browser window to the element with ID equal to the `hash` parameter. This behaviour emulates the native behaviour of the same nature, but is implemented in Batman so the functionality works after each dispatch (instead of each page refresh) and when Batman is using hash bang routing. `autoScrollToHash` is true by default.

## defaultRenderYield[= 'main'] : String

`defaultRenderYield` is a `String` representing which yield a controller should automatically render into if no yield is mentioned explicitly. `defaultRenderYield` is `'main'` normally, which means calls to `@render()` or actions which rely on the implicit rendering render their views into the `main` yield (and end up wherever `data-yield="main"` is found in your HTML).


## Controller Actions

## executeAction

## render

## redirect

## scrollToHash
