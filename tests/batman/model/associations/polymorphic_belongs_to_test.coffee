{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = window
helpers = window.viewHelpers
{baseSetup} = if typeof require is 'undefined' then window.PolymorphicAssociationHelpers else require './polymorphic_association_helper'

QUnit.module "Batman.Model polymorphic belongsTo associations",
  setup: baseSetup

asyncTest "belongsTo associations are loaded from remote", 4, ->
  @Metafield.find 1, (err, metafield) =>
    throw err if err
    metafield.get('subject').load (err, store) =>
      throw err if err
      ok store instanceof @Store
      equal store.get('id'), 1
      @Metafield.find 2, (err, metafield) =>
        throw err if err
        metafield.get('subject').load (err, product) =>
          throw err if err
          ok product instanceof @Product
          equal product.get('id'), 1
          QUnit.start()

asyncTest "belongsTo associations are loaded from custom urls if specified", 2, ->
  @Metafield._batman.get('associations').get('subject').options.url = '/subject'
  associationSpy = spyOn(@storeAdapter, 'perform')
  @Metafield.find 1, (err, metafield) =>
    store = metafield.get 'subject'
    delay ->
      equal associationSpy.lastCallArguments[2].recordUrl, '/subject'
      equal associationSpy.callCount, 1

asyncTest "belongsTo associations are loaded from inline json", 2, ->
  @Metafield.find 4, (err, metafield) =>
    throw err if err
    product = metafield.get('subject')
    equal product.get('name'), "Product 5"
    equal product.get('id'), 5
    QUnit.start()

asyncTest "belongsTo associations are saved", ->
  metafield = new @Metafield id: 10, key: "SEO Title"
  store = new @Store id: 11, name: "Store 11"
  metafield.set 'subject', store
  metafield.save (err, record) =>
    throw err if err
    equal record.get('subject_id'), 11
    equal record.get('subject_type'), 'store'
    storedJSON = @metafieldAdapter.storage["metafields10"]
    deepEqual storedJSON, metafield.toJSON()
    QUnit.start()

test "belongsTo associations don't encode their foreignTypeKeys if not asked to", ->
  class Product extends Batman.Model
    @encode 'id', 'name'
    @belongsTo 'store', {namespace: @namespace, autoload: false, encodeForeignTypeKey: false}

  @product = new Product(id: 1, name: "Chair", store_id: 1, store_type: "Store")
  deepEqual @product.toJSON(), {id: 1, name: "Chair", store_id: 1}

asyncTest "belongsTo supports inline saving", 1, ->
  namespace = @namespace
  class @InlineMetafield extends Batman.Model
    @encode 'key'
    @belongsTo 'subject', {namespace, saveInline: true, polymorphic: true}

  namespace.Store = class @Store extends Batman.Model
    @encode 'name'

  storageAdapter = createStorageAdapter @InlineMetafield, AsyncTestStorageAdapter

  metafield = new @InlineMetafield key: "SEO Title"
  store = new @Store name: "Inline Store"
  metafield.set 'subject', store
  metafield.save (err, record) =>
    deepEqual storageAdapter.storage["inline_metafields#{record.get('id')}"],
      key: "SEO Title"
      subject: {name: "Inline Store"}
      subject_type: 'store'
    QUnit.start()

asyncTest "belongsTo parent models are added to the identity map", 1, ->
  @Metafield.find 4, (err, metafield) =>
    throw err if err
    equal @Product.get('loaded').length, 1
    QUnit.start()

asyncTest "belongsTo parent models are passed through the identity map", 2, ->
  @Product.find 5, (err, product) =>
    throw err if err
    @Metafield.find 4, (err, metafield) =>
      equal @Product.get('loaded').length, 1
      ok metafield.get('subject') == product
      QUnit.start()

asyncTest "belongsTo supports custom foreign keys", 2, ->
  namespace = @namespace
  class SillyMetafield extends Batman.Model
    @encode 'id', 'key'
    @belongsTo 'doodad', {namespace, foreignKey: 'subject_id', polymorphic: true}

  sillyMetafieldAdapter = createStorageAdapter SillyMetafield, AsyncTestStorageAdapter,
    'silly_metafields1':
      id: 1
      key: 'SEO Title'
      subject_id: 1
      doodad_type: 'store'

  SillyMetafield.find 1, (err, metafield) ->
    store = metafield.get('doodad')
    delay ->
      equal store.get('id'), 1
      equal store.get('name'), 'Store One'

asyncTest "belongsTo supports custom type keys", 2, ->
  namespace = @namespace
  class SillyMetafield extends Batman.Model
    @encode 'id', 'key'
    @belongsTo 'subject', {namespace, foreignTypeKey: 'doodad_type', polymorphic: true}

  sillyMetafieldAdapter = createStorageAdapter SillyMetafield, AsyncTestStorageAdapter,
    'silly_metafields1':
      id: 1
      key: 'SEO Title'
      subject_id: 1
      doodad_type: 'store'

  SillyMetafield.find 1, (err, metafield) ->
    store = metafield.get('subject')
    delay ->
      equal store.get('id'), 1
      equal store.get('name'), 'Store One'

QUnit.module "Batman.Model polymorphic belongsTo associations with inverseof to a hasMany",
  setup: ->
    baseSetup.call(@)
    namespace = @namespace
    # Redefine models with the inverseof relationship inplace from the start.
    namespace.Metafield = class @Metafield extends Batman.Model
      @encode 'key'
      @belongsTo 'subject', {namespace, polymorphic: true, inverseOf: 'metafields'}
    @Metafield.persist @metafieldAdapter
    namespace.Product = class @Product extends Batman.Model
        @encode 'id', 'name'
        @hasMany 'metafields', {as: 'subject', namespace}
    @Product.persist @productAdapter

asyncTest "belongsTo sets the foreign key on itsself so the parent relation SetIndex adds it, if the parent hasn't been loaded", 1, ->
  @Metafield.find 4, (err, metafield) =>
    throw err if err
    product = metafield.get('subject')
    delay ->
      ok product.get('metafields').has(metafield)

asyncTest "belongsTo sets the foreign key on itself so the parent relation SetIndex adds it, if the parent has already been loaded", 1, ->
  @Product.find 5, (err, product) =>
    throw err if err
    @Metafield.find 4, (err, metafield) =>
      throw err if err
      product = metafield.get('subject')
      delay ->
        ok product.get('metafields').has(metafield)

asyncTest "belongsTo sets the foreign key foreign key on itself such that many loads are picked up by the parent", 3, ->
  @Product.find 5, (err, product) =>
    throw err if err
    @Metafield.find 4, (err, metafield) =>
      throw err if err
      equal product.get('metafields').length, 1
      @Metafield.find 7, (err, metafield) =>
        throw err if err
        equal product.get('metafields').length, 2
        equal @Product.get('loaded').length, 1, 'Only one parent record should be created'
        QUnit.start()
