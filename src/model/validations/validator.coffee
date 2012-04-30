class Batman.Validator extends Batman.Object
  constructor: (@options, mixins...) ->
    super mixins...

  validate: (record) -> Batman.developer.error "You must override validate in Batman.Validator subclasses."
  format: (key, messageKey, interpolations) ->
    Batman.t 'errors.format',
      attribute: key,
      message: Batman.t("errors.messages.#{messageKey}", interpolations)

  @options: (options...) ->
    Batman.initializeObject @
    if @_batman.options then @_batman.options.concat(options) else @_batman.options = options

  @matches: (options) ->
    results = {}
    shouldReturn = no
    for key, value of options
      if ~@_batman?.options?.indexOf(key)
        results[key] = value
        shouldReturn = yes
    return results if shouldReturn
