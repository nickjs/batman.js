{UniqueSetIndex} = require 'foundation'

module.exports = class PolymorphicUniqueAssociationSetIndex extends UniqueSetIndex
  constructor: (@association, @type, key) ->
    super @association.getRelatedModelForType(type).get('loaded'), key
