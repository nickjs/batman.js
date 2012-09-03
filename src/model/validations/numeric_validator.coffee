#= require ./validators

class Batman.NumericValidator extends Batman.Validator
  @triggers 'numeric'
  @options 'allowBlank'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !value? || !(@isNumeric(value) || @canCoerceToNumeric(value))
      errors.add key, @format(key, 'not_numeric')
    callback()

  isNumeric: (value) ->
    !isNaN(parseFloat(value)) && isFinite(value)

  canCoerceToNumeric: (value) ->
    `(value - 0) == value && value.length > 0`
Batman.Validators.push Batman.NumericValidator
