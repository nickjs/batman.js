#= require ./validators

class Batman.LengthValidator extends Batman.Validator
    @triggers 'minLength', 'maxLength', 'length', 'lengthWithin', 'lengthIn'
    @options 'allowBlank'
    constructor: (options) ->
      if range = (options.lengthIn or options.lengthWithin)
        options.minLength = range[0]
        options.maxLength = range[1] || -1
        delete options.lengthWithin
        delete options.lengthIn

      super

    validateEach: (errors, record, key, callback) ->
      options = @options
      value = record.get(key)
      return callback() if @handleBlank(value)
      value ?= []
      if options.minLength and value.length < options.minLength
        errors.add key, @format(key, 'too_short', {count: options.minLength}, record)
      if options.maxLength and value.length > options.maxLength
        errors.add key, @format(key, 'too_long', {count: options.maxLength}, record)
      if options.length and value.length isnt options.length
        errors.add key, @format(key, 'wrong_length', {count: options.length}, record)
      callback()

Batman.Validators.push Batman.LengthValidator
