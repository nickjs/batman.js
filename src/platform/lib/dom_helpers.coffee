Batman.extend Batman.DOM,
  querySelectorAll: if window?.document?.querySelectorAll?
      (node = document, selector) -> node.querySelectorAll(selector)
    else
      -> Batman.developer.error("Please include either jQuery or a querySelectorAll polyfill, or set Batman.DOM.querySelectorAll to return an empty array.")

  querySelector: if window?.document?.querySelector?
      (node = document, selector) -> node.querySelector(selector)
    else
      -> Batman.developer.error("Please include either jQuery or a querySelector polyfill, or set Batman.DOM.querySelector to an empty function.")

  setInnerHTML: (node, html) ->
    node?.innerHTML = html

  destroyNode: (node) ->
    Batman.DOM.cleanupNode(node)
    node?.parentNode?.removeChild(node)

  textContent: (node) ->
    node.textContent
