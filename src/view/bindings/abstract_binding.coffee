#= require ../dom/dom
#= require ../../object

# Bindings are shortlived objects which manage the observation of any keypaths a `data` attribute depends on.
# Bindings parse any keypaths which are filtered and use an accessor to apply the filters, and thus enjoy
# the automatic trigger and dependency system that Batman.Objects use. Every, and I really mean every method
# which uses filters has to be defined in terms of a new binding. This is so that the proper order of
# objects is traversed and any observers are properly attached.
class Batman.DOM.AbstractBinding extends Batman.Object
  # A beastly regular expression for pulling keypaths out of the JSON arguments to a filter.
  # Match either strings, object literals, or keypaths.
  keypath_rx = ///
    (^|,)             # Match either the start of an arguments list or the start of a space inbetween commas.
    \s*               # Be insensitive to whitespace between the comma and the actual arguments.
    (?:
      (true|false)
      |
      ("[^"]*")         # Match string literals
      |
      (\{[^\}]*\})      # Match object literals
      |
      (
        [a-zA-Z][\w\-\.]*   # Now that true and false can't be matched, match a dot delimited list of keys.
        [\?\!]?             # Allow ? and ! at the end of a keypath to support Ruby's methods
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
  @accessor 'filteredValue'
    get: ->
      unfilteredValue = @get('unfilteredValue')
      self = @
      renderContext = @get('renderContext')
      if @filterFunctions.length > 0
        Batman.developer.currentFilterStack = renderContext

        result = @filterFunctions.reduce((value, fn, i) ->
          # Get any argument keypaths from the context stored at parse time.
          args = self.filterArguments[i].map (argument) ->
            if argument._keypath
              self.renderContext.get(argument._keypath)
            else
              argument

          # Apply the filter.
          args.unshift value
          args.push undefined while args.length < (fn.length - 1)
          args.push self
          fn.apply(renderContext, args)
        , unfilteredValue)
        Batman.developer.currentFilterStack = null
        result
      else
        unfilteredValue

    # We ignore any filters for setting, because they often aren't reversible.
    set: (_, newValue) -> @set('unfilteredValue', newValue)

  # The `unfilteredValue` is whats evaluated each time any dependents change.
  @accessor 'unfilteredValue'
    get: ->
      # If we're working with an `@key` and not an `@value`, find the context the key belongs to so we can
      # hold a reference to it for passing to the `dataChange` and `nodeChange` observers.
      if k = @get('key')
        Batman.RenderContext.deProxy(Batman.getPath(this, ['keyContext', k]))
      else
        @get('value')
    set: (_, value) ->
      if k = @get('key')
        keyContext = @get('keyContext')
        # Supress sets on the window
        if keyContext and keyContext != Batman.container
          prop = Batman.Property.forBaseAndKey(keyContext, k)
          prop.setValue(value)
      else
        @set('value', value)


  # The `keyContext` accessor is
  @accessor 'keyContext', -> @renderContext.contextForKey(@key)

  bindImmediately: true
  shouldSet: true
  isInputBinding: false
  escapeValue: true
  onlyObserve: false

  constructor: (@definition) ->
    {@node, @keyPath, context: @renderContext, @renderer} = definition
    @onlyObserve = definition.onlyObserve if definition.onlyObserve?

    # Pull out the `@key` and filter from the `@keyPath`.
    @parseFilter()

    # Observe the node and the data.
    @bind() if @bindImmediately

  isTwoWay: -> @key? && @filterFunctions.length is 0

  bind: ->
    # Attach the observers.
    if @node? && @onlyObserve in [false, 'node'] and Batman.DOM.nodeIsEditable(@node)
      Batman.DOM.events.change @node, @_fireNodeChange

      # Usually, we let the HTML value get updated upon binding by `observeAndFire`ing the dataChange
      # function below. When dataChange isn't attached, we update the JS land value such that the
      # sync between DOM and JS is maintained.
      if @onlyObserve is 'node'
        @_fireNodeChange()

    # Observe the value of this binding's `filteredValue` and fire it immediately to update the node.
    if @onlyObserve in [false, 'data']
      @observeAndFire 'filteredValue', @_fireDataChange

    Batman.DOM.trackBinding(this, @node) if @node

  _fireNodeChange: (event) =>
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
    @fire('die')
    @dead = true
    return true

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
