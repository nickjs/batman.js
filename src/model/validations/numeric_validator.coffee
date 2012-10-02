#= require ./validators

class Batman.NumericValidator extends Batman.Validator
  @triggers 'numeric', 'greaterThan', 'greaterThanOrEqualTo', 'equalTo', 'lessThan', 'lessThanOrEqualTo'
  @options 'allowBlank'

  validateEach: (errors, record, key, callback) ->
    options = @options
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !value? || !(@isNumeric(value) || @canCoerceToNumeric(value))
      errors.add key, @format(key, 'not_numeric')
    else
      if options.greaterThan and value <= options.greaterThan
        errors.add key, @format(key, 'greater_than', {count: options.greaterThan})
      if options.greaterThanOrEqualTo and value < options.greaterThanOrEqualTo
        errors.add key, @format(key, 'greater_than_or_equal_to', {count: options.greaterThanOrEqualTo})
      if options.equalTo and value != options.equalTo
        errors.add key, @format(key, 'equal_to', {count: options.equalTo})
      if options.lessThan and value >= options.lessThan
        errors.add key, @format(key, 'less_than', {count: options.lessThan})
      if options.lessThanOrEqualTo and value > options.lessThanOrEqualTo
        errors.add key, @format(key, 'less_than_or_equal_to', {count: options.lessThanOrEqualTo})
    callback()

  isNumeric: (value) ->
    !isNaN(parseFloat(value)) && isFinite(value)

  canCoerceToNumeric: (value) ->
    `(value - 0) == value && value.length > 0`
Batman.Validators.push Batman.NumericValidator
