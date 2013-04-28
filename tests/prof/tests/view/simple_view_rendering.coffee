Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
jsdom = require 'jsdom'

global.window = jsdom.jsdom("<html><head><script></script></head><body></body></html>").createWindow()
global.window.Benchmark = Watson.Benchmark
global.document = window.document

simpleSource = '''
<div data-bind="foo"></div>
'''

loopSource = '''
<div data-foreach-obj="objects">
  <span data-bind="obj"></span>
</div>
'''

nestedLoopSource = '''
<div data-foreach-key="keys">
  <div data-foreach-val="sets[key]">
    <span data-bind="val"></span>
  </div>
</div>
'''

Watson.benchmark 'simple view rendering', (error, suite) ->
  throw error if error

  do ->
    suite.add('simple bindings rendering',((deferred) ->
      node = document.createElement 'div'
      node.innerHTML = simpleSource
      context = Batman(foo: 'bar')

      view = new Batman.View({context, node})
      view.on 'ready', -> deferred.resolve()
      return
    ),{
      defer: true
    })

  do ->
    suite.add('simple loop rendering', ((deferred) ->
      node = document.createElement 'div'
      node.innerHTML = loopSource
      context = Batman(objects: new Batman.Set([0...100]...))

      view = new Batman.View({context, node})
      view.on 'ready', -> deferred.resolve()
      return
    ),{
      defer: true
      maxTime: 6
    })

  do ->
    suite.add('nested loop rendering', ((deferred) ->
      node = document.createElement 'div'
      node.innerHTML = nestedLoopSource
      context = Batman
        keys: ['foo', 'bar', 'baz', 'qux']
        sets: new Batman.Hash
          foo: new Batman.Set([0...100]...)
          bar: new Batman.Set([0...100]...)
          baz: new Batman.Set([0...100]...)
          qux: new Batman.Set([0...100]...)

      view = new Batman.View({context, node})
      if view.on?
        view.on 'ready', -> deferred.resolve()
      else
        view.ready -> deferred.resolve()
      return
    ),{
      maxTime: 10
      defer: true
    })

  do ->
    suite.add('deep tree rendering', ((deferred) ->
      rootNode = node = document.createElement 'div'
      for i in [0..100]
        newNode = document.createElement 'div'
        node.appendChild newNode
        node = newNode

      context = Batman()
      view = new Batman.View({context, node})
      view.on 'ready', -> deferred.resolve()
      return
    ),{
      maxTime: 10
      defer: true
    })

  do ->
    suite.add('deep tree rendering with bindings', ((deferred) ->
      rootNode = node = document.createElement 'div'
      for i in [0..100]
        newNode = document.createElement 'div'
        newNode.setAttribute 'data-bind', 'foo'
        node.appendChild newNode
        node = newNode

      context = Batman(foo: 'bar')
      view = new Batman.View({context, node: rootNode})
      view.on 'ready', -> deferred.resolve()
      return
    ),{
      maxTime: 10
      defer: true
    })

  suite.run()
