#!/bin/bash
#
# Run `bundle install` once on first run
#

FILE=".init"
MSG="[bundle] First run detected, installing..."
CMD="bundle install"
SETUP="bundle exec rails db:setup"
CLEANUP="rm -f /app/tmp/pids/server.pid"
RUN="bundle exec rails server -p 5000 -b 0.0.0.0"

if [[ -f ${FILE} ]]; then
  ${CLEANUP}
  ${RUN}
else
  echo ${MSG}
  ${CMD} && touch ${FILE}
  ${SETUP}
  ${RUN}
fi

