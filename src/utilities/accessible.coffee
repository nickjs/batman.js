#= require ../object

class Batman.Accessible extends Batman.Object
  constructor: -> @accessor.apply(@, arguments)

class Batman.TerminalAccessible extends Batman.Accessible
  propertyClass: Batman.Property
  isTerminalAccessible: true
