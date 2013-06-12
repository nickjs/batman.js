helpers = window.viewHelpers

QUnit.module "Batman.View subclasses: argument declaration and passing"

asyncTest "should allow class level declaration of arguments", 3, ->
  class TestView extends Batman.View
    @option 'keyA', 'keyB', "notgiven"

  html = '<div data-view="testView" data-view-keyA="one" data-view-keyB="two"/>'
  testView = new TestView

  helpers.render html, {testView, one: 'foo', two: 'bar'}, (node, view) ->
    equal testView.get('keyA'), "foo"
    equal testView.get('keyB'), "bar"
    equal testView.get('notgiven'), undefined
    QUnit.start()

asyncTest "should allow keypaths as argument definitions", 1, ->
  class TestView extends Batman.View
    @option 'test'

  html = '<div data-view="testView" data-view-test="foo.bar.baz" />'
  context =
    testView: (testView = new TestView)
    foo: Batman
      bar: Batman
        baz: "qux"

  helpers.render html, context, ->
    equal testView.get('test'), "qux"
    QUnit.start()

asyncTest "should track keypath argument changes and update the property on the view", 4, ->
  class TestView extends Batman.View
    @option 'keyA', 'keyB'

  html = '<div data-view="testView" data-view-keyA="one" data-view-keyB="two"/>'
  context = one: "foo", two: "bar", testView: (testView = new TestView)

  helpers.render html, context, (node, view) ->
    equal testView.get('keyA'), "foo"
    equal testView.get('keyB'), "bar"
    view.set('one', 10)
    equal testView.get('keyA'), 10
    equal testView.get('keyB'), "bar"
    QUnit.start()

asyncTest "should make the arguments available in the context of the view", ->
  class TestView extends Batman.View
    @option 'viewKey'

  source = '<div data-view="testView" data-view-viewKey="test"><p data-bind="viewKey"></p></div>'
  testView = new TestView

  helpers.render source, {testView}, (node, view) =>
    equal $('p', node).html(), ""
    view.set("test", "foo")
    equal $('p', node).html(), "foo"
    view.set("test", "bar")
    equal $('p', node).html(), "bar"
    QUnit.start()

asyncTest "should allow view arguments to be set on the view", ->
  class TestView extends Batman.View
    @option 'viewKey'

  source = '<div data-view="testView" data-view-viewKey="test"><input data-bind="viewKey" type="text" /></div>'
  testView = new TestView

  helpers.render source, {testView, test: "foo"}, (node, view) =>
    input = $('input', node)[0]
    equal input.value, "foo"

    input.value = "bar"
    helpers.triggerChange input

    equal view.get("test"), "bar"
    QUnit.start()

asyncTest "should recreate argument bindings if the view's node changes", 4, ->
  class TestView extends Batman.View
    @option 'keyA', 'keyB'

  initialHTML = '<div data-view="testView" data-view-keyA="one" data-view-keyB="two"/>'
  newHTML = '<div data-view="testView" data-view-keyA="two" data-view-keyB="one"/>'
  testView = new TestView

  helpers.render initialHTML, {testView, one: 'foo', two: 'bar'}, (node, view) ->
    equal testView.get('keyA'), "foo"
    equal testView.get('keyB'), "bar"

    view.prevent('ready')
    view.set('html', newHTML)

    equal testView.get('keyA'), "bar"
    equal testView.get('keyB'), "foo"
    QUnit.start()

