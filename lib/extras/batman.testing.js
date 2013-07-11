(function() {
  Batman.XhrMocking = {
    xhrSetup: function() {
      var testCase;
      testCase = this;
      this._requests = {};
      this._savedSend = Batman.Request.prototype.send;
      return Batman.Request.prototype.send = function(data) {
        var beforeResponse, mockedResponse, response, status;
        data || (data = this.get('data'));
        this.fire('loading');
        mockedResponse = testCase.fetchMockedResponse(this.get('url'), this.get('method'));
        if (!mockedResponse) {
          return;
        }
        status = mockedResponse.status, response = mockedResponse.response, beforeResponse = mockedResponse.beforeResponse;
        this.mixin({
          status: status,
          response: JSON.stringify(response)
        });
        if (typeof beforeResponse === "function") {
          beforeResponse(this);
        }
        if (status < 400) {
          this.fire('success', response);
        } else {
          this.fire('error', {
            response: response,
            status: status,
            request: this
          });
        }
        return this.fire('loaded');
      };
    },
    xhrTeardown: function() {
      return Batman.Request.prototype.send = this._savedSend;
    },
    fetchMockedResponse: function(url, method) {
      var expectationCallback, id;
      id = "" + method + "::" + url;
      expectationCallback = this._requests[id];
      if (!expectationCallback) {
        return;
      }
      delete this._requests[id];
      return expectationCallback();
    },
    setMockedResponse: function(url, method, cb) {
      return this._requests["" + method + "::" + url] = cb;
    },
    assertGET: function(url, params) {
      return this._assertXHR('GET', url, params);
    },
    assertPOST: function(url, params) {
      return this._assertXHR('POST', url, params);
    },
    assertPUT: function(url, params) {
      return this._assertXHR('PUT', url, params);
    },
    assertDELETE: function(url, params) {
      return this._assertXHR('DELETE', url, params);
    },
    _assertXHR: function(method, url, params) {
      var id,
        _this = this;
      id = "" + method + " to " + url;
      this.addExpectation(id);
      return this.setMockedResponse(url, method, function() {
        _this.completeExpectation(id);
        params || (params = {});
        params.status || (params.status = 200);
        params.response || (params.response = {});
        return params;
      });
    }
  };

}).call(this);

