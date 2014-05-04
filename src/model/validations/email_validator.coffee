#= require ./validators

class Batman.EmailValidator extends Batman.Validator
  @triggers 'email'

  # WebKit's email validation regexp, which is a slightly lax implementation of
  # the HTML5 definition of a valid e-mail address. This definition was picked
  # over pure RFC 5322 due to simplicity and the reasons outlined here:
  # http://www.w3.org/TR/html5/forms.html#valid-e-mail-address
  emailRegexp: /[a-z0-9!#$%&'*+\/=?^_`{|}~.-]+@[a-z0-9-]+(\.[a-z0-9-]+)*/

  validateEach: (errors, record, key, callback) ->
    value = record.get(key)
    if !value? || value == '' || !@emailRegexp.test(value)
      errors.add key, @format(key, 'not_an_email', {}, record)
    callback()

Batman.Validators.push Batman.EmailValidator
