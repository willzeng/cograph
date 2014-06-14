express = require 'express'
router = express.Router()

utils = require './utils'
nodes = require './nodes'
connections = require './connections'
documents = require './documents'

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
router.post     '/documents',       documents.create
router.get      '/documents/:id',   documents.read
router.get      '/documents',       documents.getAll
router.put      '/documents',       documents.update
router.delete   '/documents',       documents.destroy

# Nodes
router.post     '/documents/:docId/nodes',               nodes.create
router.get      '/documents/:docId/nodes/:id',           nodes.read
router.get      '/documents/:docId/nodes',               nodes.getAll
router.get      '/documents/:docId/nodes/neighbors/:id', nodes.getNeighbors
router.get      '/documents/:docId/nodes/spokes/:id',    nodes.getSpokes
router.get      '/documents/:docId/ndoes/get_connections/:id' nodes.getConnections
router.put      '/documents/:docId/nodes',               nodes.update
router.delete   '/documents/:docId/nodes',               nodes.destroy

# Connections
router.post     '/documents/:docId/connections',      connections.create
router.get      '/documents/:docId/connections/:id',   connections.read
router.get      '/documents/:docId/connections',      connections.getAll
router.put      '/documents/:docId/connections',      connections.update
router.delete   '/documents/:docId/connections',      connections.destroy

module.exports = router
