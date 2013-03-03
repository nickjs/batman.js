#= require ./validators

class Batman.InclusionValidator extends Batman.Validator
  @triggers 'inclusionIn'

  constructor: (options) ->
    @acceptableValues = options.inclusionIn
    super

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)

    for acceptableValue in @acceptableValues
      return callback() if acceptableValue == value

    errors.add key, @format(key, 'not_included_in_list')
    callback()

Batman.Validators.push Batman.InclusionValidator
