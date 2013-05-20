QUnit.module "Batman.StateMachine",
  setup: ->
    class @SwitchStateMachine extends Batman.StateMachine
      @transitions
        switch: {on: 'off', off: 'on'}
        switchOn: {off: 'on'}

    @sm = new @SwitchStateMachine 'on'

test "should start in the inital state given", ->
  equal 'on', @sm.get('state')

test "should define accessors and function state predicates", ->
  ok @sm.isOn()
  ok @sm.get('isOn')
  ok !@sm.isOff()
  ok !@sm.get('isOff')

test "should accept a transition table in the constructor", ->
  equal @sm.get('state'), 'on'
  @sm.switch()
  equal @sm.get('state'), 'off'
  @sm.switch()
  equal @sm.get('state'), 'on'
  @sm.startTransition('switch')
  equal @sm.get('state'), 'off'

  ok @sm.canStartTransition('switch')
  ok @sm.canStartTransition('switchOn')

test "should not allow transitions which aren't in the table", ->
  equal @sm.get('state'), 'on'
  equal @sm.switchOn(), false
  equal @sm.get('state'), 'on'

  ok !@sm.canStartTransition('switchOn')
  ok !@sm.canStartTransition('nonExistant'), "Non existant events can't be done"

test "should allow observing state entry", 2, ->
  @sm.onEnter 'off', =>
    ok true, 'callback is called'
    equal @sm.get('state'), 'off', 'State should have set when enter callback fires'

  @sm.switch()

test "should allow observing state exit", 2, ->
  @sm.onExit 'on', =>
    ok true, 'callback is called'
    equal @sm.get('state'), 'on', 'State should not have changed when callback fires'
  @sm.switch()

test "should allow observing events", 2, ->
  @sm.on 'switch', =>
    ok true, 'callback is called'
    equal @sm.get('state'), 'off', 'State should have changed when callback fires'
  @sm.switch()

test "should allow observing state transition", 2, ->
  @sm.onTransition 'on', 'off', =>
    ok true, 'callback is called'
    equal @sm.get('state'), 'off', 'State should have changed when callback fires'
  @sm.switch()

test "should allow observing before a state change occurs", 3, ->
  @sm.onBefore 'off', =>
    ok true, 'callback is called'
    equal @sm.isTransitioning, false, 'Should not be transitioning when callback fires'
    equal @sm.get('state'), 'on', 'State should not have changed when callback fires'
  @sm.switch()

test "should allow removing enter observing callbacks", 1, ->
  cb = createSpy()
  @sm.onEnter 'off', cb
  @sm.offEnter 'off', cb
  @sm.switch
  ok !cb.called

test "should allow removing exit observing callbacks", 1, ->
  cb = createSpy()
  @sm.onExit 'on', cb
  @sm.offExit 'on', cb
  @sm.switch
  ok !cb.called

test "should allow removing transition observing callbacks", 1, ->
  cb = createSpy()
  @sm.onTransition 'on', 'off', cb
  @sm.offTransition 'on', 'off', cb
  @sm.switch
  ok !cb.called

test "should allow removing before observing callbacks", 1, ->
  cb = createSpy()
  @sm.onBefore 'off', cb
  @sm.offBefore 'off', cb
  @sm.switch
  ok !cb.called


test "should allow transitioning into the same state", 3, ->
  class Silly extends Batman.StateMachine
    @transitions sillySwitch: {on: 'on'}

  @sm = new Silly 'on'

  @sm.onExit 'on', exitSpy = createSpy()
  @sm.onTransition 'on', 'on', transitionSpy = createSpy()
  @sm.onEnter 'on', enterSpy = createSpy()

  @sm.sillySwitch()

  ok exitSpy.called
  ok transitionSpy.called
  ok enterSpy.called

test "should allow changing the state in callbacks", 5, ->
  @sm.onExit 'on', =>
    @sm.switch()

  callOrder = []
  @sm.onTransition 'on', 'off', transitionToOffSpy = createSpy()
  @sm.onEnter 'off', enterOffSpy = createSpy()
  @sm.onExit 'off', exitOffSpy = createSpy()
  @sm.onTransition 'off', 'on', transitionToOnSpy = createSpy()
  @sm.onEnter 'on', enterOnSpy = createSpy()

  @sm.switch()

  ok transitionToOnSpy.called
  ok enterOffSpy.called
  ok exitOffSpy.called
  ok transitionToOnSpy.called
  ok enterOnSpy.called

test "should recognize the shorthand for many incoming states converging to one", 3, ->
  class ArrayTest extends Batman.StateMachine
    @transitions
      fade:
        from: ['on', 'half']
        to: 'off'
      flick: {off: 'half'}

  @sm = new ArrayTest('on')
  @sm.fade()
  equal @sm.get('state'), 'off'
  @sm.flick()
  equal @sm.get('state'), 'half'
  @sm.fade()
  equal @sm.get('state'), 'off'

test "subclasses should inherit transitions", 2, ->
  class TwoWaySwitch extends @SwitchStateMachine
    @transitions
      switchOff: {on: 'off'}

  @sm = new TwoWaySwitch('on')
  @sm.switchOff()
  equal @sm.get('state'), 'off'
  @sm.switchOn()
  equal @sm.get('state'), 'on'

test "accessors should be able to source state", 2, ->
  x = Batman(sm: @sm)
  x.accessor 'foo', -> @get('sm.state').toUpperCase()

  equal x.get('foo'), 'ON'
  @sm.switch()
  equal x.get('foo'), 'OFF'

test "transitions in accessors shouldn't add sources", ->
  x = Batman(sm: @sm)
  x.accessor 'foo', => @sm.switch()
  x.get('foo')
  deepEqual x.property('foo').sources, []
