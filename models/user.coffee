# /models/user.coffee
# load the things we need
mongoose = require "mongoose"
bcrypt = require "bcrypt-nodejs"

# define the schema for our user model
userSchema = mongoose.Schema(
  local:
    email: 
      type: String
    password: String
    name: 
      type: String
      required: true
      unique: true
    nameLower:
      type: String
      required: true
      unique: true

  twitter:
    dump: String
    id: String
    token: String
    displayName: String
    username: String

  documents: Array
)

# methods ======================
# generating a hash
userSchema.methods.generateHash = (password) ->
  bcrypt.hashSync password, bcrypt.genSaltSync(8), null

# checking if password is valid
userSchema.methods.validPassword = (password) ->
  bcrypt.compareSync password, @local.password

# add a document that is owned by that user
userSchema.methods.addDocument = (docId, cb) ->
  @documents.push docId
  @save (err, saved) ->
    if err? then throw err else if cb? then cb saved

# create the model for users and expose it to our app
module.exports = mongoose.model("User", userSchema)