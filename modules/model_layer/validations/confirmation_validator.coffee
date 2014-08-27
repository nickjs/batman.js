Validator = require './validator'
{typeOf} = require 'foundation'

module.exports = class ConfirmationValidator extends Validator
  @triggers 'confirmation'
  validateEach: (errors, record, key, callback) ->
    options = @options
    return if !options.confirmation

    if typeOf(@options.confirmation) == "String"
      confirmation_key = @options.confirmation
    else
      confirmation_key = key + "_confirmation"

    value = record.get(key)
    confirmation_value = record.get(confirmation_key)

    if value != confirmation_value
      errors.add key, @format(key, 'confirmation_does_not_match', {}, record)
    callback()
