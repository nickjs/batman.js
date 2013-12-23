# Batman.Model

For a general explanation of `Batman.Model` and how it works, see [the guide](/docs/models.html).

_Note_: This documentation uses the term _model_ to refer to the class `Model`
or a `Model` subclass, and the term _record_ to refer to one instance of a
model.

## @primaryKey : string

`primaryKey` is a class level configuration option to change which key batman.js uses as the primary key. Change the option using `set`, like so:

    test 'primary key can be set using @set', ->
      class Shop extends Batman.Model
        @set 'primaryKey', 'shop_id'

      equal Shop.get('primaryKey'), 'shop_id'

The `primaryKey` is what batman.js uses to compare instances to see if they represent the same domain-level object: if two records have the same value at the key specified by `primaryKey`, only one will be in the identity map. The key specified by `primaryKey` is also used by the associations system when determining if a record is related to another record, and by the remote storage adapters to generate URLs for records.

_Note_: The default primaryKey is 'id'.

## @storageKey : string

`storageKey` is a class level option which gives the storage adapters something to interpolate into their specific key generation schemes. In the case of `LocalStorage` or `SessionStorage` adapters, the `storageKey` defines what namespace to store this record under in the `localStorage` or `sessionStorage` host objects, and with the case of the `RestStorage` family of adapters, the `storageKey` assists in URL generation. See the documentation for the storage adapter of your choice for more information.

The default `storageKey` is `null`.

## @persist(mechanism : StorageAdapter) : StorageAdapter

`@persist` is how a `Model` subclass is told to persist itself by means of a `StorageAdapter`. `@persist` accepts either a `StorageAdapter` class or instance and will return either the instantiated class or the instance passed to it for further modification.

    test 'models can be told to persist via a storage adapter', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @persist TestStorageAdapter

      record = new Shop
      ok record.hasStorage()

    test '@persist returns the instantiated storage adapter', ->
      adapter = false
      class Shop extends Batman.Model
        @resourceName: 'shop'
        adapter = @persist TestStorageAdapter

      ok adapter instanceof Batman.StorageAdapter

    test '@persist accepts already instantiated storage adapters', ->
      adapter = new Batman.StorageAdapter
      adapter.someHandyConfigurationOption = true
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @persist adapter

      record = new Shop
      ok record.hasStorage()

## @encode(keys...[, encoderObject : [Object|Function]])

`@encode` specifies a list of `keys` a model should expect from and send back to a storage adapter, and any transforms to apply to those attributes as they enter and exit the world of batman.js in the optional `encoderObject`.

The `encoderObject` should have an `encode` and/or a `decode` key which point to functions. The functions accept the "raw" data (the batman.js land value in the case of `encode`, and the backend land value in the case of `decode`), and should return the data suitable for the other side of the link. The functions should have the following signatures:

    encoderObject = {
      encode: (value, key, builtJSON, record) ->
      decode: (value, key, incomingJSON, outgoingObject, record) ->
    }

By default these functions are the identity functions. They apply no transformation. The arguments for `encode` functions are as follows:

 + `value` is the client side value of the `key` on the `record`
 + `key` is the key that `value` is stored under on the `record`. This is useful when passing the same `encoderObject` which needs to pivot on what key is being encoded to different calls to `encode`.
 + `builtJSON` is the object passed to and modified by each encoder, and eventually becomes the return value of the `toJSON` call.
 + `record` is the record on which `toJSON` has been called.

For `decode` functions:

 + `value` is the raw value received from the storage adapter.
 + `key` is the key that `value` is stored under on the incoming data.
 + `incomingJSON` is the object which is being decoded into the `record`. This can be used to create compound key decoders.
 + `outgoingObject` is the object built up by the decoders and mixed into the record.
 + `record` is the record on which `fromJSON` has been called.

The `encode` and `decode` keys can also be false to avoid using the default identity function encoder or decoder.

To encode a `key` under a name which differs from that in the raw data, you can specify the `as` option with the raw key name. The `as` option can be either a string or function.

If you specify the `as` option as a function it will receive the following arguments:

 + `key` is the name which the `value` is stored under in the raw data.
 + `value` is the `value` of the `key` which will end up on the `record`.
 + `data` is the object which is modified by each encoder or decoder.
 + `record` is the record on which `toJSON` or `fromJSON` has been called.

