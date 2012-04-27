#= require abstract_binding

class Batman.DOM.ViewBinding extends Batman.DOM.AbstractBinding
  constructor: ->
    super
    @renderer.prevent 'rendered'
    @node.removeAttribute 'data-view'

  dataChange: (viewClassOrInstance) ->
    return unless viewClassOrInstance?
    if viewClassOrInstance.isView
      @view = viewClassOrInstance
      @view.set 'context', @renderContext
      @view.set 'node', @node
    else
      @view = new viewClassOrInstance
        node: @node
        context: @renderContext
        parentView: @renderer.view

    @view.on 'ready', =>
      @renderer.allowAndFire 'rendered'

    @die()

