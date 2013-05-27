#= require ../view
#= require ./abstract_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  skipChildren: true

  constructor: (definition) ->
    {node, keyPath, view: superview} = definition
    return {} if Batman._data(node, 'view') instanceof Batman.ProxyView

    @proxyView = new Batman.ProxyView(node: node)
    superview.subviews.set("<context-#{@_batmanID()}-#{keyPath}>", @proxyView)

    super

  dataChange: (proxiedObject) ->
    @proxyView.set('proxiedObject', proxiedObject)

class Batman.ProxyView extends Batman.View
  proxiedObject: null
  isProxyView: true

  targetForKeypathBase: (base) ->
    if Batman.get(@proxiedObject, base)?
      return @proxiedObject

    super

  addToDOM: ->
