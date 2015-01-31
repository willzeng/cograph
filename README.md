Cograph
=====
Live at: [cograph.co](http://cograph.co)

![Cograph screenshot](http://www.wjzeng.net/shared/screenshot.png)

Cograph is a free, open source platform for making and sharing webs of ideas.

It was born of many ideas and is maintained by [Will Zeng](https://github.com/willzeng), [David Furlong](https://github.com/davidfurlong/) + [contributors](https://github.com/willzeng/cograph/graphs/contributors).
We're happy to [acknowledge the help of many friends](https://github.com/willzeng/cograph/wiki/Acknowledgements) who helped inspire the project.

Contributing
----------
Anyone is welcome to report a bug, request a feature, or otherwise contribute to Cograph.  We'll be tracking all such things through this repo's [issue tracker](https://github.com/willzeng/cograph/issues) and you can some of the upcoming roadmap on the project's [homepage](http://cograph.co).

API
----------
Some details of the Cograph server API can be found on the [wiki page](https://github.com/willzeng/cograph/wiki).

How to Run Locally
----------

- Neo4j Server >= 2.1.3 Required
You can get the Community edition here: [Download](http://neo4j.com/download-4/?utm_expid=86168100-4.4jhtKky8TSanVw1z1BH-8A.3&utm_referrer=http%3A%2F%2Fneo4j.com%2F)
- Clone this repo
- `npm install` should install your node modules in the `node_modules/` folder.
- `npm install -g bower` should install bower to your global path.
- `bower install` should install your front end models in the `assets/libs/` folder.

Then you should be able to run `./bin/www` to get the server running at `localhost:3000/`

Testing
-------
TODO

Copyright & License
-------
Copyright (c) 2014-2015 GraphDocs Inc. - Released under [GPLv2](https://github.com/willzeng/cograph/blob/dev/LICENSE)
