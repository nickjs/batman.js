
Translate =
# `translate` is hook for the i18n extra to override and implement. All strings which might
# be shown to the user pass through this method. `translate` is aliased to `t` internally.
  translate: (x, values = {}) ->
    message = Batman.get(Batman.translate.messages, x)
    Batman.helpers.interpolate(message, values)

  t: -> Batman.translate(arguments...)

Translate.translate.messages = require './validations/error_messages'


module.exports = Translate