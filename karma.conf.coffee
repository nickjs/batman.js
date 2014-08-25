module.exports = (config) ->
  config.set
    frameworks: ['qunit'],

    files: [
      # vendor
      'tests/lib/json2.js'
      'tests/lib/jquery.js'
      'tests/lib/sinon.js'
      'polyfills/es5-shim.js'
      'polyfills/es6-promises.js'

      # Batman & Extras
      'dist/batman.js'
      'dist/extras/batman.i18n.js'
      'dist/extras/batman.rails.js'
      'dist/extras/batman.paginator.js'
      'dist/batman.testing.js'
      # Batman.Request stubs
      'platform/testing.coffee'

      # test helpers
      'tests/batman/test_helper.coffee'
      'tests/batman/model/model_helper.coffee'
      'tests/batman/model/associations/polymorphic_association_helper.coffee'
      'tests/batman/storage_adapter/storage_adapter_helper.coffee'
      'tests/batman/storage_adapter/rest_storage_helper.coffee'
      'tests/batman/testing/test_case_helper.coffee'
      'tests/batman/view/view_helper.coffee'

      # tests
      'tests/batman/controller/*.coffee'
      'tests/batman/events/**/*.coffee'
      'tests/batman/extras/**/*.coffee'
      'tests/batman/model/**/*.coffee'
      'tests/batman/navigator/*.coffee'
      'tests/batman/object/**/*.coffee'
      'tests/batman/observable/**/*.coffee'
      'tests/batman/property/**/*.coffee'
      'tests/batman/routes/**/*.coffee'
      'tests/batman/set/**/*.coffee'
      'tests/batman/storage_adapter/**/*.coffee'
      'tests/batman/testing/**/*.coffee'
      'tests/batman/utilities/**/*.coffee'
      'tests/batman/view/*.coffee'
      'tests/batman/app_test.coffee'
      'tests/batman/data_test.coffee'
      'tests/batman/enumerable_test.coffee'
      'tests/batman/hash_test.coffee'
      'tests/batman/paginator_test.coffee'
      'tests/batman/namespace_test.coffee'
      'docs/docs.coffee'
      'docs/**/*.litcoffee'
    ]

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

    customLaunchers: {
      'PhantomJS_debug': {
        base: 'PhantomJS',
        flags: ['--remote-debugger-port=9000', '--remote-debugger-autorun=yes']
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
