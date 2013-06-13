#= require ../dom/dom
#= require ../../object
#= require ../view

# Bindings are shortlived objects which manage the observation of any keypaths a `data` attribute depends on.
# Bindings parse any keypaths which are filtered and use an accessor to apply the filters, and thus enjoy
# the automatic trigger and dependency system that Batman.Objects use. Every, and I really mean every method
# which uses filters has to be defined in terms of a new binding. This is so that the proper order of
# objects is traversed and any observers are properly attached.
class Batman.DOM.AbstractBinding extends Batman.Object
  # A beastly regular expression for pulling keypaths out of the JSON arguments to a filter.
  # Match either strings, object literals, or keypaths.
  keypath_rx = ///
    (^|,)             # Match either the start of an arguments list or the start of a space in-between commas.
    \s*               # Be insensitive to whitespace between the comma and the actual arguments.
    (?:
      (true|false)
      |
      ("[^"]*")         # Match string literals
      |
      (\{[^\}]*\})      # Match object literals
      |
      (
        ([0-9]+[a-zA-Z\_\-]|[a-zA-Z]) # Keys that start with a number must contain at least one letter or an underscore
        [\w\-\.]*                   # Now that true and false can't be matched, match a dot delimited list of keys.
        [\?\!]?                     # Allow ? and ! at the end of a keypath to support Ruby's methods
      )
    )
    \s*                 # Be insensitive to whitespace before the next comma or end of the filter arguments list.
    (?=$|,)             # Match either the next comma or the end of the filter arguments list.
  ///g

  # A less beastly pair of regular expressions for pulling out the [] syntax `get`s in a binding string, and
  # dotted names that follow them.
  get_dot_rx = /(?:\]\.)(.+?)(?=[\[\.]|\s*\||$)/
  get_rx = /(?!^\s*)\[(.*?)\]/g

  # The `filteredValue` which calculates the final result by reducing the initial value through all the filters.
  @accessor 'filteredValue',
    get: ->
      unfilteredValue = @get('unfilteredValue')
      self = this
      if @filterFunctions.length > 0
        result = @filterFunctions.reduce((value, fn, i) ->
          # Get any argument keypaths from the context stored at parse time.
          args = self.filterArguments[i].map (argument) ->
            if argument._keypath
              self.view.lookupKeypath(argument._keypath)
            else
              argument

          # Apply the filter.
          args.unshift value
          args.push undefined while args.length < (fn.length - 1)
          args.push self
          fn.apply(self.view, args)
        , unfilteredValue)

        result
      else
        unfilteredValue

    # We ignore any filters for setting, because they often aren't reversible.
    set: (_, newValue) -> @set('unfilteredValue', newValue)

  # The `unfilteredValue` is whats evaluated each time any dependents change.
  @accessor 'unfilteredValue',
    get: -> @_unfilteredValue(@get('key'))
    set: (_, value) ->
      if k = @get('key')
        target = @get('targetForKeypathPrefix')
        if target and target isnt window
          property = Batman.Property.forBaseAndKey(target, k)
          property.setValue(value)
      else
        @set('value', value)

  _unfilteredValue: (key) ->
    # If we're working with an `@key` and not an `@value`, find the context the key belongs to so we can
    # hold a reference to it for passing to the `dataChange` and `nodeChange` observers.
    if key
      @view.lookupKeypath(key)
    else
      @get('value')

  @accessor 'targetForKeypathPrefix', ->
    if not @keyPrefix
      index = @get('key').lastIndexOf('.')
      @keyPrefix = if index != -1 then @key.substr(0, index) else @key
      @keySuffix = if index != -1 then @key.substr(index + 1) else @key

    @view.targetForKeypathBase(@keyPrefix)


  onlyAll = Batman.BindingDefinitionOnlyObserve.All
  onlyData = Batman.BindingDefinitionOnlyObserve.Data
  onlyNode = Batman.BindingDefinitionOnlyObserve.Node

  bindImmediately: true
  shouldSet: true
  isInputBinding: false
  escapeValue: true
  onlyObserve: onlyAll
  skipParseFilter: false

  constructor: (definition) ->
    {@node, @keyPath, @view} = definition
    @onlyObserve = definition.onlyObserve if definition.onlyObserve
    @skipParseFilter = definition.skipParseFilter if definition.skipParseFilter?


    # Pull out the `@key` and filter from the `@keyPath`.
    @parseFilter() if not @skipParseFilter

    viewClass = @backWithView if typeof @backWithView is 'function'
    @setupBackingView(viewClass, definition.viewOptions) if @backWithView

    # Observe the node and the data.
    @bind() if @bindImmediately

  isTwoWay: -> @key? && @filterFunctions.length is 0

  bind: ->
    # Attach the observers.
    if @node and @onlyObserve in [onlyAll, onlyNode] and Batman.DOM.nodeIsEditable(@node)
      Batman.DOM.events.change @node, @_fireNodeChange.bind(this)

      # Usually, we let the HTML value get updated upon binding by `observeAndFire`ing the dataChange
      # function below. When dataChange isn't attached, we update the JS land value such that the
      # sync between DOM and JS is maintained.
      if @onlyObserve is onlyNode
        @_fireNodeChange()

    # Observe the value of this binding's `filteredValue` and fire it immediately to update the node.
    if @onlyObserve in [onlyAll, onlyData]
      @observeAndFire 'filteredValue', @_fireDataChange

    @view._addChildBinding(this)

  _fireNodeChange: (event) ->
    @shouldSet = false
    val = @value || @get('keyContext')
    @nodeChange?(@node, val, event)
    @fire 'nodeChange', @node, val
    @shouldSet = true

  _fireDataChange: (value) =>
    if @shouldSet
      @dataChange?(value, @node)
      @fire 'dataChange', value, @node

  die: ->
    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()

    @node = null
    @keyPath = null
    @view = null
    @backingView = null
    @superview = null

  parseFilter: ->
    # Store the function which does the filtering and the arguments (all except the actual value to apply the
    # filter to) in these arrays.
    @filterFunctions = []
    @filterArguments = []

    # Rewrite [] style gets, replace quotes to be JSON friendly, and split the string by pipes to see if there are any filters.
    keyPath = @keyPath
    keyPath = keyPath.replace(get_dot_rx, "]['$1']") while get_dot_rx.test(keyPath)  # Stupid lack of lookbehind assertions...
    filters = keyPath.replace(get_rx, " | get $1 ").replace(/'/g, '"').split(/(?!")\s+\|\s+(?!")/)

    # The key will is always the first token before the pipe.
    try
      key = @parseSegment(orig = filters.shift())[0]
    catch e
      Batman.developer.warn e
      Batman.developer.error "Error! Couldn't parse keypath in \"#{orig}\". Parsing error above."
    if key and key._keypath
      @key = key._keypath
    else
      @value = key

    if filters.length
      while filterString = filters.shift()
        # For each filter, get the name and the arguments by splitting on the first space.
        split = filterString.indexOf(' ')
        split = filterString.length if split is -1

        filterName = filterString.substr(0, split)
        args = filterString.substr(split)

        # If the filter exists, grab it; otherwise, bail.
        unless filter = Batman.Filters[filterName]
          return Batman.developer.error "Unrecognized filter '#{filterName}' in key \"#{@keyPath}\"!"

        @filterFunctions.push filter

        # Get the arguments for the filter by parsing the args as JSON, or
        # just pushing an placeholder array
        try
          @filterArguments.push @parseSegment(args)
        catch e
          Batman.developer.error "Bad filter arguments \"#{args}\"!"
      true

  # Turn a piece of a `data` keypath into a usable javascript object.
  #  + replacing keypaths using the above regular expression
  #  + wrapping the `,` delimited list in square brackets
  #  + and `JSON.parse`ing them as an array.
  parseSegment: (segment) ->
    segment = segment.replace keypath_rx, (match, start = '', bool, string, object, keypath, offset) ->
      replacement = if keypath
        '{"_keypath": "' + keypath + '"}'
      else
        bool || string || object
      start + replacement
    JSON.parse("[#{segment}]")

  setupBackingView: (viewClass, viewOptions) ->
    return @backingView if @backingView
    return @backingView if @node and @backingView = Batman._data(@node, 'view')

    @superview = @view

    viewOptions ||= {}
    viewOptions.node ?= @node
    viewOptions.parentNode ?= @node

    @backingView = new (viewClass || Batman.BackingView)(viewOptions)
    @superview.subviews.add(@backingView)
    Batman._data(@node, 'view', @backingView) if @node

    return @backingView

class Batman.BackingView extends Batman.View
  bindImmediately: false