_Note_: `Batman.Model` subclasses have no encoders by default, except for one which automatically decodes the `primaryKey` of the model, which is usually `id`. To get any data into or out of your model, you must white-list the keys you expect from the server or storage attribute.

    test '@encode accepts a list of keys which are used during decoding', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'name', 'url', 'email', 'country'

      json = {name: "Snowdevil", url: "snowdevil.ca"}
      record = new Shop()
      record.fromJSON(json)
      equal record.get('name'), "Snowdevil"

    test '@encode accepts a list of keys which are used during encoding', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'name', 'url', 'email', 'country'

      record = new Shop(name: "Snowdevil", url: "snowdevil.ca")
      deepEqual record.toJSON(), {name: "Snowdevil", url: "snowdevil.ca"}

    test '@encode accepts custom encoders', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'name',
          encode: (name) -> name.toUpperCase()

      record = new Shop(name: "Snowdevil")
      deepEqual record.toJSON(), {name: "SNOWDEVIL"}

    test '@encode accepts custom decoders', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'name',
          decode: (name) -> name.replace('_', ' ')

      record = new Shop()
      record.fromJSON {name: "Snow_devil"}
      equal record.get('name'), "Snow devil"

    test '@encode can be passed an encoderObject with false to prevent the default encoder or decoder', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'name', {encode: false, decode: (x) -> x}
        @encode 'url'

      record = new Shop()
      record.fromJSON {name: "Snowdevil", url: "snowdevil.ca"}
      equal record.get('name'), 'Snowdevil'
      equal record.get('url'), "snowdevil.ca"
      deepEqual record.toJSON(), {url: "snowdevil.ca"}, 'The name key is absent because of encode: false'

    test '@encode accepts an as option to encode a key under a name which differs from that in the raw data', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'countryCode',
          as: 'country_code'
          encode: @defaultEncoder.encode
          decode: @defaultEncoder.decode

      record = new Shop(countryCode: 'SE')
      deepEqual record.toJSON(), {country_code: 'SE'}

Some more handy examples:

    test '@encode can be used to turn comma separated values into arrays', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'tags',
          decode: (string) -> string.split(', ')
          encode: (array) -> array.join(', ')

      record = new Post()
      record.fromJSON({tags: 'new, hot, cool'})
      deepEqual record.get('tags'), ['new', 'hot', 'cool']
      deepEqual record.toJSON(), {tags: 'new, hot, cool'}

    test '@encode can be used to turn arrays into sets', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'tags',
          decode: (array) -> new Batman.Set(array...)
          encode: (set) -> set.toArray()

      record = new Post()
      record.fromJSON({tags: ['new', 'hot', 'cool']})
      ok record.get('tags') instanceof Batman.Set
      deepEqual record.toJSON(), {tags: ['new', 'hot', 'cool']}

    test '@encode accepts the as option as a function', ->
      class Shop extends Batman.Model
        @resourceName: 'shop'
        @encode 'countryCode',
          as: (key) -> Batman.helpers.underscore(key)
          encode: @defaultEncoder.encode
          decode: @defaultEncoder.decode

      record = new Shop(countryCode: 'SE')
      deepEqual record.toJSON(), {country_code: 'SE'}

## @validate(keys...[, options : [Object|Function]])

Validations allow a model to be marked as `valid` or `invalid` based on a set of programmatic rules. By validating a model's data before it gets to the server we can provide immediate feedback to the user about what they have entered and forgo waiting on a round trip to the server. `validate` allows the attachment of validations to the model on particular keys, where the validation is either a built in one (invoked by use of options to pass to them) or a custom one (invoked by use of a custom function as the second argument).

_Note_: Validation in batman.js is always asynchronous, despite the fact that none of the validations may use an asynchronous operation to check for validity. This is so that the API is consistent regardless of the validations used.

Built in validators are attached by calling `@validate` with options designating how to calculate the validity of the key:

    test '@validate accepts options to check for validity', ->
      QUnit.expect(0)
      class Post extends Batman.Model
        @resourceName: 'post'
        @validate 'title', 'body', {presence: true}

The built in validation options are listed below:

 + `presence : boolean`: Assert that the string value is existent (not undefined or null) and has length greater than 0.
 + `numeric : true`: Assert that the value is or can be coerced into a number using `parseFloat`.
 + `greaterThan : number`: Assert that the value is greater than the given number.
 + `greaterThanOrEqualTo : number`: Assert that the value is greater than or equal to the given number.
 + `equalTo : number`: Assert that the value is equal to the given number.
 + `lessThan : number`: Assert that the value is less than the given number.
 + `lessThanOrEqualTo : number`: Assert that the value is less than or equal to the given number.
 + `minLength : number`: Assert that the value's `length` property is greater than the given number.
 + `maxLength : number`: Assert that the value's `length` property is less than the given number.
 + `length : number`: Assert that the value's `length` property is exactly the given number.
 + `lengthWithin : [number, number]` or `lengthIn : [number, number]`: Assert that the value's `length` property is within the ranger specified by the given array of two numbers, where the first number is the lower bound and the second number is the upper bound.
 + `inclusion : in : [list, of, acceptable, values]`: Assert that the value is equal to one of the values in an array.
 + `exclusion : in : [list, of, unacceptable, values]`: Assert that the value is not equal to any of the values in an array.

