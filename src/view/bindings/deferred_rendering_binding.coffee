#= require ./abstract_binding

class Batman.DOM.DeferredRenderingBinding extends Batman.DOM.AbstractBinding
  rendered: false
  skipChildren: true

  constructor: ->
    super
    @node.removeAttribute "data-renderif"

  nodeChange: ->
  dataChange: (value) ->
    if value && !@rendered
      @render()

  render: ->
    new Batman.Renderer(@node, @renderContext, @renderer.view)
    @rendered = true
