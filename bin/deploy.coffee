#!/usr/bin/env coffee

require 'shelljs/global'

HEROKU_APP = process.env.HEROKU_APP ? throw new Error("Please set environment variable HEROKU_APP")

run = (cmd, options = {}) ->
  continue_on_failure = options.continue_on_failure ? false
  echo "==> #{cmd}"
  code = (exec cmd).code
  if code isnt 0
    echo 'COMMAND FAILED'
    exit(code) unless continue_on_failure
  code

run "bin/compile"
run "git add ."
run "git add --force --no-ignore-removal app/assets/libs/"
run "git commit -m 'deploy'"
# run "heroku maintenance:on --app #{HEROKU_APP}"
deploy_result = run "git push --force git@heroku.com:#{HEROKU_APP}.git HEAD:master", continue_on_failure: true
# run "heroku maintenance:off --app #{HEROKU_APP}"
exit deploy_result
