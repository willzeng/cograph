//load node_modules/coffee-script folder
require('../node_modules/coffee-script');

var url = 'http://wikinets-edge:wiKnj2gYeYOlzWPUcKYb@wikinetsedge.sb01.stations.graphenedb.com:24789';

//load node_modules/neo4js folder
var neo4js = require('../node_modules/neo4js');
var graphDb = new neo4js.GraphDatabase4Node(url);

// includes server.coffee
var App = require('./server');
app = new App(graphDb);
