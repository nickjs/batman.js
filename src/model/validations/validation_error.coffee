#= require ../../object

class Batman.ValidationError extends Batman.Object
  constructor: (attribute, message) -> super({attribute, message})

