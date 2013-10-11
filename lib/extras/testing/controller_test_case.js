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
        this.assert(false, "exception was raised in view bindings: " + (e.toString()));
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
