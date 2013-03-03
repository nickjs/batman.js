#= require ./validators

class Batman.ExclusionValidator extends Batman.Validator
  @triggers 'exlusionIn'

  constructor: (options) ->
    @acceptableValues = options.exlusionIn
    super

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)

    for acceptableValue in @acceptableValues
      if acceptableValue == value
        errors.add key, @format(key, 'included_in_list')
        return callback() 

    callback()

Batman.Validators.push Batman.ExclusionValidator
