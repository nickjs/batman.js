(function() {
  var emptyNode, isDeveloperNamespace, isPropertyAccessOnDeveloperNamespace, uglify;

  uglify = require('uglify-js');

  emptyNode = function(node) {
    var newNode;

    newNode = new uglify.AST_EmptyStatement;
    newNode.start = node.start;
    newNode.end = node.end;
    return newNode;
  };

  isDeveloperNamespace = function(nodeOrString) {
    var node, _ref;

    if (nodeOrString instanceof uglify.AST_Node) {
      node = nodeOrString;
      if (node instanceof uglify.AST_Dot && node.expression.name === "Batman" && (node.property = "developer")) {
        return true;
      }
      if (node instanceof uglify.AST_Sub && node.expression.name === "Batman" && ((_ref = node.property) != null ? _ref.value : void 0) === "developer") {
        return true;
      }
      if (node instanceof uglify.AST_SymbolRef && node.name === "developer") {
        return true;
      }
      if (node instanceof uglify.AST_SymbolVar && node.name === "developer") {
        return true;
      }
    } else {
      if (nodeOrString === "developer") {
        return true;
      }
    }
    return false;
  };

  isPropertyAccessOnDeveloperNamespace = function(node) {
    if (node.expression != null) {
      return isDeveloperNamespace(node.expression);
    }
    return false;
  };

  exports.removeDevelopment = function(toplevel) {
    var remover;

    remover = new uglify.TreeTransformer(function(node, descend) {
      if (node instanceof uglify.AST_Definitions) {
        descend(node, this);
        node.definitions = node.definitions.filter(function(node) {
          return !node instanceof uglify.AST_EmptyStatement;
        });
        if (node.definitions.length === 0) {
          return emptyNode(node);
        } else {
          return true;
        }
      }
      if (node instanceof uglify.AST_Call) {
        if (isPropertyAccessOnDeveloperNamespace(node.expression)) {
          return emptyNode(node);
        }
      }
      if (node instanceof uglify.AST_Assign) {
        if (isDeveloperNamespace(node.left) || isDeveloperNamespace(node.right) || isPropertyAccessOnDeveloperNamespace(node.left) || isPropertyAccessOnDeveloperNamespace(node.right)) {
          return emptyNode(node);
        }
      }
      if (node instanceof uglify.AST_VarDef) {
        if (isDeveloperNamespace(node.name)) {
          return emptyNode(node);
        }
        if (node.value && (isDeveloperNamespace(node.value) || isPropertyAccessOnDeveloperNamespace(node.value))) {
          return emptyNode(node);
        }
      }
      if (node instanceof uglify.AST_Conditional || node instanceof uglify.AST_If) {
        if (isDeveloperNamespace(node.condition) || isPropertyAccessOnDeveloperNamespace(node.condition)) {
          return emptyNode(node);
        }
      }
    });
    return toplevel.transform(remover);
  };

}).call(this);
