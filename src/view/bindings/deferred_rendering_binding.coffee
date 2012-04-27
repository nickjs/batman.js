#= require abstract_binding

class Batman.DOM.DeferredRenderingBinding extends Batman.DOM.AbstractBinding
  rendered: false
  constructor: ->
    super
    @node.removeAttribute "data-renderif"

  nodeChange: ->
  dataChange: (value) ->
    if value && !@rendered
      @render()

  render: ->
    new Batman.Renderer(@node, null, @renderContext, @renderer.view)
    @rendered = true
