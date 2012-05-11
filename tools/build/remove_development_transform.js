(function() {
  var DEVELOPER_NAMESPACES, MAP, REMOVE_NODE, deepEqual, isArguments, isUndefinedOrNull, objEquiv, uglify;

  uglify = require('uglify-js');

  MAP = uglify.uglify.MAP;

  REMOVE_NODE = {
    remove: true
  };

  DEVELOPER_NAMESPACES = ['developer', ['name', 'developer'], ['dot', ['name', 'Batman'], 'developer']];

  isUndefinedOrNull = function(value) {
    return value === null || value === undefined;
  };

  isArguments = function(object) {
    return Object.prototype.toString.call(object) === "[object Arguments]";
  };

  deepEqual = function(actual, expected) {
    if (actual === expected) {
      return true;
    } else if (actual instanceof Date && expected instanceof Date) {
      return actual.getTime() === expected.getTime();
    } else if (actual instanceof RegExp && expected instanceof RegExp) {
      return actual.source === expected.source && actual.global === expected.global && actual.ignoreCase === expected.ignoreCase && actual.multiline === expected.multiline;
    } else if (typeof actual !== "object" && typeof expected !== "object") {
      return actual === expected;
    } else {
      return objEquiv(actual, expected);
    }
  };

  objEquiv = function(a, b) {
    var i, ka, kb, key;
    if (isUndefinedOrNull(a) || isUndefinedOrNull(b)) {
      return false;
    }
    if (a.prototype !== b.prototype) {
      return false;
    }
    if (isArguments(a)) {
      if (!isArguments(b)) {
        return false;
      }
      a = pSlice.call(a);
      b = pSlice.call(b);
      return deepEqual(a, b);
    }
    try {
      ka = Object.keys(a);
      kb = Object.keys(b);
      key = void 0;
      i = void 0;
    } catch (e) {
      return false;
    }
    if (ka.length !== kb.length) {
      return false;
    }
    ka.sort();
    kb.sort();
    i = ka.length - 1;
    while (i >= 0) {
      if (ka[i] !== kb[i]) {
        return false;
      }
      i--;
    }
    i = ka.length - 1;
    while (i >= 0) {
      key = ka[i];
      if (!deepEqual(a[key], b[key])) {
        return false;
      }
      i--;
    }
    return true;
  };

  exports.removeDevelopment = function(ast) {
    var clean, cleanBlock, cleanLambdaBody, cleanupWalker, isDeveloperNamespace, keepNode, removalWalker;
    removalWalker = uglify.uglify.ast_walker();
    cleanupWalker = uglify.uglify.ast_walker();
    isDeveloperNamespace = function(x) {
      return DEVELOPER_NAMESPACES.some(function(y) {
        return deepEqual(x, y);
      });
    };
    ast = removalWalker.with_walkers({
      call: function(expr, args) {
        var fn, op, upon;
        op = expr[0], upon = expr[1], fn = expr[2];
        if (isDeveloperNamespace(upon)) {
          return REMOVE_NODE;
        }
        return ['call', removalWalker.walk(expr), MAP(args, removalWalker.walk)];
      },
      assign: function(_, lvalue, rvalue) {
        var op, upon;
        if (rvalue.length) {
          if (isDeveloperNamespace(rvalue)) {
            return REMOVE_NODE;
          }
        }
        if (lvalue.length) {
          if (isDeveloperNamespace(lvalue)) {
            return REMOVE_NODE;
          }
          op = lvalue[0], upon = lvalue[1];
          if (isDeveloperNamespace(upon)) {
            return REMOVE_NODE;
          }
        }
        return ['assign', _, removalWalker.walk(lvalue), removalWalker.walk(rvalue)];
      },
      "var": function(defs) {
        defs = defs.filter(function(_arg) {
          var name, val, _ref;
          name = _arg[0], val = _arg[1];
          if (isDeveloperNamespace(name) || isDeveloperNamespace(val) || (val && ((_ref = val[0]) === 'dot' || _ref === 'sub') && val[1].length && isDeveloperNamespace(val[1]))) {
            return false;
          } else {
            return true;
          }
        });
        return ["var", defs];
      }
    }, function() {
      return removalWalker.walk(ast);
    });
    keepNode = function(node) {
      switch (node[0]) {
        case "stat":
        case "assign":
          return node[node.length - 1] !== REMOVE_NODE;
        case "var":
          return node[1].length !== 0;
        case "return":
          return node[1] !== REMOVE_NODE;
        default:
          return true;
      }
    };
    clean = function(statements) {
      if (statements == null) {
        return null;
      }
      return statements.filter(keepNode);
    };
    cleanLambdaBody = function(name, args, body) {
      return [this[0], name, args, MAP(clean(body), cleanupWalker.walk)];
    };
    cleanBlock = function(statements) {
      return [this[0], MAP(clean(statements), cleanupWalker.walk)];
    };
    return cleanupWalker.with_walkers({
      toplevel: function(body) {
        return ["toplevel", MAP(clean(body), cleanupWalker.walk)];
      },
      "function": cleanLambdaBody,
      defun: cleanLambdaBody,
      block: cleanBlock,
      splice: cleanBlock,
      "return": function(expr) {
        if (keepNode(this)) {
          return [this[0], cleanupWalker.walk(expr)];
        } else {
          return [this[0], null];
        }
      },
      "try": function(statements, catchBlock, finallyBlock) {
        return [this[0], MAP(clean(statements), cleanupWalker.walk), catchBlock ? [catchBlock[0], MAP(clean(catchBlock[1]), cleanupWalker.walk)] : catchBlock, finallyBlock ? MAP(clean(finallyBlock), cleanupWalker.walk) : void 0];
      },
      "switch": function(expr, body) {
        return [
          this[0], cleanupWalker.walk(expr), MAP(clean(body), function(branch) {
            return [(branch[0] ? cleanupWalker.walk(branch[0]) : null), MAP(clean(branch[1]), cleanupWalker.walk)];
          })
        ];
      }
    }, function() {
      return cleanupWalker.walk(ast);
    });
  };

}).call(this);
