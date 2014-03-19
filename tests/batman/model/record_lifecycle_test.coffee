{TestStorageAdapter} = window

QUnit.module "Batman.Model record lifecycle",
  setup: ->
    class @Product extends Batman.Model
      @encode 'name'
      @persist TestStorageAdapter

asyncTest "new record lifecycle callbacks fire in order", ->
  callOrder = []

  product = new @Product()
  product.get('lifecycle').onEnter 'dirty',      -> callOrder.push(0)
  product.on 'set',                              -> callOrder.push(1)
  product.get('lifecycle').onEnter 'creating',   -> callOrder.push(2)
  product.on 'create',                           -> callOrder.push(3)
  product.get('lifecycle').onEnter 'clean',      -> callOrder.push(4)
  product.on 'created',                          -> callOrder.push(5)
  # save callback
  product.get('lifecycle').onEnter 'destroying', -> callOrder.push(7)
  product.on 'destroy',                          -> callOrder.push(8)
  product.get('lifecycle').onEnter 'destroyed',  -> callOrder.push(9)
  product.on 'destroyed',                        -> callOrder.push(10)

  product.set('foo', 'bar')

  product.save (err) ->
    throw err if err
    callOrder.push(6)

    product.destroy (err) ->
      throw err if err
      deepEqual(callOrder, [0,1,2,3,4,5,6,7,8,9,10])
      QUnit.start()

asyncTest "existing record lifecycle callbacks fire in order", ->
  callOrder = []

  @Product.find 10, (err, product) ->
    product.get('lifecycle').onEnter 'saving',     -> callOrder.push(0)
    product.on 'save',                             -> callOrder.push(1)
    product.get('lifecycle').onEnter 'clean',      -> callOrder.push(2)
    product.on 'saved',                            -> callOrder.push(3)
    # save callback
    product.get('lifecycle').onEnter 'destroying', -> callOrder.push(5)
    product.on 'destroy',                          -> callOrder.push(6)
    product.get('lifecycle').onEnter 'destroyed',  -> callOrder.push(7)
    product.on 'destroyed',                        -> callOrder.push(8)

    product.save (err) ->
      throw err if err
      callOrder.push(4)

      product.destroy (err) ->
        throw err if err
        deepEqual(callOrder, [0,1,2,3,4,5,6,7,8])
        QUnit.start()


QUnit.module "Batman.Model record lifecycle prototype listeners",
  setup: ->
    class @Product extends Batman.Model
      @encode 'name'
      @persist TestStorageAdapter
      @loadingCallOrder = [101, 102, 103, 5, 104, 105]
      @expectedCallOrder = [0,1,2,3,4,5,6,7,8,9,10,11,12,13]
      _push: (i) ->
        @callOrder ?= []
        @callOrder.push(i)

      @::on 'enter loading', -> @_push(101)
      @::on 'load', -> @_push(102)
      @::on 'exit loading', -> @_push(103)
      # enter clean 5
      @::on 'loaded', -> @_push(104)
      # loaded callback 105

      @::on 'enter dirty', -> @_push(0)
      @::on 'set', -> @_push(1)
      @::on 'enter creating', -> @_push(2)
      @::on 'enter saving', -> @_push(2)
      @::on 'create', -> @_push(3)
      @::on 'save', -> @_push(3)
      @::on 'exit creating', -> @_push(4)
      @::on 'exit saving', -> @_push(4)
      @::on 'enter clean', -> @_push(5)
      @::on 'created', -> @_push(6)
      @::on 'saved', -> @_push(6)
      # save callback
      @::on 'enter destroying', -> @_push(8)
      @::on 'destroy', -> @_push(9)
      @::on 'exit destroying', -> @_push(10)
      @::on 'enter destroyed', -> @_push(11)
      @::on 'destroyed', -> @_push(12)
      # destroy callback 13

asyncTest "new record lifecycle prototype callbacks fire in order", ->

  product = new @Product()

  product.set('foo', 'bar')

  product.save (err) =>
    throw err if err
    product._push(7)

    product.destroy (err) =>
      throw err if err
      product._push(13)
      deepEqual(product.callOrder, @Product.expectedCallOrder)
      QUnit.start()

asyncTest "existing record lifecycle callbacks fire in order", ->
  @Product.find 10, (err, product) =>
    product._push(105)
    product.set('foo', 'bar')

    product.save (err) =>
      throw err if err
      product._push(7)

      product.destroy (err) =>
        throw err if err
        product._push(13)
        deepEqual(product.callOrder, @Product.loadingCallOrder.concat(@Product.expectedCallOrder))
        QUnit.start()

asyncTest "throwing an error stops the storage operation", ->

  @Product.find 10, (err, product) =>
    product._push(105)
    product.set('foo', 'bar')
    product.on 'before saving', ->
      throw "Stop saving!"

    try
      product.save (err) =>
        throw err if err
        product._push(7)
    catch err
      equal "#{err}", "Stop saving!"
      deepEqual product.callOrder, @Product.loadingCallOrder.concat([0,1])
      QUnit.start()
