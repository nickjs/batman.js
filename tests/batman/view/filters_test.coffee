helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View filter execution',
asyncTest 'get', 1, ->
  context = Batman
    foo: new Batman.Hash({bar: "qux"})

  helpers.render '<div data-bind="foo | get \'bar\'"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'keypaths with dashes', ->
  context = Batman "foo-bar": "baz"
  helpers.render '<div data-bind="foo-bar"></div>', context, (node) ->
    equal node.html(), 'baz'
    QUnit.start()

asyncTest 'get dotted syntax', 1, ->
  context = Batman
    foo: new Batman.Hash({bar: "qux"})

  helpers.render '<div data-bind="foo.bar"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'get short syntax', 1, ->
  context = Batman
    foo: new Batman.Hash({bar: "qux"})

  helpers.render '<div data-bind="foo[\'bar\']"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'get short syntax with looked-up key', 1, ->
  context = Batman
    key: 'bar'
    foo: new Batman.Hash({bar: "qux"})

  helpers.render '<div data-bind="foo[key]"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'get short syntax with complex key', 1, ->
  context = Batman
    complex: { key: 'bar'}
    foo: new Batman.Hash({bar: "qux"})

  helpers.render '<div data-bind="foo[complex.key]"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'get short syntax with chained dot lookup', 1, ->
  context = Batman
    key: 'bar'
    foo: new Batman.Hash({bar: { baz: "qux" }})

  helpers.render '<div data-bind="foo[key].baz"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'get chained short syntax', 1, ->
  context = Batman
    foo: new Batman.Hash({bar: {baz: "qux"}})

  helpers.render '<div data-bind="foo[\'bar\'][\'baz\']"></div>', context, (node) ->
    equal node.html(), "qux"
    QUnit.start()

asyncTest 'hideously complex chain of property lookups', 1, ->
  context = Batman
    ss: { ee: 'c' }
    a: new Batman.Hash
      b:
        c:
          d:
            e:
              f:
                g:
                  h: 'value'

  helpers.render '<div data-bind="a.b[ss.ee].d[\'e\'][\'f\'].g.h"></div>', context, (node) ->
    equal node.html(), "value"
    QUnit.start()

asyncTest 'hideously complex chain of property lookups with filters', 1, ->
  context = Batman
    ss: { ee: 'c' }
    a: new Batman.Hash
      b:
        c:
          d:
            e:
              f:
                g:
                  h: 'value'
  spyOn Batman.Filters, 'spy'
  helpers.render '<div data-bind="a.b[ss.ee].d[\'e\'][\'f\'].g.h | spy"></div>', context, (node) ->
    equal Batman.Filters.spy.lastCallArguments[0], 'value'
    delete Batman.Filters.spy
    QUnit.start()

asyncTest 'truncate', 2, ->
  helpers.render '<div data-bind="foo | truncate 5"></div>',
    foo: 'your mother was a hampster'
  , (node) ->
    equal node.html(), "yo..."

    helpers.render '<div data-bind="foo.bar | truncate 5, \'\'"></div>',
      foo: Batman
        bar: 'your mother was a hampster'
    , (node) ->
      equal node.html(), "your "
      QUnit.start()

asyncTest 'prepend', 2, ->
  context = Batman(foo: 'bar')
  helpers.render '<div data-bind="foo | prepend \'special-\'"></div>', context, (node) ->
    equal node.html(), "special-bar"
    context.unset 'foo'
    equal node.html(), "special-"
    QUnit.start()

asyncTest 'prepend does not change the value if the suffix is undefined', 1, ->
  context = Batman(foo: 'bar')
  helpers.render '<div data-bind="foo | prepend test"></div>', context, (node) ->
    equal node.html(), "bar"
    QUnit.start()

asyncTest 'append', 2, ->
  context = Batman(foo: 'bar')
  helpers.render '<div data-bind="foo | append \'-special\'"></div>', context, (node) ->
    equal node.html(), "bar-special"
    context.unset 'foo'
    equal node.html(), "-special"
    QUnit.start()

