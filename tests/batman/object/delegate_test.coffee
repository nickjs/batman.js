QUnit.module "Batman.Object delegation",
  setup: ->
    scope = @
    class @MyObject extends Batman.Object
      @accessor 'address', -> Batman(number: '123', zip: '90210', country: Batman(country_code: 'CA'))
      @classAccessor 'classAccessor1', -> 'classAccessor 1'
      @classAccessor 'classAccessor2', -> 'classAccessor 2'

    class @OtherObject extends Batman.Object
      @set 'myObjectClass', scope.MyObject
      @classDelegate 'classAccessor1', 'classAccessor2', to: 'myObjectClass'

test 'classDelegate delegates from the class', ->
  equal @OtherObject.get('classAccessor1'), "classAccessor 1"
  equal @OtherObject.get('classAccessor2'), "classAccessor 2", 'works with multiple properties'

test 'delegate without to option raises developer warning', ->
  spy = spyOn(Batman.developer, 'warn')
  @MyObject.delegate 'number'
  ok spy.called

test 'delegate a single property to containing keypath', ->
  @MyObject.delegate 'number', to: 'address'

  obj = new @MyObject
  equal obj.get('number'), '123'
  equal obj.set('number', '456'), '456', "it's set on the object"
  equal obj.get('address').get('number'), '456', "it's set on the delegation target"
  equal obj.get('number'), '456'
  obj.unset('number')
  equal obj.get('number'), undefined, "it's unset on the object"
  equal obj.get('address').get('number'), undefined, "it's unset on the delegation target"

test 'delegate multiple properties to containing keypath', ->
  @MyObject.delegate 'number', 'zip', to: 'address'

  obj = new @MyObject
  equal obj.get('number'), '123'
  equal obj.get('zip'), '90210'

test 'delegate property to a multi segment keypath', ->
  @MyObject.delegate 'country_code', to: 'address.country'

  obj = new @MyObject
  equal obj.get('country_code'), 'CA'
  obj.set('country_code', 'US')
  equal obj.get('country_code'), 'US'
  equal obj.get('address').get('country').get('country_code'), 'US'
  obj.unset('country_code')
  equal obj.get('address').get('country').get('country_code'), undefined


test 'chained delegates should resolve', ->
  @MyObject.delegate 'country', to: 'address'
  @MyObject.delegate 'country_code', to: 'country'

  obj = new @MyObject
  equal obj.get('country_code'), 'CA'
  obj.set('country_code', 'US')
  equal obj.get('country_code'), 'US'
  equal obj.get('address').get('country').get('country_code'), 'US'
  obj.unset('country_code')
  equal obj.get('country_code'), undefined
  equal obj.get('address').get('country').get('country_code'), undefined
