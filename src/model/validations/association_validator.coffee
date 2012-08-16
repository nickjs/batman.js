#= require ./validators

class Batman.AssociationValidator extends Batman.Validator
  @triggers 'association'
  @options 'allowBlank'

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !value?
      errors.add key, @format(key, 'not_valid')

    value = value.get('target') if value instanceof Batman.AssociationProxy
    if value?
      count = 1
      childFinished = (err, childErrors) =>
        if childErrors.length > 0
          errors.add key, @format(key, 'invalid_association')
        if --count == 0 then callback()

      if value.forEach?
        value.forEach (record) ->
          count += 1
          record.validate(childFinished)
      else if value.validate?
        count += 1
        value.validate(childFinished)
      childFinished(null, [])


Batman.Validators.push Batman.AssociationValidator

