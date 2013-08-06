QUnit.module "Batman.EventEmitter",
  setup: ->
    @prototypeRainHandler = prototypeRainHandler = createSpy()
    @WeatherSystem = class WeatherSystem
      Batman.mixin @::, Batman.EventEmitter
      @::on 'rain', prototypeRainHandler
    @ottawaWeather = new WeatherSystem
    @rain = @ottawaWeather.event('rain')

test "on attaches handlers which get called during firing", ->
  @ottawaWeather.on 'rain', spy = createSpy()
  @rain.fire()
  ok spy.called

test "on attaches handlers to many keys at once", ->
  @ottawaWeather.on 'snow', 'sleet', 'hail', spy = createSpy()
  @ottawaWeather.fire('snow')
  @ottawaWeather.fire('sleet')
  @ottawaWeather.fire('hail')
  ok spy.callCount, 3

test "off detaches handlers", ->
  spy = createSpy()
  @ottawaWeather.on 'rain', spy
  @ottawaWeather.off 'rain', spy
  @rain.fire()
  ok !spy.called

test "off detaches handlers from many keys at once", ->
  spy = createSpy()
  @ottawaWeather.on 'snow', 'sleet', 'hail', spy
  @ottawaWeather.off 'snow', 'sleet', 'hail', spy
  @ottawaWeather.fire('snow')
  @ottawaWeather.fire('sleet')
  @ottawaWeather.fire('hail')
  ok !spy.called

test "off detaches all handlers if no handler given", ->
  first = createSpy()
  second = createSpy()
  @ottawaWeather.on 'snow', first
  @ottawaWeather.on 'snow', second
  @ottawaWeather.off 'snow'
  @ottawaWeather.fire('snow')
  ok !first.called
  ok !second.called

test "once attaches handlers which get called during firing and then remove themselves", ->
  @ottawaWeather.once 'rain', spy = createSpy()
  @rain.fire()
  equal spy.callCount, 1
  @rain.fire()
  equal spy.callCount, 1

test "hasEvent reports presence of events on the object itself", ->
  ok !@ottawaWeather.hasEvent('sunny')
  @ottawaWeather.on 'sunny', ->
  ok @ottawaWeather.hasEvent('sunny')

test "hasEvent reports presence of events on the prototype", ->
  ok !@ottawaWeather.hasEvent('sunny')
  @WeatherSystem::on 'sunny', ->
  ok @ottawaWeather.hasEvent('sunny')

test "hasEvent reports presence of events on grand-ancestors", ->
  class Thunderstorm extends @WeatherSystem
  @storm = new Thunderstorm
  ok !@storm.hasEvent('sunny')
  @WeatherSystem::on 'sunny', ->
  ok @storm.hasEvent('sunny')

test "firing an event calls ancestor event handlers for that event too", ->
  secondPrototypeHandler = createSpy()
  class Thunderstorm extends @WeatherSystem
    @::on 'rain', secondPrototypeHandler

  storm = new Thunderstorm
  storm.on 'rain', instanceHandler = createSpy()
  storm.fire('rain', 1,2,3)

  for handler in [instanceHandler, @prototypeRainHandler, secondPrototypeHandler]
    equal handler.callCount, 1
    ok handler.lastCallContext == storm
    deepEqual handler.lastCallArguments, [1,2,3]

test "events inherited from ancestors retain oneshot status", ->
  @WeatherSystem::event('snow').oneShot = true

  ok @ottawaWeather.event('snow').oneShot

  class TestWeatherSystem extends @WeatherSystem

  ok TestWeatherSystem::event('snow').oneShot
  ok (new TestWeatherSystem).event('snow').oneShot

test "mutate prevents change events and fires one after", ->
  item = Batman()
  item.on('change', spy = createSpy())

  item.mutate ->
    @fire('change')
    equal spy.callCount, 0
    @fire('change')
    equal spy.callCount, 0

  equal spy.callCount, 1

