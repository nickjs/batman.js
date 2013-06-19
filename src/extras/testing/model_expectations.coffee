Batman.ModelExpectations =
  expectCreate: (instance, params, err, result) ->
    confirmExpectation = @mock()
    @assert instance.isNew(), "Expected #{instance.constructor.name} to be new when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(err, result)

  expectUpdate: (instance, params, err, result) ->
    confirmExpectation = @mock()
    @assert !instance.isNew(), "Expected #{instance.constructor.name} to exist when saving"

    @stub instance, 'save', (callback) ->
      confirmExpectation()
      callback(err, result)

  expectLoad: (klass, params, err, result) ->
    confirmExpectation = @mock()

    @stub klass, 'load', (innerParams, callback) =>
      @assertEqual params, innerParams if params?
      confirmExpectation()

      callback(err, result)

  expectFind: (klass, params, err, result) ->
    confirmExpectation = @mock()

    @stub klass, 'find', (innerParams, callback) =>
      @assertEqual params, innerParams
      confirmExpectation()

      callback(err, result)    
