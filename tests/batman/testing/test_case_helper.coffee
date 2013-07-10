exports = window.testCaseHelper = {}

exports.runTestCase = (testCase, testFn, cb) ->
  args = []
  sinon.stub(QUnit, 'ok', -> args.push(arguments))

  validate = ->
    testCase.verifyExpectations()
    sandbox.restore()
    QUnit.ok.restore()
    cb(args.length, args.map((arg) -> arg[0]))

  sandbox = sinon.sandbox.create(injectInto: testCase, properties: ['stub', 'mock', 'spy'])
  testFn(validate)
