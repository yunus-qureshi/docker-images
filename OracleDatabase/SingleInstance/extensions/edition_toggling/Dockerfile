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
ENV RELINK_BINARY_FILE="relinkOracleBinary.sh"

# backup origin runOracle
RUN mv "$ORACLE_BASE/$RUN_FILE" "$ORACLE_BASE/$RUN_FILE.$EXTENSION_NAME"

# Copy updated runOracle.sh and relinkOracleBinary.sh supporting edition switching
COPY  --chown=oracle:dba $RUN_FILE $RELINK_BINARY_FILE $ORACLE_BASE/
RUN chmod ug+x $ORACLE_BASE/*.sh && sync

# Append a call to main runOracle
RUN echo -e "\n. $ORACLE_BASE/$RUN_FILE.$EXTENSION_NAME" >> "$ORACLE_BASE/$RUN_FILE"
