oldOffset = Batman.Encoders.railsDate.defaultTimezoneOffset
QUnit.module "Batman.Rails: date encoding",
  teardown: ->
    Batman.Encoders.railsDate.defaultTimezoneOffset = oldOffset

dateEqual = (a, b, args...) ->
  equal a.getTime(), b.getTime(), args...

test "it should parse ISO 8601 dates", ->
  # Date not during DST
  Batman.Encoders.railsDate.defaultTimezoneOffset = 300
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06"), new Date("Tues, 03 Jan 2012 13:35:06 EST")
  # Date during DST
  Batman.Encoders.railsDate.defaultTimezoneOffset = 240
  dateEqual Batman.Encoders.railsDate.decode("2012-04-13T13:35:06"), new Date("Sun, 13 Apr 2012 13:35:06 EDT")

test "it should parse ISO 8601 dates with timezones", ->
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06-05:00"), new Date(1325615706000)
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06-07:00"), new Date(1325622906000)

QUnit.module "encodeTimestamps",
  setup: ->
    class @Model extends Batman.Model

test "it should be defined on models", ->
  ok Batman.Model.encodeTimestamps

test "with no options should decode created_at and updated_at", ->
  @Model.encodeTimestamps()

  # FIXME when this is a model testcase, this could use assertDecoders
  decoders = []
  @Model::_batman.get("encoders").forEach (key, encoder) ->
    decoders.push(key) if encoder.decode

  notEqual decoders.indexOf('created_at', 'updated_at'), -1

test "should properly decode a Rails date", ->
  @Model.encodeTimestamps('tested_at')
  instance = @Model.createFromJSON(tested_at: "2012-01-03T13:35:06-05:00")

  ok instance.get('tested_at') instanceof Date
  dateEqual instance.get('tested_at'), new Date(1325615706000)

QUnit.module "Batman.Rails: CSRF protection",
  setup: ->
    theTest = this

    class MockRailsStorage extends Batman.RailsStorage
      request: (env) ->
        theTest.lastRequest = env

    class @Model extends Batman.Model
      @persist MockRailsStorage

test "if protectFromCSRF is false, the request does not include a CSRF header", ->
  Batman.config.protectFromCSRF = false
  @Model.get('all')
  ok !@lastRequest.options.headers?['X-CSRF-Token']

test "if protectFromCSRF is true and the appropriate meta tag exists, the request should include a CSRF header", ->
  Batman.config.protectFromCSRF = true
  meta = document.createElement('meta')
  meta.setAttribute('name', 'csrf-token')
  meta.setAttribute('content', 'metaTag!')
  document.head.appendChild(meta)

  @Model.get('all')
  equal @lastRequest.options.headers['X-CSRF-Token'], 'metaTag!'

test "if protectFromCSRF is true and the appropriate config option exists, the request should include a CSRF header", ->
  Batman.config.protectFromCSRF = true
  Batman.config.CSRF_TOKEN = 'configOption!'

  @Model.get('all')
  equal @lastRequest.options.headers['X-CSRF-Token'], 'configOption!'
