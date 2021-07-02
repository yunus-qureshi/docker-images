#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
# 
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Creates an Oracle Database based on following parameters:
#              $ORACLE_SID: The Oracle SID and CDB name
#              $ORACLE_PDB: The PDB name
#              $ORACLE_PWD: The Oracle password
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

set -e

############## Setting up network related config files (sqlnet.ora, tnsnames.ora, listener.ora) ##############
function setupNetworkConfig {
  mkdir -p $ORACLE_HOME/network/admin

  # sqlnet.ora
  echo "NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)" > $ORACLE_HOME/network/admin/sqlnet.ora

  # listener.ora
  echo "LISTENER = 
(DESCRIPTION_LIST = 
  (DESCRIPTION = 
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1)) 
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) 
  ) 
) 

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
" > $ORACLE_HOME/network/admin/listener.ora

  # tnsnames.ora
  echo "$ORACLE_SID=localhost:1521/$ORACLE_SID" > $ORACLE_HOME/network/admin/tnsnames.ora

  if [[ "${CREATE_PDB}" == "true" ]]; then
    echo "$ORACLE_PDB= 
(DESCRIPTION = 
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)" >> $ORACLE_HOME/network/admin/tnsnames.ora
  fi;

}

###################################
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
############# MAIN ################
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
###################################

# Check whether ORACLE_SID is passed on
export ORACLE_SID=${1:-ORCLCDB}

# Check whether ORACLE_PDB is passed on
export ORACLE_PDB=${2:-ORCLPDB1}

# Checking if only one of INIT_SGA_SIZE & INIT_PGA_SIZE is provided by the user
if [[ "${INIT_SGA_SIZE}" != "" && "${INIT_PGA_SIZE}" == "" ]] || [[ "${INIT_SGA_SIZE}" == "" && "${INIT_PGA_SIZE}" != "" ]]; then
   echo "ERROR: Provide both the values, INIT_SGA_SIZE and INIT_PGA_SIZE or neither of them. Exiting.";
   exit 1;
fi;

# Auto generate ORACLE PWD if not passed on
export ORACLE_PWD=${3:-"`openssl rand -base64 8`1"}
echo "ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: $ORACLE_PWD";

