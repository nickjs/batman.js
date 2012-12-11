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
    if parts.length is 2
      attribute = "#{Batman.helpers.singularize(parts[0])} #{parts[1]}"
    return attribute
