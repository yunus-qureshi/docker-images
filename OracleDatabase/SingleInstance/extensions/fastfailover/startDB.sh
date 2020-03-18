#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: Mar, 2020
# Author: mohammed.qureshi@oracle.com
# Description: Starts the Listener and Oracle Database.
#              The ORACLE_HOME and the PATH has to be set.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# Check that ORACLE_HOME is set
if [ "$ORACLE_HOME" == "" ]; then
  script_name=`basename "$0"`
  echo "$script_name: ERROR - ORACLE_HOME is not set. Please set ORACLE_HOME and PATH before invoking this script."
  exit 1;
fi;

# Start database in nomount mode
sqlplus / as sysdba << EOF
   STARTUP nomount;
   exit;
EOF

$ORACLE_BASE/$LOCKING_SCRIPT --acquire --file $EXIST_LOCK_FILE --block

# Start Listener
lsnrctl start

# Start database
sqlplus / as sysdba << EOF
   alter database mount;
   alter database open;
   alter pluggable database all open;
   alter system register;
   exit;
EOF

$ORACLE_BASE/$LOCKING_SCRIPT --release --file $CREATE_LOCK_FILE