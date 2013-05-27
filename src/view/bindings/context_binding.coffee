#= require ../view
#= require ./abstract_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  skipChildren: true

  constructor: (definition) ->
    {node, keyPath, view: superview} = definition
    return {} if Batman._data(node, 'view') instanceof Batman.ProxyView

    @proxyName = definition.attr
    @proxyView = new Batman.ProxyView(proxyName: @proxyName, node: node)
    superview.subviews.set("<context-#{@_batmanID()}-#{keyPath}>", @proxyView)

    super

  dataChange: (proxiedObject) ->
    @proxyView.set(@proxyName || '_proxiedObject', proxiedObject)

class Batman.ProxyView extends Batman.View
  _proxiedObject: null
  isProxyView: true

  targetForKeypathBase: (base) ->
    if not @proxyName
      if Batman.get(@_proxiedObject, base)?
        return @_proxiedObject

    super

  addToDOM: ->
