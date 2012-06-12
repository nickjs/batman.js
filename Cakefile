# Cakefile
# batman
# Copyright Shopify, 2011

muffin       = require 'muffin'
path         = require 'path'
q            = require 'q'
glob         = require 'glob'
{exec, fork, spawn} = require 'child_process'

option '-w', '--watch',  'continue to watch the files and rebuild them when they change'
option '-c', '--commit', 'operate on the git index instead of the working tree'
option '-d', '--dist',   'compile minified versions of the platform dependent code into lib/dist (build task only)'
option '-m', '--compare', 'compare to git refs (stat task only)'
option '-s', '--coverage', 'run jscoverage during tests and report coverage (test task only)'

pipedExec = do ->
  running = false
  pipedExec = (args..., callback) ->
    if !running
      running = true
      child = spawn 'node', args
      process.on 'exit', exitListener = -> child.kill()
      child.stdout.on 'data', (data) -> process.stdout.write data
      child.stderr.on 'data', (data) -> process.stderr.write data
      child.on 'exit', (code) ->
        process.removeListener 'exit', exitListener
        running = false
        callback(code)

task 'build', 'compile Batman.js and all the tools', (options) ->
  files = glob.sync('./src/**/*').concat(glob.sync('./tests/run.coffee'))
  muffin.run
    files: files
    options: options
    map:
      'src/batman\.coffee'            : (matches) -> muffin.compileTree(matches[0], 'lib/batman.js', options)
      'src/platform/(.+)\.coffee'     : (matches) -> muffin.compileScript(matches[0], "lib/batman.#{matches[1]}.js", options) unless matches[1] == 'node'
      'src/extras/(.+)\.coffee'       : (matches) -> muffin.compileScript(matches[0], "lib/extras/#{matches[1]}.js", options)
      'tests/run\.coffee'             : (matches) -> muffin.compileScript(matches[0], 'tests/run.js', options)

  invoke 'build:node'
  invoke 'build:tools'

  if options.dist
    invoke 'build:dist'

task 'build:tools', 'compile command line batman tools and build transforms', (options) ->
  muffin.run
    files: './src/tools/**/*'
    options: options
    map:
      'src/tools/batman\.coffee'      : (matches) -> muffin.compileScript(matches[0], "tools/batman", muffin.extend({}, options, {mode: 0o755, hashbang: true}))
      'src/tools/(.+)\.coffee'        : (matches) -> muffin.compileScript(matches[0], "tools/#{matches[1]}.js", options)

task 'build:node', 'compile node distribution of Batman.js', (options) ->
  muffin.run
    files: './src/dist/*'
    options: options
    map:
      'src/dist/batman\.node\.coffee' : (matches) -> debugger; muffin.compileTree(matches[0], 'lib/dist/batman.node.js', options)

task 'build:dist', 'compile Batman.js files for distribution', (options) ->
  temp    = require 'temp'
  tmpdir = temp.mkdirSync()
  distDir = "lib/dist"
  developmentTransform = require('./tools/build/remove_development_transform').removeDevelopment

  # Run a task which concats the coffeescript, compiles it, and then minifies it
  first = true
  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/dist/(.+)\.coffee' : (matches) ->
        return if matches[1] == 'batman.node'
        destination = "lib/dist/#{matches[1]}.js"
        muffin.compileTree(matches[0], destination).then ->
          options.transform = developmentTransform
          muffin.minifyScript(destination, options).then ->
            muffin.notify(destination, "File #{destination} minified.")

task 'doc', 'build the Percolate documentation', (options) ->
  muffin.run
    files: './docs/**/*'
    options: options
    map:
      'docs/percolate\.coffee'  : (matches) -> muffin.compileScript(matches[0], 'docs/percolate.js', options)
      'docs/js/docs.coffee'     : (matches) -> muffin.compileScript(matches[0], 'docs/js/docs.js', options)
      '(.+).percolate'          : -> true
    after: ->
      pipedExec 'docs/percolate.js', options, (code) ->
        process.exit(code) unless options.watch

task 'test', 'compile Batman.js and the tests and run them on the command line', (options) ->
  muffin.run
    files: glob.sync('./src/**/*.coffee').concat(glob.sync('./tests/**/*.coffee')).concat(glob.sync('./docs/**/*.coffee'))
    options: options
    map:
      'src/dist/batman\.node\.coffee'            : (matches) -> muffin.compileTree(matches[0], 'lib/dist/batman.node.js', options)
      'tests/batman/(.+)_(test|helper).coffee'   : (matches) -> true
      'docs/percolate\.coffee'                   : (matches) -> muffin.compileScript(matches[0], 'docs/percolate.js', options)
      'tests/run.coffee'                         : (matches) -> muffin.compileScript(matches[0], 'tests/run.js', options)
    after: ->
      failFast = (code) ->
        if !options.watch
          process.exit code if code != 0

      pipedExec 'tests/run.js', (code) ->
        failFast(code)
        unless process.env['FILTER']?
          pipedExec 'docs/percolate.js', '--test-only', (code) ->
            failFast(code)

task 'test:doc', 'run the percolate test suite', (options) ->
  muffin.run
    files: glob.sync('./src/**/*.coffee').concat(glob.sync('./tests/batman/.coffee')).concat(glob.sync('./docs/**/*.coffee'))
    options: options
    map:
      'src/dist/batman\.node\.coffee'            : (matches) -> muffin.compileTree(matches[0], 'lib/dist/batman.node.js', options)
      'tests/batman/(.+)_(test|helper).coffee'   : (matches) -> true
      'docs/percolate\.coffee'                   : (matches) -> muffin.compileScript(matches[0], 'docs/percolate.js', options)
    after: ->
      pipedExec 'docs/percolate.js', '--test-only', (code) ->
        process.exit(code) unless options.watch

task 'stats', 'compile the files and report on their final size', (options) ->
  muffin.statFiles(glob.sync('./src/**/*.coffee').concat(glob.sync('./lib/**/*.js')), options)

task 'build:site', (options) ->
  temp    = require 'temp'
  tmpdir = temp.mkdirSync()
  filesToCopy = ["docs/css", "docs/img", "docs/js", "docs/batman.html", "examples", "lib"]
    .map((f) -> path.join(__dirname, f))
  console.warn filesToCopy
  console.warn tmpdir
  cmd = " #{("mkdir -p #{path.dirname(file.replace __dirname, tmpdir)} && cp -r #{file} #{file.replace __dirname, tmpdir}" for file in filesToCopy).join ' && '}
          && git checkout gh-pages
          && rm -rf docs examples lib
          && cp -r #{tmpdir}/* .
          && git add .
          && git ls-files -d -z | xargs -0 git update-index --remove
          && git commit -m 'Import docs and examples.'
          && git checkout master"

  exec cmd, (error, stdout, stderr) ->
    console.warn stdout.toString()
    console.warn stderr.toString()
    throw error if error
