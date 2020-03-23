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

if [ "${ORACLE_EDITION,,}" == "enterprise" ]; then
  cp $ORACLE_HOME/bin/oracle_ent $ORACLE_HOME/bin/oracle
fi

if [ "${ORACLE_EDITION,,}" == "standard" ]; then
  cp $ORACLE_HOME/bin/oracle_std $ORACLE_HOME/bin/oracle
fi

# Deleting rest of the oracle binaries
rm $ORACLE_HOME/bin/oracle_*

echo "Copied the oracle binary for edition: ${ORACLE_EDITION}"