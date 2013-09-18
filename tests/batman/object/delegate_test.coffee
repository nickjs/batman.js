QUnit.module "Batman.Object delegation",
  setup: ->
    class @MyObject extends Batman.Object
      @accessor 'address', -> Batman(number: '123', zip: '90210', country: Batman(country_code: 'CA'))

test 'delegate without to option raises developer warning', ->
  spy = spyOn(Batman.developer, 'warn')
  @MyObject.delegate 'number'
  ok spy.called

test 'delegate a single property to containing keypath', ->
  @MyObject.delegate 'number', to: 'address'

  obj = new @MyObject
  equal obj.get('number'), '123'

test 'delegate multiple properties to containing keypath', ->
  @MyObject.delegate 'number', 'zip', to: 'address'

  obj = new @MyObject
  equal obj.get('number'), '123'
  equal obj.get('zip'), '90210'

test 'delegate property to a multi segment keypath', ->
  @MyObject.delegate 'country_code', to: 'address.country'

  obj = new @MyObject
  equal obj.get('country_code'), 'CA'
