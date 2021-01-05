#!/bin/bash
#
# In development, run `bundle install` once and run debugger.
#
# In prod, cleanup pids and run server.
#

FILE=".init"
INSTALL="bundle install"
SETUP="bundle exec rails db:setup"
CLEANUP="rm -f /app/tmp/pids/server.pid"
RUN="bundle exec rails server -p 5000 -b 0.0.0.0"
DEBUG="bundle exec rdebug-ide --debug --host 0.0.0.0 --port 4444 -- bin/rails server -p 5000 -b 0.0.0.0"

if [ "$DEBUGGER" == "true" ]; then
  echo "[bundle] Setting up debugger..."
  RUN=${DEBUG}
fi

if [[ -f ${FILE} ]]; then
  ${CLEANUP}
  ${RUN}
else

  # bundle install in development
  if [ "$RAILS_ENV" == "development" ]; then
    echo "[bundle] First run detected, installing..."
    ${INSTALL}
  fi

  # 
  touch ${FILE} && ${SETUP}

  ${RUN}
fi
