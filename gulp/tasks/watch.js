var gulp = require('gulp');

gulp.task('watch', ['less'], function() {
  gulp.watch('assets/less/**/*.less', ['less']);
});
