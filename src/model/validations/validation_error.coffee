#= require ../../object

class Batman.ValidationError extends Batman.Object
  @accessor 'fullMessage', ->
    if @attribute == 'base'
      Batman.t 'errors.base.format',
        message: @message
    else
      Batman.t 'errors.format',
        attribute: Batman.helpers.humanize(@attribute)
        message: @message
  constructor: (attribute, message) -> super({attribute, message})
