QUnit.module "Batman.ModelExpectations",
  setup: ->
    class Test extends Batman.TestCase
      @mixin Batman.ModelExpectations
    @testCase = new Test
    @model = new Batman.Model

test 'setup variables should be available', 1, ->
  self = this
  @model.unset('id')

  (sinon.test ->
    confirmExpectation = @mock()

    self.testCase.expectCreate.call this, self.model, response: "{}"
    self.model.save ->
      confirmExpectation()
  )()

test 'setup variables should be available', 1, ->
  self = this
  @model.set('id', 1)

  (sinon.test ->
    confirmExpectation = @mock()

    self.testCase.expectCreate.call this, self.model, response: "{}"
    self.model.save ->
      confirmExpectation()
  )()


  # call the callback
  # call save on the model
  # check if object is new

# test 'it should fail if save method is not called', 0, ->
#   @bar = new @Bar
#   @test.expectSave @bar