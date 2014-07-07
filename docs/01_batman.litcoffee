# Batman

Batman includes a number of useful, general purpose helper functions and references. They can all be found attached to the `Batman` object and can optionally be exported into the global namespace with a `$` prefix.

## container

`Batman.container` points to either the `window` object if running in the browser, or the `global` object if running in node. This is useful if you want to add something to the global scope in all environments.

## @typeOf(object) : string

`typeOf` determines a more specific type of an `object` than the native `typeof` operator in JavaScript. This is useful for a number of situations like dealing with `Object` promoted strings and numbers, or arrays which look like `object`s to `typeof`. Use `typeOf` when you need more than `"object"` from `typeof`.

_Note_: `typeOf` is substantially slower than `typeof`. `typeOf` works in a somewhat hackish manner by getting the `Object::toString` representation of the object and slicing it to retrieve the name of the constructor.

    test 'typeOf returns "String" for both strings and Object strings', ->
      primitive = "test"
      objectified = new String("test")
      equal typeof primitive, "string"
      equal typeof objectified, "object"
      equal Batman.typeOf(primitive), "String"
      equal Batman.typeOf(objectified), "String"

    test 'typeOf returns Array for arrays', ->
      array = [];
      equal typeof array, "object"
      equal Batman.typeOf(array), "Array"

## @mixin(subject, objects...) : subject

`mixin`, occasionally known elsewhere as `extend` or `merge`, flattens a series of objects onto the subject. Key/value pairs on objects passed as later arguments (arguments with a higher index) take precedence over earlier arguments. Returns the `subject` passed in with the new values.

`mixin` also has special properties that make it different than the canonical `extend` functions:

 1. If the `subject` has a `set` function, `subject.set(key, value)` will be used to apply keys instead of `subject[key] = value`. This means that if the subject is a `Batman.Object`, observers and thus bindings on the object will be notified when other (Batmanified or not) objects are mixed into it.
 2. If a mixed-in `object` has an `initialize` function defined, that function will be called and passed the `subject`. This is useful for custom extension logic, similar to `self.included` in Ruby. For this reason, the keys `initialize` and `uninitialize` are skipped by `mixin`.
 3. `mixin` only iterates over keys for which the `hasOwnProperty` test passes.

_Note_: `mixin` is destructive to (only) the first argument. If you need a non-destructive version of `mixin`, just pass an empty object as the first object, and all keys from the successive arguments will be applied to the empty object.

    test 'mixin merges argument objects', ->
      subject = {}
      deepEqual Batman.mixin(subject, {fit: true}, {fly: true}, {funky: true}), {fit: true, fly: true, funky: true}, "mixin returns the subject"
      deepEqual subject, {fit: true, fly: true, funky: true}, "the subject is modified destructively"

    test 'mixin merges argument objects', ->
      unmodified = {fit: true}
      deepEqual Batman.mixin({}, unmodified, {fly: true}, {funky: true}), {fit: true, fly: true, funky: true}, "mixin returns the subject"
      deepEqual unmodified, {fit: true}, "argument objects are untouched allowing non-destructive merge"

    test 'mixed in objects passed as higher indexed arguments take precedence', ->
      subject = {}
      deepEqual Batman.mixin(subject, {x: 1, y: 1}, {x: 2}), {x: 2, y: 1}

## @unmixin(subject, objects...) : subject

`unmixin` "unmerges" the passed objects from the `subject`. If a key exists on any of the `objects` it will be `delete`d from the `subject`. Returns the `subject`.

`unmixin`, similar to `mixin`, supports calling an `uninitialize` function for each of the `objects` being unmixed in. If an `uninitialize` function exists on each

    test 'unmixin removes keys found on the unmixined objects on the subject', ->
      subject = {fit: true, fly: true, funky: true}
      deepEqual Batman.unmixin(subject, {fit: true}, {fly: true}), {funky: true}, "unmixin returns the subject"
      deepEqual subject, {funky: true}, "the subject is destructively modified."

## @functionName(function) : string

`functionName` returns the name of a given function, if any. Works with Internet Explorer 7/8/9, FireFox, Chrome, and Safari.

    test 'functionName returns the name of a given function', ->
      equal Batman.functionName("".toString), 'toString'

