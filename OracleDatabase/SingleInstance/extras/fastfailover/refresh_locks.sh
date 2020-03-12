#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Starts the Listener and Oracle Database.
#              The ORACLE_HOME and the PATH has to be set.
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

$ORACLE_BASE/file_lock.py --acquire --file $ORACLE_BASE/oradata/$ORACLE_SID.exist_lck --block
$ORACLE_BASE/file_lock.py --release --file $ORACLE_BASE/oradata/$ORACLE_SID.create_lck
