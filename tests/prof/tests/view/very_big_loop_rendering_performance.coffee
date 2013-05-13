Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'

Watson.makeADom()

getSet = (limit = 1000)->
  set = new Batman.Set
  set.add(i) for i in [1..limit]
  set

Watson.benchmark 'IteratorBinding performance', (error, suite) ->
  throw error if error

  root = document.body
  context = false
  view = false
  node = false

  setContext = (count) ->
    context = Batman.RenderContext.base.descend {items: getSet(count)}

  setNode    = (source) ->
    Batman.DOM.destroyNode(node) if node
    node = document.createElement("div")
    node.innerHTML = source
    root.appendChild(node)
    node

  do ->
    source = """
      <div data-foreach-item="items">
        <span data-bind="item"></span>
        <span data-bind="item"></span>
        <span data-bind="item"></span>
      </div>
    """

    suite.add "loop over an array of 200 items with 3 bindings", (deferred) ->
      view = new Batman.View({context, node, html: source})
      view.on 'ready', ->
        deferred.resolve()
    , {
      onCycle: ->
        setContext(200)
        setNode(source)
      onStart: ->
        setContext(200)
        setNode(source)
      defer: true
      minSamples: 30
    }

    suite.add "loop over an array of 400 items with 3 bindings", (deferred) ->
      view = new Batman.View
        context: context
        node: node
        html: source
      view.on 'ready', ->
        deferred.resolve()
    , {
      onCycle: ->
        setContext(400)
        setNode(source)
      onStart: ->
        setContext(400)
        setNode(source)
      defer: true
      minSamples: 30
    }

  do ->
    source = """
      <div data-foreach-item="items">
        <p data-bind="item" data-bind-class="item">
          <span data-showif="item"></span>
          <span data-insertif="item"></span>
          Foo bar
          <span data-insertif="item"></span>
          <select>
            <option data-bind="item"></option>
          </select>
        </p>
        <p>Baz</p>
      </div>
    """

    suite.add "loop over an array of 200 items with repaint-y bindings", (deferred) ->
      view = new Batman.View({context, node, html: source})
      view.on 'ready', -> deferred.resolve()
    , {
      onCycle: ->
        setContext(200)
        setNode(source)
      onStart: ->
        setContext(200)
        setNode(source)
      defer: true
      minSamples: 30
    }

  suite.run()
