uglify = require 'uglify-js'
glob = require 'glob'
fs = require 'fs'

replacements = null

emptyNode = (node) ->
  newNode = new uglify.AST_EmptyStatement
  newNode.start = node.start
  newNode.end = node.end
  newNode

isDeveloperNamespace = (nodeOrString) ->
  if nodeOrString instanceof uglify.AST_Node
    node = nodeOrString
    if node instanceof uglify.AST_Dot && node.expression.name == "Batman" && node.property == "developer"
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
  node.expression? && isDeveloperNamespace(node.expression)

removeDevelopment = (toplevel) ->
  replacements = 0
  remover = new uglify.TreeTransformer (node, descend) ->
    if node instanceof uglify.AST_Definitions
      descend(node, this)
      node.definitions = node.definitions.filter (node) -> !node instanceof uglify.AST_EmptyStatement
      if node.definitions.length == 0
        replacements += 1
        return emptyNode(node)
      else
        return true

    if node instanceof uglify.AST_Call
      if isPropertyAccessOnDeveloperNamespace(node.expression)
        replacements += 1
        return emptyNode(node)

    if node instanceof uglify.AST_Assign
      if isDeveloperNamespace(node.left) || isDeveloperNamespace(node.right) || isPropertyAccessOnDeveloperNamespace(node.left) || isPropertyAccessOnDeveloperNamespace(node.right)
        replacements += 1
        return emptyNode(node)

    if node instanceof uglify.AST_VarDef
      if isDeveloperNamespace(node.name)
        replacements += 1
        return emptyNode(node)

      if node.value && (isDeveloperNamespace(node.value) || isPropertyAccessOnDeveloperNamespace(node.value))
        replacements += 1
        return emptyNode(node)

    if node instanceof uglify.AST_Conditional || node instanceof uglify.AST_If
      if isDeveloperNamespace(node.condition) || isPropertyAccessOnDeveloperNamespace(node.condition)
        replacements += 1
        return emptyNode(node)
    return node

  # console.log "Made #{replacements} replacements."
  return toplevel.transform(remover)

transformFile = (fileName, newFileName) ->
  console.log "transforming #{fileName} => #{newFileName}"
  oldCode = fs.readFileSync(fileName, "utf8")
  ast = uglify.parse(oldCode, {filename: fileName})
  ast.figure_out_scope()
  ast = removeDevelopment(ast)
  compressor = uglify.Compressor({warnings: false})
  ast = ast.transform(compressor)
  ast.compute_char_frequency()
  ast.mangle_names()
  newCode = ast.print_to_string({beautify: false})
  fs.writeFileSync(newFileName, newCode)

transformGlob = (pattern) ->
  files = glob.sync(pattern, {})
  throw err if err?
  for f in files when f.indexOf(".min.js") is -1
    transformFile(f, f.replace(/\.js/, '.min.js'))

module.exports = {transformFile, removeDevelopment, transformGlob}