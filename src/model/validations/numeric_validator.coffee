#= require ./validators

class Batman.NumericValidator extends Batman.Validator
  @triggers 'numeric'
  @options 'allowBlank'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !@isNumeric(value)
      errors.add key, @format(key, 'not_numeric')
    callback()

  isNumeric: (value) ->
    !isNaN(parseFloat(value)) && isFinite(value)

Batman.Validators.push Batman.NumericValidator
