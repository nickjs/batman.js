Batman.ModelExpectations =
  expectCreate: (instance, options = {}) ->
    confirmExpectation = @mock()
    # QUnit.ok true
    QUnit.ok instance.isNew(), "Expected #{instance.constructor.name} to be new when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(options["err"], options["response"])

  expectUpdate: (instance, options = {}) ->
    confirmExpectation = @mock()
    QUnit.ok !instance.isNew(), "Expected #{instance.constructor.name} to exist when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(options["err"], options["response"])

  expectLoad: (klass, options = {}) ->
    confirmExpectation = @mock()

    @stub klass, 'load', (innerParams, callback) =>
      callback = innerParams if typeof innerParams in ['function', 'undefined']

      @assertEqual options["params"], innerParams if options["params"]?
      confirmExpectation()
      callback(options["err"], options["response"])

  expectFind: (klass, options = {}) ->
    confirmExpectation = @mock()

    @stub klass, 'find', (innerParams, callback) =>
      callback = innerParams if typeof innerParams in ['function', 'undefined']

      @assertEqual options["params"], innerParams if options["params"]?
      confirmExpectation()
      callback(options["err"], options["response"])
