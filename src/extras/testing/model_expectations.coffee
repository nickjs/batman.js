Batman.ModelExpectations =
  expectCreate: (instance, options) ->
    confirmExpectation = @mock()
    @assert instance.isNew(), "Expected #{instance.constructor.name} to be new when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(options["err"], options["result"])

  expectUpdate: (instance, options) ->
    confirmExpectation = @mock()
    @assert !instance.isNew(), "Expected #{instance.constructor.name} to exist when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(options["err"], options["result"])

  expectLoad: (klass, options) ->
    confirmExpectation = @mock()

    @stub klass, 'load', (innerParams, callback) =>
      @assertEqual options["params"], innerParams if options["params"]?
      confirmExpectation()

      callback(options["err"], options["result"])

  expectFind: (klass,options) ->
    confirmExpectation = @mock()

    @stub klass, 'find', (innerParams, callback) =>
      @assertEqual options["params"], innerParams if options["params"]?
      confirmExpectation()

      callback(options["err"], options["result"])
