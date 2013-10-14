QUnit.module "Batman.Route",
test "routes should match and dispatch", 3, ->
  @route = new Batman.CallbackActionRoute "/why/where/what", {callback: spy = createSpy()}

  ok @route.test "/why/where/what"
  ok !@route.test "/when/how"

  [path, params] = @route.pathAndParamsFromArgument "/why/where/what"

  @route.dispatch params

  deepEqual spy.lastCallArguments, [{path}]

test "routes should test against params hashes", 4, ->
  @route = new Batman.ControllerActionRoute "/products/:id/edit", {controller: 'products', action: 'edit'}

  ok @route.test {path: "/products/10/edit"}
  ok @route.test {controller: 'products', action: 'edit', id: 10}
  ok !@route.test {controller: 'products', action: 'edit'}
  ok !@route.test {controller: 'products', action: 'show', id: 10}

test "routes with extra parameters should match and dispatch", 1, ->
  @route = new Batman.CallbackActionRoute "/why/where/what", {handy: true, callback: spy = createSpy()}

  [path, params] = @route.pathAndParamsFromArgument "/why/where/what"

  @route.dispatch params
  deepEqual spy.lastCallArguments, [{path, handy:true}]

test "routes with named parameters should match and dispatch", 5, ->
  @route = new Batman.CallbackActionRoute "/products/:id", {callback: spy = createSpy()}

  ok @route.test "/products/10"
  ok @route.test "/products/20"
  ok !@route.test "/products/"
  ok !@route.test "/products"

  [path, params] = @route.pathAndParamsFromArgument "/products/10"

  @route.dispatch params
  deepEqual spy.lastCallArguments, [{id: '10', path: "/products/10"}]

test "routes with splat parameters should match and dispatch", 9, ->
  @route = new Batman.CallbackActionRoute "/books/*categories/all", {callback: spy = createSpy()}

  ok @route.test "/books/fiction/fantasy/vampires/all"
  ok @route.test "/books/non-fiction/biography/all"
  ok @route.test "/books/non-fiction/all"
  ok @route.test "/books//all"
  ok !@route.test "/books/"
  ok !@route.test "/books/a/b/c"

  [path, params] = @route.pathAndParamsFromArgument "/books/non-fiction/biography/all"

  @route.dispatch params
  deepEqual spy.lastCallArguments, [{categories: 'non-fiction/biography', path}]

  [path, params] = @route.pathAndParamsFromArgument "/books/non-fiction/all"
  @route.dispatch params
  deepEqual spy.lastCallArguments, [{categories: 'non-fiction', path}]

  [path, params] = @route.pathAndParamsFromArgument "/books//all"
  @route.dispatch params
  deepEqual spy.lastCallArguments, [{categories: '', path}]

test "routes should build paths without named parameters", 1, ->
  @route = new Batman.Route "/products", {}
  equal @route.pathFromParams({}), "/products"

test "routes should build paths with named parameters", 3, ->
  @route = new Batman.Route "/products/:id", {}
  equal @route.pathFromParams({id:1}), "/products/1"
  equal @route.pathFromParams({id:10}), "/products/10"

  @route = new Batman.Route "/products/:product_id/images/:id", {}
  equal @route.pathFromParams({product_id: 10, id:20}), "/products/10/images/20"

test "routes should build paths with splat parameters", 2, ->
  @route = new Batman.Route "/books/*categories/all", {}
  equal @route.pathFromParams({categories: ""}), "/books//all"
  equal @route.pathFromParams({categories: "fiction/fantasy"}), "/books/fiction/fantasy/all"

test "routes should build paths with query parameters", 3, ->
  @route = new Batman.Route "/books/:id", {}
  equal @route.pathFromParams({id: 1, page: 3, limit: 10}), "/books/1?page=3&limit=10"

  @route = new Batman.Route "/books/:page", {}
  equal @route.pathFromParams({id: 1, page: 3, limit: 10}), "/books/3?id=1&limit=10"

  @route = new Batman.Route "/welcome", {}
  equal @route.pathFromParams({"the phrase": "a phrase with spaces"}), "/welcome?the+phrase=a+phrase+with+spaces"

test "routes should build paths with hashes", 1, ->
  @route = new Batman.Route "/books/:id", {}
  equal @route.pathFromParams({id: 1, '#': 'foo'}), "/books/1#foo"

test "routes should build paths with query parameters and hashes", 1, ->
  @route = new Batman.Route "/books/:id", {}
  equal @route.pathFromParams({id: 1, page: 3, limit: 10, '#': 'foo'}), "/books/1?page=3&limit=10#foo"

test "routes should parse paths with query parameters", ->
  route = new Batman.Route "/welcome", {}
  path = "/welcome?the%20phrase=a+phrase+with+spaces+and+a+plus+%2B"
  expectedParams =
    path: "/welcome"
    "the phrase": "a phrase with spaces and a plus +"
  deepEqual route.paramsFromPath(path), expectedParams

test "controller action routes should match", ->
  App =  Batman
    dispatcher: Batman
      controllers: Batman
        products: Batman
          dispatch: productSpy = createSpy()

        savedSearches: Batman
          dispatch: searchSpy = createSpy()

  @route = new Batman.ControllerActionRoute "/products/:id/edit",
    controller: 'products'
    action: 'edit'
    app: App

  ok @route.test "/products/10/edit"
  ok !@route.test "/products/10"

  @route = new Batman.ControllerActionRoute "/saved_searches/:id/duplicate",
    controller: 'savedSearches'
    action: 'duplicate'
    app: App

  ok @route.test "/saved_searches/10/duplicate"
  ok !@route.test "/saved_searches/10"

test "controller/action routes should call the controller's dispatch function", ->
  App =  Batman
    dispatcher: Batman
      controllers: Batman
        products: Batman
          dispatch: productSpy = createSpy()

        savedSearches: Batman
          dispatch: searchSpy = createSpy()

  @route = new Batman.ControllerActionRoute "/products/:id/edit",
    controller: 'products'
    action: 'edit'
    app: App

  [path, params] = @route.pathAndParamsFromArgument "/products/10/edit"
  @route.dispatch params

  equal productSpy.lastCallArguments[0], "edit"
  equal productSpy.lastCallArguments[1].id, "10"

  @route = new Batman.ControllerActionRoute "/saved_searches/:id/duplicate",
    controller: 'savedSearches'
    action: 'duplicate'
    app: App

  [path, params] = @route.pathAndParamsFromArgument "/saved_searches/20/duplicate"
  @route.dispatch params
  equal searchSpy.lastCallArguments[0], "duplicate"
  equal searchSpy.lastCallArguments[1].id, "20"

test "routes should build paths with optional segments", 3, ->
  route = new Batman.Route "/calendar(/:type(/:date))", {}

  equal route.pathFromParams({}), "/calendar"
  equal route.pathFromParams({type: "m"}), "/calendar/m"
  equal route.pathFromParams({type: "m", date: "2012-11"}), "/calendar/m/2012-11"

test "routes should decode URI components when parsing params", ->
  route = new Batman.Route("/users/:name", {})

  path = '/users/Hello%20World'
  deepEqual route.paramsFromPath(path), { name: 'Hello World', path }

test "routes with optional segments should parse params", ->
  type = 'm'
  date = '2012-11'
  route = new Batman.Route "/calendar(/:type(/:date))", {}

  path = "/calendar/#{type}/#{date}"
  deepEqual route.paramsFromPath(path), { path, type, date }

  path = "/calendar/#{type}"
  deepEqual route.paramsFromPath(path), { path, type }

  path = "/calendar"
  deepEqual route.paramsFromPath(path), { path }
