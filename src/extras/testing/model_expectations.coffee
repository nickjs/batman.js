Batman.ModelExpectations =
  expectCreate: (instance, options = {}) ->
    @addExpectation('expectCreate')
    QUnit.ok instance.isNew(), "Expected #{instance.constructor.name} to be new when saving"

    @stub instance, 'save', (callback) =>
      @completeExpectation('expectCreate')
      callback(options.error, options.response)

  expectUpdate: (instance, options = {}) ->
    @addExpectation('expectUpdate')
    QUnit.ok !instance.isNew(), "Expected #{instance.constructor.name} to exist when saving"

    @stub instance, 'save', (callback) =>
      @completeExpectation('expectUpdate')
      callback(options.error, options.response)

  expectLoad: (klass, options = {}) ->
    @addExpectation('expectLoad')

    @stub klass, 'load', (innerParams, callback) =>
      callback = innerParams if typeof innerParams in ['function', 'undefined']

      @assertEqual options.params, innerParams if options.params?
      @completeExpectation('expectLoad')

      callback(options.error, options.response)

  expectFind: (klass, options = {}) ->
    @addExpectation('expectFind')

    @stub klass, 'find', (innerParams, callback) =>
      callback = innerParams if typeof innerParams in ['function', 'undefined']

      @assertEqual options.params, innerParams if options.params?
      @completeExpectation('expectFind')

      callback(options.error, options.response)