(function() {
  Batman.ModelExpectations = {
    expectCreate: function(instance, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectCreate');
      this.assert(instance.isNew(), "Expected " + instance.constructor.name + " to be new when saving");
      return this.stub(instance, 'save', function(callback) {
        _this.completeExpectation('expectCreate');
        return callback(options.error, options.response);
      });
    },
    expectUpdate: function(instance, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectUpdate');
      this.assert(!instance.isNew(), "Expected " + instance.constructor.name + " to exist when saving");
      return this.stub(instance, 'save', function(callback) {
        _this.completeExpectation('expectUpdate');
        return callback(options.error, options.response);
      });
    },
    expectLoad: function(klass, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectLoad');
      return this.stub(klass, 'load', function(innerParams, callback) {
        var _ref;
        if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
          callback = innerParams;
        }
        if (options.params != null) {
          _this.assertEqual(options.params, innerParams);
        }
        _this.completeExpectation('expectLoad');
        return callback(options.error, options.response);
      });
    },
    expectFind: function(klass, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectFind');
      return this.stub(klass, 'find', function(innerParams, callback) {
        var _ref;
        if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
          callback = innerParams;
        }
        if (options.params != null) {
          _this.assertEqual(options.params, innerParams);
        }
        _this.completeExpectation('expectFind');
        return callback(options.error, options.response);
      });
    }
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Batman.TestCase = (function(_super) {
    __extends(TestCase, _super);

    TestCase.mixin(Batman.XhrMocking);

    TestCase.Test = (function() {
      function Test(name, expected, testFunction) {
        this.name = name;
        this.expected = expected;
        this.testFunction = testFunction;
      }

      Test.prototype.run = function(testCase, callback) {
        var wrappedTest,
          _this = this;
        wrappedTest = function() {
          testCase.xhrSetup();
          testCase.clearExpectations();
          sinon.test(_this.testFunction).call(testCase);
          testCase.verifyExpectations();
          testCase.xhrTeardown();
          return typeof callback === "function" ? callback() : void 0;
        };
        return QUnit.test(this.name, this.expected, wrappedTest);
      };

      return Test;

    })();

    TestCase.test = function(name, expected, testFunction) {
      if (typeof expected === 'function') {
        testFunction = expected;
        expected = null;
      }
      this.tests || (this.tests = []);
      return this.tests.push(new this.Test(name, expected, testFunction));
    };

    function TestCase() {
      this._expectations = {};
    }

    TestCase.prototype.runTests = function() {
      var desc, test, _ref, _results;
      QUnit.module(this.constructor.name, {
        setup: this.setup.bind(this),
        teardown: this.teardown.bind(this)
      });
      _ref = this.constructor.tests;
      _results = [];
      for (desc in _ref) {
        test = _ref[desc];
        _results.push(test.run(this));
      }
      return _results;
    };

    TestCase.prototype.setup = function() {};

    TestCase.prototype.teardown = function() {};

    TestCase.prototype["continue"] = function() {
      return QUnit.start();
    };

    TestCase.prototype.wait = function() {
      return QUnit.stop();
    };

    TestCase.prototype.assert = function(assertion, message) {
      if (message == null) {
        message = 'was not true';
      }
      return QUnit.ok(assertion, message);
    };

    TestCase.prototype.assertEqual = function(expected, actual, message) {
      return QUnit.deepEqual(actual, expected, message);
    };

    TestCase.prototype.assertNotEqual = function(expected, actual, message) {
      return QUnit.notDeepEqual(actual, expected, message);
    };

    TestCase.prototype.assertMatch = function(expected, actual, message) {
      return QUnit.ok(expected.test(actual), message);
    };

    TestCase.prototype.assertNoMatch = function(expected, actual, message) {
      return QUnit.ok(!expected.test(actual), message);
    };

    TestCase.prototype.assertDifference = function(expressions, difference, message, callback) {
      var before, e, error, i, _i, _len, _results;
      if (difference == null) {
        difference = 1;
      }
      if (Batman.typeOf(expressions) !== 'Array') {
        expressions = [expressions];
      }
      if (arguments.length === 2) {
        callback = difference;
        difference = 1;
      } else if (arguments.length === 3) {
        callback = message;
        message = null;
      }
      before = expressions.map(function(expression) {
        return eval(expression);
      });
      callback();
      _results = [];
      for (i = _i = 0, _len = expressions.length; _i < _len; i = ++_i) {
        e = expressions[i];
        error = "" + e + " didn't change by " + difference;
        if (message) {
          error = "" + message + ".\n" + error;
        }
        _results.push(this.assertEqual(before[i] + difference, eval(e), error));
      }
      return _results;
    };

    TestCase.prototype.assertNoDifference = function(expressions, message, callback) {
      if (arguments.length === 2) {
        callback = message;
        message = null;
      }
      return this.assertDifference(expressions, 0, message, callback);
    };

    TestCase.prototype.assertRaises = function(expected, callback, message) {
      return QUnit.raises(callback, expected, message);
    };

    TestCase.prototype.addExpectation = function(name) {
      if (this._expectations[name]) {
        return this._expectations[name]++;
      } else {
        return this._expectations[name] = 1;
      }
    };

    TestCase.prototype.completeExpectation = function(name) {
      if (!this._expectations[name]) {
        return;
      }
      QUnit.ok(true, "Completed " + name);
      if (this._expectations[name] === 1) {
        return delete this._expectations[name];
      } else {
        return this._expectations[name]--;
      }
    };

    TestCase.prototype.verifyExpectations = function() {
      var count, key, _ref, _results;
      _ref = this._expectations;
      _results = [];
      for (key in _ref) {
        count = _ref[key];
        _results.push(QUnit.ok(false, "Expectation " + key + " did not callback " + count + " time(s)"));
      }
      return _results;
    };

    TestCase.prototype.clearExpectations = function() {
      return this._expectations = {};
    };

    return TestCase;

  })(Batman.Object);

  (function() {
    var originalPush, parseActual, parseExpected;
    originalPush = QUnit.push;
    parseExpected = function(exp) {
      return "\x1B[32m" + (QUnit.jsDump.parse(exp)) + "\x1B[39m";
    };
    parseActual = function(act) {
      return "\x1B[31m" + (QUnit.jsDump.parse(act)) + "\x1B[39m";
    };
    return QUnit.push = function(result, actual, expected, message) {
      message || (message = "" + (parseExpected(expected)) + " expected but was " + (parseActual(actual)));
      return originalPush.call(QUnit, result, actual, expected, message);
    };
  })();

}).call(this);

(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Batman.ModelTestCase = (function(_super) {
    __extends(ModelTestCase, _super);

    function ModelTestCase() {
      _ref = ModelTestCase.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ModelTestCase.mixin(Batman.ModelExpectations);

    ModelTestCase.prototype.assertValid = function(model, message) {
      var _this = this;
      if (message == null) {
        message = "" + model + " expected to be valid";
      }
      return model.validate(function(_, err) {
        return _this.assert(err.length === 0, message);
      });
    };

    ModelTestCase.prototype.assertNotValid = function(model, message) {
      var _this = this;
      if (message == null) {
        message = "" + model + " expected to be not valid";
      }
      return model.validate(function(_, err) {
        return _this.assert(err.length > 0, message);
      });
    };

    ModelTestCase.prototype.assertDecoders = function() {
      var decoders, keys, modelClass;
      modelClass = arguments[0], keys = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      decoders = [];
      modelClass.prototype._batman.get("encoders").forEach(function(key, encoder) {
        if (encoder.decode) {
          return decoders.push(key);
        }
      });
      return this.assertEqual(keys.sort(), decoders.sort());
    };

    ModelTestCase.prototype.assertEncoders = function() {
      var encoders, keys, modelClass;
      modelClass = arguments[0], keys = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      encoders = [];
      modelClass.prototype._batman.get("encoders").forEach(function(key, encoder) {
        if (encoder.encode) {
          return encoders.push(key);
        }
      });
      return this.assertEqual(keys.sort(), encoders.sort());
    };

    ModelTestCase.prototype.assertEncoded = function(model, key, expected) {
      var value;
      value = model.toJSON()[key];
      if (typeof expected === 'function') {
        return this.assert(expected(value));
      } else {
        return this.assertEqual(expected, value);
      }
    };

    return ModelTestCase;

  })(Batman.TestCase);

}).call(this);

(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Batman.ControllerTestCase = (function(_super) {
    __extends(ControllerTestCase, _super);

    function ControllerTestCase() {
      _ref = ControllerTestCase.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ControllerTestCase.mixin(Batman.ModelExpectations);

    return ControllerTestCase;

  })(Batman.TestCase);

}).call(this);

(function() {


}).call(this);
