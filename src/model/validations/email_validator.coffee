#= require ./validators

class Batman.EmailValidator extends Batman.Validator
  @triggers 'email'

  # WebKit's email validation regexp
  emailRegexp: /[a-z0-9!#$%&'*+\/=?^_`{|}~.-]+@[a-z0-9-]+(\.[a-z0-9-]+)*/

  constructor: (options) ->
    super

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if !value? || value == '' || !@emailRegexp.test(value)
      errors.add key, @format(key, 'not_an_email')
    callback()

Batman.Validators.push Batman.EmailValidator
