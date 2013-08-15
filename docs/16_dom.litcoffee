# Batman.DOM

Batman includes some helper methods to assist in DOM manipulation.

The following are included in the platform adapters:
 - `querySelector`
 - `querySelectorAll`
 - `destroyNode`
 - `setInnerHTML`
 - `textContent`
 - `addEventListener`
 - `removeEventListener`

## @scrollIntoView (elementID)
Scrolls the desired element into view.  If the element isn't there or
doesn't have a `scrollIntoView` method this will fail silently.

## @setStyleProperty ( node : Node, property : String, value : String, importance : String )
Sets the style property or attribute on the supplied node.  This method will prefer `setProperty` over `setAttribute`.

    test "setStyleProperty", ->
      node = document.createElement('div')
      Batman.DOM.setStyleProperty( node, "color", "white", "important")
      equal node.style.getPropertyValue("color"), "white"
      equal "important", node.style.getPropertyPriority("color")

## @valueForNode ( node: Node, [ value = '', escapeValue = true ] )
Gets the value of a node and optionally sets it as well.  `escapeValue` will escape the value via `Batman.escapeHTML`

    test 'valueForNode', ->
      node = document.createElement('input')
      val = Batman.DOM.valueForNode(node, 'stuff' )
      equal val, "stuff"
      equal node.value, "stuff"

## @nodeIsEditable ( node )
Returns whether a node is editable or not.

    test 'nodeIsEditable', ->
      node = document.createElement('div')
      ok !Batman.DOM.nodeIsEditable(node)
      node = document.createElement('input')
      ok Batman.DOM.nodeIsEditable(node)

## @addEventListener ( node, eventName, callback )
Adds the event listener, uses the platform `addEventListener` if available otherwise use `attachEvent on{eventName}`
Batman stores the listeners internally.

    test 'addEventListener', 1, ->
      node = document.createElement('div')
      Batman.DOM.addEventListener( node, 'click', -> ok true )
      node.dispatchEvent(new Event('click'))

## @removeEventListener( node, eventName, callback )
Removes the event listener from the node and removes any internal references to it.

## @cleanupNode (node)
Removes all the event listeners from the specified node and any child nodes.

## @hasAddEventListener
Returns the whether the `window` object contains addEventListener.

    test "does the window have an event listener", ->
      ok Batman.DOM.hasAddEventListener

## @preventDefault ( e : Event )
Prevents the default event from happening.  If preventDefault isn't a `function` then it will set the `returnValue` to false

    test "preventDefault", ->
      e = { returnValue: true }
      Batman.DOM.preventDefault(e)
      ok !e.returnValue

      e = { preventDefault: -> ok true }
      Batman.DOM.preventDefault(e)

## @ stopPropagation ( e : Event )
Stops the event from propogating.  If the stopPropgation isn't a `function` then it will set `cancelBubble` to true

    test "stopPropagation", ->
      e = { cancelBubble: false }
      Batman.DOM.stopPropagation(e)
      ok e.cancelBubble

      e = {stopPropagation: -> ok true }
      Batman.DOM.stopPropagation(e)

### The following methods are only available with the jQuery platform or a polyfill

## @querySelectorAll (node, selector)
Performs a jQuery like selector depending on your platform

## @querySelector (node, selector )
Performs a jQuery like selector that returns one element

## @destroyNode (node)
Calls `Batman.DOM.cleanupNode` and  removes node and anything inside from the document tree.

    test 'destroyNode', ->
      node1 = document.createElement('div')
      node2 = document.createElement('div')
      node3 = document.createElement('div')
      node1.appendChild(node2)
      node2.appendChild(node3)

      Batman.DOM.destroyNode( node1 )
      equal node1.childNodes.length, 1

## @setInnerHtml (node, html)
Set an element's content and any content that was in that element is completely replaced by the new content.
_note_ this can't be used on XML documents.

    test "innerHTML", ->
      node = document.createElement('div')
      Batman.DOM.setInnerHTML(node, "FOO")
      equal node.innerHTML, "FOO"

## @textContent ( node )
Returns the string of the text contained in the node.

    test "textContent", ->
      node = document.createElement('div')
      content = document.createTextNode("FOO")
      node.appendChild(content)
      equal Batman.DOM.textContent(node), "FOO"
