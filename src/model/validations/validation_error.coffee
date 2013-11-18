#= require ../../object

class Batman.ValidationError extends Batman.Object
  @accessor 'fullMessage', ->
    if @attribute == 'base'
      Batman.t 'errors.base.format',
        message: @message
    else
      Batman.t 'errors.format',
        attribute: Batman.helpers.humanize(Batman.ValidationError.singularizeAssociated(@attribute))
        message: @message

  constructor: (attribute, message) -> super({attribute, message})

  @singularizeAssociated: (attribute) ->
    parts = attribute.split(".")
    for i in [0...parts.length - 1] by 1
      parts[i] = Batman.helpers.singularize(parts[i])
    parts.join(" ")
