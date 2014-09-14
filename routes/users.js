// routes/users.js

var documents = require('./documents');

module.exports = function(app, passport) {

  // =====================================
  // HOME PAGE (with login links) ========
  // =====================================
  app.get('/u', function(req, res) {
    res.render('user-index.jade'); // load the index.ejs file
  });

  // =====================================
  // LOGIN ===============================
  // =====================================
  // show the login form
  app.get('/u/login', function(req, res) {

    // render the page and pass in any flash data if it exists
    res.render('login.jade', { message: req.flash('loginMessage') }); 
  });

  // process the login form
  app.post('/login', passport.authenticate('local-login', {
    successRedirect : '/u/profile', // redirect to the secure profile section
    failureRedirect : '/u/login', // redirect back to the signup page if there is an error
    failureFlash : true // allow flash messages
  }));

  // =====================================
  // SIGNUP ==============================
  // =====================================
  // show the signup form
  app.get('/u/signup', function(req, res) {

    // render the page and pass in any flash data if it exists
    res.render('signup.jade', { message: req.flash('signupMessage') });
  });

  // process the signup form
  app.post('/signup', passport.authenticate('local-signup', {
    successRedirect : '/u/profile', // redirect to the secure profile section
    failureRedirect : '/u/signup', // redirect back to the signup page if there is an error
    failureFlash : true // allow flash messages
  }));

  // =====================================
  // PROFILE SECTION =====================
  // =====================================
  // we will want this protected so you have to be logged in to visit
  // we will use route middleware to verify this (the isLoggedIn function)
  app.get('/u/profile', isLoggedIn, function(req, res) {
    documents.helper.getAll(function(docs){
      res.render('profile.jade', {
        user : req.user, // get the user out of session and pass to template
        docs : docs // prefetch the list of document names for opening
      });
    });
  });

  // =====================================
  // LOGOUT ==============================
  // =====================================
  app.get('/u/logout', function(req, res) {
    req.logout();
    res.redirect('/u');
  });
};

// route middleware to make sure a user is logged in
function isLoggedIn(req, res, next) {

  // if user is authenticated in the session, carry on 
  if (req.isAuthenticated())
    return next();

  // if they aren't redirect them to the home page
  res.redirect('/u');
}
