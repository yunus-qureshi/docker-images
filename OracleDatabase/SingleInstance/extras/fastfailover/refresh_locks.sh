#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: November, 2020
# Author: mohammed.qureshi@oracle.com
# Description: Refreshes file locks 
#
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

$ORACLE_BASE/file_lock.py --acquire --file $ORACLE_BASE/oradata/$ORACLE_SID.exist_lck --block
$ORACLE_BASE/file_lock.py --release --file $ORACLE_BASE/oradata/$ORACLE_SID.create_lck
