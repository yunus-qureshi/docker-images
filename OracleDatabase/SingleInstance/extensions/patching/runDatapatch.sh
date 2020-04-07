#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: March, 2020
# Author: rishabh.y.gupta@oracle.com
# Description: Runs datapatch in a container while using existing datafiles if container is at different RU level
#              than the container which created the datafiles
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

LSPATCHES_FILE="${ORACLE_SID}.lspatches"
LSPATCHES_FILE_PATH="${ORACLE_BASE}/oradata/dbconfig/${ORACLE_SID}/${LSPATCHES_FILE}"

if [ -e $LSPATCHES_FILE_PATH ]; then
  cd ${ORACLE_BASE}/oradata/dbconfig/${ORACLE_SID};
  $ORACLE_HOME/OPatch/opatch lspatches >> temp.lspatches;
  diff -r ${LSPATCHES_FILE} temp.lspatches;
  if [ $? -eq 0 ]; then
    echo "Container is already patched. Skipping datapatch run."
  else
    echo "Running datapatch...";
    $ORACLE_HOME/OPatch/datapatch -skip_upgrade_check;
    if [ $? -ne 0 ]; then
      echo "Datapatch execution has failed."
      exit;
    fi
  fi
  rm temp.lspatches;
else
  echo "Running datapatch...";
  $ORACLE_HOME/OPatch/datapatch -skip_upgrade_check;
  if [ $? -eq 0 ]; then
    $ORACLE_HOME/OPatch/opatch lspatches >> ${LSPATCHES_FILE_PATH};
  else
    echo "Datapatch execution has failed.";
    exit;
  fi
fi