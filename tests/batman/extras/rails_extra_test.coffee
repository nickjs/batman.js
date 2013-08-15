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
