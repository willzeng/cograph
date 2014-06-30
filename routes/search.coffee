url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'
_ = require __dirname + '/../node_modules/underscore/underscore'

# returns a list of objects for nodes in a given document
# each object has the _id and name of a node
exports.getNodeNames = (req, resp) ->
  docId = req.params.docId || 0
  cypherQuery = "match (n:_doc_#{docId}) return n.name, n._id;"
  graphDb.query cypherQuery, {}, (err, results) ->
    resp.send ({name: node['n.name'], _id: node['n._id']} for node in results)

# returns a list of tags in a given document
exports.getTagNames = (req, resp) ->
  docId = req.params.docId
  cypherQuery = "match (n:_doc_#{docId}) return labels(n)"
  graphDb.query cypherQuery, {}, (err, results) ->
    labels = _.uniq _.flatten _.map results, (result) -> result['labels(n)']
    labelDict = utils.parseLabels labels
    resp.send labelDict.tags
