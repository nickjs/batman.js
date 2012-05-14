#= require ./validators

class Batman.PresenceValidator extends Batman.Validator
  @options 'presence'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if @options.presence && (!value? || value is '')
      errors.add key, @format(key, 'blank')
    callback()

Batman.Validators.push Batman.PresenceValidator
