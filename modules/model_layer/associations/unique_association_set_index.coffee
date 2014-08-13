{UniqueSetIndex} = require 'foundation'

module.exports = class UniqueAssociationSetIndex extends UniqueSetIndex
  constructor: (@association, key) ->
    super @association.getRelatedModel().get('loaded'), key
