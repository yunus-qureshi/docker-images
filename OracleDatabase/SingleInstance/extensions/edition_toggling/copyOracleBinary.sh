#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
# 
# Since: March, 2020
# Author: rishabh.y.gupta@oracle.com
# Description: Copies the correct oracle binary in accordance with the edition passed by the user.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# Default for ORACLE_EDITION
export ORACLE_EDITION=${ORACLE_EDITION:-enterprise}

BINARY_NAME=""

if [ "${ORACLE_EDITION,,}" == "enterprise" ]; then
  BINARY_NAME="oracle_ent"
fi;

if [ "${ORACLE_EDITION,,}" == "standard" ]; then
  BINARY_NAME="oracle_std"
fi;

# Checking for existence of oracle binaries as during restart of docker
# container the ent/std binaries won't be present inside the container
if [ -e $ORACLE_HOME/bin/$BINARY_NAME ]; then
  cp $ORACLE_HOME/bin/$BINARY_NAME $ORACLE_HOME/bin/oracle
  echo "Copied the oracle binary for edition: ${ORACLE_EDITION}"
  # Deleting rest of the oracle binaries
  rm $ORACLE_HOME/bin/oracle_*
else
  echo "Oracle binary is already linked for edition ${ORACLE_EDITION}"
fi;