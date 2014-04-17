QUnit.module "Model association reflection",
  setup: ->
    app = Batman.currentApp = {}
    class app.Card extends Batman.Model
      @belongsTo 'deck'
    class app.Deck extends Batman.Model
      @hasMany 'cards'
      @belongsTo 'player'
    class app.Player extends Batman.Model
      @hasOne 'deck'

    @app = app

  teardown: ->
    Batman.currentApp = null

test 'reflectOnAssociation returns the association with that name', ->
  deck = new @app.Deck
  ok deck.reflectOnAssociation('cards') instanceof Batman.HasManyAssociation
  ok deck.reflectOnAssociation('player') instanceof Batman.BelongsToAssociation

test 'reflectOnAllAssociations returns an array of all associations', ->
  deck = new @app.Deck
  allAssociations = deck.reflectOnAllAssociations()
  ok allAssociations.length == 2
  ok allAssociations instanceof Batman.SimpleSet

test 'reflectOnAllAssociations(type) gives associations of that type', ->
  deck = new @app.Deck
  ok deck.reflectOnAllAssociations('hasMany').length == 1, "Finds the hasMany"
  equal deck.reflectOnAllAssociations('hasMany').constructor.name, "SimpleSet"
  ok deck.reflectOnAllAssociations('belongsTo').at(0) instanceof Batman.BelongsToAssociation, "finds the belongsTo"

test 'reflectOnAllAssociations returns null for a model with no associations', ->
  class BoringModel extends Batman.Model
  boringInstance = new BoringModel
  equal boringInstance.reflectOnAllAssociations(), null
  equal boringInstance.reflectOnAllAssociations('hasMany'), null
  equal boringInstance.reflectOnAllAssociations('belongsTo'), null

test 'reflectOnAssociation returns null if no association with that name', ->
  class BoringModel extends Batman.Model
  boringInstance = new BoringModel
  equal boringInstance.reflectOnAssociation('boring_things'), null