Custom validators should have the signature `(errors, record, key, callback)`. The arguments are as follows:

 + `errors`: an `ErrorsSet` instance which expects to have `add` called on it to add errors to the model
 + `record`: the record being validated
 + `key`: the key to which the validation has been attached
 + `callback`: a function to call once validation has been completed. Calling this function is __mandatory__.

See [`Model::validate`](/docs/api/batman.model.html#prototype_function_validate) for information on how to get a particular record's validity.

## @loaded : Set

The `loaded` set is available on every model class and holds every model instance seen by the system in order to function as an identity map. Successfully loading or saving individual records or batches of records will result in those records being added to the `loaded` set. Destroying instances will remove records from the identity set.

    test 'the loaded set stores all records seen', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @persist TestStorageAdapter
        @encode 'name'

      ok Post.get('loaded') instanceof Batman.Set
      equal Post.get('loaded.length'), 0
      post = new Post()
      post.save()
      equal Post.get('loaded.length'), 1

    test 'the loaded adds new records caused by loads and removes records caused by destroys', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'

      adapter = new TestStorageAdapter(Post)
      adapter.storage =
          'posts1': {name: "One", id:1}
          'posts2': {name: "Two", id:2}

      Post.persist(adapter)
      Post.load()
      equal Post.get('loaded.length'), 2
      post = false
      Post.find(1, (err, result) -> post = result)
      post.destroy()
      equal Post.get('loaded.length'), 1

## @all : Set

The `all` set is an alias to the `loaded` set but with an added implicit `load` on the model. `Model.get('all')` will synchronously return the `loaded` set and asynchronously call `Model.load()` without options to load a batch of records and populate the set originally returned (the `loaded` set) with the records returned by the server.

_Note_: The notion of "all the records" is relative only to the client. It completely depends on the storage adapter in use and any backends which they may contact to determine what comes back during a `Model.load`. This means that if for example your API paginates records, the set found in `all` may hold on the first 50 records instead of the entire backend set.

`all` is useful for listing every instance of a model in a view, and since the `loaded` set will change when the `load` returns, it can be safely bound to.

    asyncTest 'the all set asynchronously fetches records when gotten', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'

      adapter = new AsyncTestStorageAdapter(Post)
      adapter.storage =
          'posts1': {name: "One", id:1}
          'posts2': {name: "Two", id:2}

      Post.persist(adapter)
      equal Post.get('all.length'), 0, "The synchronously returned set is empty"
      delay ->
        equal Post.get('all.length'), 2, "After the async load the set is populated"

## @clear() : Set

`Model.clear()` empties that `Model`'s identity map. This is useful for tests and other unnatural situations where records new to the system are guaranteed to be as such.

    test 'clearing a model removes all records from the identity map', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'

      adapter = new TestStorageAdapter(Post)
      adapter.storage =
          'posts1': {name: "One", id:1}
          'posts2': {name: "Two", id:2}
      Post.persist(adapter)
      Post.load()
      equal Post.get('loaded.length'), 2
      Post.clear()
      equal Post.get('loaded.length'), 0, "After clear() the loaded set is empty"

## @find(id, callback : Function) : Model

`Model.find()` retrieves a record with the specified `id` from the storage adapter and calls back with an error if one occurred and the record if the operation was successful. `find` delegates to the storage adapter the `Model` has been `@persist`ed with, so it is up to the storage adapter's semantics to determine what type of errors may return and the timeline on which the callback may be called. The `callback` is a required function which should adopt the node style callback signature which accepts two arguments: an error, and the record asked for. `find` returns an "unloaded" record which, following the load completion, will be populated with the data from the storage adapter.

_Note_: `find` gives two results to calling code: one immediately, and one later. `find` returns a record synchronously as it is called and calls back with a record, and importantly these two records are __not__ guaranteed to be the same instance. This is because batman.js maps the identities of incoming and outgoing records such that there is only ever one canonical instance representing a record, which is useful so bindings are always bound to the same thing. In practice, this means that calling code should use the record `find` calls back with if anything is going to bind to that object, which is most of the time. The returned record however remains useful for state inspection and bookkeeping.

    asyncTest '@find calls back the requested model if no error occurs', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'
        @persist AsyncTestStorageAdapter,
          storage:
            'posts2': {name: "Two", id:2}

      post = Post.find 2, (err, result) ->
        throw err if err
        post = result
      equal post.get('name'), undefined
      delay ->
        equal post.get('name'), "Two"

_Note_: `find` must be passed a callback function. This is for two reasons: calling code must be aware that `find`'s return value is not necessarily the canonical instance, and calling code must be able to handle errors.

    asyncTest '@find calls back with the error if an error occurs', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'
        @persist AsyncTestStorageAdapter

      error = false
      post = Post.find 3, (err, result) ->
        error = err
      delay ->
        ok error instanceof Error

## @load(options = {}, callback : Function)

`Model.load()` retrieves an array of records according to the given `options` from the storage adapter and calls back with an error if one occurred and the set of records if the operation was successful. `load` delegates to the storage adapter the `Model` has been `@persist`ed with, so it is up to the storage adapter's semantics to determine what the options do, what kind of errors may arise, and the timeline on which the callback may be called. The `callback` is a required function which should adopt the node style callback signature which accepts two arguments, an error, and the array of records. `load` returns undefined.

For the two main `StorageAdapter`s batman.js provides, the `options` do different things:

- For `Batman.LocalStorage`, `options` act as a filter. The adapter will scan all the records in `localStorage` and return only those records which match all the key/value pairs given in the options.
- For `Batman.RestStorage`, `options` are serialized into query parameters on the `GET` request.

It accepts a callback with two arguments: any error that occurred, and an array of loaded records.

    asyncTest '@load calls back an array of records retrieved from the storage adapter', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'
        @persist TestStorageAdapter,
          storage:
            'posts1': {name: "One", id:1}
            'posts2': {name: "Two", id:2}

      posts = false
      Post.load (err, result) ->
        throw err if err
        posts = result

      delay ->
        equal posts.length, 2
        equal posts[0].get('name'), "One"

    asyncTest '@load calls back with an empty array if no records are found', ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'
        @persist TestStorageAdapter, storage: []

      posts = false
      Post.load (err, result) ->
        throw err if err
        posts = result

      delay ->
        equal posts.length, 0

## @create(attributes = {}, callback) : Model

`App.Model.create` is a convenience method that is essentially equivalent to
calling `(new App.Model).save()`:

    asyncTest "@create instantiates a new record instance and saves it", ->
      class Post extends Batman.Model
        @resourceName: 'post'
        @encode 'name'
        @persist TestStorageAdapter, storage: []

      # Using new + save:
      record = new Post(name: 'aName')
      record.save()

      # Using create:
      otherRecord = Post.create name: 'aName', ->

      delay ->
        equal record.get('name'), otherRecord.get('name')
        equal record.isNew(), false
        equal otherRecord.isNew(), false

_Note_ : `attributes` is an empty object `{}` by default. This means the single-argument version of `create` accepts the callback, and not the attributes object.

## @findOrCreate(attributes = {}, callback) : Model

## ::%id

A universally accessible accessor to the record's primary key. If the record's
primary key is `id` (the default), getting/setting this accessor simply passes
the call through to `id`, otherwise it proxies the call to the custom primary key.

    asyncTest "id proxies the primary key", ->
      class Post extends Batman.Model
        @primaryKey: 'name'

      post = new Post(name: 'Witty title')
      equal post.get('id'), 'Witty title'

      post.set('id', 'Wittier title')
      equal post.get('name'), 'Wittier title'

## ::%dirtyKeys : Set

The set of keys which have been modified since the last time the record was saved.

## ::%errors : Batman.ErrorsSet

`errors` is a `Batman.ErrorsSet`, which is simply a `Batman.Set` of [`Batman.ValidationError`](/docs/api/batman.validationerror.html)s present on the model instance.

- `user.get('errors')` returns the errors on the `user` record
- `user.get('errors.length')` returns the number of errors, total

You can also access the errors for a specific attribute of the record:

- `user.get('errors.email_address')` returns the errors on the `email_address` attribute
- `user.get('errors.email_address.length')` returns the number of errors on the `email_address` attribute

## @constructor(idOrAttributes = {}) : Model

## ::isNew() : boolean
Returns true if the instance represents a record that hasn't yet been persisted to storage. The default implementation simply checks if `@get('id')` is undefined, but you can override this on your own models.

`isNew` is used to determine whether `record.save()` will perform a `create` action or a `save` action.

## updateAttributes(attributes) : Model

## toString() : string

Returns a string representation suitable for debugging. By default this just contains the model's `resourceName` and `id`

## ::toJSON() : Object

Returns a JavaScript object containing the attributes of the record, using any specified encoders.

    test "toJSON returns a JavaScript object with the record's attributes", ->
      class Criminal extends Batman.Model
        @encode "name", "notorious"

      criminal = new Criminal(name: "Talia al Ghul", notorious: true)
      criminal_json = criminal.toJSON()
      equal criminal_json.name, "Talia al Ghul"
      equal criminal_json.notorious, true


## ::fromJSON() : Model

Loads attributes from a bare object into this instance.

    test 'fromJSON overwrites existing attributes', ->
      class Criminal extends Batman.Model
        @encode "name", "notorious"

      criminal = new Criminal(name: "Dr. Jonathan Crane", notorious: false)
      new_params =
        name: "Scarecrow"
        notorious: true
      criminal.fromJSON(new_params)

      equal criminal.get("notorious"), true
      equal criminal.get("name"), "Scarecrow"


## ::toParam() : value

Returns a representation of the model suitable for use in a URL. By default, this is the record's `id`.

This method is used by the routing system for serializing records into a URL.

## ::hasStorage() : boolean

True when the record has a storage adapter defined.

## ::load(options = {}, callback)
`Load` tries to read the record from its storage adapter. The options object will be passed to the storage adapter when it performs the `read` operation. The callback takes three parameters: error, the loaded record, and the environment. `Load`ing a record clears all errors on that record.

If the read operation fails or if the record is in a state which doesn't permit `load`, (for example, calling `load` on a deleted record) the callback will be invoked with an error.

## ::save(options = {}, callback)
`Save` [validates](http://localhost:4000/docs/api/batman.model.html#prototype_function_validate) the record, and if it passes, fires the corresponding storage operation (defined by the `Batman.StorageAdapter` passed to  [`@persist`](/docs/api/batman.model.html#class_function_persist)). When the storage operation is complete, the callback is invoked with two parameters: any JavaScript error and the record.

If the record [`isNew`](/docs/api/batman.model.html#prototype_function_isnew), `save` performs a `create` operation. Otherwise, it performs a `save` operation.

If the record is not valid, the [validation errors](/docs/api/batman.validationerror.html) will be passed to the first parameter of the callback function and the storage operation will not be performed.

## ::destroy(options = {}, callback)

`Destroy` fires the corresponding storage operation. The callback takes three arguments: JavaScript Error, the record, and the environment. If the operation is successful, the record is removed from its Model's [`loaded`](/docs/api/batman.model.html#class_function_loaded) set.

```coffeescript
criminal = new Criminal name: "The penguin"
criminal.destroy (err, record, env) ->
  if err
    console.log "Oh no! #{record.get('name')} is still on the loose!"
```

If the record's current lifecycle state doesn't allow the `destroy` action, the callback will be invoked with a `Batman.StateMachine.InvalidTransitionError`. For example, this could occur if `destroy` is called on an already-destroyed record.

## ::validate(callback)

`Model::validate` checks the model against the validations declared in the model definition (with [`Model@validate`](/docs/api/batman.model.html#class_function_validate)). This method accepts a callback with two arguments: any JS error that occurred within the validator function, and the set of [`Batman.ValidationError`](/docs/api/batman.validationerror.html)s that the input generated.

For example:

    test "validate(callback) will call the callback only after all keys have been validated", ->
      class Product extends Batman.Model
        @validate 'name', 'price', presence: yes

      newProduct = new Product
      newProduct.validate (javascriptError, validationErrors) ->
        throw javascriptError if javascriptError
        equal validationErrors.length, 2
        equal newProduct.get('errors.length'), 2
        equal newProduct.get('errors.name.length'), 1
        equal newProduct.get('errors.price.length'), 1

# Batman.ValidationError

`Batman.ValidationError`s represent a failure for a model's field to to pass validation.
They are usually accessed by getting a model's [errors](/docs/api/batman.model.html#prototype_accessor_errors).

## ::%fullMessage

Returns the human-readable attribute name and the validation message:

    test "ValidationError should humanize attribute in the full message", ->
      error = new Batman.ValidationError("fooBarBaz", "isn't valid")
      equal error.get('fullMessage'), "Foo bar baz isn't valid"

