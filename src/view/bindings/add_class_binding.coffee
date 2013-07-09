#= require ./abstract_attribute_binding

class Batman.DOM.AddClassBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {@invert} = definition

    @classes = for name in definition.attr.split('|')
      {name: name, pattern: new RegExp("(?:^|\\s)#{name}(?:$|\\s)", 'i')}

    super

  dataChange: (value) ->
    currentName = @node.className
    for {name, pattern} in @classes
      includesClassName = pattern.test(currentName)
      if !!value is !@invert
        if !includesClassName
          addSpace = currentName.length and currentName[currentName.length - 1] isnt ' '
          @node.className = currentName = if addSpace then "#{currentName} #{name}" else "#{currentName}#{name}"
      else
        @node.className = currentName = currentName.replace(pattern, ' ') if includesClassName
    true
