{SimpleHash, SimpleSet} = require 'foundation'
{StateMachine} = require 'utilities'

module.exports = class AssociationCurator extends SimpleHash
  @availableAssociations: ['belongsTo', 'hasOne', 'hasMany']
  constructor: (@model) ->
    super()
    # Contains (association, label) pairs mapped by association type
    # ie. @storage = {<Association.associationType>: [<Association>, <Association>]}
    @_byTypeStorage = new SimpleHash

  add: (association) ->
    @set association.label, association
    unless associationTypeSet = @_byTypeStorage.get(association.associationType)
      associationTypeSet = new SimpleSet
      @_byTypeStorage.set association.associationType, associationTypeSet
    associationTypeSet.add association

  getByType: (type) -> @_byTypeStorage.get(type)
  getByLabel: (label) -> @get(label)

  getAll: ->
    typeSets = @_byTypeStorage.map (label, typeSet) -> typeSet
    allAssociations = (new SimpleSet).merge(typeSets...)

  reset: ->
    @forEach (label, association) -> association.reset()
    true

  merge: (others...) ->
    result = super
    result._byTypeStorage = @_byTypeStorage.merge(others.map (other) -> other._byTypeStorage)
    result

  _markDirtyAttribute: (key, oldValue) ->
    unless @lifecycle.get('state') in ['loading', 'creating', 'saving', 'saved']
      if @lifecycle.startTransition 'set'
        @dirtyKeys.set(key, oldValue)
      else
        throw new StateMachine.InvalidTransitionError("Can't set while in state #{@lifecycle.get('state')}")
