
_entityMap =
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  "\"": "&#34;"
  "/": "&#47;"
  "'": "&#39;"

_unsafeChars = []
_encodedChars = []

for chr of _entityMap
  _unsafeChars.push(chr)
  _encodedChars.push(_entityMap[chr])

_unsafeCharsPattern = new RegExp("[#{_unsafeChars.join('')}]", "g")
_encodedCharsPattern = new RegExp("(#{_encodedChars.join('|')})", "g")


module.exports = DOMHelpers =
  escapeHTML: do ->
    return (s) -> (""+s).replace(_unsafeCharsPattern, (c) -> _entityMap[c])

  unescapeHTML: do ->
    return (s) ->
      return unless s?
      node = Batman._unescapeHTMLNode ||= document.createElement('DIV')
      node.innerHTML = s
      Batman.DOM.textContent(node)