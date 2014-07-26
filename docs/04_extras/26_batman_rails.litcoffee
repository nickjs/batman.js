# /api/Extras/Batman.Rails

The `batman.rails` extra provides helpers for using batman.js with [Ruby on Rails](http://rubyonrails.org). It is packaged with batman.js builds on the [downloads page](/download.html).

See the [`batman-rails` gem](https://github.com/batmanjs/batman-rails) for more information about batman.js-Rails integration.

## Configuration

`batman.rails` provides the following default configurations:

```coffeescript
Batman.config.pathToHTML = '/assets/batman/html'
Batman.config.protectFromCSRF = true
Batman.config.metaNameForCSRFToken = 'csrf-token'
```

# /api/Extras/Batman.Rails/Batman.RailsStorage

`Batman.RailsStorage` extends `Batman.RestStorage`. It adds some features for integration with [Ruby on Rails](http://rubyonrails.org). You can use it to persist your `Batman.Model` subclasses:

```coffeescript
class MyApp.MyModel extends Batman.Model
  @persist Batman.RailsStorage
```

## ".json" Request Suffix

When performing storage operations, `Batman.RailsStorage` will add `.json` to URLs if it isn't already present. This way, Rails will always recognize it as `format: :json`.

## Cross-Site Request Forgery Protection

By default, `batman.rails` participates in the Ruby on Rails cross-site request forgery (CSRF) protection scheme. Batman.js will:

- extract the CSRF token from meta-tags (using `Batman.config.metaNameForCSRFToken`)
- `Batman.RailsStorage` will send the CSRF token as a request header, `X-CSRF-Token`, when performing storage operations.

You can disable CSRF protection by setting the configuration to `false`:

```coffeescript
Batman.config.protectFromCSRF = false
```

## Server-Side Errors

After update and create operations, `Batman.RailsStorage` checks for validation errors returned from the server.  The response must have status code `422` (Rails' default for validation errors).

The response JSON may have an `errors` key:

```javascript
{ "errors" : {
    "user" : {
      "email": ["must be unique"],
      "first_name": ["must be present", "must be longer than 3 characters"]
    }
  }
}
```

Or, the errors may be at the top level:

```javascript
{ "user" : {
    "email": ["must be unique"],
    "first_name": ["must be present", "must be longer than 3 characters"]
    }
  }
}
```

Any errors will be added to client-side record according to its key in the JSON.

## Date Encoder

`Batman.Encoders.railsDate` may be used to send and receive dates with the Rails default date serialization:

```coffeescript
  @encode 'last_retrieved_at', Batman.Encoders.railsDate
```




# /api/Extras/Batman.Rails/Batman.RailsStorage ModelMixin

The following functions are mixed into models persisted with `Batman.RailsStorage`.

## @encodeTimestamps(attrs... =['created_at', 'updated_at'])

Pulls `attrs` from JSON, but doesn't send them back to the server. It uses `Batman.Encoders.railsDate`, which is provided by `batman.rails`.

## @encodesNestedAttributesFor(keys...)

Associations named by `keys` will be encoded in the parent model's JSON so that they work with Rails' `accepts_nested_attributes_for`. These associations must have the `saveInline: true` option.

This means:

- data will be sent to the server with an `_attributes` suffix
- after an update, any associated records where `record.get("_destroy")` is truthy will be counted as destroyed. (This assumes that Rails destroyed them on the backend, too.)
