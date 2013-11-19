Snockets = require('snockets')
glob     = require('glob')
snockets = new Snockets()

files = {}

files.source   = snockets.scan('src/batman.coffee', async: false).getChain('src/batman.coffee')
files.platform = snockets.scan('src/platform/testing.coffee', async: false).getChain('src/platform/testing.coffee')
files.helpers  = snockets.scan('tests/batman/test_requires.coffee', async: false).getChain('tests/batman/test_requires.coffee')
files.tests    = snockets.scan('tests/batman/tests.coffee', async: false).getChain('tests/batman/tests.coffee')
files.docs     = snockets.scan('docs/docs.coffee', async: false).getChain('docs/docs.coffee')

files.lib = [
  'lib/polyfills/es5-shim.js'
  'tests/lib/json2.js',
  'tests/lib/jquery.js',
  'tests/lib/sinon.js'
]

files.extra = [
  'src/extras/batman.rails.coffee',
  'src/extras/batman.paginator.coffee',
  'src/extras/batman.i18n.coffee'
]

main = [].concat(
  files.lib,
  files.source,
  files.platform,
  files.extra,
  files.helpers
)

module.exports = (config) ->
  config.set
    frameworks: ['qunit'],

    files: do ->
      if pattern = process.env.JS_TEST
        return main.concat(glob.sync(pattern))
      return main.concat(files.tests, files.docs)

    reporters: ['dots']

    autoWatch: true

    reportSlowerThan: 500

    coffeePreprocessor: {
      options: {
        bare: false
      }
    }

    customPreprocessors: {
      literate_coffee: {
        base: 'coffee',
        options: {
          bare: true,
          literate: true
        }
      }
    }

    preprocessors: {
      '**/*.coffee': ['coffee'],
      '**/*.litcoffee': ['literate_coffee']
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
