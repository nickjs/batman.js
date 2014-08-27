AbstractAttributeBinding = require './abstract_attribute_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

redundantWhitespaceRegex = /[ \t]{2,}/g

module.exports = class AddClassBinding extends AbstractAttributeBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

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
        currentName = "#{currentName} #{name}" if !includesClassName
      else
        currentName = currentName.replace(pattern, ' ') if includesClassName

    @node.className = currentName.trim().replace(redundantWhitespaceRegex, ' ')
    true
