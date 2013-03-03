#= require ./validators

class Batman.ExclusionValidator extends Batman.Validator
  @triggers 'exclusionIn'

  constructor: (options) ->
    @unacceptableValues = options.exclusionIn
    super

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)

    for unacceptableValue in @unacceptableValues
      if unacceptableValue == value
        errors.add key, @format(key, 'included_in_list')
        return callback() 

    callback()

Batman.Validators.push Batman.ExclusionValidator
