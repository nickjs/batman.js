QUnit.module "Batman.Model::transaction",
  setup: ->
    scope = this
    class @TestNested extends Batman.Model
      @resourceName: 'testNested'
      @persist Batman.RestStorage
      @belongsTo 'testModel', namespace: scope
      @encode 'name'

    class @TestModel extends Batman.Model
      @resourceName: 'test'
      @persist Batman.RestStorage

      @encode 'banana'
      @validate 'banana', presence: true
      @validate 'money', numeric: true, allowBlank: true
      @hasOne 'testNested', namespace: scope
      @hasMany 'apples', name: 'TestNested', namespace: scope

    @nested = new @TestNested(name: 'bob')
    @apple1 = new @TestNested(name: 'apple1')
    @apple2 = new @TestNested(name: 'apple2')
    @apples = new Batman.AssociationSet()
    @apples.add(@apple1)
    @apples.add(@apple2)

    @base = new @TestModel(testNested: @nested, apples: @apples)
    @nested.set 'testModel', @base
    @apple1.set 'testModel', @base
    @apple2.set 'testModel', @base

    @transaction = @base.transaction()

test 'changes made to the base object do not affect the transaction', ->
  @base.set('banana', 'rama')
  ok !@transaction.get('banana')

test 'changes made to the transaction object do not affect the base', ->
  @transaction.set('banana', 'rama')
  ok !@base.get('banana')

test 'applyChanges applies the changes in the transaction object to the base', ->
  @transaction.set('banana', 'rama')
  @transaction.applyChanges()
  equal 'rama', @base.get('banana')

test 'save applies the changes in the transaction object and saves the object', ->
  s = sinon.stub(Batman.Model.prototype, '_doStorageOperation', (callback) -> callback?(null, this))
  @transaction.set('banana', 'rama')
  @transaction.save()
  s.restore()

  equal 'rama', @base.get('banana')

test 'errors on the transaction object are not applied to the base object', ->
  @transaction.validate()
  equal 1, @transaction.get('errors.length')
  equal 0, @base.get('errors.length')

test 'errors on the transaction object are not applied to the base object after save', ->
  s = sinon.stub(Batman.Model.prototype, 'save', (callback) => callback?(@transaction.get('errors'), this))
  @transaction.validate()
  equal 1, @transaction.get('errors.length')
  equal 0, @base.get('errors.length')

  @transaction.save()
  equal 1, @transaction.get('errors.length')
  equal 0, @base.get('errors.length')

  @transaction.set('money', 'banana tree')
  @transaction.validate()
  s.restore()

  equal 2, @transaction.get('errors.length')
  equal 0, @base.get('errors.length')

test 'errors on the base object are applied to the transaction on save', ->
  @transaction.save()
  equal 1, @transaction.get('errors.length')

test 'nested models get their own transaction in a hasOne', ->
  ok @base.get('testNested') == @nested
  ok @transaction.get('testNested') != @nested

test 'nested models get their own transaction in a hasMany', ->
  ok @base.get('testNested') == @nested
  ok @transaction.get('apples').first != @apple1

test 'nested model transactions get properly applied', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.set('banana', 'rama')
  @transaction.applyChanges()

  equal 'rama', @base.get('banana')
  equal 'jim', @nested.get('name')

test 'nested model transactions get properly saved', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.get('apples.first').set('name', 'peach1')
  @transaction.set('banana', 'rama')
  @transaction.save()

  equal 'rama', @base.get('banana')
  equal 'jim', @nested.get('name')
  equal 'peach1', @base.get('apples.first.name')

test 'nested model transactions block sets from modifying the original', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.get('apples.first').set('name', 'peach1')
  @transaction.set('banana', 'rama')

  equal undefined, @base.get('banana')
  equal 'bob', @nested.get('name')
  equal 'apple1', @apple1.get('name')

test 'recursive nested model transactions get properly loaded and applied', ->
  transaction = @base.transaction()
  ok transaction == transaction.get('testNested.testModel')

  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')
  transaction.applyChanges()

  equal 'rama', @base.get('banana')
  equal 'jim', @nested.get('name')

test 'recursive nested hasOne model transactions get properly saved', ->
  transaction = @base.transaction()
  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')
  transaction.save()

  equal 'rama', @base.get('banana')
  equal 'jim', @nested.get('name')

test 'recursive nested toMany transactions get properly saved', ->
  transaction = @base.transaction()
  transaction.get('apples.first').set('name', 'apple3')
  transaction.get('apples.first.testModel').set('banana', 'rama')
  transaction.save()

  equal 'rama', @base.get('banana')
  equal 'apple3', @base.get('apples.first.name')

test 'recursive nested hasOne model transactions block sets from modifying the original', ->
  transaction = @base.transaction()
  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')

  equal undefined, @base.get('banana')
  equal 'bob', @nested.get('name')

test 'recursive nested hasMany model transactions block sets from modifying the original', ->
  transaction = @base.transaction()
  transaction.get('apples.first').set('name', 'apple3')
  transaction.get('apples.first.testModel').set('banana', 'rama')

  equal undefined, @base.get('banana')
  equal 'bob', @nested.get('name')
  equal 'apple1', @apple1.get('name')
