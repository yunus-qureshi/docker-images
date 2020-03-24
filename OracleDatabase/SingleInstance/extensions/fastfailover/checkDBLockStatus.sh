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

if "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file "$ORACLE_BASE/oradata/${ORACLE_SID}.create_lck"; then
  exit 1  # create lock held, DB is still initializing
elif ! "$ORACLE_BASE/$CHECK_DB_FILE"; then
  # DB status is not good, check if blocked acquiring create lock
  if pgrep -f "$LOCKING_SCRIPT.*--acquire.*create_lck"; then
    # blocked acquiring create lock
    exit 1
  else
    # if not blocked, release exist lock
    "$ORACLE_BASE/$LOCKING_SCRIPT" --release --file "$ORACLE_BASE/oradata/${ORACLE_SID}.exist_lck"
    # Kill the process that keeps the container alive
    pkill -9 -f "tail.*alert"
  fi
fi