asyncTest 'append does not change the value if the suffix is undefined', 1, ->
  context = Batman(foo: 'bar')
  helpers.render '<div data-bind="foo | append test"></div>', context, (node) ->
    equal node.html(), "bar"
    QUnit.start()

asyncTest 'replace', 1, ->
  helpers.render '<div data-bind="foo | replace \'bar\', \'baz\'"></div>',
    foo: 'bar'
  , (node) ->
    equal node.html(), "baz"
    QUnit.start()

asyncTest 'matches', 1, ->
  helpers.render '<div data-addclass-hasstring="foo | matches \'string\'"></div>',
    foo: 'this_has_some_strings'
  , (node) ->
    ok node.hasClass 'hasstring'
    QUnit.start()

asyncTest 'trim', 1, ->
  helpers.render '<div data-bind="foo | trim"></div>',
    foo: '    fooo      '
  , (node) ->
    equal node[0].innerHTML, "fooo"
    QUnit.start()

asyncTest 'downcase', 1, ->
  helpers.render '<div data-bind="foo | downcase"></div>',
    foo: 'BAR'
  , (node) ->
    equal node.html(), "bar"
    QUnit.start()

asyncTest 'upcase', 1, ->
  helpers.render '<div data-bind="foo | upcase"></div>',
    foo: 'bar'
  , (node) ->
    equal node.html(), "BAR"
    QUnit.start()

asyncTest 'pluralize with a count', 1, ->
  helpers.render '<div data-bind="object | pluralize count"></div>',
    object: 'foo'
    count: 2
  , (node) ->
    equal node.html(), "2 foos"
    QUnit.start()

asyncTest 'pluralize without a count', 1, ->
  helpers.render '<div data-bind="object | pluralize"></div>',
    object: 'foo'
  , (node) ->
    equal node.html(), "foos"
    QUnit.start()

asyncTest 'pluralize with a count without including the count', 2, ->
  context = Batman
    object: 'foo'
    count: 2

  helpers.render '<div data-bind="object | pluralize count, false"></div>', context, (node) ->
    equal node.html(), "foos"
    context.set 'count', 1
    equal node.html(), "foo"
    QUnit.start()

asyncTest 'pluralize with a count of 0', 1, ->
  helpers.render '<div data-bind="object | pluralize count"></div>',
    object: 'foo'
    count: 0
  , (node) ->
    equal node.html(), "0 foos"
    QUnit.start()

asyncTest 'humanize', 1, ->
  helpers.render '<div data-bind="foo | humanize"></div>',
    foo: 'one_two_three'
  , (node) ->
    equal node.html(), "One two three"
    QUnit.start()

asyncTest 'join', 2, ->
  helpers.render '<div data-bind="foo | join"></div>',
    foo: ['a', 'b', 'c']
  , (node) ->
    equal node.html(), "abc"

    helpers.render '<div data-bind="foo | join \'|\'"></div>',
      foo: ['a', 'b', 'c']
    , (node) ->
      equal node.html(), "a|b|c"
      QUnit.start()

asyncTest 'sort', 1, ->
  helpers.render '<div data-bind="foo | sort | join"></div>',
    foo: ['b', 'c', 'a', '1']
  , (node) ->
    equal node.html(), "1abc"
    QUnit.start()

asyncTest 'not', 1, ->
  helpers.render '<input type="checkbox" data-bind="foo | not" />',
    foo: true
  , (node) ->
    equal node[0].checked, false
    QUnit.start()

asyncTest 'and', 4, ->
  context = Batman
    pieuvre: true
    jambon: false

  source =  '<input type="checkbox" data-bind="pieuvre | and pieuvre"/>' +
            '<input type="checkbox" data-bind="pieuvre | and jambon"/>' +
            '<input type="checkbox" data-bind="jambon | and pieuvre"/>' +
            '<input type="checkbox" data-bind="jambon | and jambon"/>'

  helpers.render source, context, (node) ->
    equal node[0].checked, true
    equal node[1].checked, false
    equal node[2].checked, false
    equal node[3].checked, false
    QUnit.start()

