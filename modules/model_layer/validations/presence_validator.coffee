Validator = require './validator'

module.exports = class PresenceValidator extends Validator
  @triggers 'presence'
  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if value?.isProxy
      value = value.get('target')
    unless @isPresent(value)
      errors.add key, @format(key, 'blank', {}, record)
    callback()
