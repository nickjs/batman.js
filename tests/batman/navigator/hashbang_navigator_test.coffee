QUnit.module 'Batman.HashbangNavigator',
  setup: ->
    @app = Batman
      dispatcher:
        dispatch: @dispatchSpy = createSpy()
    @nav = new Batman.HashbangNavigator(@app)

test "pathFromLocation(window.location) returns the app-relative path", ->
  equal @nav.pathFromLocation(hash: '#!/foo/bar?page=2'), '/foo/bar?page=2'
  equal @nav.pathFromLocation(hash: '#/foo/bar?page=2'), '/'
  equal @nav.pathFromLocation(hash: '#'), '/'
  equal @nav.pathFromLocation(hash: ''), '/'

asyncTest "pushState(stateObject, title, path) sets window.location.hash", ->
  @nav.pushState(null, '', '/foo/bar')
  delay =>
    equal window.location.hash, "#!/foo/bar"

unless IN_NODE #jsdom doesn't like window.location.replace
  asyncTest "replaceState(stateObject, title, path) replaces the current history entry", ->
    window.location.hash = '#!/one'
    window.location.hash = '#!/two'
    @nav.replaceState(null, '', '/three')
    equal window.location.hash, "#!/three"

    window.history.back()

    doWhen (-> window.location.hash is "#!/one"), ->
      equal window.location.hash, "#!/one"
      QUnit.start()

test "handleLocation(window.location) dispatches based on pathFromLocation", ->
  @nav.handleLocation
    pathname: Batman.config.pathToApp
    search: ''
    hash: '#!/foo/bar?page=2'
  equal @dispatchSpy.callCount, 1
  deepEqual @dispatchSpy.lastCallArguments, ["/foo/bar?page=2"]


test "handleLocation(window.location) handles the real non-hashbang path if present, but only if Batman.config.usePushState is true", ->
  location =
    pathname: @nav.normalizePath(Batman.config.pathToApp, '/baz')
    search: '?q=buzz'
    hash: '#!/foo/bar?page=2'
    replace: createSpy()
  @nav.handleLocation(location)
  equal location.replace.callCount, 1
  deepEqual location.replace.lastCallArguments, ["#{Batman.config.pathToApp}#!/baz?q=buzz"]

  Batman.config.usePushState = false
  @nav.handleLocation(location)
  equal location.replace.callCount, 1

test "handleLocation(window.location) handles the real non-hashbang path, and persists any additional initial hashes in params", ->
  location =
    pathname: @nav.normalizePath(Batman.config.pathToApp, '/baz')
    hash: '#layout/theme.liquid'
    replace: createSpy()

  # We need to go from test.html/baz#layout/theme.liquid to test.html/#!/baz but somehow include #layout/theme.liquid
  # The first checkInitialHash will observe that we have an extra hash and the first handle location will redirect from
  # the pushState URL to the new hashbang URL, and include an extra bit in the URL with the initial hash information.
  @nav.checkInitialHash(location)
  @nav.handleLocation(location)
  equal location.replace.callCount, 1

  # Ok, we're now in hashbang land: test.html/#!/baz##BATMAN##layout/theme.liquid
  path = location.replace.lastCallArguments[0]
  index = path.indexOf('#')
  location.pathname = path.substr(0, index)
  location.hash = path.substr(index)

  # The next checkInitialHash will then parse off the initial hash info, and do another replace location
  # to the current hashbang URL minus the extra initial hash info.
  @nav.checkInitialHash(location)
  equal location.replace.callCount, 2
  equal @nav.initialHash, 'layout/theme.liquid'

  # After one page reload and one URL replace, we're now at test.html/#!/baz
  path = location.replace.lastCallArguments[0]
  index = path.indexOf('#')
  location.pathname = path.substr(0, index)
  location.hash = path.substr(index)

  # The final handleLocation after the last replace will trigger the first dispatch to be sent.
  # Included in the params object for this dispatch will be an extra field called initialHash.
  @nav.handleLocation(location)
  deepEqual @app.dispatcher.dispatch.lastCallArguments[1], {initialHash: 'layout/theme.liquid'}

  # Finally, initialHash is deleted after the first dispatch. Cache it if you need it!
  ok !@nav.initialHash?

test "detectHashChange should trigger handleHashChange on change", ->
  @nav.handleHashChange = createSpy()

  window.location.hash = 'new_hash'
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 1

  # Make sure handleHashChange is not called when hash hasn't changed
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 1

  window.location.hash = 'new_hash_2'
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 2
