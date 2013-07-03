(function() {
  var coffee, glob, path, qqunit,
    __hasProp = {}.hasOwnProperty;

  glob = require('glob');

  path = require('path');

  coffee = require('coffee-script-mapped');

  qqunit = require('qqunit');

  qqunit.Environment.jsdom.jQueryify(window, path.join(__dirname, 'lib', 'jquery.js'), function(window, jQuery) {
    var Helper, e, k, tests, v;
    global.jQuery = jQuery;
    try {
      require('./lib/query_selector_polyfill');
      Helper = require('./batman/test_helper');
      for (k in Helper) {
        if (!__hasProp.call(Helper, k)) continue;
        v = Helper[k];
        global[k] = v;
      }
      global.Batman = require('../lib/dist/batman.node');
      require('../lib/extras/batman.testing');
      Batman.Request.prototype.getModule = function() {
        return {
          request: function() {
            throw new Error("Can't send requests during tests!");
          }
        };
      };
      tests = glob.sync("" + __dirname + "/batman/**/*_test.coffee").map(function(test) {
        return path.resolve(process.cwd(), test);
      });
    } catch (_error) {
      e = _error;
      console.error(e.stack);
      process.exit(1);
    }
    console.log("Running Batman test suite. " + tests.length + " files required.");
    return qqunit.Runner.run(tests, function(stats) {
      return process.exit(stats.failed);
    });
  });

}).call(this);
