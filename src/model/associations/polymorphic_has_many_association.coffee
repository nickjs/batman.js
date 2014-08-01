#= require ./has_many_association

class Batman.PolymorphicHasManyAssociation extends Batman.HasManyAssociation
  proxyClass: Batman.PolymorphicAssociationSet
  isPolymorphic: true

  constructor: (model, label, options) ->
    options.inverseOf = @foreignLabel = options.as
    delete options.as

    super(model, label, options)

    @foreignTypeKey = options.foreignTypeKey || "#{@foreignLabel}_type"
    @model.encode @foreignTypeKey

  provideDefaults: (options) ->
    Batman.mixin {}, super,
      foreignKey: "#{@foreignLabel}_id"

  apply: (baseSaveError, base) ->
    unless baseSaveError
      if relations = @getFromAttributes(base)
        super
        relations.forEach (model) => model.set @foreignTypeKey, @modelType()
    return

  proxyClassInstanceForKey: (indexValue) ->
    new @proxyClass(indexValue, @modelType(), this)

  getRelatedModelForType: (type) ->
    scope = @options.namespace

    if type
      relatedModel = scope?[type]
      relatedModel ||= scope?[Batman.helpers.camelize(type)]
    else
      relatedModel = @getRelatedModel()

    Batman.developer.do ->
      if Batman.currentApp? and not relatedModel
        Batman.developer.warn "Related model #{type} for hasMany polymorphic association #{@label} not found."

    relatedModel

  modelType: -> @model.get('resourceName')

  setIndex: ->
    @typeIndex ||= new Batman.PolymorphicAssociationSetIndex(this, @modelType(), @[@indexRelatedModelOn])

  encoder: ->
    association = this
    (relationSet, _, __, record) ->
      if relationSet?
        jsonArray = []
        relationSet.forEach (relation) ->
          relationJSON = relation.toJSON()
          relationJSON[association.foreignKey] = record.get(association.primaryKey)
          relationJSON[association.foreignTypeKey] = association.modelType()
          jsonArray.push relationJSON

      jsonArray

  decoder: ->
    association = this
    (data, key, _, __, parentRecord) ->
      children = association.getFromAttributes(parentRecord) || association.setForRecord(parentRecord)
      newChildren = children.filter((relation) -> relation.isNew()).toArray()

      recordsToAdd = []

      for jsonObject in data
        type = jsonObject[association.options.foreignTypeKey]

        unless relatedModel = association.getRelatedModelForType(type)
          Batman.developer.error "Can't decode model #{association.options.name} because it hasn't been loaded yet!"
          return

        id = jsonObject[relatedModel.primaryKey]
        record = relatedModel._loadIdentity(id)

        if record?
          record._withoutDirtyTracking -> @fromJSON(jsonObject)
          recordsToAdd.push(record)
        else
          if newChildren.length > 0
            record = newChildren.shift()
            record._withoutDirtyTracking -> @fromJSON(jsonObject)
            record = relatedModel._mapIdentity(record)
          else
            record = relatedModel.createFromJSON(jsonObject)
            recordsToAdd.push(record)

        if association.options.inverseOf
          record._withoutDirtyTracking ->
            record.set(association.options.inverseOf, parentRecord)

      children.addArray(recordsToAdd)
      children.markAsLoaded()
      children
