#= require ./object
#= require_tree ./routing

class Batman.App extends Batman.Object
  @classAccessor 'currentParams',
    get: ->
      return unless nav = @get('navigator')
      new Batman.Params({}, nav)
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
      Batman.navigator = @get('navigator')

      @on 'run', =>
        Batman.navigator.start() if Object.keys(@get('dispatcher').routeMap).length > 0

    @observe 'layout', (layout) =>
      layout?.on 'ready', => @fire 'ready'

    layout = @get('layout')
    if layout
      if typeof layout == 'string'
        layoutClass = @[Batman.helpers.camelize(layout) + 'View']
    else
      layoutClass = (class LayoutView extends Batman.View) unless layout == null

    if layoutClass
      layout = @set('layout', new layoutClass(node: document.documentElement))
      layout.propagateToSubviews('viewWillAppear')
      layout.initializeBindings()
      layout.propagateToSubviews('isInDOM', true)
      layout.propagateToSubviews('viewDidAppear')

    if Batman.config.translations
      @set('t', Batman.I18N.get('translations'))

    @hasRun = yes
    @fire('run')
    return this

  @event('ready').oneShot = true
  @event('stop').oneShot = true

  @stop: ->
    @navigator?.stop()
    Batman.navigator = null
    @hasRun = no
    @fire('stop')
    @
