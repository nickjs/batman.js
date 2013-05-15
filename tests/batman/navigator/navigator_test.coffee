QUnit.module 'Batman.Navigator',
  setup: ->

test "normalizePath(segments...) joins the segments with slashes, prepends a slash if necessary, and removes final trailing slashes", ->
  equal Batman.Navigator.normalizePath(''), '/'
  equal Batman.Navigator.normalizePath('','foo','','bar'), '/foo/bar'
  equal Batman.Navigator.normalizePath('foo'), '/foo'
  equal Batman.Navigator.normalizePath('/foo'), '/foo'
  equal Batman.Navigator.normalizePath('//foo'), '//foo'
  equal Batman.Navigator.normalizePath('foo','bar','baz'), '/foo/bar/baz'
  equal Batman.Navigator.normalizePath('foo','//bar/baz/'), '/foo//bar/baz'
  equal Batman.Navigator.normalizePath('foo','bar/baz//'), '/foo/bar/baz'

test "push with dispatch that includes nested push only pushes inner state", ->
  navigator = new Batman.Navigator
  navigator.app = new Batman.Object
    dispatcher:
      pathFromParams: (params) -> params
      dispatch: (params) ->
        navigator.redirect('/redirected') if params is '/foo'
        params

  pushSpy = navigator.pushState = createSpy()
  navigator.redirect('/foo')

  ok pushSpy.callCount, 1
  deepEqual pushSpy.lastCallArguments, [null, '', '/redirected']

test "replace with dispatch that includes nested replace only replaces inner state", ->
  navigator = new Batman.Navigator
  navigator.app = new Batman.Object
    dispatcher:
      pathFromParams: (params) -> params
      dispatch: (params) ->
        navigator.redirect('/redirected', true) if params is '/foo'
        params

  replaceSpy = navigator.replaceState = createSpy()
  navigator.redirect('/foo', true)

  ok replaceSpy.callCount, 1
  deepEqual replaceSpy.lastCallArguments, [null, '', '/redirected']

test "back and forward browser events should both cause a dispatch", ->
  dispatchSpy = createSpy()

  navigator = new Batman.Navigator
  navigator.pathFromLocation = (location) -> location.path
  navigator.app = new Batman.Object
    dispatcher:
      pathFromParams: (params) -> params
      dispatch: (params) ->
        dispatchSpy()
        params

  navigator.replaceState = createSpy()
  navigator.redirect '/foo', true

  window.location.path = '/bar'
  navigator.handleCurrentLocation()

  window.location.path = '/foo'
  navigator.handleCurrentLocation()

  equal dispatchSpy.callCount, 3
