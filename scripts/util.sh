#!/bin/bash

function create_external_facter {
  # FACT_LOCATION=/etc/puppetlabs/facter/facts.d
  FACT_LOCATION=/etc/facter/facts.d/
  mkdir -p "${FACT_LOCATION}"
  chown root:root "${FACT_LOCATION}"
  chmod 700 "${FACT_LOCATION}"

  ROLE="testing_whatever"
  touch ${FACT_LOCATION}/pp_role.txt && \
  chown root:root ${FACT_LOCATION}/pp_role.txt && \
  chmod 644 ${FACT_LOCATION}/pp_role.txt && \
  echo -e "pp_role=${ROLE}" >> ${FACT_LOCATION}/pp_role.txt
}