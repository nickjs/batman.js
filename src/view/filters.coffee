# Filters
# -------
#
# `Batman.Filters` contains the simple, deterministic transforms used in view bindings to
# make life a little easier.
buntUndefined = (f) ->
  (value) ->
    unless value?
      undefined
    else
      f.apply(@, arguments)

defaultAndOr = (lhs, rhs) ->
  lhs || rhs

Batman.Filters =
  raw: buntUndefined (value, binding) ->
    binding.escapeValue = false
    value

  get: buntUndefined (value, key) ->
    if value.get?
      value.get(key)
    else
      value[key]

  equals: buntUndefined (lhs, rhs, binding) ->
    lhs is rhs

  eq: ( lhs, rhs ) ->
    lhs is rhs

  neq: ( lhs, rhs ) ->
    lhs != rhs

  lt: buntUndefined ( lhs, rhs ) ->
    lhs < rhs

  gt: buntUndefined ( lhs, rhs ) ->
    lhs > rhs

  lteq: buntUndefined ( lhs, rhs ) ->
    lhs <= rhs

  gteq: buntUndefined ( lhs, rhs ) ->
    lhs >= rhs

  and: (lhs, rhs) ->
    lhs && rhs

  or: (lhs, rhs, binding) ->
    lhs || rhs

  not: (value, binding) ->
    !value

  ceil: (value) ->
    Math.ceil(value)

  floor: (value) ->
    Math.floor(value)

  round: (value) ->
    Math.round(value)

  precision: (value, p) ->
    parseFloat(value).toPrecision(p)

  fixed: (value, f) ->
    parseFloat(value).toFixed(f)

  # this method was found here http://blog.stevenlevithan.com/archives/commafy-numbers
  # and only slightly modified here. I won't take credit for creating this.
  delimitNumber: (value) ->
    value = value.toString()
    value.replace /(^|[^\w.])(\d{4,})/g, ($0, $1, $2) ->
      $1 + $2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g, "$&,")

  trim: buntUndefined (value, binding) ->
    value.trim()

  matches: buntUndefined (value, searchFor) ->
    value.indexOf(searchFor) isnt -1

  truncate: buntUndefined (value, length, end = "...", binding) ->
    if !binding
      binding = end
      end = "..."
    if value.length > length
      value = value.substr(0, length-end.length) + end
    value

  default: (value, defaultValue, binding) ->
    if value? && value != ''
      value
    else
      defaultValue

  prepend: (value, string, binding) ->
    (string ? '') + (value ? '')

  append: (value, string, binding) ->
    (value ? '') + (string ? '')

  replace: buntUndefined (value, searchFor, replaceWith, flags, binding) ->
    if !binding
      binding = flags
      flags = undefined
    # Work around FF issue, "foo".replace("foo","bar",undefined) throws an error
    if flags is undefined
      value.replace searchFor, replaceWith
    else
      value.replace searchFor, replaceWith, flags

  downcase: buntUndefined (value) ->
    value.toLowerCase()

  upcase: buntUndefined (value) ->
    value.toUpperCase()

  pluralize: buntUndefined (string, count, includeCount, binding) ->
    if !binding
      binding = includeCount
      includeCount = true
      if !binding
        binding = count
        count = undefined

    if count?
      Batman.helpers.pluralize(count, string, undefined, includeCount)
    else
      Batman.helpers.pluralize(string)

  humanize: buntUndefined (string, binding) -> Batman.helpers.humanize(string)

  join: buntUndefined (value, withWhat = '', binding) ->
    if !binding
      binding = withWhat
      withWhat = ''
    value.join(withWhat)

  sort: buntUndefined (value) ->
    value.sort()

  map: buntUndefined (value, key) ->
    value.map((x) -> Batman.get(x, key))

  has: (set, item) ->
    return false unless set?
    Batman.contains(set, item)

  first: buntUndefined (value) ->
    value[0]

  meta: buntUndefined (value, keypath) ->
    Batman.developer.assert value.meta, "Error, value doesn't have a meta to filter on!"
    value.meta.get(keypath)

  interpolate: (string, interpolationKeypaths, binding) ->
    if not binding
      binding = interpolationKeypaths
      interpolationKeypaths = undefined
    return if not string
    values = {}
    for k, v of interpolationKeypaths
      values[k] = @lookupKeypath(v)
      if !values[k]?
        Batman.developer.warn "Warning! Undefined interpolation key #{k} for interpolation", string
        values[k] = ''

    Batman.helpers.interpolate(string, values)

  # allows you to curry arguments to a function via a filter
  withArguments: (block, curryArgs..., binding) ->
    return unless block
    if typeof block is "function"
      (regularArgs...) -> block.call @, curryArgs..., regularArgs...
    else if typeof block.get is "function"
      block.get(curryArgs...)

  escape: buntUndefined(Batman.escapeHTML)

do ->
  for k in ['capitalize', 'singularize', 'underscore', 'camelize']
    Batman.Filters[k] = buntUndefined Batman.helpers[k]

Batman.developer.addFilters()
