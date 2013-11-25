# Batman.StorageAdapter

`Batman.StorageAdapter`s handle persistence of [`Batman.Model`s](/docs/api/batman.model.html). Any `Batman.Model` which will be created, read, updated or deleted must have a storage adapter, which is declared with [`Batman.Model@persist`](/docs/api/batman.model.html#class_function_persist):

```coffeescript
class App.Superhero extends Batman.Model
  @persist Batman.RestStorage # a StorageAdapter subclass
```

__Protip:__ Consider setting the storage adapter in one `Batman.Model` subclass, then extending that subclass in the rest of your app. Then, you won't have to call `@persist` every time:

```coffeescript
class App.Model extends Batman.Model
  @persist Batman.LocalStorage

class App.Superhero extends App.Model
  # no need to call @persist here!

class App.Sidekick extends App.Model
  # or here!
```

### Batman's Included StorageAdapters

Batman ships with a few storage adapters to get you up and coding quickly:

- `Batman.LocalStorage` uses [`window.localStorage`](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#localStorage) to persist records.
- `Batman.SessionStorage` extends `Batman.LocalStorage` and uses [`window.sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#sessionStorage) to persist records.
- `Batman.RestStorage` uses [HTTP REST](http://en.wikipedia.org/wiki/REST) to persist records, mapping HTTP verbs to storage operations and handling HTTP response codes appropriately. _Note: Because `Batman.RestStorage` depends on [`Batman.Request`](/docs/api/batman.request.html), you'll need a [platform library](/docs/api/batman.request.html#platform_request_implmentation_libraries) to implement `Batman.Request`._

### Batman.RailsStorage
Also, `Batman.RailsStorage` (available in separate file: [Coffee](https://github.com/batmanjs/batman/blob/master/src/extras/batman.rails.coffee), JS) extends `Batman.RestStorage` and provides some helpful Rails integrations:

- If the response's status code is 422 (`Unprocessable Entity`), Any `errors` defined in the JSON response will be added to the `Batman.Model`'s [errors](/docs/api/batman.model.html#prototype_accessor_errors).
- By default, Batman will get the Rails CSRF token from the `<head>`and send it as a request header. (This can be prevented by setting `Batman.config.protectFromCSRF = false`.)
- If a record's URL doesn't end in `.json` and doesn't include a query string, `.json` is automatically appended to the URL.


_Note: Like `Batman.RestStorage`, `Batman.RailsStorage` depends on [`Batman.Request`](/docs/api/batman.request.html), so you'll need a [platform library](/docs/api/batman.request.html#platform_request_implmentation_libraries) to implement `Batman.Request`._

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
### `env` and `next`

Storage operations and callbacks each take two arguments: `env` and `next`.

`env` is a vanilla JS object which is passed to each function in the chain. `Batman.StorageAdapter` sets these attributes on `env`:

- `env.subject` is the `Batman.Model` record which had the storage operation called on it.
- `env.options` is an object containing the options passed when the operations was called on the subject.
- `env.action` is the storage operation that will be executed by the storage adapter.
- `env.error` stores any errors that occur during the chain. It becomes the first argument to them model's callback.
- `env.result` must be set by the `Batman.StorageAdapter` subclass after the operation is complete. It is a copy of the record and it becomes the second argument to the model's callback.

Storage adapters may use `env` to gather information and use it in its operations. For example, `Batman.RestStorage` adds some attributes to `env` and `env.options`:

- `env.request` is the `Batman.Request` which implements the storage operation.
- `env.options.method` is the HTTP method used by `Batman.Request` to implement the storage operation.
- `env.options.url` is the URL used by `Batman.Request` to implement the storage operation.

`next` is a reference to the next operation in the call chain. Any operation must call `next()`, otherwise the call chain will not continue. To ensure the completion of the call chain, consider wrapping your function in [`@nextIfError`](/docs/api/batman.storageadapter.html#class_function_nextiferror).


### Adding Callbacks

Callbacks can be registered with [`before`](/docs/api/batman.storageadapter.html#prototype_function_before) and [`after`](/docs/api/batman.storageadapter.html#prototype_function_after) on any storage operation (listed below) or `'all'` (which runs the callback before or after any operation). Callbacks accept two arguments, `env` and `next`, discussed below.

```coffeescript
class App.SpecificHeaderStorageAdapter extends Batman.RestStorage
  # include a specific header in all requests:
  @::before 'all', (env, next) ->
    headers = env.options.headers || {}
    headers["App-Specific-Header"] = App.getSpecificHeader()
    next()

  @::after 'create', (env, next) ->
    console.log "A #{env.subject.constructor.name} was created!"
    next()
```

### Storage Operations

Any `StorageAdapter` must implement these operations as instance methods, for example:
```
class App.ModifiedStorageAdapter extends Batman.RestStorage
  destroy: (env, next) ->
    # your custom destroy operation
    next()
```

## ::create(env : Object, next : Function)

Saves a new record. When `save` is called on a record and `isNew` returns `true`, the storage adapter's `create` method is called.

## ::read(env : Object, next : Function)

Loads a record from storage into a Batman app.

## ::update(env : Object, next : Function)

Updates an existing record. When `save` is called on a record and `isNew` returns `false`, the storage adapter's `save` method is called.

## ::destroy(env : Object, next : Function)

Destroys an existing record.

## ::readAll(env : Object, next : Function)

Loads all instances of a `Batman.Model` from storage into memory.

### Other Useful Methods

## @nextIfError(wrappedFunction : Function )

Wraps functions in the call chain, bypassing the function body and calling `next()` if `env.error?`
Otherwise, calls the wrapped function with `env` and `next`.

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

## ::before (keys... : Strings, filter : Function)

Registers `filter` as a before-operation callback for the storage operations named by `keys...`.

## ::after (keys... : Strings, filter : Function)

Registers `filter` as a after-operation callback for the storage operations named by `keys...`.
