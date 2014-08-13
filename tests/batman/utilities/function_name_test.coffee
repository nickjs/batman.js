QUnit.module 'helpers',
test 'functionName', ->
  class Function
  class ExtendedFunction extends Function
  class Foo_Bar
  class FooBar
  class P
  namespace = P: P
  equal "Function", Batman.functionName(Function)
  equal "ExtendedFunction", Batman.functionName(ExtendedFunction)
  equal "Foo_Bar", Batman.functionName(Foo_Bar)
  equal "FooBar", Batman.functionName(FooBar)
  equal "P", Batman.functionName(namespace.P)
  equal undefined, Batman.functionName ->
  equal undefined, Batman.functionName =>