## @isChildOf(parent : HTMLElement, child : HTMLElement) : boolean

`isChildOf` is a simple DOM helper which returns a boolean describing if the passed `child` node can be found in the descendants of the passed `parent` node.

## @setImmediate(callback : Function) : object

`setImmediate` (and its sister `clearImmediate`) are a more efficient version of `setTimeout(callback, 0)`. Due to timer resolution issues, setTimeout passed a timeout of 0 doesn't actually execute the function as soon as the JS execution stack has been emptied, but at minimum 4ms and maxmium 25ms after. For this reason Batman provides a cross browser implementation of `setImmediate` which does its best to call the callback immediately after the stack empties. Batman's `setImmediate` polyfill uses the native version if available, `window.postmessage` trickery if supported, and falls back on `setTimeout(->, 0)`.

`setImmediate` returns a handle which can be passed to `clearImmediate` to cancel the future calling of the callback.

## @clearImmediate(handle)

`clearImmediate` stops the calling of a callback in the future when passed its `handle` (which is returned from the `setImmediate` call used to enqueue it).

## @forEach(iterable : object, iterator : Function[, context : Object])

The `forEach` Batman helper is a universal iteration helper. When passed an `iterable` object, the helper will call the `iterator` (optionally in the `context`) for each item in the `iterable`. The `iterable` can be:

 1. something which has its own `forEach`, in which case the `iterator` will just be passed to `iterable.forEach`.
 2. an array like object, in which case a JavaScript `for(;;)` loop will be used to iterate over each entry
 3. or an object, in which case a JavaScript `for-in` loop will be used to iterate over each entry.

The `forEach` helper is useful for iterating over objects when the type of those objects isn't guaranteed.

    test 'forEach iterates over objects with forEach defined', ->
      results = []
      set = new Batman.SimpleSet ['a']
      Batman.forEach(set, (x) -> results.push(x))
      deepEqual results, ['a']

    test 'forEach iterates over array like objects', ->
      results = []
      ArrayLike = ->
      ArrayLike:: = []
      imitation = new ArrayLike
      Array::push.call(imitation, "a")
      Array::push.call(imitation, "b")
      Batman.forEach(imitation, (x) -> results.push(x))
      deepEqual results, ['a', 'b']

    test 'forEach iterates over objects', ->
      result = {}
      object = {x: true}
      Batman.forEach(object, (key, val) -> result[key] = val)
      deepEqual result, object

## @objectHasKey(object, key) : boolean

`objectHasKey` returns a boolean describing the presence of the `key` in the passed `object`. `objectHasKey` delegates to the `object`'s `hasKey` function if present, and otherwise just does a check using the JavaScript `in` operator.

    test 'objectHasKey verifies if a key is present in an object', ->
      subject = {fit: true}
      ok Batman.objectHasKey(subject, 'fit')
      equal Batman.objectHasKey(subject, 'flirty'), false

    test 'objectHasKey verifies if a key is present in an object with `hasKey` defined', ->
      subject = new Batman.SimpleHash {fit: true}
      ok Batman.objectHasKey(subject, 'fit')
      equal Batman.objectHasKey(subject, 'flirty'), false

## @contains(object, item) : boolean

`contains` returns a boolean describing if the given `object` has member `item`. Membership in this context is defined as:

 + the result of `object.has(item)` if the `object` has a `has` function defined
 + the result of `item in object` if the `object` is arraylike
 + the result of the Batman.objectHasKey otherwise

_Note_: When passed an object without a `has` function, `contains` will return `true` if the `object` has `item` as a *`key`*, not as a value at any key.

`contains` is useful for checking item membership when the type of the object can't be relied on.

## @get(object, key) : value

`get` is a general purpose function for retrieving the value from a `key` on an `object` of an indeterminate type. This is useful if code needs to work with both `Batman.Object`s and Plain Old JavaScript Objects. `get` has the following semantics:

