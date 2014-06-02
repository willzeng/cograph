(function(){
  requirejs.config({
    baseUrl: "../",
    cb: 'cb=' + Math.random(),
    paths: {
      'jquery': 'assets/libs/jquery/dist/jquery.min',
      'underscore': 'assets/libs/underscore/underscore',
      'backbone': 'assets/libs/backbone/backbone',
      'text': 'assets/libs/requirejs-text/text',
      'd3': 'assets/libs/d3/d3.min',
      'backbone-forms': 'assets/libs/backbone-forms/distribution.amd/backbone-forms.min',
      'backbone-forms-bootstrap': 'assets/js/backbone-forms/bootstrap3',
      'list': 'assets/libs/backbone-forms/distribution.amd/editors/list.min',
      'typeahead': 'assets/libs/typeahead.js/dist/typeahead.jquery.min',
      'bloodhound': 'assets/libs/typeahead.js/dist/bloodhound.min',
      'bootstrap': 'assets/libs/bootstrap/dist/js/bootstrap.min',
      'jasmine': 'assets/libs/jasmine/lib/jasmine-core/jasmine',
      'jasmine-html': 'assets/libs/jasmine/lib/jasmine-core/jasmine-html',
      'boot': 'assets/libs/jasmine/lib/jasmine-core/boot'
      },
    shim: {
      'backbone': {
        deps: ['underscore', 'jquery'],
        exports: 'Backbone'
      },
      'typeahead': {
        deps: ['jquery']
      },
      'bloodhound': {
        deps: ['jquery']
      },
      'jasmine': {
        exports: 'window.jasmineRequire'
      },
      'jasmine-html': {
        deps: ['jasmine'],
        exports: 'window.jasmineRequire'
      },
      'boot': {
        deps: ['jasmine', 'jasmine-html'],
        exports: 'window.jasmineRequire'
      }
    },
    packages: [{
        name: 'cs',
        location: 'assets/libs/require-cs',
        main: 'cs'
      }, {
        name: 'coffee-script',
        location: 'assets/libs/coffee-script',
        main: 'index'
    }]
  });

  specs = [
    'cs!tests/NodeModelSpec'
  ];

  require(['boot'], function(boot) {
    require(specs, function() {
      window.onload();
    });
  });

})();
