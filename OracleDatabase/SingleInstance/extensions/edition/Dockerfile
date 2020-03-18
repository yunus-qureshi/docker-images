# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database with Edition Switch support
#
# REQUIREMETNS FOR THIS IMAGE
# ----------------------------------
#
#
# HOW TO BUILD THIS IMAGE
# -----------------------
#
# Run:
#      $ docker build -t oracle/database
#
# Pull base image
# ---------------

FROM oracle/database

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------

#  Relinking enterprise and standard oracle binaries
USER oracle
RUN mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_bkp && \
    cd $ORACLE_HOME/rdbms/lib && \
    make -f ins_rdbms.mk edition_enterprise ioracle && \
    mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_ent && \
    make -f ins_rdbms.mk edition_standard ioracle && \
    mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_std && \
    mv $ORACLE_HOME/bin/oracle_bkp $ORACLE_HOME/bin/oracle



