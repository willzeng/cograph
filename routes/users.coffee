# routes/users.coffee
documents = require "./documents"
utils = require "./utils"
async = require 'async'
crypto = require 'crypto'
User = require '../models/user.coffee'
BetaUser = require '../models/beta-requests.coffee'
flash = require 'express-flash'
nodemailer = require 'nodemailer'
bcrypt = require "bcrypt-nodejs"

module.exports = (app, passport) ->

  app.use(flash())
  
  # =====================================
  # HOME PAGE (with login links) ========
  # =====================================
  app.get "/", (req, res) ->
    documents.helper.getAll (docs) ->
      if req.isAuthenticated()
        username = req.user.local.nameLower
        User.findOne { 'local.nameLower' :  username }, (err, profiledUser) ->
          if err or not(profiledUser?) then res.render "index.jade", {docs:docs}
          else
            res.render "index-logged-in.jade", {docs:docs, user: profiledUser, isAuthenticated:true}
      else 
        res.render "index.jade", {docs:docs}
  
  # =====================================
  # LOGIN ===============================
  # =====================================
  # show the login form
  app.get "/login", (req, res) ->
    # render the page and pass in any flash data if it exists
    if req.isAuthenticated()
      res.redirect "/"
    else
      res.render "login.jade",
        message: req.flash("loginMessage")
  
  # process the login form
  app.post "/login", (req, res, next) ->
    passport.authenticate("local-login", (err, user, info) ->
      if err then next err
      if not user then res.redirect '/login'
      else
        req.logIn user, (err) ->
          if err then next err
          res.redirect '/'
    )(req, res, next)

  # =====================================
  # REQUEST BETA KEY ====================
  # =====================================

  app.get "/request-key", (req, res) ->
    if req.isAuthenticated()
      res.redirect "/"
    else
      res.render "request-key.jade"
        message: req.flash("")

  app.post "/request-key", (req, res) ->
    x = new BetaUser()
    x.email = req.body.email
    x.save()
    res.redirect '/'
    return

  # =====================================
  # FORGOT PASSWORD =====================
  # =====================================
  
  app.get "/forgotten-password", (req, res) ->
    if req.isAuthenticated()
      res.redirect "/"
    else
      res.render "forgotten-password.jade"
        message: req.flash("forgotMessage") # TODO?

  app.post "/forgotten-password", (req, res) ->
    async.waterfall [
      (done) ->
        crypto.randomBytes 10, (err, buf) ->
          token = buf.toString("hex")
          done err, token
          return

      (token, done) ->
        User.findOne({'local.email': req.body.email}, (err, user) ->
          unless user
            req.flash "error", "No account with that email address exists."
            return res.redirect("/forgotten-password")
          user.local.password = bcrypt.hashSync token, bcrypt.genSaltSync(8), null
          user.save (err) ->
            done err, token, user
            return

          return
        )

      (token, user, done) ->
        smtpTransport = nodemailer.createTransport("SMTP",
          service: "SendGrid"
          auth:
            user: "davidfurlong"
            pass: "david4226"
        )
        mailOptions =
          to: user.local.email
          from: "passwordreset@cograph.co"
          subject: "cograph password reset"
          text: "You are receiving this because you (or someone else) has requested the reset of the password for your account. Your new password is "+token

        smtpTransport.sendMail mailOptions, (err) ->
          req.flash "info", "An e-mail has been sent to " + user.local.email + " with further instructions."
          done err, "done"
          return

    ], (err) ->
      console.log err
      # the next two redirects are the same for security reasons
      return res.redirect "/login" if err
      res.redirect "/login"
      return

    return


  app.post '/account', (req, res) ->
    username = req.user.local.nameLower #if we used post username data this would be a security flaw
    User.findOne { 'local.nameLower' :  username }, (err, user) ->
      if(req.body.newPassword != req.body.newPasswordRepeat)
        res.render "account.jade"
          user: user
          isAuthenticated: true
          message: "New Passwords don't match"
          messageType: 0
      if(user.validPassword(req.body.oldPassword))
        user.local.email = req.body.email 
        #todo user user model?
        user.local.password = user.generateHash(req.body.newPassword)
        user.save (err) ->
          return
        res.render "account.jade"
          user: user
          isAuthenticated: true
          message: "Successfully changed"
          messageType: 1
      else
        # wrong password
        res.render "account.jade"
          user: req.user
          isAuthenticated: true
          message: "wrong password"
          messageType: 0
      

  # =====================================
  # SIGNUP ==============================
  # =====================================
  # show the signup form
  app.get "/signup", (req, res) ->
    if req.isAuthenticated()
      res.redirect "/"
    else
      # render the page and pass in any flash data if it exists
      res.render "signup.jade",
        message: req.flash("signupMessage")
  

  # // Redirect the user to Twitter for authentication.  When complete, Twitter
  # // will redirect the user back to the application at
  # //   /auth/twitter/callback
  app.get('/auth/twitter', passport.authenticate('twitter'));

  # // Twitter will redirect the user to this URL after approval.  Finish the
  # // authentication process by attempting to obtain an access token.  If
  # // access was granted, the user will be logged in.  Otherwise,
  # // authentication has failed.
  app.get('/auth/twitter/callback', 
    passport.authenticate('twitter', 
      { 
        successRedirect: '/',
        failureRedirect: '/login' 
      }
    )
  )
  
  app.post "/signup", (req, res, next) ->
    passport.authenticate("local-signup", (err, user, info) ->
      if err then next err
      if not user then res.redirect '/signup'
      else
        req.logIn user, (err) ->
          if err then next err
          res.redirect '/'+user.local.nameLower
    )(req, res, next)

  # # =====================================
  # # PROFILE SECTION =====================
  # # =====================================
  # # we will want this protected so you have to be logged in to visit
  # # we will use route middleware to verify this (the isLoggedIn function)
  # app.get "/profile", utils.isLoggedIn, (req, res) ->
  #   documents.helper.getAll (docs) ->
  #     documents.helper.getByIds req.user.documents, (privateDocs) ->
  #       res.render "profile.jade",
  #         user: req.user # get the user out of session and pass to template
  #         docs: docs # prefetch the list of document names for opening
  #         userDocs: privateDocs # prefetch the users private documents
  
  # =====================================
  # LOGOUT ==============================
  # =====================================
  app.get "/logout", (req, res) ->
    req.logout()
    res.redirect "/"
