GraphDocs
=====

How to Run
----------

`npm install` should install your node modules in the `node_modules/` folder.

`npm install -g bower` should install bower to your global path.

`bower install` should install your front end models in the `assets/libs/` folder.

Then you should be able to run `./bin/www` to get the server running at `localhost:3000/`


Testing using Jasmine
----------

jasmine-node --coffee spec/

specs must match `*spec.coffee`

Reference:
http://jasmine.github.io/1.3/introduction.html
https://www.npmjs.org/package/jasmine-node