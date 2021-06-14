#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
#
# Since: March, 2020
# Author: rishabh.y.gupta@oracle.com
# Description: Relinks oracle binary in accordance with the edition passed by the user.
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

major_version=$(${ORACLE_HOME}/bin/oraversion -majorVersion)
LIB_EDITION="/usr/bin/ar t ${ORACLE_HOME}/lib/libedtn"
if [ ${major_version} -gt 19 ]; then
    LIB_EDITION=$(${LIB_EDITION}.a)
else
    LIB_EDITION=$(${LIB_EDITION}${major_version}.a)
fi
LIB_EDITION=$(echo ${LIB_EDITION} | cut -d. -f1)
LIB_EDITION=${LIB_EDITION: -3}

if [ "${LIB_EDITION}" == "ent" ]; then
    CURRENT_EDITION="ENTERPRISE"
fi

if [ "${LIB_EDITION}" == "std" ]; then
    CURRENT_EDITION="STANDARD"
fi

# If datafiles already exists
if [ -d $ORACLE_BASE/oradata/$ORACLE_SID ]; then
    datafiles_edition=$(ls $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/.docker_* | rev | cut -d_ -f1 | rev)
    if [ -n "${ORACLE_EDITION}" ] && [ "${ORACLE_EDITION,,}" != $datafiles_edition ]; then
        echo "The datafiles being used were created with $datafiles_edition edition software home. Please pass -e ORACLE_EDITION=$datafiles_edition to the docker run cmd.";
        exit 1;
    elif [ -z "${ORACLE_EDITION}" ] && [ "${CURRENT_EDITION,,}" != $datafiles_edition ]; then
        echo "The current software home is of ${CURRENT_EDITION,,} edition whereas the datafiles being used were created with $datafiles_edition edition software home. Please pass -e ORACLE_EDITION=$datafiles_edition to the docker run cmd.";
        exit 1;
    fi
fi

if [ -n "${ORACLE_EDITION}" ]; then
    if [ "${CURRENT_EDITION}" != "${ORACLE_EDITION^^}" ]; then
        echo "Relinking oracle binary for edition: ${ORACLE_EDITION}";
        cmd="make -f ${ORACLE_HOME}/rdbms/lib/ins_rdbms.mk edition_${ORACLE_EDITION,,} ioracle";
        echo "$cmd";
        $cmd;
        CURRENT_EDITION=${ORACLE_EDITION^^}
    fi
fi

echo "ORACLE EDITION: ${CURRENT_EDITION}"
touch $ORACLE_HOME/install/.docker_${CURRENT_EDITION,,}
