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
