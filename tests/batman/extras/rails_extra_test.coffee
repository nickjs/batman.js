QUnit.module "Batman.Rails: date encoding"

dateEqual = (a, b, args...) ->
  equal a.getTime(), b.getTime(), args...

test "it parses ISO 8601 dates without a timezone offset in the local timezone", ->
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06"), new Date(2012, 0, 3, 13, 35, 6)

test "it correctly parses ISO 8601 dates with a timezone offset", ->
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06-05:00"), new Date(Date.UTC(2012, 0, 3, 18, 35, 6))
  dateEqual Batman.Encoders.railsDate.decode("2012-01-03T13:35:06-07:00"), new Date(Date.UTC(2012, 0, 3, 20, 35, 6))

test "it uses the appropriate offset for the given timestamp", ->
  sinon.stub Date.prototype, "getTimezoneOffset", -> if this.getFullYear() > 2000 then -660 else -600

  dateEqual Batman.Encoders.railsDate.decode("2012-08-09T09:00:00"), new Date(Date.UTC(2012, 7, 8, 22))
  dateEqual Batman.Encoders.railsDate.decode("1988-08-09T09:00:00"), new Date(Date.UTC(1988, 7, 8, 23))

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
