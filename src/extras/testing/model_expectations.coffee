Batman.ModelExpectations =
  expectCreate: (model, params, err, result) ->
    @mock(model, 'save').withArgs(params).once()

  expectSave: (model, params, err, result) ->
    @mock(model, 'save').withArgs(params).once()

  expectLoad: (class, params, err, result) ->
    @mock(class, 'load').withArgs(params).once()

  expectFind: (class, params, err, result) ->
    @mock(class, 'find').withArgs(params).once()
