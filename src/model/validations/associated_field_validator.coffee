#= require ./validators

class Batman.AssociatedFieldValidator extends Batman.Validator
  @triggers 'associatedFields'

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if value?
      value = value.get?('target') if value instanceof Batman.AssociationProxy
      count = 1

      childFinished = (err, childErrors) =>
        childErrors?.forEach (validationError) ->
          errors.add validationError.get('attribute'), validationError.get('message')
        if --count == 0 then callback()

      if value?.forEach?
        value.forEach (record) ->
          count += 1
          record.validate(childFinished)
      else if value?.validate?
        count += 1
        value.validate(childFinished)
      childFinished(null, [])
    else
      callback()

Batman.Validators.push Batman.AssociatedFieldValidator



