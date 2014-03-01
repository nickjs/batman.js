# /api/Data Structures/Batman.Object/Batman.Object Accessors

When defining a class that extends `Batman.Object`, `@accessor` defines properties of instances of that class:

```coffeescript
class Superhero extends Batman.Object
  @accessor 'name', 'hasCape'                         # uses default accessor
  @accessor 'isBatman', -> @get('name') is 'Batman'   # defines a custom `get` function

  @accessor 'butler',                                 # defines `get` and `set` functions
    get: -> @_butler ||= if @get('isBatman')
          new Butler(name: "Alfred")
        else
          new Butler(name: "Jeeves")
    set: (key, value) -> @_butler = value

  @::observe 'isBatman' (newValue, oldValue) ->       # prototype observes its own accessor
    if newValue is true
      console.log "Batman has arrived!"
```

_(`@classAccessor` provides the same functionality on the constructor.)_

`@accessor` is a Batman- and old-browser-friendly version of [ES5 `Object.defineProperty`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty).

Accessors __track their sources__. If an accessor's `get` function has other `get` calls inside it, the other property will be [registered as a source](/docs/api/batman.property.html#source_tracking_by_batman.property). The accessor will be eagerly reevaluated when any of its sources change. In the example above, `isBatman` will be reevaluated when `name` changes. `butler` will be reevalutated too, but because the value is being cached manually, it won't actually change.

Accessors can be __observed__. `Batman.Property` extends `Batman.Event`, which makes properties observable.

Accessors are __inherited__, so accessors defined anywhere in an object's prototype chain will be used.


## Accessors as Computed Properties

You can define transforms on properties which automatically update when their sources change. For example, you might want to truncate a potentially long piece of text before putting it in the view or the current URL:

    test '@accessor can be called on a class to define how a property is calculated', ->
      class Post extends Batman.Object
        @accessor 'summary', -> @get('body').slice(0, 10) + "..."

      post = new Post(body: "Why Batman is Useful: A lengthy post on an important subject")
      equal post.get('summary'), "Why Batman..."

You can also use accessors to combine properties:

    test '@accessor can define a transform on several properties', ->
      class User extends Batman.Object
        @accessor 'fullName', -> "#{@get('firstName')} #{@get('lastName')}"

      tim = new User(firstName: "Tim", lastName: "Thomas")
      equal tim.get('fullName'), "Tim Thomas"
      tim.set('firstName', "Timmy")
      equal tim.get('fullName'), "Timmy Thomas"

Accessors can define custom `get`, `set`, and `unset` functions to support each operation on the property:

    test '@accessor can define the get, set, and unset methods for the property', ->
      class AbsoluteNumber extends Batman.Object
        @accessor 'value',
          get: -> @_value
          set: (_, value) -> @_value = Math.abs(value)
          unset: -> delete @_value

      number = new AbsoluteNumber(value: -10)
      equal number.get('value'), 10

It is also safe to use branching, loops, or whatever logic you want in accessor bodies:

    test '@accessor can use arbitrary logic to define the value', ->
      class Player extends Batman.Object
        @accessor 'score', ->
          if @get('played')
            (@get('goals') * 2) + (@get('assists') * 1)
          else
            0

      rick = new Player(played: false, goals: 0, assists: 0)
      equal rick.get('score'), 0
      rick.set('played', true)
      equal rick.get('score'), 0
      rick.set('goals', 3)
      equal rick.get('score'), 6
      rick.set('assists', 1)
      equal rick.get('score'), 7

## Promise Accessors

If an accessor object has a `promise` key, it is a promise accessor. The `promise` function will be called with a `deliver` function as its only argument, which it must call with `(err, value)` when its operation is complete. For example:

```coffeescript
class City extends Batman.Object
  @accessor 'population',
    promise: (deliver) ->
      new Batman.Request
        url: "/#{@get('name')}/headcount"
        success: (data) ->
          deliver(null, data.population)
        error: (err) ->
          deliver(err, null)
      return undefined

gotham = new City(name: "Gotham")
# we'll observe the property:
gotham.observe 'population', (newValue, oldValue) ->
  console.log("Population of #{@get('name')} is #{newValue}")
gotham.get('population') # returns undefined, fires a XHR request to /Gotham/headcount
# when the request succeeds with {population: 10,000,001}...
# log: "Population of Gotham is 10,000,001"
```

__Note:__ If the `promise` function returns anything truthy, its return value will be treated as an early, synchronous return.

## Default accessor as "doesNotUnderstand" or "method_missing"

The default accessor may be used as batman.js's analogue to the [`doesNotUnderstand`](http://c2.com/cgi/wiki?DoesNotUnderstand)-[`method_missing`](http://www.ruby-doc.org/core-2.1.0/BasicObject.html#method-i-method_missing)-[`__getattr__`](http://docs.python.org/2/reference/datamodel.html#object.__getattr__) pattern. Whenever `get` or `set` is called on a `Batman.Object` for a `key` which doesn't have a defined accessor, the arguments are passed to the contructor's `defaultAccessor`:

```coffeescript
class City extends Batman.Object

gotham = new City
gotham.set("name", "Gotham") # handled by City.defaultAccessor
```

The [default implementation](/docs/api/batman.property.html#class_property_defaultaccessor) of `defaultAccessor` simply stores the value. Calling `@accessor` without any `keys` redefines the `defaultAccessor` for that class:

```coffeescript
class City extends Batman.Object
  @accessor
    get: (key) -> console.log("Someone asked for #{key}")
    set: (key, value) -> console.log("Someone tried to set #{key} = #{value}")

gotham = new City
gotham.set("name", "Gotham")  # "Someone tried to set name = Gotham"
gotham.get("name")            # "Someone asked for name"
```

See the [batman.js source for `SetIndex.accessor`](https://github.com/batmanjs/batman/blob/master/src/set/set_index.coffee#L24) for an example or redefining the default accessor.

## Optimizing Accessors

### Accessors should be cachable or marked `cache: false`.

Batman.js memoizes the value of accessors and will not re-execute the body until one of the accessor's sources changes. If you need the accessor to recalculate every time the property is gotten, pass `cache: false`:

    test "@accessor usually caches results", ->
      counter = 0
      class Example extends Batman.Object
        @accessor 'cachedCounter', -> ++counter
        @accessor 'notCachedCounter',
          get: -> ++counter
          cache: false

      example = new Example()
      equal example.get('cachedCounter'), 1
      equal example.get('cachedCounter'), 1
      equal example.get('cachedCounter'), 1, "The second and third calls do not execute the function"
      equal example.get('notCachedCounter'), 2
      equal example.get('notCachedCounter'), 3, "Passing cache: false does re-execute the function"
      equal example.get('cachedCounter'), 1

### Accessors _must_ use `get` to access their sources

Batman.js tracks an accessor's sources by adding a global hook to all `get`s done, so if you don't use `get` to access properties on objects, your sources won't be registered.

### Accessors should rarely return new objects

If you return a brand new object (ie, `new ...`), you run the risk of creating performance problems. This is because accessors are recomputed every time one of their sources changes and for every call to `set`. Instead of recomputing expensive things every time the accessor is called, use objects which do smart re-computation using observers.

Practically, this translates to using things like:

```coffeescript
@accessor 'mergeSets' -> @get('setA').merge(@get('setB')          # bad! (returns a new Batman.Set)
@accessor 'mergeSets' -> @_union ||= new SetUnion(@get('setA'), @get('setB')) # good!
```

