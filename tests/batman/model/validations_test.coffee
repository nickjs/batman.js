validationsTestSuite = ->
  asyncTest "validation should leave the model in the same state it left it", ->
    class Product extends Batman.Model
      @validate 'name', presence: yes

    p = new Product
    oldState = p.get('lifecycle.state')
    p.validate (error, errors) ->
      equal p.get('lifecycle.state'), oldState
      QUnit.start()

  asyncTest "validate(callback) will call the callback only after all keys have been validated", ->
    class Product extends Batman.Model
      @validate 'name', 'price', presence: yes

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 2
      QUnit.start()

  asyncTest "length", 2, ->
    class Product extends Batman.Model
      @validate 'exact', length: 5
      @validate 'max', maxLength: 4
      @validate 'range', lengthWithin: [3, 5]

    p = new Product exact: '12345', max: '1234', range: '1234'
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0

      p.set 'exact', '123'
      p.set 'max', '12345'
      p.set 'range', '12'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 3
        QUnit.start()

  asyncTest "length with allow blank", 2, ->
    class Product extends Batman.Model
      @validate 'min', minLength: 4, allowBlank: true

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      p.set 'min', '123'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        QUnit.start()

  asyncTest "presence", 3, ->
    class Product extends Batman.Model
      @validate 'name', presence: yes

    p = new Product name: 'nick'
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      p.unset 'name'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        p.set 'name', ''
        p.validate (error, errors) ->
          throw error if error
          equal errors.length, 1
          QUnit.start()

  asyncTest "presence and length", 2, ->
    class Product extends Batman.Model
      @validate 'name', {presence: yes, maxLength: 10, minLength: 3}

    p = new Product
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 2

      p.set 'name', "beans"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "regexp", ->
    class Product extends Batman.Model
      @validate 'name', {pattern: /[0-9]+/}

    p = new Product(name: "foo")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.set 'name', "123"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "regexp with allow blank", ->
    class Product extends Batman.Model
      @validate 'name', {pattern: /[0-9]+/, allowBlank: true}

    p = new Product(name: "foo")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.unset 'name'
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "inclusion", ->
    class Product extends Batman.Model
      @validate 'name', inclusion: in: ["Batman", "Catwoman"]

    p = new Product(name: "Batman")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0

      p.set 'name', "The Penguin"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "exclusion", ->
    class Product extends Batman.Model
      @validate 'name', exclusion: in: ["Batman", "Catwoman"]

    p = new Product(name: "Batman")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.set 'name', "The Penguin"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "custom async validations which don't rely on model state", ->
    letItPass = true
    class Product extends Batman.Model
      @validate 'name', (errors, record, key, callback) ->
        setTimeout ->
          errors.add 'name', "didn't validate" unless letItPass
          callback()
        , 0

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      letItPass = false
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric with string", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes

    p = new Product number: "5"
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric with allow blank", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes, allowBlank: yes

    p = new Product
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric using greaterThan", ->
    class Product extends Batman.Model
      @validate 'number', greaterThan: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 15
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "numeric using greaterThanOrEqualTo", ->
    class Product extends Batman.Model
      @validate 'number', greaterThanOrEqualTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "numeric using equalTo", ->
    class Product extends Batman.Model
      @validate 'number', equalTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 1
          QUnit.start()

  asyncTest "numeric using lessThan", ->
    class Product extends Batman.Model
      @validate 'number', lessThan: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', 15
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric using lessThanOrEqualTo", ->
    class Product extends Batman.Model
      @validate 'number', lessThanOrEqualTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 1
          QUnit.start()

  asyncTest "associated for hasMany", ->
    namespace = @
    class @Product extends Batman.Model
      @validate 'id', presence: true

    class @Collection extends Batman.Model
      @hasMany 'products', {namespace, autoload: false}
      @validate 'products', associated: true

    @collection = new @Collection
    @collection.get('products').add new @Product
    @collection.get('products').add new @Product
    @collection.validate (err, errors) =>
      throw err if err
      equal errors.length, 2
      @collection.get('products.toArray.0').set('id', 1)
      @collection.validate (err, errors) =>
        throw err if err
        equal errors.length, 1
        @collection.get('products.toArray.1').set('id', 2)
        @collection.validate (err, errors) =>
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "associated for belongsTo", ->
    namespace = @
    class @Product extends Batman.Model
      @belongsTo 'collection', {namespace, autoload: false}
      @validate 'collection', associated: true

    class @Collection extends Batman.Model
      @validate 'id', presence: true

    @product = new @Product
    @collection = new @Collection
    @product.validate (err, errors) =>
      throw err if err
      equal errors.length, 0
      @product.set 'collection', @collection
      @product.validate (err, errors) =>
        throw err if err
        equal errors.length, 1
        @collection.set('id', 2)
        @product.validate (err, errors) =>
          throw err if err
          equal errors.length, 0
          QUnit.start()

