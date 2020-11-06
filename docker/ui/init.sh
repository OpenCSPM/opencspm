#!/bin/bash
#
# Run `yarn install` once on first run
#

FILE=".init"
MSG="[yarn] First run detected, installing..."
CMD="yarn install"
RUN="yarn serve"

if [[ -f ${FILE} ]]; then
  ${RUN}
else
  echo ${MSG}
  ${CMD} && touch ${FILE}
  ${RUN}
fi