- if the `object` has a `get` function defined, return the result of `object.get(key)`
- if the object does not have a `get` function defined, use an ephemeral `Batman.Property` to retrieve the key. This is equivalent to `object[key]` for single segment `key`s, but if the `key` is multi-segment (example: 'product.customer.name'), `get` will do nested gets until the either `undefined` or the end of the keypath is reached.

<!-- tests -->

    test 'get returns the value at a key on a POJO', ->
      subject = {fit: true}
      equal Batman.get(subject, 'fit'), true
      equal Batman.get(subject, 'flirty'), undefined

    test 'get returns the value at a key on a Batman.Object', ->
      subject = Batman {fit: true}
      equal Batman.get(subject, 'fit'), true
      equal Batman.get(subject, 'flirty'), undefined

    test 'get returns the value at a deep key on a POJO', ->
      subject = {customer: {name: "Joe"}}
      equal Batman.get(subject, 'customer.name'), "Joe"
      equal Batman.get(subject, 'customer.age'), undefined

    test 'get returns the value at a deep key on a Batman.Object', ->
      subject = Batman {customer: {name: "Joe"}}
      equal Batman.get(subject, 'customer.name'), "Joe"
      equal Batman.get(subject, 'customer.age'), undefined

## @getPath(base, segments) : string

`getPath` returns the hash value denoted by the specified path, which consists of an array of nested hash keys. See examples below for more detail.

    test "takes a base and an array of keys and returns the corresponding nested value", ->
      @complexObject = new Batman.Object
        hash: new Batman.Hash
          foo: new Batman.Object(bar: 'nested value'),
          "foo.bar": 'flat value'
      equal Batman.getPath(@complexObject, ['hash', 'foo', 'bar']), 'nested value'
      equal Batman.getPath(@complexObject, ['hash', 'foo.bar']), 'flat value'
      strictEqual Batman.getPath(@complexObject, ['hash', 'not-foo', 'bar']), undefined

    test "returns just the base if the key array is empty", ->
      @complexObject = new Batman.Object
        hash: new Batman.Hash
          foo: new Batman.Object(bar: 'nested value'),
          "foo.bar": 'flat value'
      strictEqual Batman.getPath(@complexObject, []), @complexObject
      strictEqual Batman.getPath(null, []), null

    test "returns undefined if the base is null-ish", ->
      @complexObject = new Batman.Object
        hash: new Batman.Hash
          foo: new Batman.Object(bar: 'nested value'),
          "foo.bar": 'flat value'
      strictEqual Batman.getPath(null, ['foo']), undefined
      strictEqual Batman.getPath(undefined, ['foo']), undefined

    test "returns falsy values", ->
      @complexObject = new Batman.Object
        hash: new Batman.Hash
          foo: new Batman.Object(bar: 'nested value'),
          "foo.bar": 'flat value'
      strictEqual Batman.getPath(num: 0, ['num']), 0
      strictEqual Batman.getPath(thing: null, ['thing']), null

## @escapeHTML(input) : string

`escapeHTML` takes a string of unknown origin and makes it safe for display on a web page by encoding control characters in HTML into their HTML entities.

*Warning*: Do not rely on `escapeHTML` to purge unsafe data from user submitted content. While `escapeHTML` is applied to every binding's contents by default, it should not be your only line of defence against script injection attacks.

    test 'escapeHTML encodes special characters into HTML entities', ->
      equal Batman.escapeHTML("& < > \" '"), "&amp; &lt; &gt; &#34; &#39;"

## @redirect(options: [string|Object])

Redirects to a new path with either pushState or hashbang navigation, depending on your [configuration](/docs/configuration.html). `options` may be:

- a string, which is treated as the target path (eg, `"/posts"`)
- a `Batman.Model` class, which redirects to "index" (eg, `Batman.redirect(MyApp.Post)` redirects to `"/posts"`)
- a `Batman.Model` instance, which redirects to "show" (eg, `Batman.redirect(thisPost)` redirects to `"/posts/#{thisPost.toParam()}"`)
- an object containing params:
  - `Batman.redirect({controller: "posts", action: "index"})` redirects to  `"/posts"`
  - `Batman.redirect({controller: "posts", action: "edit", id: 6})` redirects to `"/posts/6/edit"`
