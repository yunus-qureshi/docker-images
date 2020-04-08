#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: Mar, 2020
# Author: mohammed.qureshi@oracle.com
# Description: Swap file locks
#
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
if ! pgrep -f pmon; then
  # there is some problem in DB create/startup. Do not swap locks
  exit 1
fi
"$ORACLE_BASE/$LOCKING_SCRIPT" --release --file "$ORACLE_BASE/oradata/.${ORACLE_SID}.create_lck"
if ! pgrep -f "$LOCKING_SCRIPT.*--acquire.*exist_lck"; then
  # Acquire exist lock if not already acquired or trying. This is a blocking class
  "$ORACLE_BASE/$LOCKING_SCRIPT" --acquire --file "$ORACLE_BASE/oradata/.${ORACLE_SID}.exist_lck" --block
fi
