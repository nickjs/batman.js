require('coffee-script/register');
var gulp = require('gulp');
var gulpWebpack = require('gulp-webpack');
var webpackConfig = require('./webpack_config');

var transformGlob = require('./tools/remove_development_transform').transformGlob

gulp.task("default", ['test'], function(){
  gulp.watch("modules/**/*.coffee", ['finalize']);
});

gulp.task("build", function() {
    return gulp.src('modules/batman.coffee')
        .pipe(gulpWebpack(webpackConfig))
        .pipe(gulp.dest('dist/'));
});

gulp.task("watch", function() {
  gulp.watch("modules/**/*.coffee", ['finalize'])
});

gulp.task("finalize", ['build'], function () {
  // .min files are skipped by transformGlob
  transformGlob("dist/**/*.js")
});

var karma = require('karma').server;

gulp.task('test', function() {
  karma.start({
    configFile: __dirname + '/karma.conf.coffee',
    singleRun: false
  });
  return true // allow other tasks to run
});

gulp.task('test:travis', ['finalize'], function (done) {
  karma.start({
    configFile: __dirname + '/karma.conf.coffee',
    singleRun: true,
    browsers: ["PhantomJS"]
  }, done);
});
