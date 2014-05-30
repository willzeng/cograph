module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffeelint:
      app: ['app/**/*.coffee', '*.coffee']
      options:
        configFile: 'coffeelint.json'
    lesslint:
      src: ['app/assets/stylesheets/*.less']
      options:
        csslint:
          'known-properties': false
          'adjoining-classes': false
          'ids': false


  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-lesslint'

  grunt.registerTask 'lint', ['coffeelint', 'lesslint']
