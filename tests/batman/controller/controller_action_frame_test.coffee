QUnit.module "Batman.ControllerActionFrame"
  setup: ->
    @completeSpy = createSpy()
    @frame = new Batman.ControllerActionFrame({}, @completeSpy)
suite = ->
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

suite()

QUnit.module "Batman.ControllerActionFrame with parent frames"
  setup: ->
    @parentCompleteSpy = createSpy()
    @completeSpy = createSpy()
    @parentFrame = new Batman.ControllerActionFrame({}, @parentCompleteSpy)
    @frame = new Batman.ControllerActionFrame({parentFrame: @parentFrame}, @completeSpy)

suite()

test "taking one action fires the complete callback on the parent frame", ->
  @frame.immediateActionTaken()
  ok @parentCompleteSpy.called

test "starting one action does not fire the complete callback on the parent frame", ->
  @frame.actionStart()
  ok !@parentCompleteSpy.called

test "finishing a started action fires the complete callback on the parent frame", ->
  @frame.actionStart()
  @frame.actionFinish()
  ok @parentCompleteSpy.called

test "finishing one of many outstanding started actions does not the complete callback on the parent frame", ->
  @frame.actionStart()
  @frame.actionStart()
  @frame.actionFinish()
  ok !@parentCompleteSpy.called

test "finishing all of many outstanding started actions does not the complete callback on the parent frame", ->
  @frame.actionStart()
  @frame.actionStart()
  @frame.actionFinish()
  @frame.actionFinish()
  ok @parentCompleteSpy.called

test "finishing a started action does not fire the complete callback on the parent frame if the parent frame has outstanding started actions", ->
  @parentFrame.actionStart()
  @frame.actionStart()
  @frame.actionFinish()
  ok !@parentCompleteSpy.called

