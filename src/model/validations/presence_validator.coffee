#= require ./validators

class Batman.PresenceValidator extends Batman.Validator
  @triggers 'presence'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if value?.isProxy
      value = value.get('target')
    unless @isPresent(value)
      errors.add key, @format(key, 'blank', {}, record)
    callback()

  isPresent: (value) -> value? && value isnt ''

Batman.Validators.push Batman.PresenceValidator
