#= require ./abstract_binding

class Batman.DOM.ShowHideBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    display = definition.node.style.display
    display = '' if not display or display is 'none'
    @originalDisplay = display

    {@invert} = definition
    super

  dataChange: (value) ->
    view = Batman._data @node, 'view'

    if !!value is not @invert
      view?.fire 'beforeAppear', @node
      @node.style.display = @originalDisplay
      view?.fire 'appear', @node
    else
      view?.fire 'beforeDisappear', @node
      Batman.DOM.setStyleProperty(@node, 'display', 'none', 'important')
      view?.fire 'disappear', @node
