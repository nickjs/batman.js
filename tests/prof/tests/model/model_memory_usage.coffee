Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter.coffee'

generateAttributes = (count) ->
  attributes = {}
  attributes["attribute#{i}"] = "value#{i}" for i in [0...count]
  JSON.stringify(attributes)

[0, 5, 50].forEach (attributeCount) ->
  class Product extends Batman.Model
    @persist TestStorageAdapter
    @encode "attribute#{i}" for i in [0...attributeCount] if attributeCount > 0

  products = []
  Watson.trackMemory "models with #{attributeCount} attributes", 2000, 1, (i) ->
    product = new Product
    product.fromJSON(generateAttributes(attributeCount))  if attributeCount > 0
    products.push product
    products = [] if i % 500 == 0
