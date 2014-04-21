#!/bin/sh

# compile the coffeescript files in this example project
coffee --watch --compile -o assets/js/ models/*.coffee &

coffee --watch --compile -o assets/js/ views/*.coffee &

coffee --watch --compile -o assets/js/ Rhizi.coffee &

coffee --watch --compile -o assets/js/ main.coffee &

coffee --watch --compile -o assets/js/ routes/routes.coffee &

# statically serve files out of ./bin/www
node bin/www
