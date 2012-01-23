(function() {
  var coffee, delayCount, exportHelpers, fs, glob, jqueryPath, oldErrorHandler, path, percolate, qqunit, testDir,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  coffee = require('coffee-script');

  qqunit = require('qqunit');

  oldErrorHandler = window.onerror;

  delete window.onerror;

  percolate = require('percolate');

  testDir = path.resolve(__dirname, '..', 'tests');

  jqueryPath = path.join(testDir, 'lib', 'jquery.js');

  delayCount = 0;

  global.delay = function(time, fn) {
    var defer, _ref;
    if (fn == null) {
      _ref = [15, time], time = _ref[0], fn = _ref[1];
    }
    delayCount++;
    defer = function() {
      fn();
      if (--delayCount === 0) {
        return QUnit.start();
      }
    };
    return setTimeout(defer, time);
  };

  exportHelpers = function(object) {
    var k, v, _results;
    _results = [];
    for (k in object) {
      if (!__hasProp.call(object, k)) continue;
      v = object[k];
      _results.push(global[k] = v);
    }
    return _results;
  };

  qqunit.Environment.jsdom.jQueryify(window, jqueryPath, function(window, jQuery) {
    var docs;
    try {
      global.jQuery = jQuery;
      exportHelpers(require("" + testDir + "/batman/test_helper"));
      global.Batman = require('../src/batman.node');
      Batman.exportGlobals(global);
      Batman.Request.prototype.send = function() {
        throw new Error("Can't send requests during tests!");
      };
      exportHelpers(require("" + testDir + "/batman/model/model_helper"));
      TestStorageAdapter.autoCreate = false;
      docs = glob.sync("" + __dirname + "/**/*.percolate").map(function(doc) {
        return path.resolve(process.cwd(), doc);
      });
      console.log("Running Batman doc suite.");
      if (process.argv[2] === '--test-only') {
        return percolate.test.apply(percolate, [__dirname].concat(__slice.call(docs), [function(error, stats) {
          return process.exit(stats.failed);
        }]));
      } else {
        return percolate.generate.apply(percolate, [__dirname].concat(__slice.call(docs), [function(error, stats, output) {
          if (error) {
            throw error;
          }
          if (!(stats.failed > 0)) {
            fs.writeFileSync(path.join(__dirname, 'batman.html'), output);
            console.log("Docs written.");
          }
          return process.exit(stats.failed);
        }]));
      }
    } catch (e) {
      console.error(e.stack);
      return process.exit(1);
    }
  });

}).call(this);
