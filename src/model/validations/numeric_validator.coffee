#= require ./validators

class Batman.NumericValidator extends Batman.Validator
    @options 'numeric'
    validateEach: (errors, record, key, callback) ->
      value = record.get(key)
      if @options.numeric and isNaN(parseFloat(value))
        errors.add key, @format(key, 'not_numeric')
      callback()

Batman.Validators.push Batman.NumericValidator
