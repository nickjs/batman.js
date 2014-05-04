# /api/App Internals/Batman.Model/Batman.Validator

`Batman.Validator` extends `Batman.Object` and is the abstract superclass for all validators in batman.js. batman.js ships with a plethora of [built-in validators](/docs/api/batman.model_validations.html).

## Custom Validators

You can create custom validators by:

- subclassing `Batman.Validator`,
- implementing `::validateEach`, and
- adding the new validator to the `Batman.Validators` array.

For example:

```coffeescript
class App.LessThanPropertyValidator extends Batman.Validator
  @triggers 'lessThanProperty'
  @options 'allowBlank'

  validateEach: (errors, record, attribute, callback) ->
      value = record.get(attribute)
      compareAttr = @options.lessThanProperty
      otherValue = record.get(compareAttr)
      else !@handleBlank(value) && value >= otherValue
        errors.add(attribute, 'must be less than #{compareAttr}')
      callback()

Batman.Validators.push App.LessThanPropertyValidator
```

Could be used as:

```coffeescript
class App.Pyramid extends Batman.Model
  @encode 'top', 'base'
  # A pyramid's top must be smaller than its base:
  @validate 'top', lessThanProperty: 'base'
```

## ::constructor(options : Object[, mixins...]) : Validator

The first argument becomes the validator's `@options`. Subsequent arguments are mixed in to the validator with `Batman.Object::mixin`. You can override this method to alter the options object before it's assigned to `@options`. (Make sure to call `super` afterwards!)

## @triggers(triggers...)

When any of the strings in `triggers` is passed to `Model.validate`:

- this validator will be instantiated and its `validateEach` will be invoked
- the key-value pairs passed to `Model.validate` with these keys will be available on `@options` for this validator.

Use this method when one validator will handle many kinds of validations. For example, a simplified length validator:

```coffeescript
class App.SimpleLengthValidator extends Batman.Validator
  @triggers 'minLength', 'maxLength', 'length'

  constructor: (options) ->
    # has access to options.minLength, options.maxLength, options.length
    super

  validateEach: (errors, record, attribute, callback) ->
    # has access to @options.minLength, @options.maxLength, @options.length
```

All three of these validations will be handled by `App.SimpleLengthValidator::validateEach`:

```coffeescript
class App.Superhero extends Batman.Model
  @validate 'name', minLength: 3
  @validate 'bio', maxLength: 250
  @validate 'phone_number', length: 10
```

## @options(options...)

The key-value pairs passed to `Batman.Model.validate` with these keys will be available on `@options` for this validator.

Unlike `@triggers`, the presence of a key in `options` will not cause this validator to be instantiated.

## ::validateEach(errors: ErrorsSet, record: Model, attribute: String, callback: Function)

This method is invoked to validate `attribute` on `record`. If this method determines that the attribute is invalid, it should add a validation error to `errors`:

```coffeescript
errors.add("phone_number", "isn't 10 characters long")
```

When the validator is finished, it must call `callback` to continue the validation chain.

## @handleBlank(value)

Returns `true` if `options.allowBlank` is `true` _and_ `value` is `null`, `undefined` or `""`

## ::format(attr, messageKey, interpolations, record) : String

Generates a human-readable message for `messageKey` by:

- Using the `message` option passed to `@validate`, if present
- Looking up `messageKey` in the current locale's `errors.messages`

# /api/App Internals/Batman.Model/Batman.ValidationError

`Batman.ValidationError`s represent a failure for a record's field to to pass validation.
They are usually accessed by getting a record's [errors](/docs/api/batman.model.html#prototype_accessor_errors).

## ::constructor(attribute: String, messageOrKey: String, options={}) : ValidationError

Returns a new validation error for `attribute`. `messageOrKey` and `options` are used to create the error message:

- if `options.message` is a string, it is used as the error's message
- if `options.message` is a function, it is called on the `record` with `(attribute, messageKey)`
- if `messageOrKey` is underscore-cased, it is used to lookup an error message
- otherwise, `messageOrKey` is used as the error's message

`options.interpolations` is interpolated into error message if one is found for `messageOrKey`.

## ::%fullMessage : String

Returns the human-readable attribute name and the validation message:

    test "ValidationError should humanize attribute in the full message", ->
      class Product extends Batman.Model
      product = new Product
      error = new Batman.ValidationError("fooBarBaz", "isn't valid")
      equal error.get('fullMessage'), "Foo bar baz isn't valid"

# /api/App Internals/Batman.Model/Batman.ErrorsSet

`Batman.ErrorsSet` extends `Batman.Set` for the special purpose of storing `Batman.ValidationError`s.

## Default Accessor

`Batman.ErrorsSet`'s default accessor returns `Batman.ValidationError`s for the given field name. For example:

```
errorsSet = record.get('errors')
errors.get('emailAddress') # Returns errors on record.emailAddress
```

This enables the `Batman.Model::errors` API:

```
record.get('errors.emailAddress.length') # => 1
record.get('errors.emailAddress.first.fullMessage')
# => "Email address is not valid"
```

## ::add(attribute : String, message: String)

Adds a new `Batman.ValidationError` on `attribute` with `message`.

