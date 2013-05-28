#= require ../view
#= require ./abstract_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  skipChildren: true

  constructor: (definition) ->
    {node, keyPath, view: superview, attr: @proxyName} = definition
    return {} if Batman._data(node, 'view') instanceof Batman.ProxyView

    @proxyView = new Batman.ProxyView(displayName: keyPath, proxyName: @proxyName, node: node)
    superview.subviews.set("<context-#{@_batmanID()}-#{keyPath}>", @proxyView)

    super

  dataChange: (proxiedObject) ->
    @proxyView.set(@proxyName || '_proxiedObject', proxiedObject)

class Batman.ProxyView extends Batman.View
  _proxiedObject: null
  isProxyView: true

  targetForKeypathBase: (base) ->
    if not @proxyName and @get('_proxiedObject')
      if Batman.get(@_proxiedObject, base)?
        return @_proxiedObject

    super

  addToDOM: ->
