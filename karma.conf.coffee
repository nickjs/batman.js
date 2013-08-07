Snockets = require('snockets')
snockets = new Snockets()

sourceFiles   = snockets.scan('src/batman.coffee', async: false).getChain('src/batman.coffee')
testFiles     = snockets.scan('tests/batman/tests.coffee', async: false).getChain('tests/batman/tests.coffee')
platformFiles = snockets.scan('src/platform/solo.coffee', async: false).getChain('src/platform/solo.coffee')

shimFiles = [
  'lib/es5-shim.js'
]

libFiles = [
  'tests/lib/json2.js',
  'tests/lib/jquery.js',
  'tests/lib/sinon.js'
]

extraFiles = [
  'src/extras/batman.rails.coffee',
  'src/extras/batman.paginator.coffee',
  'src/extras/batman.i18n.coffee'
]

module.exports = (config) ->
  config.set
    frameworks: ['qunit'],

    files: [].concat(
      shimFiles,
      sourceFiles,
      platformFiles,
      libFiles,
      extraFiles,
      testFiles
    )

    reporters: ['progress']

    autoWatch: true

    reportSlowerThan: 500

    coffeePreprocessor: {
      options: {
        bare: false
      }
    }

    preprocessors: {
      '**/*.coffee': ['coffee']
    }

    browsers: [
      'Chrome'
    ]

    plugins: [
      'karma-qunit',
      'karma-chrome-launcher',
      'karma-phantomjs-launcher',
      'karma-coffee-preprocessor'
    ]
