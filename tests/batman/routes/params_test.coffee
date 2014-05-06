QUnit.module "Batman.Params",
  setup: ->
    @params = new Batman.Params

test "@url is set", ->
  ok @params.url() instanceof Batman.UrlParams
  equal @params.url(), @params.get('url')

QUnit.module "Batman.UrlParams",
  window.location.pathname = '/'
  window.location.search = '?page=5&limit=10'

  setup: ->
    @navigator =
      setPath: createSpy()
    @params = new Batman.Params({
      foo: 'fooVal'
      bar: 'barVal'
      }, @navigator)

    @urlParams = @params.url()

test "it sets params from URL", ->
  equal @urlParams.get('page'), 5
  equal @urlParams.get('limit'), 10

test "it sets URL from params", ->
  @urlParams.set(page: 8)
  equal window.location.search, '?page=8&limit=10'
