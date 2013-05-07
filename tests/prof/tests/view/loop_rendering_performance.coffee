Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
jsdom = require 'jsdom'

Watson.makeADom()

Batman.Renderer::deferEvery = 0

div = (text) ->
  node = document.createElement('div')
  node.innerHTML = text if text?
  node

getSet = (limit = 1000)->
  set = new Batman.Set
  set.add(i) for i in [1..limit]
  set

Watson.benchmark 'IteratorBinding performance', (error, suite) ->
  throw error if error

  for count in [50, 100, 150]
    do (count) ->
      source = """
        <div data-foreach-item="items"></div>
      """
      getContext = ->
        Batman.RenderContext.base.descend {items: getSet(count)}
      context = getContext()

      suite.add "loop over an array of #{count} items", (deferred) ->
        view = new Batman.View
          context: context
          html: source
        view.on 'ready', -> deferred.resolve()
      , {
        onCycle: ->
          context = getContext()
        defer: true
        minSamples: 10
      }

  do ->
    source = """
      <div data-foreach-item="items"></div>
    """

    items = false
    context = false
    setContext = ->
      set = new Batman.Set
      set.add(Batman(num: i)) for i in [1..100]
      items = set.sortedBy('num')
      context = Batman.RenderContext.base.descend {items}

    setContext()

    suite.add "move one item from the top to the bottom of the set", (deferred) ->
      view = new Batman.View
        context: context
        html: source
      view.on 'ready', ->
        items.toArray()[0].set('num', 101)
        deferred.resolve()
    , {
      onCycle: ->
        setContext()
      defer: true
      minSamples: 10
    }

  do ->
    source = """
      <div data-foreach-item="items"></div>
    """

    set = false
    context = false
    boundObject = false
    setContext = ->
      set = new Batman.Set
      set.add(Batman(num: i)) for i in [1..100]
      boundObject = Batman({items: set.sortedBy('num')})
      context = Batman.RenderContext.base.descend(boundObject)

    setContext()

    suite.add "reverse the set", (deferred) ->
      view = new Batman.View
        context: context
        html: source
      view.on 'ready', ->
        boundObject.set('items', set.sortedBy('num', 'desc'))
        deferred.resolve()
    , {
      onCycle: ->
        setContext()
      defer: true
      minSamples: 10
    }

  suite.run()