QUnit.module "Batman.Model: Validations",
validationsTestSuite()

QUnit.module "Batman.Model: Validations with I18N",
  setup: ->
    Batman.I18N.enable()
  teardown: ->
    Batman.I18N.disable()

validationsTestSuite()

QUnit.module "Batman.Model: binding to errors",
  setup: ->
    class @Product extends Batman.Model
      @validate 'name', {presence: true}

    @product = new @Product
    @someObject = Batman {product: @product}

asyncTest "errors set length should be observable", 4, ->
  count = 0
  errorsAtCount =
    0: 1
    1: 0

  @product.get('errors').observe 'length', (newLength, oldLength) ->
    equal newLength, errorsAtCount[count++]

  @product.validate (err, errors) =>
    throw err if err
    equal errors.get('length'), 1
    @product.set 'name', 'Foo'
    @product.validate (err, errors) =>
      throw err if err
      equal errors.get('length'), 0
      QUnit.start()

asyncTest "errors set contents should be observable", 3, ->
  x = @product.get('errors.name')
  x.observe 'length', (newLength, oldLength) ->
    equal newLength, 1

  @product.validate (error, errors) =>
    throw error if error
    equal errors.get('length'), 1
    equal errors.length, 1
    QUnit.start()

asyncTest "errors set length should be bindable", 4, ->
  @someObject.accessor 'productErrorsLength', ->
    errors = @get('product.errors')
    errors.get('length')

  equal @someObject.get('productErrorsLength'), 0, 'the errors should start empty'

  @someObject.observe 'productErrorsLength', (newVal, oldVal) ->
    return if newVal == oldVal # Prevents the assertion below when the errors set is cleared and its length goes from 0 to 0
    equal newVal, 1, 'the foreign observer should fire when errors are added'

  @product.validate (error, errors) =>
    throw error if error
    equal errors.length, 1, 'the validation shouldn\'t succeed'
    equal @someObject.get('productErrorsLength'), 1, 'the foreign key should have updated'
    QUnit.start()

asyncTest "errors set contents should be bindable", 4, ->
  @someObject.accessor 'productNameErrorsLength', ->
    errors = @get('product.errors.name.length')

  equal @someObject.get('productNameErrorsLength'), 0, 'the errors should start empty'

  @someObject.observe 'productNameErrorsLength', (newVal, oldVal) ->
    return if newVal == oldVal # Prevents the assertion below when the errors set is cleared and its length goes from 0 to 0
    equal newVal, 1, 'the foreign observer should fire when errors are added'

  @product.validate (error, errors) =>
    throw error if error
    equal errors.length, 1, 'the validation shouldn\'t succeed'
    equal @someObject.get('productNameErrorsLength'), 1, 'the foreign key should have updated'
    QUnit.start()

test "ValidationError should get full message", ->
  error = new Batman.ValidationError("foo", "isn't valid")
  equal error.get('fullMessage'), "Foo isn't valid"

test "ValidationError should humanize attribute in the full message", ->
  error = new Batman.ValidationError("fooBarBaz", "isn't valid")
  equal error.get('fullMessage'), "Foo bar baz isn't valid"
