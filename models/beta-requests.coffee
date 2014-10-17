mongoose = require "mongoose"

# define the schema for our beta request model
betaRequestSchema = mongoose.Schema(
  email: String
  invited: { type: Boolean, default: false }
  inviteKey: { type: String, default: null }
  requestDate: { type: Date, default: Date.now }
)

# create the model for beta requests and expose it to our app
module.exports = betaRequestConnection.model("BetaRequest", betaRequestSchema)