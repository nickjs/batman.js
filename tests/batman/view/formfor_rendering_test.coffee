helpers = window.viewHelpers

QUnit.module 'Batman.View rendering formfor',
  setup: ->
    @User = class User extends MockClass
      name: 'default name'

asyncTest 'it should pull in objects for form rendering', 1, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    instanceOfUser: new @User

  node = helpers.render source, context, (node) ->
    equal $('input', node).val(), "default name"
    QUnit.start()

asyncTest 'it should update objects when form rendering', 1, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    instanceOfUser: new @User

  node = helpers.render source, context, (node) =>
    $('input', node).val('new name')
    # IE8 inserts explicit text nodes
    childNode = if node[0].childNodes[2].nodeName != '#text' then node[0].childNodes[2] else node[0].childNodes[1]
    helpers.triggerChange(childNode)
    equal @User.lastInstance.name, "new name"

    QUnit.start()

asyncTest 'it should update the context for the form if the context changes', 2, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <input type="text" data-bind="user.name">
  </form>
  '''
  context = Batman()

  node = helpers.render source, context, (node, view) =>
    equal $('input', node).val(), ""
    view.set('instanceOfUser', new @User)
    equal $('input', node).val(), "default name"

    QUnit.start()

asyncTest 'it should add the errors class to an input bound to a field on the subject', 2, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <input type="text" data-bind="user.name">
  </form>
  '''

  context = instanceOfUser: Batman(name: '')

  helpers.render source, context, (node, view) =>
    ok !$('input', node).hasClass('error')

    errors = new Batman.ErrorsSet
    errors.add('name', "can't be blank")
    view.instanceOfUser.set('errors', errors)

    ok $('input', node).hasClass('error')

    QUnit.start()

asyncTest 'it should not add the errors class to a bound input if the bound input already has an errors class', ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <input type="text" data-bind="user.name" data-addclass-error="user.hasAnError" />
  </form>
  '''

  context = instanceOfUser: Batman(name: '', hasAnError: false)

  helpers.render source, context, (node, view) =>
    ok !$('input', node).hasClass('error')
    view.instanceOfUser.set('hasAnError', true)
    ok $('input', node).hasClass('error')

    QUnit.start()

asyncTest 'it should add the error list HTML to the default selected node', 3, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <div class="errors"></div>
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    instanceOfUser: Batman
      name: ''
      errors: new Batman.ErrorsSet

  helpers.render source, context, (node, view) =>
    ok node.find("div.errors ul").length > 0
    view.lookupKeypath('instanceOfUser.errors').add('name', "can't be blank")
    equal node.find("div.errors li").length, 1

    delay ->
      equal node.find("div.errors li").html(), "Name can't be blank"



asyncTest 'it should only show the errors list when there are errors', 2, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <div class="errors"></div>
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    instanceOfUser: Batman
      name: ''
      errors: new Batman.ErrorsSet

  helpers.render source, context, (node, view) =>
    equal node.find("div.errors").css('display'), 'none'
    view.lookupKeypath('instanceOfUser.errors').add('name', "can't be blank")
    equal node.find("div.errors").css('display'), ''

    QUnit.start()

asyncTest 'it shouldn\'t override already existing showif bindings on the errors list', 2, ->
  source = '''
  <form data-formfor-user="instanceOfUser">
    <div class="errors" data-showif="isVisible"></div>
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    isVisible: true
    instanceOfUser: Batman
      name: ''
      errors: new Batman.ErrorsSet

  helpers.render source, context, (node, view) =>
    equal node.find("div.errors").css('display'), ''
    view.lookupKeypath('instanceOfUser.errors').add('name', "can't be blank")
    equal node.find("div.errors").css('display'), ''

    QUnit.start()

asyncTest 'it should add the error list HTML to a specified selected node', 3, ->
  source = '''
  <form data-formfor-user="instanceOfUser" data-errors-list="#testy">
    <div class="errors"><div><span id="testy"></span></div></div>
    <input type="text" data-bind="user.name">
  </form>
  '''
  context =
    instanceOfUser: Batman
      name: ''
      errors: new Batman.ErrorsSet

  helpers.render source, context, (node, view) =>
    ok node.find("#testy ul").length > 0
    view.get('instanceOfUser.errors').add 'name', "can't be blank"
    equal node.find("#testy li").length, 1

    delay ->
      equal node.find("#testy li").html(), "Name can't be blank"
