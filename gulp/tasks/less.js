var gulp = require('gulp');

var less = require('gulp-less');
var sourcemaps = require('gulp-sourcemaps');
var handleErrors = require('../util/handle_errors');
var gulpif = require('gulp-if');
var minifyCss = require('gulp-minify-css');
var args = require('yargs').argv;

gulp.task('less', function() {
  var production = args.environment === 'production';

  return gulp.src('./app/assets/stylesheets/custom.less')
    .pipe(sourcemaps.init())
    .pipe(less({
      paths: ['./app/assets/stylesheets', './app/assets/libs']
    }))
    .pipe(sourcemaps.write())
    .pipe(gulpif(production, minifyCss()))
    .pipe(gulp.dest('./public/css'))
    .on('error', handleErrors);
});
