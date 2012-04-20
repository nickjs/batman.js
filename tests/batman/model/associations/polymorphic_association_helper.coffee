{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = if typeof require isnt 'undefined' then require '../model_helper' else window

if typeof exports is 'undefined'
  ex = window.PolymorphicAssociationHelpers = {}
else
  ex = module.exports

ex.baseSetup = ->
  namespace = @namespace = {}
  namespace.Metafield = class @Metafield extends Batman.Model
    @belongsTo 'subject', {polymorphic: true, namespace}
    @encode 'id', 'key'

  @metafieldAdapter = createStorageAdapter @Metafield, AsyncTestStorageAdapter,
    'metafields1':
      id: 1
      subject_id: 1
      subject_type: 'Store'
      key: 'Store metafield'
    'metafields2':
      id: 2
      subject_id: 1
      subject_type: 'Product'
      key: 'Product metafield'
    'metafields3':
      id: 3
      subject_id: 1
      subject_type: 'Store'
      key: 'Store metafield 2'
    'metafields4':
      id: 4
      key: 'Product metafield 2'
      subject_type: 'Product'
      subject:
        name: "Product 5"
        id: 5
    'metafields7':
      id: 7
      key: 'Product metafield 2.1'
      subject_type: 'Product'
      subject:
        name: "Product 5"
        id: 5
    'metafields20':
        id: 20
        key: "SEO Title"
    'metafields30':
        id: 30
        key: "SEO Title"

  namespace.Store = class @Store extends Batman.Model
    @encode 'id', 'name'
    @hasMany 'metafields', {as: 'subject', namespace}

  @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
    'stores1':
      name: "Store One"
      id: 1
    'stores2':
      name: "Store Two"
      id: 2
      metafields: [{
        id: 5
        key: "SEO Title"
      }]

  namespace.Product = class @Product extends Batman.Model
    @encode 'id', 'name'
    @hasMany 'metafields', {as: 'subject', namespace}

  @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter,
    'products1':
      name: "Product One"
      id: 1
      store_id: 1
    'products4':
      name: "Product One"
      id: 1
      metafields: [{
        id: 6
        key: "SEO Title"
      }]
    'products5':
      name: "Product 5"
      id: 5
    'products6':
      name: "Product Six"
      id: 6
      metafields: [{
        id: 20
        key: "SEO Title"
      },{
        id: 30
        key: "SEO Title"
      }]
