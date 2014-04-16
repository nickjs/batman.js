# /api/App Components/Batman.Model/Batman.Validator

batman.js ships with a plethora of [built-in validators](/docs/api/batman.model.html#class_function_validate), but when they don't meet your needs, you can create custom validators by subclassing `Batman.Validator`, implementing `Batman.Validator::validateEach`, and adding the new validator to `Batman.Validators`. For example:

```coffeescript
class App.LessThanPropertyValidator extends Batman.Validator
  @triggers 'lessThanProperty'
  @options 'allowBlank'

  validateEach: (errors, record, key, callback) ->
      value = record.get(key)
      compareKey = @options.lessThanProperty
      otherValue = record.get(compareKey)
      else !@handleBlank(value) && value >= otherValue
        errors.add(key, 'must be less than #{compareKey}')
      callback()

Batman.Validators.push App.LessThanPropertyValidator
```

## ::constructor(options : Object[, mixins...])

The first argument becomes the validator's `@options`. Subsequent arguments are mixed in to the validator with `Batman.Object::mixin`. You can override this method to alter the options object before it's assigned to `@options`. (Make sure to call `super` afterwards!)

## @triggers(triggers...)

When any of the strings in `triggers` is passed to `Model@validate`:

- this validator will be instantiated and its `validateEach` will be invoked
- the key-value pairs passed to `Model@validate` with these keys will be available on `@options` for this validator.

Use this method when one validator will handle many kinds of validations. For example, a simplified length validator:

```coffeescript
class App.SimpleLengthValidator extends Batman.Validator
  @triggers 'minLength', 'maxLength', 'length'

  constructor: (options) ->
    # has access to options.minLength, options.maxLength, options.length
    super

  validateEach: (errors, record, key, callback) ->
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

The key-value pairs passed to `Model@validate` with these keys will be available on `@options` for this validator.

Unlike `@triggers`, the presence of a key in `options` will not cause this validator to be instantiated.

## ::validateEach(errors: Batman.ErrorsSet, record: Batman.Model, key: String, callback: Function)

This method is invoked to validate `key` on `record`. If this method determins that the key is invalid, it should add a validation error to `errors`.

`errors` is a `Batman.ErrorsSet`, which is a [`Batman.Set`](/docs/api/batman.set.html) with `::add(key, message)` as a convenience method for adding [`Batman.ValidationError`](/docs/api/batman.validationerror.html)s. So, to easily add a new validation error:

```coffeescript
errors.add("phone_number", "isn't 10 characters long")
```

When the validator is finished, it must call `callback` to continue the validation chain.

## @handleBlank(value)

Returns `true` if `options.allowBlank` is `true` _and_ `value` is `null`, `undefined` or `""`

# /api/App Components/Batman.Model/Batman.ValidationError

`Batman.ValidationError`s represent a failure for a model's field to to pass validation.
They are usually accessed by getting a model's [errors](/docs/api/batman.model.html#prototype_accessor_errors).

## ::%fullMessage

Returns the human-readable attribute name and the validation message:

    test "ValidationError should humanize attribute in the full message", ->
      error = new Batman.ValidationError("fooBarBaz", "isn't valid")
      equal error.get('fullMessage'), "Foo bar baz isn't valid"