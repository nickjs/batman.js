{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = if typeof require isnt 'undefined' then require '../model_helper' else window
helpers = if typeof require is 'undefined' then window.viewHelpers else require '../../view/view_helper'
{baseSetup} = if typeof require is 'undefined' then window.PolymorphicAssociationHelpers else require './polymorphic_association_helper'

QUnit.module "Batman.Model polymorphic hasMany associations"
  setup: baseSetup

asyncTest "hasMany associations are loaded from remote", 5, ->
  @Store.find 1, (err, store) =>
    throw err if err
    metafields = store.get('metafields')
    delay =>
      array = metafields.toArray()
      equal array.length, 2
      equal array[0].get('key'), "Store metafield"
      equal array[0].get('id'), 1
      equal array[1].get('key'), "Store metafield 2"
      equal array[1].get('id'), 3

asyncTest "hasMany associations are loaded from inline json", 3, ->
  @Store.find 2, (err, store) =>
    throw err if err
    metafields = store.get('metafields')
    array = metafields.toArray()
    equal array.length, 1
    equal array[0].get('key'), 'SEO Title'
    equal array[0].get('id'), 5
    QUnit.start()

asyncTest "hasMany associations loaded from inline json should not trigger an implicit fetch", 2, ->
  @Store.find 2, (err, store) =>
    throw err if err
    delay =>
      metafieldLoadSpy = spyOn @metafieldAdapter, 'readAll'
      metafields = store.get('metafields')
      delay =>
        equal metafields.get('length'), 1
        equal metafieldLoadSpy.callCount, 0

asyncTest "hasMany associations are saved via the parent model", 7, ->
  store = new @Store name: 'Zellers'
  metafield1 = new @Metafield key: 'Gizmo'
  metafield2 = new @Metafield key: 'Gadget'
  store.set 'metafields', new Batman.Set(metafield1, metafield2)

  storeSaveSpy = spyOn store, 'save'
  store.save (err, record) =>
    throw err if err
    equal storeSaveSpy.callCount, 1
    equal metafield1.get('subject_id'), record.get('id')
    equal metafield1.get('subject_type'), 'Store'
    equal metafield2.get('subject_id'), record.get('id')
    equal metafield2.get('subject_type'), 'Store'

    @Store.find record.get('id'), (err, store2) =>
      throw err if err
      storedJSON = @storeAdapter.storage["stores#{record.get('id')}"]
      deepEqual store2.toJSON(), storedJSON
      # hasMany saves inline by default
      sorter = generateSorterOnProperty('key')
      deepEqual sorter(storedJSON.metafields), sorter([
        {key: "Gizmo", subject_id: record.get('id'), subject_type: 'Store'}
        {key: "Gadget", subject_id: record.get('id'), subject_type: 'Store'}
      ])
      QUnit.start()

asyncTest "hasMany associations are saved via the child model", 3, ->
  @Store.find 1, (err, store) =>
    throw err if err
    metafield = new @Metafield key: 'Store Metafield'
    metafield.set 'subject', store
    metafield.save (err, savedMetafield) ->
      throw err if err
      equal savedMetafield.get('subject_id'), store.get('id')
      equal savedMetafield.get('subject_type'), 'Store'
      metafields = store.get('metafields')
      ok metafields.has(savedMetafield)
      QUnit.start()

asyncTest "hasMany associations should index the loaded set", 3, ->
  @Product.find 4, (err, product) =>
    throw err if err
    metafields = product.get('metafields')
    ok metafields instanceof Batman.AssociationSet
    equal metafields.get('length'), 1
    metafield = new @Metafield(subject_id: 4, subject_type: 'Product', key: "Test Metafield")
    metafield.save (err) ->
      throw err if err
      equal metafields.get('length'), 2
      QUnit.start()

asyncTest "hasMany child models are added to the identity map", 2, ->
  equal @Metafield.get('loaded').length, 0
  @Product.find 4, (err, product) =>
    equal @Metafield.get('loaded').length, 1
    QUnit.start()

asyncTest "unsaved hasMany models should accept associated children", 2, ->
  product = new @Product
  metafields = product.get('metafields')
  delay =>
    equal metafields.length, 0
    metafield = new @Metafield
    metafields.add metafield
    equal metafields.length, 1

asyncTest "unsaved hasMany models should save their associated children", 4, ->
  product = new @Product(name: "Hello!")
  metafields = product.get('metafields')
  metafield = new @Metafield(key: "test")
  metafields.add metafield

  # Mock out what a realbackend would do: assign ids to the child records
  # The TestStorageAdapter is smart enough to do this for the parent, but not the children.
  @productAdapter.create = (record, options, callback) ->
    id = record.set('id', @counter++)
    if id
      @storage[@storageKey(record) + id] = record.toJSON()
      record.fromJSON
        id: id
        metafields: [{
          key: "test"
          id: 12
        }]
      callback(undefined, record)
    else
      callback(new Error("Couldn't get record primary key."))

  product.save (err, product) =>
    throw err if err
    storedJSON = @productAdapter.storage["products#{product.get('id')}"]
    deepEqual storedJSON,
      id: 11
      name: "Hello!"
      metafields:[
        {key: "test", subject_id: product.get('id'), subject_type: 'Product'}
      ]

    ok !product.isNew()
    ok !metafield.isNew()
    equal metafield.get('subject_id'), product.get('id')
    QUnit.start()

asyncTest "unsaved hasMany models should reflect their associated children after save", 3, ->
  product = new @Product(name: "Hello!")
  metafields = product.get('metafields')
  metafield = new @Metafield(key: "test")
  metafields.add metafield

  # Mock out what a realbackend would do: assign ids to the child records
  # The TestStorageAdapter is smart enough to do this for the parent, but not the children.
  @productAdapter.create = (record, options, callback) ->
    id = record.set('id', @counter++)
    if id
      @storage[@storageKey(record) + id] = record.toJSON()
      record.fromJSON
        id: id
        metafields: [{
          key: "test"
          id: 12
        }]
      callback(undefined, record)
    else
      callback(new Error("Couldn't get record primary key."))

  product.save (err, product) =>
    throw err if err
    # Mock out what a realbackend would do: assign ids to the child records
    # The TestStorageAdapter is smart enough to do this for the parent, but not the children.
    equal product.get('metafields.length'), 1
    ok product.get('metafields').has(metafield)
    equal metafields.get('length'), 1
    QUnit.start()

asyncTest "hasMany sets the foreign key on the inverse relation if the children haven't been loaded", 3, ->
  @Product.find 6, (err, product) =>
    throw err if err
    metafields = product.get('metafields')
    delay ->
      metafields = metafields.toArray()
      equal metafields.length, 2
      ok metafields[0].get('subject') == product
      ok metafields[1].get('subject') == product

asyncTest "hasMany sets the foreign key on the inverse relation if the children have already been loaded", 3, ->
  @Metafield.load (err, metafields) =>
    throw err if err
    @Product.find 6, (err, product) =>
      throw err if err
      metafields = product.get('metafields')
      delay ->
        metafields = metafields.toArray()
        equal metafields.length, 2
        ok metafields[0].get('subject') == product
        ok metafields[1].get('subject') == product


