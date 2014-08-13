isEmptyDataObject = (obj) ->
  for name of obj
    return false
  return true

module.exports = Data =
  cache: {}
  uuid: 0
  expando: "batman" + Math.random().toString().replace(/\D/g, '')
  # Test to see if it's possible to delete an expando from an element
  # Fails in Internet Explorer
  canDeleteExpando: do ->
    try
      div = document.createElement 'div'
      delete div.test
    catch e
      Batman.canDeleteExpando = false

  # lower and upper case for efficiency
  noData: # these throw exceptions if you attempt to add expandos to them
    "embed": true,
    "EMBED": true,
    # Ban all objects except for Flash (which handle expandos)
    "object": "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
    "OBJECT": "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
    "applet": true,
    "APPLET": true

  hasData: (elem) ->
    elem = (if elem.nodeType then Batman.cache[elem[Batman.expando]] else elem[Batman.expando])
    !!elem and !isEmptyDataObject(elem)

  data: (elem, name, data, pvt) -> # pvt is for internal use only
    return unless Batman.acceptData(elem)
    internalKey = Batman.expando
    getByName = typeof name == "string"
    cache = Batman.cache
    # Only defining an ID for JS objects if its cache already exists allows
    # the code to shortcut on the same path as a DOM node with no cache
    id = elem[Batman.expando]

    # Avoid doing any more work than we need to when trying to get data on an
    # object that has no data at all
    if (not id or (pvt and id and (cache[id] and not cache[id][internalKey]))) and getByName and data == undefined
      return

    unless id
      # Also check that it's not a text node; IE can't set expandos on them
      if elem.nodeType isnt 3
        elem[Batman.expando] = id = ++Batman.uuid
      else
        id = Batman.expando

    cache[id] = {} unless cache[id]

    # An object can be passed to Batman._data instead of a key/value pair; this gets
    # shallow copied over onto the existing cache
    if typeof name == "object" or typeof name == "function"
      if pvt
        cache[id][internalKey] = Batman.extend(cache[id][internalKey], name)
      else
        cache[id] = Batman.extend(cache[id], name)

    thisCache = cache[id]

    # Internal Batman data is stored in a separate object inside the object's data
    # cache in order to avoid key collisions between internal data and user-defined
    # data
    if pvt
      thisCache[internalKey] ||= {}
      thisCache = thisCache[internalKey]

    if data != undefined
      thisCache[name] = data

    # Check for both converted-to-camel and non-converted data property names
    # If a data property was specified
    if getByName
      # First try to find as-is property data
      ret = thisCache[name]
    else
      ret = thisCache

    return ret

  removeData: (elem, name, pvt, all) -> # pvt is for internal use only
    return unless Batman.acceptData(elem)
    internalKey = Batman.expando
    isNode = elem.nodeType
    # non DOM-nodes have their data attached directly
    cache = Batman.cache
    id = elem[Batman.expando]

    # If there is already no cache entry for this object, there is no
    # purpose in continuing
    return unless cache[id]

    if name
      thisCache = if pvt then cache[id][internalKey] else cache[id]
      if thisCache
        # Support interoperable removal of hyphenated or camelcased keys
        delete thisCache[name]
        # If there is no data left in the cache, we want to continue
        # and let the cache object itself get destroyed
        return unless isEmptyDataObject(thisCache)

    if pvt
      delete cache[id][internalKey]
      # Don't destroy the parent cache unless the internal data object
      # had been the only thing left in it
      return unless isEmptyDataObject(cache[id])

    internalCache = cache[id][internalKey]

    # Browsers that fail expando deletion also refuse to delete expandos on
    # the window, but it will allow it on all other JS objects; other browsers
    # don't care
    # Ensure that `cache` is not a window object
    if Batman.canDeleteExpando or !cache.setInterval
      delete cache[id]
    else
      cache[id] = null

    # We destroyed the entire user cache at once because it's faster than
    # iterating through each key, but we need to continue to persist internal
    # data if it existed
    if internalCache && !all
      cache[id] = {}
      cache[id][internalKey] = internalCache
    # Otherwise, we need to eliminate the expando on the node to avoid
    # false lookups in the cache for entries that no longer exist
    else
      if Batman.canDeleteExpando
        delete elem[Batman.expando]
      else if elem.removeAttribute
        elem.removeAttribute Batman.expando
      else
        elem[Batman.expando] = null

  # For internal use only
  _data: (elem, name, data) ->
    Batman.data elem, name, data, true

  acceptData: (elem) ->
    return unless elem
    elem.___acceptData ||= if elem.nodeName
      match = Batman.noData[elem.nodeName]
      if match
        !(match == true or elem.getAttribute("classid") != match)
      else
        true
    else
      true
