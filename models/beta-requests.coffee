	
	mongoose = require "mongoose"
	betaRequestDB = require '../config/beta-request-database.js'
	betaRequestConnection = mongoose.createConnection betaRequestDB.url # connect to beta request db

	# define the schema for our beta request model
	BetaUser = mongoose.Schema(
	  email: String
	  invited: { type: Boolean, default: false }
	  inviteKey: { type: String, default: null }
	  requestDate: { type: Date, default: Date.now }
	)

	# create the model for beta requests and expose it to our app
	module.exports = betaRequestConnection.model("BetaUser", BetaUser)

