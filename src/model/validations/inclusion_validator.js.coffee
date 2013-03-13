#= require ./validators

class Batman.InclusionValidator extends Batman.Validator
  @triggers 'inclusion'

  constructor: (options) ->
    @acceptableValues = options.inclusion.in
    super

  validateEach: (errors, record, key, callback) ->
    if @acceptableValues.indexOf(record.get(key)) == -1
      errors.add key, @format(key, 'not_included_in_list')

    callback()

Batman.Validators.push Batman.InclusionValidator
