// Karma configuration

// Full hacks to get karma to build with coffee --bare=false
// Will be fixed in upcoming version of karma
var coffee = require('coffee-script'),
    old = coffee.compile.bind(coffee);

coffee.compile = function(content, options) {
  options.bare = false;
  return old(content, options);
};


// build ordered list of source files
var Snockets = require('snockets'),
    snockets = new Snockets();

var sourceFiles = snockets.scan('src/batman.coffee', {async: false}).getChain('src/batman.coffee'),
    testFiles = snockets.scan('tests/batman/tests.coffee', {async: false}).getChain('tests/batman/tests.coffee'),
    platformFiles = snockets.scan('src/platform/solo.coffee', {async: false}).getChain('src/platform/solo.coffee'),

    libFiles = [
      'tests/lib/json2.js',
      'tests/lib/jquery.js',
      'tests/lib/sinon.js'
    ],
    extraFiles = [
      'src/extras/batman.rails.coffee',
      'src/extras/batman.paginator.coffee',
      'src/extras/batman.i18n.coffee'
    ];


// base path, that will be used to resolve files and exclude
basePath = '';


// list of files / patterns to load in the browser
files = [QUNIT, QUNIT_ADAPTER, 'lib/es5-shim.js'].concat(sourceFiles,
                                                         platformFiles,
                                                         libFiles,
                                                         extraFiles,
                                                         testFiles);


// preprocessors
preprocessors = {
  '**/*.coffee' : 'coffee' ,
};


// test results reporter to use
// possible values: 'dots', 'progress', 'junit'
reporters = ['progress'];


// web server port
port = 9876;


// cli runner port
runnerPort = 9100;


// enable / disable colors in the output (reporters and logs)
colors = true;


// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;


// enable / disable watching file and executing tests whenever any file changes
autoWatch = true;


// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['Chrome'];


// If browser does not capture in given timeout [ms], kill it
captureTimeout = 60000;


// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;
