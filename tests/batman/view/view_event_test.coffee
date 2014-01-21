
QUnit.module 'Batman.View lifecycle events',
  setup: ->
    @superview = new Batman.View(html: '')
    @superview.addToParentNode(document.body)
    @view = new Batman.View(html: '')

    @attachViewSpies = (view) ->
      events = [
        'ready'
        'destroy'
        'viewDidMoveToSuperview'
        'viewWillAppear'
        'viewDidAppear'
        'viewWillRemoveFromSuperview'
        'viewWillDisappear'
        'viewDidDisappear'
        'viewDidLoad'
      ]
      ret = {}
      for key in events
        @view.on key, ret[key] = createSpy()
        @view[key] = ret[key]
      ret

  teardown: ->
    @superview.die() unless @superview.isDead

test 'adding to and removing from a superview fires the correct events', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 2
  equal spies.viewDidMoveToSuperview.callCount, 2
  equal spies.viewWillAppear.callCount, 2
  equal spies.viewDidAppear.callCount, 2

  @view.removeFromSuperview()
  equal spies.viewWillRemoveFromSuperview.callCount, 2
  equal spies.viewWillDisappear.callCount, 2
  equal spies.viewDidDisappear.callCount, 2
  equal spies.destroy.callCount, 0

test 'manipulating nested views fires the correct events', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 2
  equal spies.viewDidMoveToSuperview.callCount, 2
  equal spies.viewWillAppear.callCount, 2
  equal spies.viewDidAppear.callCount, 2

  @superview.removeFromParentNode()
  equal spies.viewWillRemoveFromSuperview.callCount, 0
  equal spies.viewWillDisappear.callCount, 2
  equal spies.viewDidDisappear.callCount, 2
  equal spies.destroy.callCount, 0

test 'killing the superview fires the correct events on subviews', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 2
  equal spies.viewDidMoveToSuperview.callCount, 2
  equal spies.viewWillAppear.callCount, 2
  equal spies.viewDidAppear.callCount, 2

  @superview.die()
  equal spies.viewWillRemoveFromSuperview.callCount, 2
  equal spies.viewWillDisappear.callCount, 2
  equal spies.viewDidDisappear.callCount, 2
  equal spies.destroy.callCount, 2

