QUnit.module "Batman.Object accessor",
  setup: ->
    @person = new Batman.Object
      firstName: "Bruce"
      lastName: "Wayne"
    @person.accessor 'fullName', -> "#{@get('firstName')} #{@get('lastName')}"

test 'batchAccessorChanges recalculates accessor once, regardless of the logic in wrappedFunction', ->
  results = []
  @person.observe 'fullName', -> results.push 'Accessor was recomputed.'
  mutateFunction = =>
    @person.set('firstName', 'Commissioner')
    @person.set('lastName', 'Gordon')
  @person.batchAccessorChanges('fullName', mutateFunction)
  equal results.length, 1

test 'batchAccessorChanges recalculates each accessor once', ->
  fullNameResults = []
  alphNameResults = []
  @person.observe 'fullName', -> fullNameResults.push 'Accessor was recomputed.'
  @person.accessor 'alphName', -> "#{@get('lastName')}, #{@get('firstName')}"
  @person.observe 'alphName', -> alphNameResults.push 'Accessor was recomputed.'
  mutateFunction = =>
    @person.set('firstName', 'Commissioner')
    @person.set('lastName', 'Gordon')
  @person.batchAccessorChanges('fullName', 'alphName', mutateFunction)
  equal fullNameResults.length, 1
  equal alphNameResults.length, 1

test 'batchAccessorChanges returns the result of wrappedFunction', ->
  @person.accessor 'fullName', -> "#{@get('firstName')} #{@get('lastName')}"
  mutateFunction = =>
    @person.set('firstName', 'Commissioner')
    @person.set('lastName', 'Gordon')
  batchResult = @person.batchAccessorChanges('fullName', mutateFunction)
  equal batchResult, 'Gordon'
