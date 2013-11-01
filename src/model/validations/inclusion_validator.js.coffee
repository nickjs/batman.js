#= require ./validators

class Batman.InclusionValidator extends Batman.Validator
  @triggers 'inclusion'
  @options 'allowBlank'

  constructor: (options) ->
    @acceptableValues = options.inclusion.in
    super

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if !@handleBlank(value) && @acceptableValues.indexOf(value) == -1
      errors.add key, @format(key, 'not_included_in_list')

    callback()

Batman.Validators.push Batman.InclusionValidator
