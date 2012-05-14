#= require ./abstract_attribute_binding

class Batman.DOM.AddClassBinding extends Batman.DOM.AbstractAttributeBinding
  constructor: (node, className, keyPath, renderContext, renderer, only, @invert = false) ->
    names = className.split('|')
    @classes = for name in names
      {
        name: name
        pattern: new RegExp("(?:^|\\s)#{name}(?:$|\\s)", 'i')
      }
    super
    delete @attributeName

  dataChange: (value) ->
    currentName = @node.className
    for {name, pattern} in @classes
      includesClassName = pattern.test(currentName)
      if !!value is !@invert
        @node.className = "#{currentName} #{name}" if !includesClassName
      else
        @node.className = currentName.replace(pattern, ' ') if includesClassName
    true
