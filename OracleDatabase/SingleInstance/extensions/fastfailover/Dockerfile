# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database with Fast Fail Over support
#
# REQUIREMETNS FOR THIS IMAGE
# ----------------------------------
# The oracle/datab
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put the downloaded patch(es) into the sub folders patch/0NN
# Run:
#      $ docker build -t oracle/database:fastfailover .
#
# Pull base image
# ---------------

ARG TAG=latest
FROM oracle/database:${TAG}

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_SID=ORCLCDB \
    LOCKING_SCRIPT=file_lock.py \
    SWAP_LOCK_FILE=swapLocks.sh

ENV CREATE_LOCK_FILE=$ORACLE_BASE/oradata/${ORACLE_SID}.create_lck \
    EXIST_LOCK_FILE=$ORACLE_BASE/oradata/${ORACLE_SID}.exist_lck

# Turn on dnfs
RUN cd $ORACLE_HOME/rdbms/lib && make -f ins_rdbms.mk dnfs_on

# Copy updated scripts to support fastfailover
COPY  --chown=oracle:dba $START_FILE $LOCKING_SCRIPT $ORACLE_BASE/
COPY  --chown=oracle:dba $SWAP_LOCK_FILE $ORACLE_BASE/scripts/setup/

HEALTHCHECK --interval=1m --start-period=15m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || \
   ( "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file $EXIST_LOCK_FILE && \
   "$ORACLE_BASE/$LOCKING_SCRIPT" --check --file $CREATE_LOCK_FILE ) || \
   "$ORACLE_BASE/$LOCKING_SCRIPT" --release --file $EXIST_LOCK_FILE

# Define default command to start Oracle Database.
CMD $ORACLE_BASE/$LOCKING_SCRIPT --acquire --file $CREATE_LOCK_FILE --block && \
    exec $ORACLE_BASE/$RUN_FILE
