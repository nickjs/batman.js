# Batman.StorageAdapter

`Batman.StorageAdapter`s handle persistence of [`Batman.Model`s](/docs/api/batman.model.html). Any `Batman.Model` which will be persisted must have a storage adapter, which is declared with [`Batman.Model@persist`](/docs/api/batman.model.html#class_function_persist):

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

Batman ships with a few storage adapters to help you get up and coding quickly:

- `Batman.LocalStorage` uses `window.localStorage` to persist records.
- `Batman.SessionStorage` extends `Batman.LocalStorage` and uses `window.sessionStorage` to persist records.
- `Batman.RestStorage` uses [HTTP REST](http://en.wikipedia.org/wiki/REST) to persist records, mapping HTTP verbs to storage operations and handling HTTP response codes appropriately. _Note: Because `Batman.RestStorage` depends on [`Batman.Request`](/docs/api/batman.request.html), you'll need a [platform library](/docs/api/batman.request.html#platform_request_implmentation_libraries) to implement `Batman.Request`._

### Batman.RailsStorage
Also, `Batman.RailsStorage` (available in separate file: [Coffee](https://github.com/batmanjs/batman/blob/master/src/extras/batman.rails.coffee), [JS](#)) extends `Batman.RestStorage` and provides some helpful Rails integrations:

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
class HeroicStorageAdapter extends Batman.LocalStorage
  # filters, overrides

class App.Superhero extends Batman.Model
  @persist App.HeroicStorageAdapter
```
### `env` and `next`

Storage operations and callbacks each take two arguments: `env` and `next`.

`next` ...

`env` ...

### Adding Callbacks

Callbacks can be registered on any storage operation (listed below).

```coffeescript
class App.SpecificHeaderStorageAdapter extends Batman.RestStorage
  # include a specific header in all requests:
  @::before 'all' (env, next) ->
    headers = env.options.headers || {}
    headers["App-Specific-Header"] = App.getSpecificHeader()
    next()

  @::after 'create', (env, next) ->
    console.log "A #{env.subject.constructor.name} was created!"
    next()
```

### Storage operations

Any `StorageAdapter` must implement these operations as instance methods, for example:
```
class App.ModifiedStorageAdapter extends Batman.RestStorage
  destroy: (env, next) ->
    # your destroy operation
    next()
```

## create

## read

## update

## destroy

## readAll
