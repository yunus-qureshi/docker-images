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
#      $ docker build -t <extended_image_name> . --build-arg BASE_IMAGE=oracle/database:18.3.0-ee
#
# Pull base image
# ---------------
ARG BASE_IMAGE=oracle/database:19.3.0-ee
FROM ${BASE_IMAGE}

# Extn name
ARG EXTENSION_NAME="edition_toggling"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV TOGGLE_EDITION_FILE="copyOracleBinary.sh"

#  Relinking enterprise and standard oracle binaries
RUN mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_bkp && \
    cd $ORACLE_HOME/rdbms/lib && \
    make -f ins_rdbms.mk edition_enterprise ioracle && \
    mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_ent && \
    make -f ins_rdbms.mk edition_standard ioracle && \
    mv $ORACLE_HOME/bin/oracle $ORACLE_HOME/bin/oracle_std && \
    mv $ORACLE_HOME/bin/oracle_bkp $ORACLE_HOME/bin/oracle

# backup origin runOracle
RUN mv "$ORACLE_BASE/$RUN_FILE" "$ORACLE_BASE/$RUN_FILE.$EXTENSION_NAME"

# Copy updated runOracle.sh and copyOracleBinary.sh supporting edition switching
COPY  --chown=oracle:dba $RUN_FILE $TOGGLE_EDITION_FILE $ORACLE_BASE/

# Append a call to main runOracle
RUN echo ". $ORACLE_BASE/$RUN_FILE.$EXTENSION_NAME" >> "$ORACLE_BASE/$RUN_FILE"
