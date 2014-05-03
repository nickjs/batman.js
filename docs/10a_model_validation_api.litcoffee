# /api/App Components/Batman.Model/Batman.Model Validations

Validations allow a record (ie, instance of `Batman.Model`) to be marked as `valid` or `invalid` based on a set of programmatic rules. `@validate` in a model definition adds validations on a model's attributes, using either a [built-in validation](/docs/api/batman.model_validations.html#built-in_validations) or a [custom validation](/docs/api/batman.model_validations.html#custom_validation).

_Note_: Validation in batman.js is always asynchronous. This is so that the API is consistent regardless of the validations used.

## Built-In Validations

Built in validators are attached by calling `@validate` with options designating how to calculate the validity of the attribute:

    test '@validate accepts options to check for validity', ->
      QUnit.expect(0)
      class Post extends Batman.Model
        @resourceName: 'post'

        @validate 'title', 'body', {presence: true} # title and body must be present (not undefined nor '')
        @validate 'body', {minLength: 10}           # body must be 10 characters long at least
        @validate 'title', {pattern: /^[A-Z]/}      # Title must start with an uppercase letter
        @validate 'author', {email: true}           # the author field must contain a valid email address

Option | Asserts that ...
--- | ---
`presence : true` | String value is existent (not undefined or null) and has length greater than 0
`numeric : true` | Value is or can be coerced into a number using `parseFloat`.
`greaterThan : Number` | Value is greater than the given number.
`greaterThanOrEqualTo : Number` | Value is greater than or equal to the given number.
`equalTo : Number` | Value is equal to the given number.
`lessThan : Number` | Value is less than the given number.
`lessThanOrEqualTo : Number` | Value is less than or equal to the given number.
`minLength : Number` | Value's `length` property is greater than the given number.
`maxLength : Number` | Value's `length` property is less than the given number.
`length : Number` | Value's `length` property is exactly the given number.
`lengthWithin : [Number, Number]`, `lengthIn : [Number, number]` | Value's `length` property is within the range `[lower, upper]`.
`inclusion : in : [list, of, acceptable, values]` | Value is equal to one of the values in an array.
`exclusion : in : [list, of, unacceptable, values]` | Value is not equal to any of the values in an array.
`regexp : /regexp/` | Value is matching the provided regular expression.
`email : true` | Value is an email address, per the [W3C HTML5 definition](http://www.w3.org/TR/html5/forms.html#valid-e-mail-ress).
`associated : true` | Associated record is also valid. If invalid, the message will be "#{associationName} is not valid".
`associatedFields : true` | Like `associated`, but adds error messages with the names of the fields on associated records, eg "Username must at least 10 characters" or "Favorite flavor is not included in the list".
`confirmation : true/String` | Record's `#{attr}_confirmation` value matches `#{attr}`. If option is a string, use that attribute instead of `#{attribute}_confirmation`.

## Custom Validation

You can easily define a custom validation by passing a function to `@validate`:

```coffeescript
class App.Product extends Batman.Model
  @validate 'name', (errors, record, attribute, callback) ->
    # custom validation ...
    callback()
```

The function takes `(errors, record, attribute, callback)`:

 + `errors`: the `Batman.ErrorsSet` for this record
 + `record`: the record being validated
 + `attribute`: the attribute  being validated
 + `callback`: a function to call once validation has been completed. Calling this function is __mandatory__: it enables validations to be asynchronous.

To show that the record is invalid, a validation function should call `errors.add(attribute, message)`.

If you really needed to, you could also extend `Batman.Validator`.

## Conditional Validation

Validations can be skipped by including a conditional check. Pass `if` or `unless` as options to `@validate`:

    test '@validate accepts an if or unless option to determine whether the validation should be performed or not', ->
      QUnit.expect(0)
      class Invoice extends Batman.Model
        @resourceName: 'invoice'
        @validate 'tax_1_rate', {presence: true, if: (errors, record, attribute) -> record.get('tax_1_enabled')} # tax 1 rate must be present if tax 1 is enabled
        @validate 'tax_2_rate', {presence: true, if: 'tax_2_rate'} # passing a string will look for an attribute or accessor with that name on the record
        @validate 'discount_rate', {presence: true, unless: 'discount_disabled'} # discount rate must be present unless discount is disabled

If you pass a string as `if` or `unless`, it will do a `@get(string)` on the record being validated. If you pass a function, it should have the signature `(errors, record, attribute)`:

- `errors`: the `Batman.ErrorsSet` for the record
- `record`: the record being validated
- `attribute`: the attribute being validated

## Custom Messages

Batman.js ships with straightforward messages for the built-in validators. However, if you need custom messages, there are several ways to add them.

1. __Pass a `message` option__. It may be a string or function. for example:
  ```
    @validate 'name', presence: true, message: "must be provided" # => "Name must be provided"
    @validate 'amount', in: [1,2,3], message: (attribute, messageKey, record) -> "can't be #{record.get('amount')}!"
  ```
1. __Use a custom validation__. In your custom validation, add the error with your custom message, for example:
  ```coffeescript
    errors.add("email_address", "must be provided to ensure that your password isn't lost!")
  ```
1. __Provide a custom translation__. In your locale, `errors.messages.#{messageKey}` should match the structure provided by batman.js ([see source](https://github.com/batmanjs/batman/blob/master/src/model/validations/validators.coffee)).
