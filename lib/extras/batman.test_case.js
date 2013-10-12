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
        var _ref;
        _this.completeExpectation('expectCreate');
        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
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
        var _ref;
        _this.completeExpectation('expectUpdate');
        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
      });
    },
    expectDestroy: function(instance, options) {
      var _this = this;
      if (options == null) {
        options = {};
      }
      this.addExpectation('expectDestroy');
      return this.stub(instance, 'destroy', function(callback) {
        var _ref;
        _this.completeExpectation('expectDestroy');
        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
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
        return typeof callback === "function" ? callback(options.error, options.response) : void 0;
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
        return typeof callback === "function" ? callback(options.error, options.response) : void 0;
      });
    }
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Batman.TestCase = (function(_super) {
    __extends(TestCase, _super);

    TestCase.Test = (function() {
      function Test(name, expected, testFunction) {
        this.name = name;
        this.expected = expected;
        this.testFunction = testFunction;
      }

      Test.prototype.run = function(testCase) {
        var wrappedTest;
        wrappedTest = sinon.test(this.testFunction).bind(testCase);
        wrappedTest = testCase.expectationsWrapper(wrappedTest);
        wrappedTest = testCase.xhrWrapper(wrappedTest);
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
        setup: this.xhrWrapper(this.setup.bind(this)),
        teardown: this.xhrWrapper(this.teardown.bind(this))
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
      return QUnit.ok(this._areEquivalent(expected, actual), message);
    };

    TestCase.prototype.assertNotEqual = function(expected, actual, message) {
      return QUnit.ok(!this._areEquivalent(expected, actual), message);
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

    TestCase.prototype.stubAccessor = function(object, keypath, fn) {
      return sinon.sandbox.stub(object.property(keypath), 'getValue', fn);
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

    TestCase.prototype.expectationsWrapper = function(fn) {
      var testCase;
      testCase = this;
      return function() {
        var results;
        testCase.clearExpectations();
        results = fn.apply(this, arguments);
        testCase.verifyExpectations();
        return results;
      };
    };

    TestCase.prototype.xhrWrapper = function(fn) {
      return function() {
        Batman.Request.setupMockedResponse();
        return fn.apply(this, arguments);
      };
    };

    TestCase.prototype.assertGET = function(url, params) {
      return this._assertXHR('GET', url, params);
    };

    TestCase.prototype.assertPOST = function(url, params) {
      return this._assertXHR('POST', url, params);
    };

    TestCase.prototype.assertPUT = function(url, params) {
      return this._assertXHR('PUT', url, params);
    };

    TestCase.prototype.assertDELETE = function(url, params) {
      return this._assertXHR('DELETE', url, params);
    };

    TestCase.prototype._assertXHR = function(method, url, params) {
      var id,
        _this = this;
      id = "" + method + " to " + url;
      this.addExpectation(id);
      return Batman.Request.addMockedResponse(method, url, function() {
        _this.completeExpectation(id);
        params || (params = {});
        params.status || (params.status = 200);
        params.response || (params.response = {});
        return params;
      });
    };

    TestCase.prototype._unwrapStringOrNumber = function(obj) {
      if (obj instanceof Number || obj instanceof String) {
        return obj.valueOf();
      }
      return obj;
    };

    TestCase.prototype._areEquivalent = function(a, b) {
      var newA, newB, prop, tmp;
      a = this._unwrapStringOrNumber(a);
      b = this._unwrapStringOrNumber(b);
      if (a === b) {
        return true;
      }
      if (a === null || b === null || typeof a !== typeof b) {
        return false;
      }
      if (a instanceof Date) {
        return b instanceof Date && a.valueOf() === b.valueOf();
      }
      if (typeof a !== "object") {
        return a === b;
      }
      newA = a.areEquivalent_Eq_91_2_34 === void 0;
      newB = b.areEquivalent_Eq_91_2_34 === void 0;
      try {
        if (newA) {
          a.areEquivalent_Eq_91_2_34 = [];
        } else if (a.areEquivalent_Eq_91_2_34.some(function(other) {
          return other === b;
        })) {
          return true;
        }
        if (newB) {
          b.areEquivalent_Eq_91_2_34 = [];
        } else if (b.areEquivalent_Eq_91_2_34.some(function(other) {
          return other === a;
        })) {
          return true;
        }
        a.areEquivalent_Eq_91_2_34.push(b);
        b.areEquivalent_Eq_91_2_34.push(a);
        tmp = {};
        for (prop in a) {
          if (prop !== "areEquivalent_Eq_91_2_34") {
            tmp[prop] = null;
          }
        }
        for (prop in b) {
          if (prop !== "areEquivalent_Eq_91_2_34") {
            tmp[prop] = null;
          }
        }
        for (prop in tmp) {
          if (!this._areEquivalent(a[prop], b[prop])) {
            return false;
          }
        }
        return true;
      } finally {
        if (newA) {
          delete a.areEquivalent_Eq_91_2_34;
        }
        if (newB) {
          delete b.areEquivalent_Eq_91_2_34;
        }
      }
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

    ControllerTestCase.prototype.dispatch = function(action, params) {
      var actionRoutes, controllerName, currentView, div, e, namedRoute, routeMap, _i, _len, _ref1,
        _this = this;
      if (params == null) {
        params = {};
      }
      this.controllerClass || (this.controllerClass = Batman.currentApp[this.constructor.name.replace(/Test/, '')]);
      if (!this.controllerClass) {
        throw new Error("Unable to deduce controller class name from test class. Please set @controllerClass if not conventional");
      }
      this.controller = params.controller || new this.controllerClass;
      controllerName = Batman.helpers.camelize(this.controllerClass.name.replace(/Controller/, ''), true);
      routeMap = Batman.currentApp.get('routes.routeMap');
      actionRoutes = routeMap.childrenByOrder.filter(function(route) {
        return route.controller === controllerName && route.action === action;
      });
      if (actionRoutes.length === 0) {
        this.assert(false, "Route doesn't exist for action");
        return;
      }
      if (actionRoutes[0].namedArguments.length > 0) {
        this.assert(params.params, 'params are required for action');
      }
      _ref1 = actionRoutes[0].namedArguments;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        namedRoute = _ref1[_i];
        this.assert(namedRoute in params.params, 'named argument mismatch');
      }
      this.assertEqual('function', typeof this.controller[action], "Action: " + action + " doesn't exist!");
      try {
        this.controller.dispatch(action, params.params);
        currentView = this.controller.get('currentView');
        this.assert(currentView.get('html'), "No HTML for view");
        div = document.createElement('div');
        document.body.appendChild(div);
        currentView.get('node');
        currentView.addToParentNode(div);
        currentView.propagateToSubviews('viewWillAppear');
        currentView.initializeBindings();
        currentView.propagateToSubviews('isInDOM', true);
        currentView.propagateToSubviews('viewDidAppear');
      } catch (_error) {
        e = _error;
        this.assert(false, "exception was raised in view bindings: " + e.stack);
      } finally {
        if (div != null) {
          document.body.removeChild(div);
        }
      }
      return null;
    };

    return ControllerTestCase;

  })(Batman.TestCase);

}).call(this);

(function() {


}).call(this);
