module.exports = developer =
  suppressed: false
  DevelopmentError: (->
    DevelopmentError = (@message) ->
      @name = "DevelopmentError"
    DevelopmentError:: = Error::
    DevelopmentError
  )()
  _ie_console: (f, args) ->
    console?[f] "...#{f} of #{args.length} items..." unless args.length == 1
    console?[f] arg for arg in args
  suppress: (f) ->
    developer.suppressed = true
    if f
      f()
      developer.suppressed = false
  unsuppress: ->
    developer.suppressed = false
  log: ->
    return if developer.suppressed or !(console?.log?)
    if console.log.apply then console.log(arguments...) else developer._ie_console "log", arguments
  warn: ->
    return if developer.suppressed or !(console?.warn?)
    if console.warn.apply then console.warn(arguments...) else developer._ie_console "warn", arguments
  error: (message) -> throw new developer.DevelopmentError(message)
  assert: (result, message) -> developer.error(message) unless result
  do: (f) -> f() unless developer.suppressed
  addFilters: ->
    Batman.extend Batman.Filters,
      log: (value, key) ->
        console?.log? arguments
        value

      logStack: (value) ->
        console?.log? developer.currentFilterStack
        value

  deprecated: (deprecatedName, upgradeString) ->
    Batman.developer.warn("#{deprecatedName} has been deprecated.", upgradeString || '')

developer.assert (->).bind, "Error! Batman needs Function.bind to work! Please shim it using something like es5-shim or augmentjs!"
