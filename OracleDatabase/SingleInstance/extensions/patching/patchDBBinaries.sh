#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
# 
# Since: March, 2020
# Author: rishabh.y.gupta@oracle.com
# Description: Applies the patches provided by the user on the oracle home.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

PATCHES_LIST=()

for patch_zip in $PATCH_DIR/*.zip; do
    patch_no=$(echo ${patch_zip##*/} | cut -d_ -f1 | cut -dp -f2)
    if [ $patch_no == "6880880" ]; then
        echo "Removing directory ${ORACLE_HOME}/OPatch";
        rm -rf ${ORACLE_HOME}/OPatch;
        echo "Unzipping OPatch archive $patch_zip to ${ORACLE_HOME}";
        unzip $patch_zip -d $ORACLE_HOME;
    else
        PATCHES_LIST+=($patch_no);
        echo "Unzipping $patch_zip";
        unzip $patch_zip -d $PATCH_DIR;
    fi
done

export PATH=${ORACLE_HOME}/perl/bin:$PATH;

for patch in ${PATCHES_LIST[@]}; do
    echo "Applying patch $patch";
    cmd="${ORACLE_HOME}/OPatch/opatchauto apply -binary -oh $ORACLE_HOME ${PATCH_DIR}/${patch} -target_type rac_database";
    echo "Running: $cmd";
    $cmd;
done



