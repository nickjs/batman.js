_implementImmediates = (container) ->
  canUsePostMessage = ->
    return false unless container.postMessage
    async = true
    oldMessage = container.onmessage
    container.onmessage = -> async = false
    container.postMessage("","*")
    container.onmessage = oldMessage
    async

  tasks = new Batman.SimpleHash
  count = 0
  getHandle = -> "go#{++count}"

  if container.setImmediate and container.clearImmediate
    Batman.setImmediate = -> container.setImmediate.apply(container, arguments)
    Batman.clearImmediate = -> container.clearImmediate.apply(container, arguments)
  else if canUsePostMessage()
    prefix = 'com.batman.'
    handler = (e) ->
      return if typeof e.data isnt 'string' or !~e.data.search(prefix)
      handle = e.data.substring(prefix.length)
      tasks.unset(handle)?()

    if container.addEventListener
      container.addEventListener('message', handler, false)
    else
      container.attachEvent('onmessage', handler)

    Batman.setImmediate = (f) ->
      tasks.set(handle = getHandle(), f)
      container.postMessage(prefix+handle, "*")
      handle
    Batman.clearImmediate = (handle) -> tasks.unset(handle)
  else if typeof document isnt 'undefined' && "onreadystatechange" in document.createElement("script")
    Batman.setImmediate = (f) ->
      handle = getHandle()
      script = document.createElement("script")
      script.onreadystatechange = ->
        tasks.get(handle)?()
        script.onreadystatechange = null
        script.parentNode.removeChild(script)
        script = null
      document.documentElement.appendChild(script)
      handle
    Batman.clearImmediate = (handle) -> tasks.unset(handle)
  else if process?.nextTick
    functions = {}
    Batman.setImmediate = (f) ->
      handle = getHandle()
      functions[handle] = f
      process.nextTick ->
        functions[handle]?()
        delete functions[handle]
      handle

    Batman.clearImmediate = (handle) ->
      delete functions[handle]

  else
    Batman.setImmediate = (f) -> setTimeout(f, 0)
    Batman.clearImmediate = (handle) -> clearTimeout(handle)

module.exports = Immediates =
  setImmediate: ->
    _implementImmediates(Batman.container)
    Batman.setImmediate.apply(@, arguments)

  clearImmediate: ->
    _implementImmediates(Batman.container)
    Batman.clearImmediate.apply(@, arguments)



