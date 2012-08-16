#= require ./validators

class Batman.PresenceValidator extends Batman.Validator
  @triggers 'presence'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    unless @isPresent(value)
      errors.add key, @format(key, 'blank')
    callback()

  isPresent: (value) -> value? && value isnt ''

Batman.Validators.push Batman.PresenceValidator
