(function() {
  Batman.TestCase = (function() {
    function TestCase() {}

    TestCase.Test = (function() {
      function Test(name, expected, testFunction) {
        this.name = name;
        this.expected = expected;
        this.testFunction = testFunction;
      }

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

    TestCase.prototype.runTests = function(context) {
      var desc, test, _ref, _results;
      QUnit.module.call(context, this.constructor.name, {
        setup: this.setup.bind(this),
        teardown: this.teardown.bind(this)
      });
      _ref = this.constructor.tests;
      _results = [];
      for (desc in _ref) {
        test = _ref[desc];
        _results.push(QUnit.test(test.name, test.expected, sinon.test(test.testFunction).bind(this)));
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

    return TestCase;

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
