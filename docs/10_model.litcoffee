# Batman.Model

For a general explanation of `Batman.Model` and it works, see [the guide](/docs/models.html).

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
 + `key` is the key which the `value` is stored under on the `record`. This is useful when passing the same `encoderObject` which needs to pivot on what key is being encoded to different calls to `encode`.
 + `builtJSON` is the object which is modified by each encoder which will eventually be returned by `toJSON`. To send the server the encoded value under a different key than the `key`, modify this object by putting the value under the desired key, and return `undefined`.
 + `record` is the record on which `toJSON` has been called.

For `decode` functions:

 + `value` is the server side value of the `key` which will end up on the `record`.
 + `key` is the key which the `value` is stored under in the incoming JSON.
 + `incomingJSON` is the JSON which is being decoded into the `record`. This can be used to create compound key decoders.
 + `outgoingObject` is the object which is built up by the decoders and then `mixin`'d to the record.
 + `record` is the record on which `fromJSON` has been called.

The `encode` and `decode` keys can also be false to avoid using the default identity function encoder or decoder.

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

 + `presence : boolean`: Assert that the string value is existent (not undefined or null) and has length greather than 0.
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

See `Model::validate` for information on how to get a particular record's validity.

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

  + For `Batman.LocalStorage`, `options` act as a filter. The adapter will scan all the records in `localStorage` and return only those records which match all the key/value pairs given in the options.
  + For `Batman.RestStorage`, `options` are serialized into query parameters on the `GET` request.

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

## @findOrCreate(attributes = {}, callback) : Model

## id : value

## dirtyKeys : Set

## errors : ErrorsSet

## constructor(idOrAttributes = {}) : Model

## isNew() : boolean

## updateAttributes(attributes) : Model

## toString() : string

## toJSON() : Object

## fromJSON() : Model

## toParam() : value

## state() : string

## hasStorage() : boolean

## load(options = {}, callback)

## save(options = {}, callback)

## destroy(options = {}, callback)

## validate(callback)

# Batman.ValidationError

# Batman.ErrorsSet
