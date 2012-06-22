#= require ../../object

class Batman.ValidationError extends Batman.Object
  @accessor 'fullMessage', -> Batman.t 'errors.format', @
  constructor: (attribute, message) -> super({attribute, message})
