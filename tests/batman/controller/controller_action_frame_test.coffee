QUnit.module "Batman.ControllerActionFrame"
  setup: ->
    @completeSpy = createSpy()
    @frame = new Batman.ControllerActionFrame({}, @completeSpy)

test "starting an action marks actionTaken on the frame", ->
  @frame.actionStart()
  ok @frame.actionTaken

test "starting an action with {internal: true} does not mark actionTaken on the frame", ->
  @frame.actionStart({internal: true})
  ok !@frame.actionTaken

test "taking one action fires the complete callback", ->
  @frame.immediateActionTaken()
  ok @completeSpy.called

test "starting one action does not fire the complete callback", ->
  @frame.actionStart()
  ok !@completeSpy.called

test "finishing a started action fires the complete callback", ->
  @frame.actionStart()
  @frame.actionFinish()
  ok @completeSpy.called

test "finishing one of many outstanding started actions does not the complete callback", ->
  @frame.actionStart()
  @frame.actionStart()
  @frame.actionFinish()
  ok !@completeSpy.called

test "finishing all of many outstanding started actions does not the complete callback", ->
  @frame.actionStart()
  @frame.actionStart()
  @frame.actionFinish()
  @frame.actionFinish()
  ok @completeSpy.called


