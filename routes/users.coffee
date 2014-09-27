# routes/users.coffee
documents = require "./documents"
utils = require "./utils"

module.exports = (app, passport) ->
  
  # =====================================
  # HOME PAGE (with login links) ========
  # =====================================
  app.get "/", utils.isNotLoggedIn, (req, res) ->
    res.render "user-index.jade"
  
  # =====================================
  # LOGIN ===============================
  # =====================================
  # show the login form
  app.get "/login", (req, res) ->
    # render the page and pass in any flash data if it exists
    res.render "login.jade",
      message: req.flash("loginMessage")
  
  # process the login form
  app.post "/login", (req, res, next) ->
    passport.authenticate("local-login", (err, user, info) ->
      if err then next err
      if not user then res.redirect '/signup'
      else
        req.logIn user, (err) ->
          if err then next err
          res.redirect '/'+user.local.nameLower
    )(req, res, next)
  
  # =====================================
  # SIGNUP ==============================
  # =====================================
  # show the signup form
  app.get "/signup", (req, res) ->
    # render the page and pass in any flash data if it exists
    res.render "signup.jade",
      message: req.flash("signupMessage")
  

  # // Redirect the user to Facebook for authentication.  When complete,
  # // Facebook will redirect the user back to the application at
  # //     /auth/facebook/callback
  app.get('/auth/facebook', passport.authenticate('facebook', {
      scope: ['public_profile', 'email', 'user_friends']
    }));

  # // Facebook will redirect the user to this URL after approval.  Finish the
  # // authentication process by attempting to obtain an access token.  If
  # // access was granted, the user will be logged in.  Otherwise,
  # // authentication has failed.
  app.get('/auth/facebook/callback', 
    passport.authenticate('facebook', 
      { 
        successRedirect: '/',
        failureRedirect: '/login' }
    )
  )

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
