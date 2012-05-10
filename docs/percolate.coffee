glob = require 'glob'
path = require 'path'
fs = require 'fs'
coffee = require 'coffee-script'

# Load test runner
qqunit = require 'qqunit'
oldErrorHandler = window.onerror
delete window.onerror

# Load percolate
percolate = require 'percolate'

testDir = path.resolve(__dirname, '..', 'tests')
jqueryPath = path.join(testDir, 'lib', 'jquery.js')

exportHelpers = (object) ->
    global[k] = v for own k,v of object

qqunit.Environment.jsdom.jQueryify window, jqueryPath, (window, jQuery) ->
  try
    global.jQuery = jQuery

    # Load test helper
    exportHelpers require path.join(testDir, 'batman', 'test_helper')

    global.Batman = require path.join('..', 'lib', 'dist', 'batman.node')

    exportHelpers require path.join(testDir, 'batman', 'model', 'model_helper')
    TestStorageAdapter.autoCreate = false

    docs = glob.sync("#{__dirname}/**/*.percolate").map (doc) -> path.resolve(process.cwd(), doc)

    console.log "Running Batman doc suite."
    if process.argv[2] == '--test-only'
      percolate.test __dirname, docs..., (error, stats) ->
        process.exit stats.failed
    else
      percolate.generate __dirname, docs..., (error, stats, output) ->
        throw error if error
        unless stats.failed > 0
          fs.writeFileSync path.join(__dirname, 'batman.html'), output
          console.log "Docs written."
        process.exit stats.failed
  catch e
    console.error e.stack
    process.exit(1)
