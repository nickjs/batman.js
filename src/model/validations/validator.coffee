class Batman.Validator extends Batman.Object
  @triggers: (triggers...) ->
    if @_triggers? then @_triggers.concat(triggers) else @_triggers = triggers

  @options: (options...) ->
    if @_options? then @_options.concat(options) else @_options = options

  @matches: (options) ->
    results = {}
    shouldReturn = no
    for key, value of options
      if ~@_options?.indexOf(key)
        results[key] = value
      if ~@_triggers?.indexOf(key)
        results[key] = value
        shouldReturn = yes
    return results if shouldReturn

  constructor: (@options, mixins...) ->
    super mixins...

  validate: (record) -> Batman.developer.error "You must override validate in Batman.Validator subclasses."
  format: (key, messageKey, interpolations) -> Batman.t("errors.messages.#{messageKey}", interpolations)

  handleBlank: (value) ->
    if @options.allowBlank && !Batman.PresenceValidator::isPresent(value)
      return true
