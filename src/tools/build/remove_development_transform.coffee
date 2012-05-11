uglify = require 'uglify-js'

MAP = uglify.uglify.MAP
REMOVE_NODE = {remove: true}
DEVELOPER_NAMESPACES = ['developer', ['name', 'developer'], ['dot', ['name', 'Batman'], 'developer']]

isUndefinedOrNull = (value) ->
  value is null or value is `undefined`

isArguments = (object) ->
  Object::toString.call(object) is "[object Arguments]"

deepEqual = (actual, expected) ->
  if actual is expected
    true
  else if actual instanceof Date and expected instanceof Date
    actual.getTime() is expected.getTime()
  else if actual instanceof RegExp and expected instanceof RegExp
    actual.source is expected.source and actual.global is expected.global and actual.ignoreCase is expected.ignoreCase and actual.multiline is expected.multiline
  else if typeof actual isnt "object" and typeof expected isnt "object"
    actual is expected
  else
    objEquiv actual, expected

objEquiv = (a, b) ->
  return false  if isUndefinedOrNull(a) or isUndefinedOrNull(b)
  return false  unless a:: == b::
  if isArguments(a)
    return false  unless isArguments(b)
    a = pSlice.call(a)
    b = pSlice.call(b)
    return deepEqual(a, b)
  try
    ka = Object.keys(a)
    kb = Object.keys(b)
    key = undefined
    i = undefined
  catch e
    return false
  return false  unless ka.length is kb.length
  ka.sort()
  kb.sort()
  i = ka.length - 1
  while i >= 0
    return false  unless ka[i] is kb[i]
    i--
  i = ka.length - 1
  while i >= 0
    key = ka[i]
    return false  unless deepEqual(a[key], b[key])
    i--
  true

exports.removeDevelopment = (ast) ->
  removalWalker = uglify.uglify.ast_walker()
  cleanupWalker = uglify.uglify.ast_walker()
  isDeveloperNamespace = (x) -> DEVELOPER_NAMESPACES.some (y) -> deepEqual(x, y)

  ast = removalWalker.with_walkers
    # Remove all calls to developer.*
    call: (expr, args) ->
      [op, upon, fn] = expr
      return REMOVE_NODE if isDeveloperNamespace(upon)
      ['call', removalWalker.walk(expr), MAP(args, removalWalker.walk)]

    # Remove all assignments to developer or developer.*
    assign: (_, lvalue, rvalue) ->
      if rvalue.length
        if isDeveloperNamespace(rvalue)
          return REMOVE_NODE

      if lvalue.length
        return REMOVE_NODE if isDeveloperNamespace(lvalue)
        [op, upon] = lvalue
        return REMOVE_NODE if isDeveloperNamespace(upon)
      ['assign', _, removalWalker.walk(lvalue), removalWalker.walk(rvalue)]

    # Remove all var developer declarations, or assignments of developer to another variable.
    var: (defs) ->
      defs = defs.filter ([name, val]) ->
        # `var developer = ` style
        # `var x = developer;` style
        if isDeveloperNamespace(name) || isDeveloperNamespace(val) ||
        # var x = developer.foo;
        (val && val[0] in ['dot', 'sub'] && val[1].length && isDeveloperNamespace(val[1]))
          # Don't allow this statement
          false
        else
          # Otherwise just pass it through
          true

      ["var", defs]
  , ->
    removalWalker.walk ast

  keepNode = (node) ->
      switch node[0]
        # Ensure statements or assignments using developer are removed
        when "stat", "assign"
          node[node.length - 1] != REMOVE_NODE
        # Ensure now-empty sequences of var statements are removed
        when "var"
          node[1].length != 0
        # Ensure returning of developer statements are removed
        when "return"
          node[1] != REMOVE_NODE
        else
          true

  clean = (statements) ->
    return null unless statements?
    statements.filter keepNode

  cleanLambdaBody = (name, args, body) ->
    [this[0], name, args, MAP(clean(body), cleanupWalker.walk)]

  cleanBlock = (statements) ->
    [this[0], MAP(clean(statements), cleanupWalker.walk)]

  cleanupWalker.with_walkers
    toplevel: (body) -> return ["toplevel", MAP(clean(body), cleanupWalker.walk)]
    function: cleanLambdaBody
    defun: cleanLambdaBody
    block: cleanBlock
    splice: cleanBlock
    return: (expr) ->
      if keepNode(@)
        return [@[0], cleanupWalker.walk(expr)]
      else
        return [@[0], null]

    try: (statements, catchBlock, finallyBlock) ->
      [@[0], MAP(clean(statements), cleanupWalker.walk),
        if catchBlock then [catchBlock[0], MAP(clean(catchBlock[1]), cleanupWalker.walk)] else catchBlock,
        if finallyBlock then MAP(clean(finallyBlock), cleanupWalker.walk)]
    switch: (expr, body) ->
      [@[0], cleanupWalker.walk(expr), MAP(clean(body), (branch) ->
        [ (if branch[0] then cleanupWalker.walk(branch[0]) else null), MAP(clean(branch[1]), cleanupWalker.walk) ]
      ) ]
  , ->
    cleanupWalker.walk ast
