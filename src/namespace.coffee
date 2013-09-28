# The global namespace, the `Batman` function will also create a new
# instance of Batman.Object and mixin all arguments to it.
Batman = (mixins...) ->
  new Batman.Object(mixins...)

Batman.version = '0.15.0'

Batman.config =
  pathToApp: '/'
  usePushState: true

  pathToHTML: 'html'
  fetchRemoteHTML: true
  cacheViews: false

  minificationErrors: true
  protectFromCSRF: false

(Batman.container = do -> this).Batman = Batman  # I am so, so sorry.

# Support AMD loaders
if typeof define is 'function'
  define 'batman', [], -> Batman

Batman.exportHelpers = (onto) ->
  for k in ['mixin', 'extend', 'unmixin', 'redirect', 'typeOf', 'redirect', 'setImmediate', 'clearImmediate']
    onto["$#{k}"] = Batman[k]
  onto

Batman.exportGlobals = -> Batman.exportHelpers(Batman.container)
