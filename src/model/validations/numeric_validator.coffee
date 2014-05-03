#= require ./validators

class Batman.NumericValidator extends Batman.Validator
  @triggers 'numeric', 'greaterThan', 'greaterThanOrEqualTo', 'equalTo', 'lessThan', 'lessThanOrEqualTo', 'onlyInteger'
  @options 'allowBlank'

  validateEach: (errors, record, key, callback) ->
    options = @options
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !value? || !(@isNumeric(value) || @canCoerceToNumeric(value))
      errors.add key, @format(key, 'not_numeric', {}, record)
    else if options.onlyInteger and !@isInteger(value)
      errors.add key, @format(key, 'not_an_integer', {}, record)
    else
      if options.greaterThan? and value <= options.greaterThan
        errors.add key, @format(key, 'greater_than', {count: options.greaterThan}, record)
      if options.greaterThanOrEqualTo? and value < options.greaterThanOrEqualTo
        errors.add key, @format(key, 'greater_than_or_equal_to', {count: options.greaterThanOrEqualTo}, record)
      if options.equalTo? and value != options.equalTo
        errors.add key, @format(key, 'equal_to', {count: options.equalTo}, record)
      if options.lessThan? and value >= options.lessThan
        errors.add key, @format(key, 'less_than', {count: options.lessThan}, record)
      if options.lessThanOrEqualTo? and value > options.lessThanOrEqualTo
        errors.add key, @format(key, 'less_than_or_equal_to', {count: options.lessThanOrEqualTo}, record)
    callback()

  isNumeric: (value) ->
    !isNaN(parseFloat(value)) && isFinite(value)

  isInteger: (value) ->
    parseFloat(value) == (value | 0)

  canCoerceToNumeric: (value) ->
    `(value - 0) == value && value.length > 0`
Batman.Validators.push Batman.NumericValidator
