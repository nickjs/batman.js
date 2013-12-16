#= require ./validators

class Batman.ConfirmationValidator extends Batman.Validator
  @triggers 'confirmation'
  validateEach: (errors, record, key, callback) ->
    options = @options
    return if !options.confirmation

    if Batman.typeOf(@options.confirmation) == "String"
      confirmation_key = @options.confirmation
    else
      confirmation_key = key + "_confirmation"

    value = record.get(key)
    confirmation_value = record.get(confirmation_key)

    if value != confirmation_value
      errors.add key, 'and confirmation do not match'
    callback()

Batman.Validators.push Batman.ConfirmationValidator
