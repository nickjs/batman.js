{BatmanObject} = require 'foundation'
{helpers} = require 'utilities'

module.exports = class ValidationError extends BatmanObject
  # FIXME TODO Batman.t
  @accessor 'fullMessage', ->
    if @attribute == 'base'
      Batman.t 'errors.base.format',
        message: @message
    else
      Batman.t 'errors.format',
        attribute: helpers.humanize(ValidationError.singularizeAssociated(@attribute))
        message: @message

  constructor: (attribute, message) -> super({attribute, message})

  @singularizeAssociated: (attribute) ->
    parts = attribute.split(".")
    for i in [0...parts.length - 1] by 1
      parts[i] = helpers.singularize(parts[i])
    parts.join(" ")
