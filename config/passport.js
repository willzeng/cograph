// config/passport.js

// load all the things we need
var LocalStrategy   = require('passport-local').Strategy;
var TwitterStrategy = require('passport-twitter').Strategy;
var _ = require(__dirname + '/../node_modules/underscore/underscore');

// load up the user model
User = require('../models/user.coffee');

// reserved usernames
// these cannot be used as usernames since they will interfere with other routes
var usernameBlacklist = ['login', 'logout', 'document', 'signup', 'profile', 'landing', 'new', 'mobile', 'errors', 'forgot-password', 'request-key'];
var userNameRegEx = /^(\w+)$/;

var Twit = require('twitter');

// expose this function to our app using module.exports
module.exports = function(passport) {

    // =========================================================================
    // passport session setup ==================================================
    // =========================================================================
    // required for persistent login sessions
    // passport needs ability to serialize and unserialize users out of session

    // used to serialize the user for the session
    passport.serializeUser(function(user, done) {
        done(null, user.id);
    });

    // used to deserialize the user
    passport.deserializeUser(function(id, done) {
        User.findById(id, function(err, user) {
            done(err, user);
        });
    });

    // Twitter Signup
        //check if local
        if (process.env.PORT){
            var cK = "iRnrLu6QrYHPlOF0wq2ns1MYl";
            var cS = "bdIQkb16hSVAvr64sTkq0YXhyysBoZ5dvMQSM9d3tdsCz3JdNx";
            var cbURL = "http://www.cograph.co/auth/twitter/callback";
        }
        else{ //local setup
            var cK = "4KN2VexuhVr7d3Ic7pHqZUVZD";
            var cS = "fy5P5cfeb6ediweO8XItI52Jlh7366bNex5tPjdyAPBq8Ix3mP";
            var cbURL = "http://127.0.0.1:3000/auth/twitter/callback";
        }
    passport.use(new TwitterStrategy({
        consumerKey: cK,
        consumerSecret: cS,
        callbackURL: cbURL
      },
      function(token, tokenSecret, profile, done) {
        process.nextTick(function() {
            User.findOne({ 'twitter.id': profile.id }, function(err, user) {
                if (err)
                    return done(err);
                    // check to see if theres already a user with that name
                User.findOne({ 'local.nameLower' : profile.username.toLowerCase() }, function(err, namedUser) {
                    // if there are any errors, return the error
                    if (err)
                        return done(err);
                    // check to see if theres already a user with that name
                    if (namedUser || _.contains(usernameBlacklist, profile.username)) {
                        if(namedUser.twitter && namedUser.twitter.id == profile.id)
                            // all is well, return successful user
                            return done(null, user);
                        else 
                            // username taken
                            // todo this should show a message to the user that appears
                            return done(null, false, {message: 'Your twitter handle is taken. Please sign up using the form instead.'});
                    }
                    else {
                        // get their tweets

                        // remote twitter
                        // check if local
                        if (process.env.PORT){
                            var twit = new twitter({
                                consumer_key: 'iRnrLu6QrYHPlOF0wq2ns1MYl',
                                consumer_secret: 'bdIQkb16hSVAvr64sTkq0YXhyysBoZ5dvMQSM9d3tdsCz3JdNx',
                                access_token_key: token,
                                access_token_secret: tokenSecret
                            });
                        }
                        else{// if local
                            var twit = new Twit({
                                consumer_key: "4KN2VexuhVr7d3Ic7pHqZUVZD",
                                consumer_secret: "fy5P5cfeb6ediweO8XItI52Jlh7366bNex5tPjdyAPBq8Ix3mP",
                                access_token: token,
                                access_token_secret: tokenSecret
                            });
                        }

                        twit.get('statuses/user_timeline', {count: 200, screen_name: profile.username, include_entities:false}, function(err, data, res) {
                            // console.log(data, res.statusCode);
                            // create the user
                            var newUser             = new User();
                            // set the user's local credentials
                            newUser.local.email     = profile.email;
                            newUser.local.name      = profile.username;
                            newUser.local.nameLower = profile.username.toLowerCase();
                            newUser.twitter = profile._json;
                            newUser.twitter.id = profile.id;
                            newUser.twitter.username = profile.username;
                            newUser.twitter.displayName = profile.displayName;
                            newUser.twitter.tweets = data; // 200 tweets
                            // save the user
                            newUser.save(function(err) {
                                if (err)
                                    throw err;
                                return done(null, newUser);
                            });
                        });        
                    }
                });
            });
        });
      }
    ));

    // =========================================================================
    // LOCAL SIGNUP ============================================================
    // =========================================================================
    // we are using named strategies since we have one for login and one for signup
    // by default, if there was no name, it would just be called 'local'

    passport.use('local-signup', new LocalStrategy({
        // by default, local strategy uses username and password, we will override with email
        usernameField : 'email',
        passwordField : 'password',
        nameField     : 'name',
        passReqToCallback : true // allows us to pass back the entire request to the callback
    },
    function(req, email, password, done) {

        // asynchronous
        // User.findOne wont fire unless data is sent back
        process.nextTick(function() {

            // find a user whose email is the same as the forms email
            // we are checking to see if the user trying to login already exists
            User.findOne({ 'local.email' :  email }, function(err, user) {
                // if there are any errors, return the error
                if (err)
                    return done(err);

                // check to see if theres already a user with that email
                if (user) {
                    return done(null, false, req.flash('signupMessage', 'That email is being used by another account.'));
                }
                if (!userNameRegEx.test(req.body.name)) {
                    return done(null, false, req.flash('signupMessage', 'You must choose a username (with only letters and numbers).'));
                }
                else {
                    // if there is no user with that email
                    // check to see if the username is available
                    User.findOne({ 'local.nameLower' :  req.body.name.toLowerCase() }, function(err, namedUser) {
                        // if there are any errors, return the error
                        if (err)
                            return done(err);
                        // check to see if theres already a user with that name
                        if (namedUser || _.contains(usernameBlacklist, req.body.name)) {
                            return done(null, false, req.flash('signupMessage', 'That username is already taken.'));
                        }
                        else {
                            // create the user
                            var newUser            = new User();

                            // set the user's local credentials
                            newUser.local.email     = email;
                            newUser.local.name      = req.body.name;
                            newUser.local.nameLower = newUser.local.name.toLowerCase();
                            newUser.local.password  = newUser.generateHash(password);
                            newUser.local.twitter   = {}
                    // save the user
                            newUser.save(function(err) {
                                if (err)
                                    throw err;
                                return done(null, newUser);
                            });
                        }
                    });
                }

            });  

        });

    }));

    // =========================================================================
    // LOCAL LOGIN =============================================================
    // =========================================================================
    // we are using named strategies since we have one for login and one for signup
    // by default, if there was no name, it would just be called 'local'

    passport.use('local-login', new LocalStrategy({
        // by default, local strategy uses username and password, we will override with email
        usernameField : 'email',
        passwordField : 'password',
        passReqToCallback : true // allows us to pass back the entire request to the callback
    },
    function(req, email, password, done) { // callback with email and password from our form

        // find a user whose email is the same as the forms email
        // we are checking to see if the user trying to login already exists
        User.findOne({ 'local.email' :  email }, function(err, user) {
            // if there are any errors, return the error before anything else
            if (err)
                return done(err);

            // if no user is found, return the message
            if (!user)
                return done(null, false, req.flash('loginMessage', 'No user found.')); // req.flash is the way to set flashdata using connect-flash

            // if the user is found but the password is wrong
            if (!user.validPassword(password))
                return done(null, false, req.flash('loginMessage', 'Oops! Wrong password.')); // create the loginMessage and save it to session as flashdata

            // all is well, return successful user
            return done(null, user);
        });

    }));

};
