QUnit.module "Batman.Proxy",
  setup: ->
    @object = Batman(foo: 'bar')
    @proxy = new Batman.Proxy(@object)

test "getting properties on the proxy should return the value from the target", ->
  equal @proxy.get('foo'), 'bar'
  equal @proxy.get('bar'), undefined

test "getting properties on the proxy should return the value from the target if the target's value has changed", ->
  equal @proxy.get('foo'), 'bar'
  @object.set 'foo', 'baz'
  equal @proxy.get('foo'), 'baz'

test "getting properties on the proxy should return the value from a new target if a new target is swapped in", ->
  equal @proxy.get('foo'), 'bar'
  @proxy.set 'target', Batman(foo: 'baz')
  equal @proxy.get('foo'), 'baz'

test "getting properties on the proxy should return undefined if no target is present", ->
  @proxy.unset 'target'
  equal @proxy.get('foo'), undefined
  equal @proxy.get('bar'), undefined

test "setting existing properties on the proxy should set the value on the target", ->
  returnValue = @proxy.set 'foo', 'baz'
  equal returnValue, 'baz'
  equal @proxy.get('foo'), 'baz'

test "setting new properties on the proxy should set the value on the target", ->
  returnValue = @proxy.set 'bar', 'foo'
  equal returnValue, 'foo'
  equal @proxy.get('bar'), 'foo'

test "setting properties on the proxy should have no effect if no target is present", ->
  @proxy.unset 'target'
  equal @proxy.set('foo', 'baz'), undefined
  equal @proxy.get('foo'), undefined

test "unsetting properties on the proxy should unset the value on the target", ->
  @proxy.unset 'foo'
  equal @proxy.get('foo'), undefined

test "unsetting properties on the proxy should have no effect if no target is present", ->
  @proxy.unset 'target'
  equal @proxy.unset('foo'), undefined
  equal @proxy.get('foo'), undefined

test "properties named target should be accessible at target.target", ->
  @object.set 'target', 1
  equal @proxy.get('target.target'), 1
