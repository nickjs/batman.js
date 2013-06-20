Batman.ViewContext =
  baseForKeypath: (keypath) ->
    keypath.split('.')[0].split('|')[0].trim()

  prefixForKeypath: (keypath) ->
    index = keypath.lastIndexOf('.')
    if index != -1 then keypath.substr(0, index) else keypath

  targetForKeypath: (keypath) ->
    proxiedObject = @get('proxiedObject')
    lookupNode = proxiedObject || this

    while lookupNode
      if typeof Batman.get(lookupNode, keypath) isnt 'undefined'
        return lookupNode

      controller = lookupNode.controller if not controller and lookupNode.isView and lookupNode.controller

      if proxiedObject and lookupNode == proxiedObject
        lookupNode = this
      else if lookupNode.isView and lookupNode.superview
        lookupNode = lookupNode.superview
      else if controller
        lookupNode = controller
        controller = null
      else if not lookupNode.window
        if Batman.currentApp and lookupNode != Batman.currentApp
          lookupNode = Batman.currentApp
        else
          lookupNode = {window: Batman.container}
      else
        return

  lookupKeypath: (keypath) ->
    base = @baseForKeypath(keypath)
    target = @targetForKeypath(base)

    Batman.get(target, keypath) if target

  setKeypath: (keypath, value) ->
    prefix = @prefixForKeypath(keypath)
    target = @targetForKeypath(prefix)

    return if not target || target is Batman.container
    Batman.Property.forBaseAndKey(target, keypath)?.setValue(value)
