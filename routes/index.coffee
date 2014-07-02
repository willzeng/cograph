express = require 'express'
router = express.Router()

utils = require './utils'
nodes = require './nodes'
connections = require './connections'
documents = require './documents'
search = require './search'

router.get '/', (request, response)->
  response.render('index.jade')

router.get '/hello', (request, response)->
  response.send('index.jade')

#defines a function to extract parameters using regex's
router.param utils.paramExtract
integerRegex = /^\d+$/
router.param 'id', integerRegex
router.param 'docId', integerRegex

# Documents
router.post     '/documents',           documents.create
router.get      '/documents/:id',       documents.read
router.get      '/documents',           documents.getAll
router.put      '/documents/:id',       documents.update
router.delete   '/documents/:id',       documents.destroy

# Nodes
router.post     '/documents/:docId/nodes',                      nodes.create
router.get      '/documents/:docId/nodes/:id',                  nodes.read
router.get      '/documents/:docId/nodes',                      nodes.getAll
router.get      '/documents/:docId/nodes/:id/neighbors/',       nodes.getNeighbors
router.get      '/documents/:docId/nodes/:id/spokes/',          nodes.getSpokes
router.post     '/documents/:docId/nodes/:id/get_connections/', nodes.getConnections
router.put      '/documents/:docId/nodes/:id',                  nodes.update
router.delete   '/documents/:docId/nodes/:id',                  nodes.destroy

# Connections
router.post     '/documents/:docId/connections',       connections.create
router.get      '/documents/:docId/connections/:id',   connections.read
router.get      '/documents/:docId/connections',       connections.getAll
router.put      '/documents/:docId/connections/:id',   connections.update
router.delete   '/documents/:docId/connections/:id',   connections.destroy

# Search
router.get      '/documents/:docId/nodes/names',       search.getNodeNames
router.get      '/documents/:docId/getNodeByName',     search.getNodeByName
router.get      '/documents/:docId/getNodesByTag',     search.getNodesByTag
router.get      '/documents/:docId/tags',              search.getTagNames

module.exports = router
