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

if "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file "$ORACLE_BASE/oradata/.${ORACLE_SID}.create_lck"; then
  exit 1  # create lock held, DB is still initializing
elif ! "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file "$ORACLE_BASE/oradata/.${ORACLE_SID}.exist_lck"; then
  exit 1 # exist lock not held, DB is still initializing
elif "$ORACLE_BASE/$CHECK_DB_FILE"; then
  # DB health is good, delete no check file
  rm -f "$ORACLE_BASE/oradata/.${ORACLE_SID}.nochk"
elif test -f "$ORACLE_BASE/oradata/.${ORACLE_SID}.nochk"; then
  exit 1 # Skip health check
else
  # DB status is not good, check if starting
  if pgrep -f "$START_FILE"; then
    # still starting
    exit 1
  else
    # if not blocked on create or start, release exist lock
    "$ORACLE_BASE/$LOCKING_SCRIPT" --release --file "$ORACLE_BASE/oradata/.${ORACLE_SID}.exist_lck"
    # Kill the process that keeps the container alive
    pkill -9 -f "tail.*alert"
  fi
fi
