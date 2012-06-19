QUnit.module "Batman.ControllerActionFrame"
  setup: ->
    @completeSpy = createSpy()
    @frame = new Batman.ControllerActionFrame({}, @completeSpy)
suite = ->
  test "starting an operation marks operationOccurred on the frame", ->
    @frame.startOperation()
    ok @frame.operationOccurred

  test "starting an operation with {internal: true} does not mark operationOccurred on the frame", ->
    @frame.startOperation({internal: true})
    ok !@frame.operationOccurred

  test "taking one operation fires the complete callback", ->
    @frame.startAndFinishOperation()
    ok @completeSpy.called

  test "starting one operation does not fire the complete callback", ->
    @frame.startOperation()
    ok !@completeSpy.called

  test "finishing a started operation fires the complete callback", ->
    @frame.startOperation()
    @frame.finishOperation()
    ok @completeSpy.called

  test "finishing one of many outstanding started actions does not the complete callback", ->
    @frame.startOperation()
    @frame.startOperation()
    @frame.finishOperation()
    ok !@completeSpy.called

  test "finishing all of many outstanding started actions does not the complete callback", ->
    @frame.startOperation()
    @frame.startOperation()
    @frame.finishOperation()
    @frame.finishOperation()
    ok @completeSpy.called

suite()

QUnit.module "Batman.ControllerActionFrame with parent frames"
  setup: ->
    @parentCompleteSpy = createSpy()
    @completeSpy = createSpy()
    @parentFrame = new Batman.ControllerActionFrame({}, @parentCompleteSpy)
    @frame = new Batman.ControllerActionFrame({parentFrame: @parentFrame}, @completeSpy)

suite()

test "taking one operation fires the complete callback on the parent frame", ->
  @frame.startAndFinishOperation()
  ok @parentCompleteSpy.called

test "starting one operation does not fire the complete callback on the parent frame", ->
  @frame.startOperation()
  ok !@parentCompleteSpy.called

test "finishing a started operation fires the complete callback on the parent frame", ->
  @frame.startOperation()
  @frame.finishOperation()
  ok @parentCompleteSpy.called

test "finishing one of many outstanding started actions does not the complete callback on the parent frame", ->
  @frame.startOperation()
  @frame.startOperation()
  @frame.finishOperation()
  ok !@parentCompleteSpy.called

test "finishing all of many outstanding started actions does not the complete callback on the parent frame", ->
  @frame.startOperation()
  @frame.startOperation()
  @frame.finishOperation()
  @frame.finishOperation()
  ok @parentCompleteSpy.called

test "finishing a started operation does not fire the complete callback on the parent frame if the parent frame has outstanding started actions", ->
  @parentFrame.startOperation()
  @frame.startOperation()
  @frame.finishOperation()
  ok !@parentCompleteSpy.called

