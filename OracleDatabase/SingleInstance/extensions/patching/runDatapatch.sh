#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
#
# Since: March, 2020
# Author: rishabh.y.gupta@oracle.com
# Description: Runs datapatch in a container while using existing datafiles if container is at different RU level
#              than the container which created the datafiles
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# LSPATCHES_FILE will have the patch summary of the datafiles.
LSPATCHES_FILE="${ORACLE_SID}.lspatches"
LSPATCHES_FILE_DIR="${ORACLE_BASE}/oradata/dbconfig/${ORACLE_SID}"

cd $LSPATCHES_FILE_DIR;
# tmp.lspatches will have the patch summary of the oracle home.
$ORACLE_HOME/OPatch/opatch lspatches > tmp.lspatches;

if diff ${LSPATCHES_FILE} tmp.lspatches 2> /dev/null; then
    echo "Datafiles are already patched. Skipping datapatch run."
else
    echo "Running datapatch...";
    if ! $ORACLE_HOME/OPatch/datapatch -skip_upgrade_check; then
        echo "Datapatch execution has failed.";
        rm tmp.lspatches;
        exit;
    fi
    $ORACLE_HOME/OPatch/opatch lspatches > tmp.lspatches;
fi
mv tmp.lspatches ${LSPATCHES_FILE};
