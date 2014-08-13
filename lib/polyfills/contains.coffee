# inspired by google closure's polyfill
# https://code.google.com/p/doctype-mirror/wiki/ArticleNodeContains

if /Safari/.test(navigator.userAgent)
  version = /WebKit\/(\S+)/.exec(navigator.userAgent)
  if version and parseFloat(version) < 540
    SAFARI_CONTAINS_IS_BROKEN = true

window.containsNode = (parent, child) ->
  return true if parent == child

  if parent.contains and !SAFARI_CONTAINS_IS_BROKEN
    return parent.contains(child)

  if parent.compareDocumentPosition
    return !!(parent.compareDocumentPosition(child) & 16)

  while child and parent != child
    child = child.parentNode

  return child == parent
