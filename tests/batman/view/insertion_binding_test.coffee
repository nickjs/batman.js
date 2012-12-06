helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View insertion bindings'
  setup: ->
    class @TestView extends Batman.View
      constructor: ->
        @constructor.instance = @
        super

asyncTest 'it should allow elements to be removed when the keypath evaluates to true', 3, ->
  source = '<div class="foo" data-removeif="foo"></div>'
  context = Batman foo: true
  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 0
    context.set 'foo', false
    equal $('.foo', node).length, 1
    context.set 'foo', true
    equal $('.foo', node).length, 0
    QUnit.start()

asyncTest 'it should allow elements to be inserted when the keypath evaluates to true', 2, ->
  source = '<div class="foo" data-insertif="foo"></div>'
  context = Batman foo: true
  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 1
    context.set 'foo', false
    equal $('.foo', node).length, 0
    QUnit.start()

asyncTest 'it should leave a comment node so bindings are properly destroyed', 1, ->
  source = '<div data-removeif="foo"><div data-view="OuterView"></div></div>'

  context = Batman
    foo: true
    OuterView: class OuterView extends @TestView

  helpers.render source, false, context, (node) ->
    context.OuterView.instance.on 'destroy', spy = createSpy()
    Batman.DOM.destroyNode(node)
    ok spy.called
    QUnit.start()

asyncTest 'nodes after the binding should be rendered if the keypath starts as true', 1, ->
  source = '<div data-insertif="foo"></div><p class="test" data-bind="bar"></p>'
  context = Batman foo: true, bar: 'bar'
  helpers.render source, false, context, (node) ->
    equal $('.test', node).html(), 'bar'
    QUnit.start()

asyncTest 'nodes after the binding should be rendered if the keypath starts as false', 1, ->
  source = '<div data-insertif="foo"></div><p class="test" data-bind="bar"></p>'
  context = Batman foo: false, bar: 'bar'
  helpers.render source, false, context, (node) ->
    equal $('.test', node).html(), 'bar'
    QUnit.start()

asyncTest 'it should allow keypaths to transition from falsy values to other falsy values', 3, ->
  source = '<div class="foo" data-insertif="foo"></div>'
  context = Batman()
  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 0
    context.set 'foo', false
    equal $('.foo', node).length, 0
    context.set 'foo', true
    equal $('.foo', node).length, 1
    QUnit.start()

