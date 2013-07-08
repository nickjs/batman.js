return unless IN_NODE?
fs = require 'fs'
path = require 'path'

QUnit.module "Version nubmering",
test "numbers are consistent", ->
  packageVersion = JSON.parse(fs.readFileSync "#{__dirname}/../../../package.json").version
  nsVersion = (fs.readFileSync "#{__dirname}/../../../src/namespace.coffee").toString().match(/Batman.version = '([\d\.]+)'/)[1]

  equal packageVersion, nsVersion, 'Both namespace and package versions are the same'
