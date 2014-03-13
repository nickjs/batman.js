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
  equal @base.get('banana'), 'rama'

test 'save applies the changes in the transaction object and saves the object', ->
  s = sinon.stub(Batman.Model.prototype, '_doStorageOperation', (callback) -> callback?(null, this))
  @transaction.set('banana', 'rama')
  @transaction.save()
  s.restore()

  equal @base.get('banana'), 'rama'

test 'errors on the transaction object are not applied to the base object', ->
  @transaction.validate()
  equal @transaction.get('errors.length'), 1
  equal @base.get('errors.length'), 0

test 'errors on the transaction object are not applied to the base object after save', ->
  s = sinon.stub(Batman.Model.prototype, 'save', (callback) => callback?(@transaction.get('errors'), this))
  @transaction.validate()
  equal @transaction.get('errors.length'), 1
  equal @base.get('errors.length'), 0

  @transaction.save()
  equal @transaction.get('errors.length'), 1
  equal @base.get('errors.length'), 0

  @transaction.set('money', 'banana tree')
  @transaction.validate()
  s.restore()

  equal @transaction.get('errors.length'), 2
  equal @base.get('errors.length'), 0

test 'errors on the base object are applied to the transaction on save', ->
  @transaction.save()
  equal @transaction.get('errors.length'), 1

test 'empty hasManys still get a transaction', ->
  newTransaction = (new @TestModel).transaction()
  transactionApples = newTransaction.get('apples')
  ok transactionApples.get('length') == 0, "its empty"
  ok transactionApples.length == 0, "it also responds to JS .length"
  ok transactionApples.isTransaction, "its a transaction"

test 'nested models get their own transaction in a hasOne', ->
  ok @base.get('testNested') == @nested
  ok @transaction.get('testNested') != @nested

test 'nested models get their own transaction in a hasMany', ->
  ok @base.get('testNested') == @nested
  ok @transaction.get('apples').first != @apple1

test 'removing nested models doesnt affect the base until applyChanges', ->
  firstTransactionApple = @transaction.get('apples.first')
  @transaction.get('apples').remove(firstTransactionApple)
  ok @base.get('apples.length') == 2, 'the item isnt removed from the base'
  ok @transaction.get('apples.length') == 1, 'the item is removed from the transaction'

  @transaction.applyChanges()
  ok @base.get('apples.length') == 1, 'the item is removed'
  ok @transaction.get('apples.length') == 1, 'the item is still gone from the transaction'

test 'adding nested models doesnt affect the base until applyChanges', ->
  @transaction.get('apples').add(new @TestModel(name: 'apple3'))
  ok @base.get('apples.length') == 2
  ok @transaction.get('apples.length') == 3

  @transaction.applyChanges()
  ok @base.get('apples.length') == 3, 'the item is added'
  ok @transaction.get('apples.length') == 3, 'the item is still in the transaction'

test 'nested model transactions get properly applied', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.set('banana', 'rama')
  @transaction.applyChanges()

  equal @base.get('banana'), 'rama'
  equal @nested.get('name'), 'jim'

test 'nested model transactions get properly saved', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.get('apples.first').set('name', 'peach1')
  @transaction.set('banana', 'rama')
  @transaction.save()

  equal @base.get('banana'), 'rama'
  equal @nested.get('name'), 'jim'
  equal @base.get('apples.first.name'), 'peach1'

test 'nested model transactions block sets from modifying the original', ->
  @transaction.get('testNested').set('name', 'jim')
  @transaction.get('apples.first').set('name', 'peach1')
  @transaction.set('banana', 'rama')

  equal @base.get('banana'), undefined
  equal @nested.get('name'), 'bob'
  equal @apple1.get('name'), 'apple1'

test 'recursive nested model transactions get properly loaded and applied', ->
  transaction = @base.transaction()
  ok transaction == transaction.get('testNested.testModel')

  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')
  transaction.applyChanges()

  equal @base.get('banana'), 'rama'
  equal @nested.get('name'), 'jim'

test 'recursive nested hasOne model transactions get properly saved', ->
  transaction = @base.transaction()
  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')
  transaction.save()

  equal @base.get('banana'), 'rama'
  equal @nested.get('name'), 'jim'

test 'recursive nested toMany transactions get properly saved', ->
  transaction = @base.transaction()
  transaction.get('apples.first').set('name', 'apple3')
  transaction.get('apples.first.testModel').set('banana', 'rama')
  transaction.save()

  equal @base.get('banana'), 'rama'
  equal @base.get('apples.first.name'), 'apple3'

test 'recursive nested hasOne model transactions block sets from modifying the original', ->
  transaction = @base.transaction()
  transaction.get('testNested').set('name', 'jim')
  transaction.get('testNested.testModel').set('banana', 'rama')

  equal @base.get('banana'), undefined
  equal @nested.get('name'), 'bob'

test 'recursive nested hasMany model transactions block sets from modifying the original', ->
  transaction = @base.transaction()
  transaction.get('apples.first').set('name', 'apple3')
  transaction.get('apples.first.testModel').set('banana', 'rama')

  equal @base.get('banana'), undefined
  equal @nested.get('name'), 'bob'
  equal @apple1.get('name'), 'apple1'
