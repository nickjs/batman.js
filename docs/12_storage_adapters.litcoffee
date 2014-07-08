# /api/App Components/Batman.StorageAdapter

`Batman.StorageAdapter`s handle persistence of [`Batman.Model`s](/docs/api/batman.model.html). Any `Batman.Model` which will be created, read, updated or deleted must have a storage adapter, which is declared with [`Batman.Model@persist`](/docs/api/batman.model.html#class_function_persist):

```coffeescript
class App.Superhero extends Batman.Model
  @persist Batman.RestStorage # a StorageAdapter subclass
```

__Note:__ `@persist` instantiates a StorageAdapter instance during model definition, so it will use `@storageKey` and `@resourceName` from the model where it was instantiated, but it won't play well with inheritance. For example:

```coffeescript
class App.Model extends Batman.Model
  @storageKey: 'model'
  @persist Batman.LocalStorage

class App.Superhero extends App.Model
  # have to do it again here, or else it will use @storageKey of 'model'
  @storageKey: 'superhero'
  @persist Batman.LocalStorage
```

### Batman's Included StorageAdapters

Batman ships with a few storage adapters to get you up and coding quickly:

- `Batman.LocalStorage` uses [`window.localStorage`](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#localStorage) to persist records.
- `Batman.SessionStorage` extends `Batman.LocalStorage` and uses [`window.sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#sessionStorage) to persist records.
- `Batman.RestStorage` uses [HTTP REST](http://en.wikipedia.org/wiki/REST) to persist records, mapping HTTP verbs to storage operations and handling HTTP response codes appropriately. _Note: Because `Batman.RestStorage` depends on [`Batman.Request`](/docs/api/batman.request.html), you'll need a [platform library](/docs/api/batman.request.html#platform_request_implementation_libraries) to implement `Batman.Request`._

### Batman.RailsStorage
Also, `Batman.RailsStorage` (available in separate file: [Coffee](https://github.com/batmanjs/batman/blob/master/src/extras/batman.rails.coffee), JS) extends `Batman.RestStorage` and provides some helpful Rails integrations:

- If the response's status code is 422 (`Unprocessable Entity`), Any `errors` defined in the JSON response will be added to the `Batman.Model`'s [errors](/docs/api/batman.model.html#prototype_accessor_errors).
- By default, Batman will get the Rails CSRF token from the `<head>`and send it as a request header. (This can be prevented by setting `Batman.config.protectFromCSRF = false`.)
- If a record's URL doesn't end in `.json` and doesn't include a query string, `.json` is automatically appended to the URL.


_Note: Like `Batman.RestStorage`, `Batman.RailsStorage` depends on [`Batman.Request`](/docs/api/batman.request.html), so you'll need a [platform library](/docs/api/batman.request.html#platform_request_implementation_libraries) to implement `Batman.Request`._

If you're using Batman and Rails, be sure to check out the [batman-rails](https://github.com/batmanjs/batman-rails) gem.

## Storage Errors

`Batman.StorageAdapter` throws [storage errors](/docs/api/batman.storageadapter_errors.html) when its operations fail. You can catch these errors with [`Batman.Controller.catchError`](/docs/api/batman.controller.html#class_function_catcherror).

## Subclassing Batman.StorageAdapter

You may want to customize Batman's storage operations for your own app, for example:

- Adding before- and after-operation callbacks
- Overriding default storage operations

To do this, extend `Batman.StorageAdapter` (or one of the provided subclasses), then use your storage adapter to persist your models.
```
class App.HeroicStorageAdapter extends Batman.LocalStorage
  # filters, overrides

class App.Superhero extends Batman.Model
  @persist App.HeroicStorageAdapter
```

## ModelMixin and RecordMixin

A storage adapter may also have a class property called `ModelMixin`. If that property exists, in will be mixed into model classes that are persisted with that adapter. `RecordMixin` works the same way: it will be mixed into the prototype of models that are persisted with this adapter.

For example, this is how `Batman.RestStorage` provides URL-related functions to models that use it for persistence.

### `env` and `next`

Storage operations and callbacks each take two arguments: `env` and `next`.

`env` is a vanilla JS object which is passed to each function in the chain. `Batman.StorageAdapter` sets these attributes on `env`:

- `env.subject` is the `Batman.Model` record which had the storage operation called on it.
- `env.options` contains the options passed to the operation on the subject.
- `env.action` is the storage operation that will be executed by the storage adapter.
- `env.error` stores any errors that occur during the chain. It becomes the first argument to the operation callback.
- `env.result` contains the record(s) returned by the operation and should be set by the storage adapter implementation. It becomes the second argument to the operation's callback.

Storage adapters may use `env` to collect any extra information needed by their operations. For example, `Batman.RestStorage` adds some attributes to `env` and `env.options`:

- `env.request` is the `Batman.Request` which implements the storage operation.
- `env.options.method` is the HTTP method used by `Batman.Request` to implement the storage operation.
- `env.options.url` is the URL used by `Batman.Request` to implement the storage operation.

`next` is a reference to the next function in the call chain for the current storage operation. `Batman.StorageAdapter` uses this to execute before-filters, storage operations and after-filters in the correct sequence.


`next` should be called (`next()`) when the current function has completed. This indicates that the operation should proceed with the next function in its call chain. To ensure the completion of the call chain, consider wrapping your function in [`@skipIfError`](/docs/api/batman.storageadapter.html#class_function_skipiferror).


### Adding Callbacks

Callbacks can be registered with [`before`](/docs/api/batman.storageadapter.html#prototype_function_before) and [`after`](/docs/api/batman.storageadapter.html#prototype_function_after) on any storage operation (listed below) or `'all'` (which runs the callback before or after any operation). Callbacks accept two arguments, `env` and `next`, discussed below.

```coffeescript
class App.SpecificHeaderStorageAdapter extends Batman.RestStorage
  # include a specific header in all requests:
  @::before 'all', (env, next) ->
    headers = env.options.headers ||= {}
    headers["App-Specific-Header"] = App.getSpecificHeader()
    next()

  @::after 'create', (env, next) ->
    console.log "A #{env.subject.constructor.name} was created!"
    next()
```

## Storage Operations

Any `StorageAdapter` must implement these operations as instance methods, for example:


```
class App.ModifiedStorageAdapter extends Batman.RestStorage
  destroy: (env, next) ->
    # your custom destroy operation
    next()
```

When a record is saved, destroyed or loaded, `Batman.StorageAdapter` invokes these methods. Although you may reimplement them, you probably don't need to call them in your application code.

## ::create(env : Object, next : Function)
Called to save a new record. When `save` is called on a record and `isNew` returns `true`, the storage adapter's `create` method is called.

## ::read(env : Object, next : Function)
Called to load a record from storage.

## ::update(env : Object, next : Function)
Called to update an existing record. When `save` is called on a record and `isNew` returns `false`, the storage adapter's `update` method is called.

## ::destroy(env : Object, next : Function)
Called to destroy an existing record.

## ::readAll(env : Object, next : Function)
Called to load all records of a particular type from storage.

## Other Useful Methods

## @skipIfError(wrappedFunction : Function )

Wraps a function, bypassing the function body and calling next() if an error has already occurred.

    test "StorageAdapter@skipIfError doesn't call the function if env.error?", ->
      insideFunction = createSpy()
      nextFunction = createSpy()

      functionWithWrapper = Batman.LocalStorage.skipIfError (env, next) ->
        insideFunction()

      dummyEnv = {error: true}

      functionWithWrapper(dummyEnv, nextFunction)

      equal dummyEnv.error?, true, 'an error is present'
      equal insideFunction.called, false, 'insideFunction was skipped'
      equal nextFunction.called, true, 'nextFunction was called'

Inside a storage adapter definition, this function is referenced as `@skipIfError`, for example:

```
class App.SpecialStorageAdapter extends Batman.RestStorage
  @::before 'create', @skipIfError (env, next) ->
    console.log("This will be skipped if env.error? is true!")
    next()
```
## ::constructor(model: Function) : StorageAdapter

Returns a `StorageAdapter` attached to `model`, which should be a subclass of `Batman.Model`.

## ::.model : Function

Returns the `Batman.Model` passed to the constructor.

## ::before (keys... : Strings, filter : Function)
Registers `filter` as a before-operation callback for the storage operations named by `keys...`.

## ::after (keys... : Strings, filter : Function)
Registers `filter` as a after-operation callback for the storage operations named by `keys...`.

## ::getRecordFromData(attributes: Object, constructor[=@model] : Function) : Model

Finds or creates an instance of `constructor` with `attributes` and returns it. Delegated to `Model.createFromJSON`.

## ::getRecordsFromData(attributesArray: Array, constructor[=@model] : Function) : Array

Finds or creates instances of `constructor` for each item in `attributesArray` and returns the resulting records. Delegated to `Model.createMultipleFromJSON`.
