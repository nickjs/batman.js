# Cakefile
# batman
# Copyright Shopify, 2011

muffin       = require 'muffin'
path         = require 'path'
q            = require 'q'
glob         = require 'glob'
{exec, fork, spawn} = require 'child_process'

require 'coffee-script'

option '-w', '--watch',  'continue to watch the files and rebuild them when they change'
option '-c', '--commit', 'operate on the git index instead of the working tree'
option '-d', '--dist',   'compile minified versions of the platform dependent code into build/dist (build task only)'
option '-m', '--compare', 'compare to git refs (stat task only)'
option '-s', '--coverage', 'run jscoverage during tests and report coverage (test task only)'

pipedExec = do ->
  running = false
  pipedExec = (args..., callback) ->
    if !running
      running = true
      child = spawn('node', args, stdio: 'inherit')
      process.on 'exit', exitListener = -> child.kill()
      child.on 'close', (code) ->
        process.removeListener('exit', exitListener)
        running = false
        callback(code)


task 'build', 'compile batman.js', (options) ->
  files = glob.sync('./src/**/*')
  muffin.run
    files: files
    options: options
    map:
      'src/batman\.coffee'            : (matches) -> muffin.compileTree(matches[0], 'build/batman.js', options)
      'src/platform/([^/]+)\.coffee'  : (matches) -> muffin.compileTree(matches[0], "build/batman.#{matches[1]}.js", options) unless matches[1] == 'node'
      'src/extras/(.+)\.coffee'       : (matches) -> muffin.compileTree(matches[0], "build/extras/#{matches[1]}.js", options)
      'tests/run\.coffee'             : (matches) -> muffin.compileTree(matches[0], 'tests/run.js', options)

  if options.dist
    invoke 'build:dist'

task 'build:dist', 'compile batman.js files for distribution', (options) ->
  temp = require 'temp'
  tmpdir = temp.mkdirSync()
  developmentTransform = require('./src/tools/remove_development_transform').removeDevelopment

  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/dist/(.+)\.coffee' : (matches) ->
        [srcPath, srcName] = matches
        return if srcName in ['undefine_module']
        destination = "build/dist/#{srcName}.js"
        muffin.compileTree(srcPath, destination).then ->
          return if srcName in ['batman.testing']
          options.transform = developmentTransform
          muffin.minifyScript(destination, options).then ->
            muffin.notify(destination, "File #{destination} minified.")

task 'test', ' run the tests continuously on the command line', (options) ->
  pipedExec './node_modules/.bin/karma', 'start', './karma.conf.coffee', (code) ->
    process.exit(code)

task 'test:travis', 'run the tests once using PhantomJS', (options) ->
  pipedExec './node_modules/.bin/karma', 'start', '--single-run', '--browsers', 'PhantomJS', './karma.conf.coffee', (code) ->
    process.exit(code)

task 'test:travis_debug', 'run the tests once using PhantomJS', (options) ->
  pipedExec './node_modules/.bin/karma', 'start', '--single-run', '--browsers', 'PhantomJS_debug', './karma.conf.coffee', (code) ->
    process.exit(code)

