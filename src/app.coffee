#= require ./object
#= require_tree ./routing

class Batman.App extends Batman.Object
  @classAccessor 'currentParams',
    get: -> new Batman.Hash
    'final': true

  @classAccessor 'paramsManager',
    get: ->
      return unless nav = @get('navigator')
      params = @get('currentParams')
      params.replacer = new Batman.ParamsReplacer(nav, params)
    'final': true

  @classAccessor 'paramsPusher',
    get: ->
      return unless nav = @get('navigator')
      params = @get('currentParams')
      params.pusher = new Batman.ParamsPusher(nav, params)
    'final': true

  @classAccessor 'routes', -> new Batman.NamedRouteQuery(@get('routeMap'))
  @classAccessor 'routeMap', -> new Batman.RouteMap
  @classAccessor 'routeMapBuilder', -> new Batman.RouteMapBuilder(@, @get('routeMap'))
  @classAccessor 'dispatcher', -> new Batman.Dispatcher(@, @get('routeMap'))
  @classAccessor 'controllers', -> @get('dispatcher.controllers')

  @classAccessor '_renderContext', -> Batman.RenderContext.base.descend(@)

  # Layout is the base view that other views can be yielded into. The
  # default behavior is that when `app.run()` is called, a new view will
  # be created for the layout using the `document` node as its content.
  # Use `MyApp.layout = null` to turn off the default behavior.
  @layout: undefined

  # shouldAllowEvent is a hash of global function delegates. You can use
  # these to intercept DOM events like click and keydown and return false
  # if you want to prematurely short circuit the event handler.
  @shouldAllowEvent: {}

  # Routes for the app are built using a RouteMapBuilder, so delegate the
  # functions used to build routes to it.
  for name in Batman.RouteMapBuilder.BUILDER_FUNCTIONS
    do (name) =>
      @[name] = -> @get('routeMapBuilder')[name](arguments...)

  # Call `MyApp.run()` to start up an app. Batman level initializers will
  # be run to bootstrap the application.
  @event('ready').oneShot = true
  @event('run').oneShot = true
  @run: ->
    if Batman.currentApp
      return if Batman.currentApp is @
      Batman.currentApp.stop()

    return false if @hasRun

    if @isPrevented 'run'
      @wantsToRun = true
      return false
    else
      delete @wantsToRun

    Batman.currentApp = @
    Batman.App.set('current', @)

    unless @get('dispatcher')?
      @set 'dispatcher', new Batman.Dispatcher(@, @get('routeMap'))
      @set 'controllers', @get('dispatcher.controllers')

    unless @get('navigator')?
      @set('navigator', Batman.Navigator.forApp(@))
      @on 'run', =>
        Batman.navigator = @get('navigator')
        Batman.navigator.start() if Object.keys(@get('dispatcher').routeMap).length > 0

    @observe 'layout', (layout) =>
      layout?.on 'ready', => @fire 'ready'

    layout = @get('layout')
    if layout
      if typeof layout == 'string'
        layoutClass = @[Batman.helpers.camelize(layout) + 'View']
    else
      layoutClass = Batman.View unless layout == null

    if layoutClass
      layout = @set 'layout', new layoutClass
        context: @
        node: document

    @hasRun = yes
    @fire('run')
    @

  @event('ready').oneShot = true
  @event('stop').oneShot = true

  @stop: ->
    @navigator?.stop()
    Batman.navigator = null
    @hasRun = no
    @fire('stop')
    @
