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
