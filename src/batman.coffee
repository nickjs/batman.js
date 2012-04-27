# The global namespace, the `Batman` function will also create also create a new
# instance of Batman.Object and mixin all arguments to it.
Batman = (mixins...) ->
  new Batman.Object(mixins...)

Batman.version = '0.9.0'

Batman.config =
  pathPrefix: '/'
  usePushState: no

Batman.container = if exports?
  module.exports = Batman
  global
else
  window.Batman = Batman
  window

# Support AMD loaders
if typeof define is 'function'
  define 'batman', [], -> Batman

Batman.exportHelpers = (onto) ->
  for k in ['mixin', 'extend', 'unmixin', 'redirect', 'typeOf', 'redirect', 'setImmediate', 'clearImmediate']
    onto["$#{k}"] = Batman[k]
  onto

Batman.exportGlobals = -> Batman.exportHelpers(Batman.container)
