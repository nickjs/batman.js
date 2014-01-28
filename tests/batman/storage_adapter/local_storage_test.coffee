if typeof require isnt 'undefined'
  {sharedStorageTestSuite} = require('./storage_adapter_helper')
else
  {sharedStorageTestSuite} = window

if typeof window.localStorage isnt 'undefined'
  QUnit.module "Batman.LocalStorage",
    setup: ->
      window.localStorage.clear()
      class @Product extends Batman.Model
        @encode 'name', 'cost'
      @adapter = new Batman.LocalStorage(@Product)
      @Product.persist @adapter

  sharedStorageTestSuite({})

  asyncTest 'reading many from storage: should callback with only records matching the options', 4, ->
    product1 = new @Product(name: "testA", cost: 20)
    product2 = new @Product(name: "testB", cost: 10)
    @adapter.perform 'create', product1, {}, (err, createdRecord1) =>
      throw err if err
      @adapter.perform 'create', product2, {}, (err, createdRecord2) =>
        throw err if err
        @adapter.perform 'readAll', product1.constructor, {data: {cost: 10}}, (err, readProducts) =>
          throw err if err
          equal readProducts.length, 1
          deepEqual readProducts[0].get('name'), "testB"
          @adapter.perform 'readAll', product1.constructor, {data: {cost: 20}}, (err, readProducts) ->
            throw err if err
            equal readProducts.length, 1
            deepEqual readProducts[0].get('name'), "testA"
            QUnit.start()

  asyncTest 'create or update whitelists attributes when supplied `only`', ->

    product = new @Product
      name: 'foo'
      cost: 50

    @adapter.perform 'create', product, {only: ['id', 'name']}, (err, createdRecord) =>
      @adapter.perform 'read', new product.constructor(createdRecord.get('id')), {}, (err, foundRecord) =>
        deepEqual foundRecord.toJSON(), {name: 'foo'}


        foundRecord.set 'name', 'bar'
        foundRecord.set 'cost', 75

        @adapter.perform 'update', foundRecord, {only: ['cost']}, (err, updatedRecord) =>
          @adapter.perform 'read', new product.constructor(updatedRecord.get('id')), {}, (err, foundRecord) ->
            deepEqual foundRecord.toJSON(), {cost: 75}

            QUnit.start()

  asyncTest 'create or update blacklists attributes when supplied `except`', ->

    product = new @Product
      name: 'foo'
      cost: 50

    @adapter.perform 'create', product, {except: ['cost']}, (err, createdRecord) =>
      @adapter.perform 'read', new product.constructor(createdRecord.get('id')), {}, (err, foundRecord) =>
        deepEqual foundRecord.toJSON(), {name: 'foo'}


        foundRecord.set 'name', 'bar'
        foundRecord.set 'cost', 75

        @adapter.perform 'update', foundRecord, {except: ['name']}, (err, updatedRecord) =>
          @adapter.perform 'read', new product.constructor(updatedRecord.get('id')), {}, (err, foundRecord) ->
            deepEqual foundRecord.toJSON(), {cost: 75}

            QUnit.start()