asyncTest 'or', 6, ->
  context = Batman
    hotdog: true
    mushroom: false
    empty: ''
    zero: 0

  source =  """
    <input type="checkbox" data-bind="hotdog | or hotdog"/>
    <input type="checkbox" data-bind="hotdog | or mushroom"/>
    <input type="checkbox" data-bind="mushroom | or hotdog"/>
    <input type="checkbox" data-bind="mushroom | or mushroom"/>
    <input type="checkbox" data-bind="empty | or hotdog"/>
    <input type="checkbox" data-bind="zero | or hotdog"/>
  """

  helpers.render source, context, (node) ->
    equal node[0].checked, true
    equal node[1].checked, true
    equal node[2].checked, true
    equal node[3].checked, false
    equal node[4].checked, true
    equal node[5].checked, true
    QUnit.start()

asyncTest 'default', ->
  context = Batman
    hotdog: true
    mushroom: false
    empty: ''
    undef: undefined
    nulll: null
    zero: 0

  source =  """
    <input type="checkbox" data-bind="hotdog | default false"></input>
    <input type="checkbox" data-bind="mushroom | default true"></input>
    <input type="text" data-bind="zero | default 'default' | append ''"></input>
    <input type="text" data-bind="empty | default 'default'"></input>
    <input type="text" data-bind="nulll | default 'default'"></input>
    <input type="text" data-bind="undef | default 'default'"></input>
  """

  helpers.render source, context, (node) ->
    equal node[0].checked, true
    equal node[1].checked, false
    equal node[2].value, '0'
    equal node[3].value, 'default',4
    equal node[4].value, 'default', 5
    equal node[5].value, 'default', 6
    QUnit.start()

asyncTest 'map', 1, ->
  helpers.render '<div data-bind="posts | map \'name\' | join \', \'"></div>',
    posts: [
      Batman
        name: 'one'
        comments: 10
    , Batman
        name: 'two'
        comments: 20
    ]
  , (node) ->
    equal node.html(), "one, two"
    QUnit.start()

asyncTest 'map with a numeric key', 1, ->
  helpers.render '<div data-bind="counts | map 1 | join \', \'"></div>',
    counts: [
      [1, 2, 3]
      [4, 5, 6]
    ]
  , (node) ->
    equal node.html(), "2, 5"
    QUnit.start()

asyncTest 'map over a set', 1, ->
  helpers.render '<div data-bind="posts | map \'name\' | join \', \'"></div>',
    posts: new Batman.Set(
      Batman
        name: 'one'
        comments: 10
    , Batman
        name: 'two'
        comments: 20
    )
  , (node) ->
    helpers.splitAndSortedEquals node.html(), "one, two", ", "
    QUnit.start()

asyncTest 'map over batman objects', 1, ->
  class Silly extends Batman.Object
    @accessor 'foo', -> 'bar'

  helpers.render '<div data-bind="posts | map \'foo\' | join \', \'"></div>',
    {posts: new Batman.Set(new Silly, new Silly)}
  , (node) ->
    equal node.html(), "bar, bar"
    QUnit.start()

asyncTest 'has in a set', 3, ->
  posts = new Batman.Set(
    Batman
      name: 'one'
      comments: 10
  , Batman
      name: 'two'
      comments: 20
  )

  context = Batman
    posts: posts
    post: posts.toArray()[0]

  helpers.render '<input type="checkbox" data-bind="posts | has post" />', context, (node) ->
    ok node[0].checked
    context.get('posts').remove(context.get('post'))
    ok !node[0].checked
    context.get('posts').add(context.get('post'))
    ok node[0].checked

    QUnit.start()

asyncTest 'has in an array', 3, ->
  posts = [
    Batman
      name: 'one'
      comments: 10
  , Batman
      name: 'two'
      comments: 20
  ]

  secondPost = [posts[1]]

  context = Batman
    posts: posts
    post: posts[0]

  helpers.render '<input type="checkbox" data-bind="posts | has post" />', context, (node) ->
    ok node[0].checked
    context.set 'posts', secondPost
    ok !node[0].checked
    context.set 'posts', posts
    ok node[0].checked

    QUnit.start()

