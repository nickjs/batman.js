#= require ./validators

class Batman.RegExpValidator extends Batman.Validator
    @options 'regexp', 'pattern'

    constructor: (options) ->
      @regexp = options.regexp ? options.pattern
      super

    validateEach: (errors, record, key, callback) ->
      value = record.get(key)
      if value? && value != ''
        unless @regexp.test(value)
          errors.add key, @format(key, 'not_matching')
      callback()

Batman.Validators.push Batman.RegExpValidator
