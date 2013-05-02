QUnit.module 'Batman.Controller and Batman.View integration',
asyncTest "yields populated by inner contentfor's should not be cleared after dispatch", ->
  mainContainer = document.createElement('div')
  sidebarContainer = document.createElement('div')
  Batman.DOM.Yield.withName('main').set 'containerNode', mainContainer
  Batman.DOM.Yield.withName('sidebar').set 'containerNode', sidebarContainer

  class TestController extends Batman.Controller

    # Renders into main and then sidebar through an inner yield encountered during render
    implicit: ->
      @render
        into: 'main'
        html: """
      <h1>Main view contents</h1>
      <div data-contentfor="sidebar">sidebar from implicit</div>
    """

  controller = TestController.get('sharedController')

  # Warm up the render cache so that the next dispatch yields content synchronously
  controller.dispatch 'implicit'

  delay ->
    equal mainContainer.childNodes.length, 1
    equal sidebarContainer.childNodes.length, 1

    controller.dispatch 'implicit'

    delay ->
      equal mainContainer.childNodes.length, 1
      equal sidebarContainer.childNodes.length, 1
