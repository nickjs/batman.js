{Set} = require 'foundation'
ValidationError = require './validation_error'
# `ErrorSet` is a simple subclass of `Set` which makes it a bit easier to
# manage the errors on a model.
module.exports = class ErrorsSet extends Set
  # Define a default accessor to get the set of errors on a key
  @accessor (key) -> @indexedBy('attribute').get(key)

  # Define a shorthand method for adding errors to a key.
  add: (key, error) -> super(new ValidationError(key, error))

