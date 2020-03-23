#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: Mar, 2020
# Author: mohammed.qureshi@oracle.com
# Description: Checks the status of Oracle Database and Locks
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

ORACLE_SID="`grep $ORACLE_HOME /etc/oratab | cut -d: -f1`"

"$ORACLE_BASE/$LOCKING_SCRIPT" --check --file "$ORACLE_BASE/oradata/${ORACLE_SID}.create_lck"
if [ $? -ne 0 ]; then  # Ok create lock not held, now check status
  "$ORACLE_BASE/$CHECK_DB_FILE"
  if [ $? -ne 0 ]; then # DB status is not good
    "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file "$ORACLE_BASE/oradata/${ORACLE_SID}.exist_lck"
    if [ $? -eq 0 ]; then # if exist lock is held release it
      "$ORACLE_BASE/$LOCKING_SCRIPT" --release --file "$ORACLE_BASE/oradata/${ORACLE_SID}.exist_lck"
    else
      exit 1
    fi
  fi
fi
