express = require 'express'
router = express.Router()

utils = require './utils'
nodes = require './nodes'
connections = require './connections'
documents = require './documents'
search = require './search'

router.get '/', (request, response)->
  response.render('index.jade')

router.get '/landing', (request, response)->
  response.render('landing.jade')

router.get '/errors/missingDocument', (request, response)->
  response.render('errors/missingDocument.jade')

#defines a function to extract parameters using regex's
router.param utils.paramExtract
integerRegex = /^\d+$/
router.param 'id', integerRegex
router.param 'docId', integerRegex

# Documents
router.post     '/document',           documents.create
router.get      '/document/:id',       documents.read
router.get      '/document',           documents.getAll
router.put      '/document/:id',       documents.update
router.delete   '/document/:id',       documents.destroy

# Nodes
router.post     '/document/:docId/nodes',                      nodes.create
router.get      '/document/:docId/nodes/:id',                  nodes.read
router.get      '/document/:docId/nodes',                      nodes.getAll
router.get      '/document/:docId/nodes/:id/neighbors/',       nodes.getNeighbors
router.get      '/document/:docId/nodes/:id/spokes/',          nodes.getSpokes
router.post     '/document/:docId/nodes/:id/get_connections/', nodes.getConnections
router.put      '/document/:docId/nodes/:id',                  nodes.update
router.delete   '/document/:docId/nodes/:id',                  nodes.destroy

# Connections
router.post     '/document/:docId/connections',       connections.create
router.get      '/document/:docId/connections/:id',   connections.read
router.get      '/document/:docId/connections',       connections.getAll
router.put      '/document/:docId/connections/:id',   connections.update
router.delete   '/document/:docId/connections/:id',   connections.destroy

# Search
router.get      '/document/:docId/nodes/names',       search.getNodeNames
router.get      '/document/:docId/getNodeByName',     search.getNodeByName
router.get      '/document/:docId/getNodesByTag',     search.getNodesByTag
router.get      '/document/:docId/tags',              search.getTagNames

module.exports = router
