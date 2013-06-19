QUnit.module "Batman.ModelExpectations",
  setup: ->
    class @Test extends Batman.TestCase
      @mixin Batman.ModelExpectations

    @test = new @Test

test 'setup variables should be available', 1, ->
  (sinon.test =>
    @model = new Batman.Model
    @test.expectSave @model

    @model.save
  )()

test 'it should fail if save method is not called', 0, ->
  @bar = new @Bar
  @test.expectSave @bar