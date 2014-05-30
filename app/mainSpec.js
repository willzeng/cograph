requirejs.config({
  baseUrl: "",
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
    'bootstrap': 'assets/libs/bootstrap/dist/js/bootstrap.min'
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

require(['jquery', 'tests/index', 'cs!GraphDocs'], function($, index, GraphDocs) {
  var jasmineEnv = jasmine.getEnv(),
      htmlReporter = new jasmine.HtmlReporter();

  jasmineEnv.addReporter(htmlReporter);

  jasmineEnv.specFilter = function(spec) {
    return htmlReporter.specFilter(spec);
  };

  $(function() {
    require(index.specs, function() {
      jasmineEnv.execute();
    });
  });
});
