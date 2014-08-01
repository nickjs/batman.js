#= require associations/polymorphic_association_helper

QUnit.module "Batman.Model::transaction",
  setup: ->
    scope = this
    window.PolymorphicAssociationHelpers.baseSetup.apply(scope)
    class @TestNested extends Batman.Model
      @resourceName: 'testNested'
      @persist Batman.RestStorage
      @belongsTo 'testModel', namespace: scope
      @encode 'name'

    class @TestModel extends Batman.Model
      @resourceName: 'test'
      @persist Batman.RestStorage

      @encode 'banana', 'money'
      @validate 'banana', presence: true
      @validate 'money', numeric: true, allowBlank: true
      @hasOne 'testNested', namespace: scope
      @hasMany 'apples', name: 'TestNested', namespace: scope
      @hasMany 'oranges', name: 'TestNested', namespace: scope, includeInTransaction: false

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

test 'properties can be excluded from transactions', ->
  ok @transaction.get('attributes.apples.length'), "included associations are present"
  ok @transaction.get('attributes.oranges') is undefined, "excluded associations are undefined"

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

test 'applyChanges filters changes with only', ->
  @transaction.set('banana', 'rama')
  @transaction.set('money', 1)

  @transaction.applyChanges([], {only: "money"})

  equal @base.get('money'), 1
  equal @base.get('banana'), undefined

test 'applyChanges filters changes with except', ->
  @transaction.set('banana', 'orange')
  @transaction.set('money', 42)

  @transaction.applyChanges([], {except: ["money"]})
  equal @base.get('money'), undefined
  equal @base.get('banana'), "orange"

test 'save applies the changes in the transaction object and saves the object', ->
  s = sinon.stub(Batman.Model.prototype, '_doStorageOperation', (options, payload, callback) -> callback?(null, this))
  @transaction.set('banana', 'rama')
  @transaction.save()
  s.restore()

  equal @base.get('banana'), 'rama'

test 'save {only} also filters applyChanges attributes', ->
  s = sinon.stub(Batman.Model.prototype, '_doStorageOperation', (options, payload, callback) -> callback?(null, this))
  # Simulate a loaded record
  @base.set('id', 5)
  @TestModel._mapIdentity(@base)
  @transaction.set('id', 5)

  @transaction.set('banana', 'rama')
  @transaction.set('money', 25)
  @transaction.save({only: ["money"]}, ->)
  s.restore()

  equal @base.get('banana'), undefined
  equal @base.get('money'), 25

test 'save {except} also filters applyChanges attributes', ->
  s = sinon.stub(Batman.Model.prototype, '_doStorageOperation', (options, payload, callback) -> callback?(null, this))
  @transaction.set('banana', 'rama')
  @transaction.set('money', 25)
  @transaction.save({except: "money"}, ->)
  s.restore()

  equal @base.get('banana'), "rama"
  equal @base.get('money'), undefined

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

test 'removed items are tracked and attached to the original associationSet', ->
  firstApple = @base.get('apples.first')
  firstTransactionApple = @transaction.get('apples.first')
  @transaction.get('apples').remove(firstTransactionApple)
  @transaction.applyChanges()
  ok @base.get('apples.removedItems.length') == 1
  ok @base.get('apples.removedItems.first') == firstApple, 'the removed original is in removedItems'

  @transaction.get('apples').add(firstApple)
  @transaction.applyChanges()
  ok @base.get('apples.removedItems.length') == 0, 'returning an item makes it not removed anymore'

test 'items loaded after `transaction()` are still in the transaction set', ->
  newBase = new @TestModel(id: 51)
  newTransaction = newBase.transaction()
  ok newTransaction.get('apples.length') == 0
  newBase.get('apples').add new @TestNested(id: 9, test_model_id: 51)
  ok newTransaction.get('apples.length') == 1, 'the item was loaded'
  ok newTransaction.get('apples.first.id') == 9, 'its the right item'

test 'adding nested models doesnt affect the base until applyChanges', ->
  @transaction.get('apples').add(new @TestModel(name: 'apple3'))
  ok @base.get('apples.length') == 2
  ok @transaction.get('apples.length') == 3

  @transaction.applyChanges()
  ok @base.get('apples.length') == 3, 'the item is added'
  ok @transaction.get('apples.length') == 3, 'the item is still in the transaction'

test 'adding hasMany children with addArray doesnt affect the base until applyChanges', ->
  @transaction.get('apples').addArray([new @TestModel(name: 'apple3')])
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

asyncTest 'polymorphic association sets get transactions', 8, ->
  @Store.find 1, (err, store) =>
    throw err if err
    store.get('metafields')
    delay =>
      transaction = store.transaction()
      metafieldsTransaction = transaction.get('metafields')
      ok metafieldsTransaction.get('association').constructor == Batman.PolymorphicHasManyAssociation, 'its actually polymorphic'
      ok metafieldsTransaction.isTransaction, 'Its actually a transaction'
      metafieldsTransaction.add(new @Metafield)
      ok metafieldsTransaction.get('length'), 3
      ok store.get('metafields.length'), 2, 'New items arent added'

      metafieldsTransaction.get('first').set('key', 'Transaction metafield')
      ok metafieldsTransaction.get('first.key') == 'Transaction metafield'
      ok store.get('metafields.first.key') != "Transaction metafield", 'item changes arent made'

      metafieldsTransaction.applyChanges()
      ok store.get('metafields.length'), 3, 'new items are added'
      ok store.get('metafields.first.key') == "Transaction metafield", 'item changes are applied'

test 'the same association set doesnt get applyChanges called twice', ->
  oldApplyChanges = Batman.Transaction.applyChanges

  changesSpy = Batman.Transaction.applyChanges = createSpy(Batman.Transaction.applyChanges)
  @base.get('apples.first').set('ownerApples', @base.get('apples'))
  equal @base.get('attributes.apples.first.ownerApples._batmanID'), @base.get('attributes.apples._batmanID'), "it's the same association set"

  transaction = @base.transaction()
  equal transaction.get('attributes.apples.first.ownerApples._batmanID'), transaction.get('attributes.apples._batmanID'), "it's the same transactionAssociationSet"
  ###
    altogether 7 objects should be found:
    base -> --- apple1 --> base
        \   \__ apple2 --> base
         \______ bob   --> base

    shouldn't find base.apple1.ownerApples (which would add 2 calls to applyChanges)
  ###
  desiredCalls = 7
  transaction.applyChanges()
  equal changesSpy.calls.length, desiredCalls

  Batman.Transaction.applyChanges = oldApplyChanges
