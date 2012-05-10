glob = require 'glob'
path = require 'path'
# Load test runner
qqunit = require 'qqunit'

qqunit.Environment.jsdom.jQueryify window, path.join(__dirname, 'lib', 'jquery.js'), (window, jQuery) ->
  global.jQuery = jQuery

  # Load test helper
  try
    Helper = require './batman/test_helper'
    global[k] = v for own k,v of Helper

    global.Batman = require '../lib/dist/batman.node'
    Batman.Request::getModule = ->
      request: -> throw new Error "Can't send requests during tests!"

    tests = glob.sync("#{__dirname}/batman/**/*_test.coffee").map (test) -> path.resolve(process.cwd(),test)
  catch e
    console.error e.stack
    process.exit 1

  console.log "Running Batman test suite. #{tests.length} files required."
  qqunit.Runner.run tests, (stats) ->
    process.exit stats.failed
