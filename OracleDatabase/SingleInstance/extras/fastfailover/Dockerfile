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

FROM oracle/database

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_SID=ORCLCDB

# Turn on dnfs
RUN cd $ORACLE_HOME/rdbms/lib && make -f ins_rdbms.mk dnfs_on

# Copy updated scripts to support multiple DB pods
COPY  --chown=oracle:dba startDB.sh file_lock.py $ORACLE_BASE/
COPY  --chown=oracle:dba refresh_locks.sh $ORACLE_BASE/scripts/setup/

HEALTHCHECK --interval=1m --start-period=5m \
   CMD $ORACLE_BASE/file_lock.py --check --file $ORACLE_BASE/oradata/$ORACLE_SID.exist_lck && \
   $ORACLE_BASE/$CHECK_DB_FILE >/dev/null || \
   $ORACLE_BASE/file_lock.py --release --file $ORACLE_BASE/oradata/$ORACLE_SID.exist_lck

# Define default command to start Oracle Database.
CMD $ORACLE_BASE/file_lock.py --acquire --file $ORACLE_BASE/oradata/$ORACLE_SID.create_lck --block && \
    exec $ORACLE_BASE/$RUN_FILE
