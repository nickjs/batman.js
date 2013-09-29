helpers = window.viewHelpers

QUnit.module 'Batman.View tracking bindings',
  setup: ->
    @trackSpy = trackSpy = createSpy()

    class EventTracker
      track: trackSpy

    Batman.currentApp = {EventTracker}

  teardown: ->
    Batman.currentApp = undefined
    Batman.Tracking.tracker = undefined

test 'Batman.Tracking will only instantiate the EventTracker once', ->
  equal Batman.Tracking.loadTracker(), Batman.Tracking.loadTracker()

asyncTest 'data-track-click should call track on the current app\'s EventTracker upon click', ->
  context = foo: 'bar'

  source = '<div data-track-click="foo"></div>'
  helpers.render source, context, (node, view) =>
    helpers.triggerClick(node[0])

    ok @trackSpy.called
    deepEqual @trackSpy.lastCallArguments, ['click', 'bar']

    QUnit.start()

asyncTest 'data-track-view should call track on the current app\'s EventTracker upon render', ->
  context = foo: 'bar'

  source = '<div data-track-view="foo"></div>'
  helpers.render source, context, (node, view) =>
    ok @trackSpy.called
    deepEqual @trackSpy.lastCallArguments, ['view', 'bar']

    QUnit.start()

asyncTest 'data-track-click will allow propagation to a data-event-click function', ->
  context =
    foo: 'bar'
    clickFunction: clickSpy = createSpy()

  source = '<div data-event-click="clickFunction" data-track-click="foo"></div>'
  helpers.render source, context, (node, view) =>
    helpers.triggerClick(node[0])

    ok clickSpy.called
    ok @trackSpy.called

    QUnit.start()
