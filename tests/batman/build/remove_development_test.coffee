return unless IN_NODE
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify
fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'
remove = require '../../../src/tools/build/remove_development_transform'

transform = (string) ->
  ast = jsp.parse(string)
  ast = remove.removeDevelopment(ast)
  pro.gen_code(ast).trim()

QUnit.module "Batman build development removal",
test "removes developer declarations", ->
  code = """
    Batman.developer = {};
    var developer = foo;
  """
  equal transform(code), ""

test "removes calls on developer", ->
  code = """
    developer.test();
    Batman.developer.test();
  """

  equal transform(code), ""

test "removes reassignments of developer", ->
  code = """
    var x = developer;
    var x = Batman.developer;
    var x = developer.foo;
    var x = Batman.developer.foo;
  """

  equal transform(code), ""

test "removes assignments on developer", ->
  code = """
    Batman.developer.foo = bar;
    developer.foo = bar;
  """

  equal transform(code), ""

test "leaves no trace in the batman minified source", ->
  code = CoffeeScript.compile(fs.readFileSync(path.join(__dirname, '..', '..', '..', 'src', 'developer.coffee')).toString())
  equal transform(code), "((function(){})).call(this)"
