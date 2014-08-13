AbstractBinding = require './abstract_binding'

module.exports = class FileBinding extends AbstractBinding
  isInputBinding: true

  constructor: ->
    super
    @view.set('fileAttributes', null)

  nodeChange: (node, subContext) ->
    return if !@isTwoWay()
    if node.hasAttribute('multiple')
      @set 'filteredValue', Array::slice.call(node.files)
    else
      @set 'filteredValue', node.files[0] || null
