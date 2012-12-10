Batman = require '../../../../lib/dist/batman.node'
Watson = require 'watson'
TestStorageAdapter = require '../lib/test_storage_adapter'

class Product extends Batman.Model
  @persist TestStorageAdapter
  @encode "attribute#{i}" for i in [0...50]

generateAttributes = (count) ->
  attributes = {}
  attributes["attribute#{i}"] = "value#{i}" for i in [0...50]
  JSON.stringify(attributes)

products = []
Watson.trackMemory 'models with 50 attributes', 2000, (i) ->
  product = new Product
  product.fromJSON(generateAttributes(50))
  products.push product

  products = [] if i % 500 == 0
