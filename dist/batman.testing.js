/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "dist/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ({

/***/ 0:
/***/ function(module, exports, __webpack_require__) {

	Batman.extend(Batman, {
	  TestCase: __webpack_require__(1),
	  ModelTestCase: __webpack_require__(2),
	  ControllerTestCase: __webpack_require__(3)
	});


/***/ },

/***/ 1:
/***/ function(module, exports, __webpack_require__) {

	var TestCase,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	module.exports = TestCase = (function(_super) {
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
	    this._refutations = {};
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

	  TestCase.prototype.refute = function(assertion, message) {
	    if (message == null) {
	      message = 'was not false';
	    }
	    return QUnit.ok(!assertion, message);
	  };

	  TestCase.prototype.assertEqual = function(expected, actual, message) {
	    return QUnit.ok(this._areEquivalent(expected, actual), message || ("Expected: " + expected + " \nGot: " + actual));
	  };

	  TestCase.prototype.assertNotEqual = function(expected, actual, message) {
	    return QUnit.ok(!this._areEquivalent(expected, actual), message || ("Value not expected to match: " + expected));
	  };

	  TestCase.prototype.assertMatch = function(expected, actual, message) {
	    return QUnit.ok(expected.test(actual), message || ("Expected: " + expected + " \nGot: " + actual));
	  };

	  TestCase.prototype.assertNoMatch = function(expected, actual, message) {
	    return QUnit.ok(!expected.test(actual), message || ("Value not expected to match: " + expected));
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
	    return QUnit.throws(callback, expected, message);
	  };

	  TestCase.prototype.stubAccessor = function(object, keypath, fn) {
	    var stub;
	    stub = sinon.sandbox.stub(object.property(keypath), 'getValue', fn);
	    object.property(keypath).refresh();
	    return stub;
	  };

	  TestCase.prototype.addExpectation = function(name) {
	    if (this._expectations[name]) {
	      return this._expectations[name]++;
	    } else {
	      return this._expectations[name] = 1;
	    }
	  };

	  TestCase.prototype.addRefutation = function(name) {
	    return this._refutations[name] = 0;
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

	  TestCase.prototype.completeRefutation = function(name) {
	    return this._refutations[name] = 1;
	  };

	  TestCase.prototype.verifyExpectations = function() {
	    var count, key, occurred, _ref, _ref1, _results;
	    _ref = this._expectations;
	    for (key in _ref) {
	      count = _ref[key];
	      QUnit.ok(false, "Expectation " + key + " did not callback " + count + " time(s)");
	    }
	    _ref1 = this._refutations;
	    _results = [];
	    for (key in _ref1) {
	      occurred = _ref1[key];
	      if (occurred) {
	        _results.push(QUnit.ok(false, "Refutation " + key + " occurred"));
	      } else {
	        _results.push(QUnit.ok(true, "Refutation " + key + " did not occur"));
	      }
	    }
	    return _results;
	  };

	  TestCase.prototype.clearExpectations = function() {
	    this._expectations = {};
	    return this._refutations = {};
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

	  TestCase.prototype.refuteGET = function(url) {
	    return this._refuteXHR('GET', url);
	  };

	  TestCase.prototype.refutePOST = function(url) {
	    return this._refuteXHR('POST', url);
	  };

	  TestCase.prototype.refutePUT = function(url) {
	    return this._refuteXHR('PUT', url);
	  };

	  TestCase.prototype.refuteDELETE = function(url) {
	    return this._refuteXHR('DELETE', url);
	  };

	  TestCase.prototype._assertXHR = function(method, url, params) {
	    var id;
	    id = "" + method + " to " + url;
	    this.addExpectation(id);
	    return Batman.Request.addMockedResponse(method, url, (function(_this) {
	      return function() {
	        _this.completeExpectation(id);
	        params || (params = {});
	        params.status || (params.status = 200);
	        params.response || (params.response = {});
	        return params;
	      };
	    })(this));
	  };

	  TestCase.prototype._refuteXHR = function(method, url, params) {
	    var id;
	    id = "" + method + " to " + url;
	    this.addRefutation(id);
	    return Batman.Request.addMockedResponse(method, url, (function(_this) {
	      return function() {
	        _this.completeRefutation(id);
	        return {};
	      };
	    })(this));
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


/***/ },

/***/ 2:
/***/ function(module, exports, __webpack_require__) {

	var ModelExpectations, ModelTestCase, TestCase,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  __slice = [].slice;

	TestCase = __webpack_require__(1);

	ModelExpectations = __webpack_require__(16);

	module.exports = ModelTestCase = (function(_super) {
	  __extends(ModelTestCase, _super);

	  function ModelTestCase() {
	    return ModelTestCase.__super__.constructor.apply(this, arguments);
	  }

	  ModelTestCase.mixin(ModelExpectations);

	  ModelTestCase.prototype.assertValid = function(model, message) {
	    if (message == null) {
	      message = "" + model + " expected to be valid";
	    }
	    return model.validate((function(_this) {
	      return function(_, err) {
	        return _this.assert(err.length === 0, message);
	      };
	    })(this));
	  };

	  ModelTestCase.prototype.assertNotValid = function(model, message) {
	    if (message == null) {
	      message = "" + model + " expected to be not valid";
	    }
	    return model.validate((function(_this) {
	      return function(_, err) {
	        return _this.assert(err.length > 0, message);
	      };
	    })(this));
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

	})(TestCase);


/***/ },

/***/ 3:
/***/ function(module, exports, __webpack_require__) {

	var ControllerTestCase, ModelExpectations, TestCase,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	TestCase = __webpack_require__(1);

	ModelExpectations = __webpack_require__(16);

	module.exports = ControllerTestCase = (function(_super) {
	  __extends(ControllerTestCase, _super);

	  function ControllerTestCase() {
	    return ControllerTestCase.__super__.constructor.apply(this, arguments);
	  }

	  ControllerTestCase.mixin(ModelExpectations);

	  ControllerTestCase.prototype.dispatch = function(action, params) {
	    var actionRoutes, controllerName, currentView, div, e, namedRoute, routeMap, _i, _len, _ref;
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
	    actionRoutes = routeMap.childrenByOrder.filter((function(_this) {
	      return function(route) {
	        return route.controller === controllerName && route.action === action;
	      };
	    })(this));
	    if (actionRoutes.length === 0) {
	      this.assert(false, "Route doesn't exist for action");
	      return;
	    }
	    if (actionRoutes[0].namedArguments.length > 0) {
	      this.assert(params.params, 'params are required for action');
	    }
	    _ref = actionRoutes[0].namedArguments;
	    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
	      namedRoute = _ref[_i];
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

	})(TestCase);


/***/ },

/***/ 16:
/***/ function(module, exports, __webpack_require__) {

	var ModelExpectations;

	module.exports = ModelExpectations = {
	  expectCreate: function(instance, options) {
	    if (options == null) {
	      options = {};
	    }
	    this.addExpectation('expectCreate');
	    this.assert(instance.isNew(), "Expected " + instance.constructor.name + " to be new when saving");
	    return this.stub(instance, 'save', (function(_this) {
	      return function(callback) {
	        var _ref;
	        _this.completeExpectation('expectCreate');
	        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
	      };
	    })(this));
	  },
	  expectUpdate: function(instance, options) {
	    if (options == null) {
	      options = {};
	    }
	    this.addExpectation('expectUpdate');
	    this.assert(!instance.isNew(), "Expected " + instance.constructor.name + " to exist when saving");
	    return this.stub(instance, 'save', (function(_this) {
	      return function(callback) {
	        var _ref;
	        _this.completeExpectation('expectUpdate');
	        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
	      };
	    })(this));
	  },
	  expectDestroy: function(instance, options) {
	    if (options == null) {
	      options = {};
	    }
	    this.addExpectation('expectDestroy');
	    return this.stub(instance, 'destroy', (function(_this) {
	      return function(callback) {
	        var _ref;
	        _this.completeExpectation('expectDestroy');
	        return callback(options.error, (_ref = options.response) != null ? _ref : instance);
	      };
	    })(this));
	  },
	  expectLoad: function(klass, options) {
	    if (options == null) {
	      options = {};
	    }
	    this.addExpectation('expectLoad');
	    return this.stub(klass, 'load', (function(_this) {
	      return function(innerParams, callback) {
	        var _ref;
	        if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
	          callback = innerParams;
	        }
	        if (options.params != null) {
	          _this.assertEqual(options.params, innerParams);
	        }
	        _this.completeExpectation('expectLoad');
	        return typeof callback === "function" ? callback(options.error, options.response) : void 0;
	      };
	    })(this));
	  },
	  expectFind: function(klass, options) {
	    if (options == null) {
	      options = {};
	    }
	    this.addExpectation('expectFind');
	    return this.stub(klass, 'find', (function(_this) {
	      return function(innerParams, callback) {
	        var _ref;
	        if ((_ref = typeof innerParams) === 'function' || _ref === 'undefined') {
	          callback = innerParams;
	        }
	        if (options.params != null) {
	          _this.assertEqual(options.params, innerParams);
	        }
	        _this.completeExpectation('expectFind');
	        return typeof callback === "function" ? callback(options.error, options.response) : void 0;
	      };
	    })(this));
	  }
	};


/***/ }

/******/ })