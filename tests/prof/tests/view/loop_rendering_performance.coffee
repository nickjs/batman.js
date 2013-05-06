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

  suite.run()
