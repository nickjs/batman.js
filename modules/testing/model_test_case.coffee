TestCase = require './test_case'
ModelExpectations = require './model_expectations'

module.exports = class ModelTestCase extends TestCase
  @mixin ModelExpectations

  assertValid: (model, message = "#{model} expected to be valid") ->
    model.validate (_, err) =>
      @assert err.length is 0, message

  assertNotValid: (model, message = "#{model} expected to be not valid") ->
    model.validate (_, err) =>
      @assert err.length > 0, message

  assertDecoders: (modelClass, keys...) ->
    decoders = []
    modelClass::_batman.get("encoders").forEach (key, encoder) ->
      decoders.push key if encoder.decode
    @assertEqual keys.sort(), decoders.sort()

  assertEncoders: (modelClass, keys...) ->
    encoders = []
    modelClass::_batman.get("encoders").forEach (key, encoder) ->
      encoders.push key if encoder.encode
    @assertEqual keys.sort(), encoders.sort()

  assertEncoded: (model, key, expected) ->
    value = model.toJSON()[key]
    if typeof expected is 'function'
      @assert expected(value)
    else
      @assertEqual expected, value
