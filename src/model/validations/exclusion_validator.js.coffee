#= require ./validators

class Batman.ExclusionValidator extends Batman.Validator
  @triggers 'exclusion'

  constructor: (options) ->
    @unacceptableValues = options.exclusion.in
    super

  validateEach: (errors, record, key, callback) ->
    if @unacceptableValues.indexOf(record.get(key)) >= 0
      errors.add key, @format(key, 'included_in_list')

    callback()

Batman.Validators.push Batman.ExclusionValidator
