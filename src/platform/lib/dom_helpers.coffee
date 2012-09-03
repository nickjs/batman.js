Batman.extend Batman.DOM,
  querySelectorAll: if window?.document?.querySelectorAll?
      (node, selector) -> node.querySelectorAll(selector)
    else
      -> Batman.developer.error("Please include either jQuery or a querySelectorAll polyfill, or set Batman.DOM.querySelectorAll to return an empty array.")
  querySelector: if window?.document?.querySelector?
      (node, selector) -> node.querySelector(selector)
    else
      -> Batman.developer.error("Please include either jQuery or a querySelector polyfill, or set Batman.DOM.querySelector to an empty function.")
  setInnerHTML: (node, html) ->
    childNodes = (child for child in node.childNodes)
    Batman.DOM.willRemoveNode(child) for child in childNodes
    result = node.innerHTML = html
    Batman.DOM.didRemoveNode(child) for child in childNodes
    result
  removeNode: (node) ->
    Batman.DOM.willRemoveNode(node)
    node.parentNode?.removeChild node
    Batman.DOM.didRemoveNode(node)
  appendChild: (parent, child) ->
    Batman.DOM.willInsertNode(child)
    parent.appendChild(child)
    Batman.DOM.didInsertNode(child)
