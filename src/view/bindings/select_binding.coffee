#= require ./abstract_binding

class Batman.DOM.SelectBinding extends Batman.DOM.AbstractBinding
  isInputBinding: true
  canSetImplicitly: true

  constructor: ->
    @selectedBindings = new Batman.SimpleSet
    super

  childBindingAdded: (binding) =>
    if binding instanceof Batman.DOM.CheckedBinding
      binding.on 'dataChange', dataChangeHandler = => @nodeChange()
      binding.on 'die', =>
        binding.forget 'dataChange', dataChangeHandler
        @selectedBindings.remove(binding)

      @selectedBindings.add(binding)
    else if binding instanceof Batman.DOM.IteratorBinding
      binding.on 'nodeAdded', dataChangeHandler = => @_fireDataChange(@get('filteredValue'))
      binding.on 'nodeRemoved', dataChangeHandler
      binding.on 'die', ->
        binding.forget 'nodeAdded', dataChangeHandler
        binding.forget 'nodeRemoved', dataChangeHandler
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
      # Gather the selected options and update the binding
      selections = if @node.multiple
        (c.value for c in @node.children when c.selected)
      else
        @node.value
      selections = selections[0] if typeof selections is Array && selections.length == 1
      @set 'unfilteredValue', selections

      @updateOptionBindings()
    return

  updateOptionBindings: =>
    @selectedBindings.forEach (binding) -> binding._fireNodeChange()

  fixSelectElementWidth: ->
    clearTimeout(@_fixWidthTimeout) if @_fixWidthTimeout

    @_fixWidthTimeout = setTimeout =>
      @_fixWidthTimeout = null
      @_fixSelectElementWidth()
    , 100

  _fixSelectElementWidth: ->
    style = @get('node').style
    style.width = '100%'
    style.width = ''
