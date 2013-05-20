uglify = require 'uglify-js'

emptyNode = (node) ->
  newNode = new uglify.AST_EmptyStatement
  newNode.start = node.start
  newNode.end = node.end
  newNode

isDeveloperNamespace = (nodeOrString) ->
  if nodeOrString instanceof uglify.AST_Node
    node = nodeOrString
    if node instanceof uglify.AST_Dot && node.expression.name == "Batman" && node.property = "developer"
      return true

    if node instanceof uglify.AST_Sub && node.expression.name == "Batman" && node.property?.value == "developer"
      return true

    if node instanceof uglify.AST_SymbolRef && node.name == "developer"
      return true

    if node instanceof uglify.AST_SymbolVar && node.name == "developer"
      return true

  else
    if nodeOrString == "developer"
      return true

  return false

isPropertyAccessOnDeveloperNamespace = (node) ->
  if node.expression?
    return isDeveloperNamespace(node.expression)
  return false

exports.removeDevelopment = (toplevel) ->
  remover = new uglify.TreeTransformer (node, descend) ->
    if node instanceof uglify.AST_Definitions
      descend(node, this)
      node.definitions = node.definitions.filter (node) -> !node instanceof uglify.AST_EmptyStatement
      if node.definitions.length == 0
        return emptyNode(node)
      else
        return true

    if node instanceof uglify.AST_Call
      return emptyNode(node) if isPropertyAccessOnDeveloperNamespace(node.expression)

    if node instanceof uglify.AST_Assign
      if isDeveloperNamespace(node.left) || isDeveloperNamespace(node.right) || isPropertyAccessOnDeveloperNamespace(node.left) || isPropertyAccessOnDeveloperNamespace(node.right)
        return emptyNode(node)

    if node instanceof uglify.AST_VarDef
      if isDeveloperNamespace(node.name)
        return emptyNode(node)

      if node.value && (isDeveloperNamespace(node.value) || isPropertyAccessOnDeveloperNamespace(node.value))
        return emptyNode(node)

    if node instanceof uglify.AST_Conditional || node instanceof uglify.AST_If
      return emptyNode(node) if isDeveloperNamespace(node.condition) || isPropertyAccessOnDeveloperNamespace(node.condition)

    return

  return toplevel.transform(remover)
