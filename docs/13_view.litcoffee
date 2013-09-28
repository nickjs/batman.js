# Batman.View

For a general explanation of `Batman.View` and how it works, see [the guide](/docs/views.html).


## ::constructor(options = {})

A `View` is a `Batman.Object`, so any options you pass are mixed in. Use this
to set `html`, `node`, `superview`, `parentNode` and/or your custom data.

    test 'constructor mixes in options', ->
      view = new Batman.View(animal: 'cat')
      equal 'cat', view.get('animal')

    test 'constructor automatically adds to the superview if supplied', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)
      equal 1, superview.subviews.length


## ::lookupKeypath(keypath) : Object

Traverses up the view tree searching for the specified keypath, and returns the
result. This is equivalent to performing a `Batman.get` for each view above
`this` in the tree, until a defined result is returned. The path it takes is as
follows:

current view → chain of superviews → layout view → active controller → app →
window

If there is no match, `undefined` is returned. However if used in an accessor
or binding, the entire path to the root will be registered as a potential
source of the keypath. Consequently, if the keypath is later set on any part of
the chain, the data will be correctly bound.

`lookupKeypath` is the function invoked to locate data when evaluating a
binding.

    test 'lookupKeypath returns the value if defined on the view', ->
      view = new Batman.View(animal: 'cat')
      equal 'cat', view.lookupKeypath('animal')

    test 'lookupKeypath returns the value if defined on an ancestor', ->
      superview = new Batman.View(animal: 'cat')
      subview = new Batman.View(superview: superview)
      equal 'cat', subview.lookupKeypath('animal')


## ::setKeypath(keypath, value) : Object

Traverses the View tree searching for the specified keypath, and sets the value
on the nearest ancestor which defines it. If no ancestor view defines the given
keypath, it will be set on the nearest ancestor which is not a
backing view.

`setKeypath` is the function invoked to set data when using an input binding.

    test 'setKeypath sets the value if defined on the view', ->
      view = new Batman.View(animal: 'dog')

      view.setKeypath('animal', 'cat')
      equal 'cat', view.get('animal')

    test 'setKeypath sets the value if defined on an ancestor', ->
      superview = new Batman.View(animal: 'dog')
      subview = new Batman.View(superview: superview)

      subview.setKeypath('animal', 'cat')
      equal 'cat', superview.get('animal')

    test 'setKeypath sets the value on the nearest non-backing view when not defined anywhere', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)
      backingView = new Batman.BackingView(superview: view)

      backingView.setKeypath('animal', 'cat')
      equal 'cat', view.get('animal')


## ::%node : Node

A reference to the DOM node that this view encapsulates. The entire tree
beneath this node is also the responsibility of this view and/or its subviews.

Accessing `node` will load and parse the template on demand if it isn't already
loaded.

    test 'node parses the template', ->
      view = new Batman.View(html: '<div>cat</div>')

      node = view.get('node')
      equal 'cat', node.firstChild.innerHTML


## ::%html : String

The HTML source for the view's template. Setting this will parse the template
and build bindings automatically, but it will not be inserted into the DOM
until the view is added to a superview.

If you don't explicitly set `html` but you do set `source`, then getting `html`
will automatically fetch the template source from the local template store.

    test 'setting a source loads the correct template', ->
      Batman.View.store.set('/animals', '<div>cat</div>')
      view = new Batman.View(source: '/animals')

      node = view.get('node')
      equal 'cat', node.firstChild.innerHTML

## ::.superview : Batman.View

A reference to the current superview (the direct ancestor in the tree). This is
used for traversing the tree when searching for data, as in
`View::lookupKeypath`.


## ::.subviews : Batman.Set

The set of direct children of a `View`. To manipulate the view tree, you should
operate directly on this set — batman.js will automatically keep the DOM in
sync with the logical tree.


## ::subviews.add(view)

Adding to a view's subview set will automatically update the tree, and parse
the template and bindings. If the superview is already in the DOM, this will
insert the current view's node into the DOM.

    test 'adding to a superview parses bindings', ->
      superview = new Batman.View()
      view = new Batman.View(html: '<div data-bind="animal"></div>', animal: 'cat')

      superview.subviews.add(view)
      equal 'cat', view.get('node').firstChild.innerHTML


## ::subviews.remove(view)

Removing from a view's subview set will automatically remove the subview from
the DOM.

    test 'removing from the current superview removes the node from the DOM', ->
      superview = new Batman.View(html: '', parentNode: document.body)
      superview.get('node')
      view = new Batman.View(html: '', superview: superview)

      ok Batman.DOM.containsNode(superview.get('node'), view.get('node'))

      superview.subviews.remove(view)
      ok not Batman.DOM.containsNode(superview.get('node'), view.get('node'))

## ::removeFromSuperview()

Removes this view from its parent, without killing it.

    test 'removing from the current superview removes the node from the DOM', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)

      view.removeFromSuperview()
      ok not superview.subviews.has(view)

## ::die()

Kills this view, which renders it to forever unusable. This has the
following implications:

- The view is removed from its superview
- The view's node is removed from the DOM
- The view's bindings are destroyed
- The view's current subviews are killed

    test 'die kills the view', ->
      superview = new Batman.View()
      view = new Batman.View(superview: superview)

      view.die()
      equal true, view.isDead
      equal 0, superview.subviews.length


## ::.isDead : boolean

True if the view has been killed, false otherwise.


## ::destroySubviews()

Kills every subview of this view.

    test 'destroySubviews kills all subviews', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: superview)

      superview.destroySubviews()
      ok one.isDead
      ok two.isDead


## ::propagateToSubviews(eventOrKey : string, value : Object)

If `value` is defined, set `eventOrKey` to `value` on the entire subtree.
Otherwise, fire `eventOrKey` on the entire subtree.

    test 'propagateToSubviews propagates events', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: one)

      superview.on 'eventName', superSpy = createSpy()
      one.on 'eventName', oneSpy = createSpy()
      two.on 'eventName', twoSpy = createSpy()

      superview.propagateToSubviews('eventName')

      equal 1, superSpy.callCount
      equal 1, oneSpy.callCount
      equal 1, twoSpy.callCount

    test 'propagateToSubviews propagates keys', ->
      superview = new Batman.View()
      one = new Batman.View(superview: superview)
      two = new Batman.View(superview: one)

      superview.propagateToSubviews('key', 'value')

      equal superview.get('key'), 'value'
      equal one.get('key'), 'value'
      equal two.get('key'), 'value'


## @viewForNode(node, climbTree = true) : Batman.View

Finds the view acting as the current context for a node — i.e. perform the
reverse mapping of the view tree to the DOM. If you pass `false` for
`climbTree`, it won't traverse up the DOM, and will return `undefined` unless
the node is the view's root.


## ::filter(label : string, filter : function)

Defines a filter on the `View` class for use within the `View` during rendering.