# Clone DB/ Standby DB creation path
if [[ "${CLONE_DB}" == "true" ]] || [[ "${STANDBY_DB}" == "true" ]]; then
  # Validation: Check if PRIMARY_DB_CONN_STR is provided or not
  if [[ -z "${PRIMARY_DB_CONN_STR}" ]] || [[ $PRIMARY_DB_CONN_STR != *:*/* ]]; then
    echo "ERROR: Please provide PRIMARY_DB_CONN_STR in <HOST>:<PORT>/<SERVICE_NAME> format to connect with primary database. Exiting..."
    exit 1
  fi

  # Validation: Check if ORACLE_PWD is provided or not
  if [[ -z "${ORACLE_PWD}" ]]; then
    echo "ERROR: Please provide password of sys user as ORACLE_PWD to connect with primary database. Exiting..."
    exit 1
  fi

  # Primary database parameters extration
  PRIMARY_DB_NAME=$(echo "${PRIMARY_DB_CONN_STR}" | cut -d '/' -f 2)
  PRIMARY_DB_IP=$(echo "${PRIMARY_DB_CONN_STR}" | cut -d ':' -f 1)
  PRIMARY_DB_PORT=$(echo "${PRIMARY_DB_CONN_STR}" | cut -d ':' -f 2 | cut -d '/' -f 1)

  # Setup network related configuration
  setupNetworkConfig;

  # Starting Listener
  lsnrctl start;

  # Creating the database using the dbca command
  if [ "${STANDBY_DB}" = "true" ]; then
    # Creating standby database
    dbca -silent -createDuplicateDB -gdbName ${PRIMARY_DB_NAME} -primaryDBConnectionString ${PRIMARY_DB_CONN_STR} -sysPassword ${ORACLE_PWD} -sid ${ORACLE_SID} -createAsStandby -dbUniquename ${ORACLE_SID} ORACLE_HOSTNAME=${ORACLE_HOSTNAME} ||
      cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log ||
      cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID.log
  else
    # Creating clone database after duplicating a primary database; CLONE_DB is set to true here
    dbca -silent -createDuplicateDB -gdbName ${ORACLE_SID} -primaryDBConnectionString ${PRIMARY_DB_CONN_STR} -sysPassword ${ORACLE_PWD} -sid ${ORACLE_SID} -databaseConfigType SINGLE -useOMF true -dbUniquename ${ORACLE_SID} ORACLE_HOSTNAME=${ORACLE_HOSTNAME} ||
      cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log ||
      cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID.log
  fi

  exit 0
fi

# Replace place holders in response file
cp $ORACLE_BASE/$CONFIG_RSP $ORACLE_BASE/dbca.rsp
sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" $ORACLE_BASE/dbca.rsp
sed -i -e "s|###ORACLE_PDB###|$ORACLE_PDB|g" $ORACLE_BASE/dbca.rsp
sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" $ORACLE_BASE/dbca.rsp
sed -i -e "s|###ORACLE_CHARACTERSET###|$ORACLE_CHARACTERSET|g" $ORACLE_BASE/dbca.rsp

# If both INIT_SGA_SIZE & INIT_PGA_SIZE aren't provided by user
if [[ "${INIT_SGA_SIZE}" == "" && "${INIT_PGA_SIZE}" == "" ]]; then
    # If there is greater than 8 CPUs default back to dbca memory calculations
    # dbca will automatically pick 40% of available memory for Oracle DB
    # The minimum of 2G is for small environments to guarantee that Oracle has enough memory to function
    # However, bigger environment can and should use more of the available memory
    # This is due to Github Issue #307
    if [ `nproc` -gt 8 ]; then
        sed -i -e "s|totalMemory=2048||g" $ORACLE_BASE/dbca.rsp
    fi;
else
    sed -i -e "s|totalMemory=2048||g" $ORACLE_BASE/dbca.rsp
    sed -i -e "s|initParams=.*|&,sga_target=${INIT_SGA_SIZE}M,pga_aggregate_target=${INIT_PGA_SIZE}M|g" $ORACLE_BASE/dbca.rsp
fi;

# Change value of the numberOfPDBs to 0 if CREATE_PDB flag is false
 if [ "$CREATE_PDB" = "false" ]; then
   sed -i "s|numberOfPDBs=1|numberOfPDBs=0|g" $ORACLE_BASE/dbca.rsp
 fi

# Create network related config files (sqlnet.ora, tnsnames.ora, listener.ora)
setupNetworkConfig;

# Directory for storing archive logs
export ARCHIVELOG_DIR=$ORACLE_BASE/oradata/$ORACLE_SID/$ARCHIVELOG_DIR_NAME

# Start LISTENER and run DBCA
lsnrctl start &&
dbca -silent -createDatabase -enableArchive $ENABLE_ARCHIVELOG -archiveLogDest $ARCHIVELOG_DIR -responseFile $ORACLE_BASE/dbca.rsp ||
 cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log ||
 cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID.log

if [ "$CREATE_PDB" = "true" ]; then
  # Make PDB auto open
  sqlplus / as sysdba << EOF
    ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
    exit;
EOF
fi;

# Remove second control file, fix local_listener, enable EM global port
# Create externally mapped oracle user for health check
sqlplus / as sysdba <<EOF
ALTER SYSTEM SET control_files='$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl' scope=spfile;
ALTER SYSTEM SET local_listener='';
EXEC DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE);

ALTER SESSION SET "_oracle_script" = true;
CREATE USER OPS\$oracle IDENTIFIED EXTERNALLY;
GRANT CREATE SESSION TO OPS\$oracle;
GRANT SELECT ON sys.v_\$pdbs TO OPS\$oracle;
GRANT SELECT ON sys.v_\$database TO OPS\$oracle;
ALTER USER OPS\$oracle SET container_data=all for sys.v_\$pdbs container = current;

exit;
EOF


# Remove temporary response file
rm $ORACLE_BASE/dbca.rsp
