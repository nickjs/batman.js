#= require ./validators

class Batman.RegExpValidator extends Batman.Validator
    @triggers 'regexp', 'pattern'
    @options 'allowBlank'

    constructor: (options) ->
      @regexp = options.regexp ? options.pattern
      super

    validateEach: (errors, record, key, callback) ->
      value = record.get(key)
      return callback() if @handleBlank(value)
      if !value? || value == '' || !@regexp.test(value)
        errors.add key, @format(key, 'not_matching', {}, record)
      callback()

Batman.Validators.push Batman.RegExpValidator
