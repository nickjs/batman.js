#= require ./abstract_binding

class Batman.SelectView extends Batman.View
  _addChildBinding: (binding) ->
    super
    @fire('childBindingAdded', binding)

class Batman.DOM.SelectBinding extends Batman.DOM.AbstractBinding
  backWithView: Batman.SelectView
  isInputBinding: true
  canSetImplicitly: true
  bindImmediately: false

  constructor: (definition) ->
    super
    definition.node.removeAttribute('data-bind')
    definition.node.removeAttribute('data-source')
    definition.node.removeAttribute('data-target')
    @backingView.on 'childBindingAdded', @childBindingAdded
    @bind()

  die: ->
    @backingView.off 'childBindingAdded', @childBindingAdded
    super

  childBindingAdded: (binding) =>
    if binding instanceof Batman.DOM.CheckedBinding
      binding.on 'dataChange', @nodeChange
    else if binding instanceof Batman.DOM.IteratorBinding
      binding.backingView.on 'itemsWereRendered', => @_fireDataChange(@get('filteredValue'))
    else
      return

    @_fireDataChange(@get('filteredValue'))

  lastKeyContext: null

  dataChange: (newValue) =>
    @lastKeyContext ||= @get('keyContext')
    if @lastKeyContext != @get('keyContext')
      @canSetImplicitly = true
      @lastKeyContext = @get('keyContext')

    # For multi-select boxes, the `value` property only holds the first
    # selection, so go through the child options and update as necessary.
    if newValue?.forEach
      # Use a hash to map values to their nodes to avoid O(n^2).
      valueToChild = {}
      for child in @node.children
        # Clear all options.
        child.selected = false

        # Avoid collisions among options with same values.
        matches = valueToChild[child.value] ||= []
        matches.push child

      # Select options corresponding to the new values
      newValue.forEach (value) =>
        if children = valueToChild[value]
          node.selected = true for node in children
        return

    # For a regular select box, update the value.
    else
      if !newValue? && @canSetImplicitly
        if @node.value
          @canSetImplicitly = false
          @set('unfilteredValue', @node.value)
      else
        @canSetImplicitly = false
        Batman.DOM.valueForNode(@node, newValue, @escapeValue)

    # Finally, update the options' `selected` bindings
    @updateOptionBindings()
    @fixSelectElementWidth()
    return

  nodeChange: =>
    if @isTwoWay()
      selections = Batman.DOM.valueForNode(@node)
      selections = selections[0] if typeof selections is Array && selections.length == 1
      @set 'unfilteredValue', selections
      @updateOptionBindings()
    return

  updateOptionBindings: =>
    for binding in @backingView.bindings
      binding._fireNodeChange() if binding instanceof Batman.DOM.CheckedBinding
    return

  fixSelectElementWidth: ->
    return if window.navigator.userAgent.toLowerCase().indexOf('msie') is -1 # I. Hate. Everything.
    clearTimeout(@_fixWidthTimeout) if @_fixWidthTimeout

    @_fixWidthTimeout = setTimeout =>
      @_fixWidthTimeout = null
      @_fixSelectElementWidth()
    , 100

  _fixSelectElementWidth: ->
    # There is a nasty bug in IE where select elements never reflow themselves (like ever),
    # until there is mouse interaction with them. This is a fix for select elements which
    # have their options set after they are rendered. They won't ever show their width without it.
    style = @get('node')?.style
    return if not style

    previousWidth = @get('node').currentStyle.width
    style.width = '100%'
    style.width = previousWidth ? ''