asyncTest 'meta', 2, ->
  context = Batman
    foo: Batman
      meta:
        get: spy = createSpy().whichReturns("something")

  helpers.render '<div data-bind="foo | meta \'bar\'"></div>', context, (node) ->
    equal node.html(), "something"
    deepEqual spy.lastCallArguments, ['bar']
    QUnit.start()

asyncTest 'meta binding to a hash', 2, ->
  context = Batman
    foo: new Batman.Hash(bar: "qux")

  helpers.render '<div data-bind="foo | meta \'length\'"></div>', context, (node) ->
    equal node.html(), "1"
    context.get('foo').set('corge', 'test')
    equal node.html(), "2"

    QUnit.start()

asyncTest 'escape', 2, ->
  context = Batman
    foo: "<script></script>"

  helpers.render '<div data-bind="foo | escape | raw"></div>', context, (node) ->
    equal node.html(), "&lt;script&gt;&lt;/script&gt;"
    context.set('foo', '"testing"')
    equal node.html(), '"testing"'

    QUnit.start()

asyncTest 'raw', 2, ->
  context = Batman
    foo: "<p></p>"

  helpers.render '<div data-bind="foo | raw"></div>', context, (node) ->
    lowerEqual node.html(), "<p></p>"
    context.set('foo', '"testing"')
    equal node.html(), '"testing"'

    QUnit.start()


QUnit.module "Batman.Filters: interpolate filter",
asyncTest "it should accept string literals", ->
  helpers.render '<div data-bind="\'this kind of defeats the purpose\' | interpolate"></div>', false, {}, (node) ->
    equal node.childNodes[0].innerHTML, "this kind of defeats the purpose"
    QUnit.start()

asyncTest "it should accept interpolation strings from other keypaths", ->
  helpers.render '<div data-bind="foo.bar | interpolate"></div>', false, {foo: {bar: "baz"}}, (node) ->
    equal node.childNodes[0].innerHTML, "baz"
    QUnit.start()

asyncTest "it should interpolate strings with simple values", ->
  source = '<div data-bind="\'pamplemouse %{kind}\' | interpolate {\'kind\': \'kind\'}"></div>'
  helpers.render source, false, {kind: 'vert'}, (node) ->
    equal node.childNodes[0].innerHTML, "pamplemouse vert"
    QUnit.start()

asyncTest "it should interpolate strings with undefined values", ->
  Batman.developer.suppress()
  source = '<div data-bind="\'pamplemouse %{kind}\' | interpolate {\'kind\': \'kind\'}"></div>'
  helpers.render source, false, {kind: undefined}, (node) ->
    Batman.developer.unsuppress()
    equal node.childNodes[0].innerHTML, "pamplemouse "
    QUnit.start()

asyncTest "it should interpolate strings with counts", ->
  context = Batman
    number: 1
    how_many_grapefruits:
      1: "1 pamplemouse"
      other: "%{count} pamplemouses"

  source = '<div data-bind="how_many_grapefruits | interpolate {\'count\': \'number\'}"></div>'
  helpers.render source, false, context, (node) ->
    equal node.childNodes[0].innerHTML, "1 pamplemouse"
    context.set 'number', 3
    helpers.render source, false, context, (node) ->
      equal node.childNodes[0].innerHTML, "3 pamplemouses"
      QUnit.start()

QUnit.module "Batman.View user defined filter execution",
asyncTest 'should render a user defined filter', 4, ->
  Batman.Filters['test'] = spy = createSpy().whichReturns("testValue")
  ctx = Batman
    foo: 'bar'
    bar: 'baz'
  helpers.render '<div data-bind="foo | test 1, \'baz\'"></div>', ctx, (node) ->
    equal node.html(), "testValue"
    equal Batman._functionName(spy.lastCallContext.constructor), 'RenderContext'
    deepEqual spy.lastCallArguments.slice(0,3), ['bar', 1, 'baz']
    ok spy.lastCallArguments[3] instanceof Batman.DOM.AbstractBinding
    delete Batman.Filters.test
    QUnit.start()
