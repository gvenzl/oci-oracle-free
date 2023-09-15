#!/bin/bash
#
# Since: September, 2023
# Author: mochoa
# Name: install.2320.sh
# Description: Install script for Oracle DB 19c EE
#
# Copyright 2023 Marcelo Ochoa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Exit on errors
# Great explanation on https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

echo "BUILDER: started"

# Build mode ("SLIM", "REGULAR", "FULL")
BUILD_MODE=${1:-"REGULAR"}

echo "BUILDER: BUILD_MODE=${BUILD_MODE}"

# Set data file sizes (only executed for REGULAR and SLIM)
SYSAUX_SIZE_CDB=536
SYSAUX_SIZE_SEED=302
SYSAUX_SIZE_PDB=307
SYSTEM_SIZE_CDB=928
SYSTEM_SIZE_SEED=276
SYSTEM_SIZE_PDB=277
REDO_SIZE=20
USERS_SIZE=10
TEMP_SIZE=10
# Overwrite REGULAR with SLIM sizes
if [ "${BUILD_MODE}" == "SLIM" ]; then
  REDO_SIZE=10
  USERS_SIZE=5
  SYSAUX_SIZE_CDB=560
  TEMP_SIZE=10
fi;

# Install 7zip
mkdir /tmp/7z
cd /tmp/7z
curl -s -L -O https://www.7-zip.org/a/7z2201-linux-x64.tar.xz
tar xf 7z*xz
mv 7zzs ${ORACLE_HOME}/bin
cd - 1> /dev/null
rm -rf /tmp/7z

# If not building the FULL image, remove and shrink additional components
if [ "${BUILD_MODE}" == "REGULAR" ] || [ "${BUILD_MODE}" == "SLIM" ]; then

  echo "BUILDER: further optimizations for REGULAR and SLIM image"

  # Open PDB\$SEED to READ/WRITE
  echo "BUILDER: Opening PDB\$SEED in READ/WRITE mode"
  sqlplus -s / as sysdba << EOF

     -- Exit on any errors
     WHENEVER SQLERROR EXIT SQL.SQLCODE

     -- Open PDB\$SEED to READ WRITE mode
     ALTER PLUGGABLE DATABASE PDB\$SEED CLOSE;
     ALTER PLUGGABLE DATABASE PDB\$SEED OPEN READ WRITE;

     exit;
EOF

  # Change parameters/settings
  echo "BUILDER: changing database configuration and parameters for REGULAR and SLIM images"
  sqlplus -s / as sysdba << EOF

     -- Exit on any errors
     WHENEVER SQLERROR EXIT SQL.SQLCODE

     -- Deactivate Intel's Math Kernel Libraries
     -- Like with every underscore parameter, DO NOT SET THIS PARAMETER EVER UNLESS YOU KNOW WHAT THE HECK YOU ARE DOING!
     ALTER SYSTEM SET "_dmm_blas_library"='libora_netlib.so' SCOPE=SPFILE;

     -- Disable shared servers (enables faster shutdown)
     ALTER SYSTEM SET SHARED_SERVERS=0;

     -------------------------------------
     -- Disable password profile checks --
     -------------------------------------

     -- Disable password profile checks (can only be done container by container)
     ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED;

     ALTER SESSION SET CONTAINER=PDB\$SEED;
     ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED;

     ALTER SESSION SET CONTAINER=FREEPDB1;
     ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED;

     exit;
EOF

  ########################
  # Remove DB components #
  ########################

  # Needs to be run as 'oracle' user (Perl script otherwise fails #TODO: see whether it can be run with su -c somehow instead)
  echo "BUILDER: Removing additional components for REGULAR image"
    cd "${ORACLE_HOME}"/rdbms/admin

    # Remove Workspace Manager
    echo "BUILDER: Removing Oracle Workspace Manager"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1  -C 'CDB$ROOT' -b builder_remove_workspace_manager_pdbs -d "${ORACLE_HOME}"/rdbms/admin owmuinst.plb
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1  -c 'CDB$ROOT' -b builder_remove_workspace_manager_cdb -d "${ORACLE_HOME}"/rdbms/admin owmuinst.plb

    # Remove Oracle Database Java Packages
    echo "BUILDER: Removing Oracle Database Java Packages"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_java_packages -d "${ORACLE_HOME}"/rdbms/admin catnojav.sql

    # Remove Oracle XDK
    echo "BUILDER: Removing Oracle XDK"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_xdk -d "${ORACLE_HOME}"/xdk/admin rmxml.sql

    # Remove Oracle JServer JAVA Virtual Machine
    echo "BUILDER: Removing Oracle JServer JAVA Virtual Machine"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_jvm -d "${ORACLE_HOME}"/javavm/install rmjvm.sql

    # https://mikedietrichde.com/2017/08/07/javavm-xml-clean-oracle-database-11-2-12-2/
    echo "BUILDER: BUG 30779964 – RMJVM.SQL BROKEN"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -S -n 1 -b drop_from_pdbs -d "${ORACLE_HOME}"/rdbms/admin drop_from_pdbs.sql
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -c 'CDB$ROOT PDB$SEED' -n 1 -b drop_from_cdb -d "${ORACLE_HOME}"/rdbms/admin drop_from_cdb.sql

    # Remove Oracle OLAP API
    echo "BUILDER: Removing  Oracle OLAP API"
    # Needs to be done one by one, otherwise there is a ORA-65023: active transaction exists in container PDB\$SEED
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'PDB$SEED' -b builder_remove_olap_api_pdbseed_2 -d "${ORACLE_HOME}"/olap/admin/ catnoxoq.sql
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'FREEPDB1' -b builder_remove_olap_api_FREEPDB1_2 -d "${ORACLE_HOME}"/olap/admin/ catnoxoq.sql
    # Remove it from the CDB
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'CDB$ROOT' -b builder_remove_olap_api_cdb_2 -d "${ORACLE_HOME}"/olap/admin/ catnoxoq.sql

    # Remove OLAP Analytic Workspace
    echo "BUILDER: Removing OLAP Analytic Workspace"
    # Needs to be done one by one, otherwise there is a ORA-65023: active transaction exists in container PDB\$SEED
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'PDB$SEED' -b builder_remove_olap_workspace_pdb_seed -d "${ORACLE_HOME}"/olap/admin/ catnoaps.sql
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'FREEPDB1' -b builder_remove_olap_workspace_FREEPDB1 -d "${ORACLE_HOME}"/olap/admin/ catnoaps.sql
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'CDB$ROOT' -b builder_remove_olap_workspace_cdb -d "${ORACLE_HOME}"/olap/admin/ catnoaps.sql

    # Recompile
    echo "BUILDER: Recompiling database objects"
    "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_recompile_all_objects -d "${ORACLE_HOME}"/rdbms/admin utlrp.sql

    # Remove all log files
    rm "${ORACLE_HOME}"/rdbms/admin/builder_*

  ####################################
  # SLIM Image: Remove DB components #
  ####################################

  if [ "${BUILD_MODE}" == "SLIM" ]; then

    # Needs to be run as 'oracle' user (Perl script otherwise fails #TODO: see whether it can be run with su -c somehow instead)

      echo "BUILDER: Removing additional components for SLIM image"
      cd "${ORACLE_HOME}"/rdbms/admin

      # Remove Oracle Text
      echo "BUILDER: Removing Oracle Text"
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_text_pdbs -C 'CDB$ROOT' -d "${ORACLE_HOME}"/ctx/admin catnoctx.sql
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_text_cdb -c 'CDB$ROOT' -d "${ORACLE_HOME}"/ctx/admin catnoctx.sql

      # Remove Spatial
      echo "BUILDER: Removing Oracle Spatial"
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -C 'CDB$ROOT' -b builder_remove_spatial_pdbs -d "${ORACLE_HOME}"/md/admin mddins.sql
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -c 'CDB$ROOT' -b builder_remove_spatial_cdb  -d "${ORACLE_HOME}"/md/admin mddins.sql

      # Remove Locator
      echo "BUILDER: Removing Oracle Locator"
      # Parent script mddinloc.sql does only check for SDO record removed or "OPTION OFF" but the script above leaves it as "REMOVED",
      # therefore this parent script doesn not do anything.
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_remove_locator_pdbs -d "${ORACLE_HOME}"/md/admin mddinsl.sql

      # Recompile
      echo "BUILDER: Recompiling database objects"
      "${ORACLE_HOME}"/perl/bin/perl catcon.pl -n 1 -b builder_recompile_all_objects -d "${ORACLE_HOME}"/rdbms/admin utlrp.sql

      # Remove all log files
      rm "${ORACLE_HOME}"/rdbms/admin/builder_*

    # Drop leftover items
    echo "BUILDER: Dropping leftover Database dictionary objects for SLIM image"
    sqlplus -s / as sysdba << EOF

       -- Exit on any errors
       WHENEVER SQLERROR EXIT SQL.SQLCODE

       -- Oracle Text leftovers
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE XDB.XDB_DATASTORE_PROC');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PUBLIC SYNONYM DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PACKAGE XDB.DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE SYS.VALIDATE_CONTEXT');

       -- Open PDB\$SEED to READ WRITE mode (catcon put it into READY ONLY again)
       ALTER PLUGGABLE DATABASE PDB\$SEED CLOSE;
       ALTER PLUGGABLE DATABASE PDB\$SEED OPEN READ WRITE;

       ALTER SESSION SET CONTAINER=PDB\$SEED;

       -- Oracle Text leftovers
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE XDB.XDB_DATASTORE_PROC');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PUBLIC SYNONYM DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PACKAGE XDB.DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE SYS.VALIDATE_CONTEXT');

       ALTER SESSION SET CONTAINER=FREEPDB1;

       -- Oracle Text leftovers
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE XDB.XDB_DATASTORE_PROC');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PUBLIC SYNONYM DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PACKAGE XDB.DBMS_XDBT');
       exec DBMS_PDB.EXEC_AS_ORACLE_SCRIPT('DROP PROCEDURE SYS.VALIDATE_CONTEXT');

       exit;
EOF

  # End of SLIM image config
  fi;

  #######################################################
  ################# Shrink data files ###################
  #######################################################

  #######################################################
  # Clean additional DB components to shrink data files #
  #######################################################
  echo "BUILDER: Clean additional DB components to shrink data files"
  sqlplus -s / as sysdba <<EOF

     -- Exit on any error
     WHENEVER SQLERROR EXIT SQL.SQLCODE

     -- Create temporary tablespace to move objects
     CREATE TABLESPACE builder_temp DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/builder_temp.dbf' SIZE 100m;

     -- Clean up METASTYLESHEET LOBs sitting at the end of the SYSTEM tablespace
     ALTER TABLE metastylesheet MOVE LOB(stylesheet) STORE AS (TABLESPACE BUILDER_TEMP);
     ALTER TABLE metastylesheet MOVE LOB(stylesheet) STORE AS (TABLESPACE SYSTEM);

     -- Clean pdb_sync\$ table in CDB\$ROOT
     -- This is part of the REPLAY UPGRADE PDB feature that is not needed in REGULAR and SLIM
     TRUNCATE TABLE pdb_sync\$;
     ALTER INDEX i_pdbsync4 REBUILD;
     ALTER INDEX i_pdbsync3 REBUILD;
     ALTER INDEX i_pdbsync2 REBUILD;
     ALTER INDEX i_pdbsync1 REBUILD;

     -- Reinsert initial row to reinitialize replay counter, as found in \$ORACLE_HOME/rdbms/admin/dcore.bsq
     INSERT INTO pdb_sync\$(scnwrp, scnbas, ctime, name, opcode, flags, replay#)
        VALUES (0, 0, sysdate, 'PDB\$LASTREPLAY', -1, 0, 0);
     COMMIT;

     -- Clean up fed\$binds blocks at the end of SYSTEM tablespace
     ALTER TABLE fed\$binds MOVE TABLESPACE BUILDER_TEMP;
     ALTER INDEX i_fed_apps\$ REBUILD;
     ALTER INDEX i_fed_binds\$ REBUILD;
     ALTER TABLE fed\$binds MOVE TABLESPACE SYSTEM;

     -- Drop temporary tablespace
     DROP TABLESPACE builder_temp INCLUDING CONTENTS AND DATAFILES;

    exit;

EOF

  ############################
  # Shrink actual data files #
  ############################
  echo "BUILDER: Shrink actual data files"
  du -ah "${ORACLE_BASE}"/oradata/
  
  sqlplus -s / as sysdba << EOF

     -- Exit on any error
     WHENEVER SQLERROR EXIT SQL.SQLCODE

     ----------------------------
     -- Shrink SYSAUX tablespaces
     ----------------------------

     -- Create new temporary SYSAUX tablespace
     --CREATE TABLESPACE SYSAUX_TEMP DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/sysaux_temp.dbf'
     --SIZE 250M AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED;

     -- Move tables to temporary SYSAUX tablespace
     --#TODO
     --BEGIN
     --   FOR cur IN (SELECT  owner || '.' || table_name AS name FROM all_tables WHERE tablespace_name = 'SYSAUX') LOOP
     --      EXECUTE IMMEDIATE 'ALTER TABLE ' || cur.name || ' MOVE TABLESPACE SYSAUX_TEMP';
     --   END LOOP;
     --END;
     --/

     -- CDB
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/sysaux01.dbf' RESIZE ${SYSAUX_SIZE_CDB}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/sysaux01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- SEED
     ALTER SESSION SET CONTAINER=PDB\$SEED;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/sysaux01.dbf' RESIZE ${SYSAUX_SIZE_SEED}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/sysaux01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- FREEPDB1
     ALTER SESSION SET CONTAINER=FREEPDB1;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/sysaux01.dbf' RESIZE ${SYSAUX_SIZE_PDB}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/sysaux01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     ALTER SESSION SET CONTAINER=CDB\$ROOT;

     ----------------------------
     -- Shrink SYSTEM tablespaces
     ----------------------------

     -- CDB
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/system01.dbf' RESIZE ${SYSTEM_SIZE_CDB}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/system01.dbf'
     AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- SEED
     ALTER SESSION SET CONTAINER=PDB\$SEED;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/system01.dbf' RESIZE ${SYSTEM_SIZE_SEED}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/system01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- FREEPDB1
     ALTER SESSION SET CONTAINER=FREEPDB1;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/system01.dbf' RESIZE ${SYSTEM_SIZE_PDB}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/system01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     ALTER SESSION SET CONTAINER=CDB\$ROOT;

     --------------------------
     -- Shrink TEMP tablespaces
     --------------------------

     -- CDB
     ALTER TABLESPACE TEMP SHRINK SPACE;
     ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/temp01.dbf' RESIZE ${TEMP_SIZE}M;
     ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/temp01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     
     -- SEED
     -- ALTER SESSION SET CONTAINER=PDB\$SEED;
     -- ALTER TABLESPACE TEMP SHRINK SPACE;
     -- ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/temp01.dbf' RESIZE ${TEMP_SIZE}M;
     -- ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/temp01.dbf'
     --    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- FREEPDB1
     ALTER SESSION SET CONTAINER=FREEPDB1;
     ALTER TABLESPACE TEMP SHRINK SPACE;
     ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/temp01.dbf' RESIZE ${TEMP_SIZE}M;
     ALTER DATABASE TEMPFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/temp01.dbf'
        AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     ALTER SESSION SET CONTAINER=CDB\$ROOT;

     ----------------------------
     -- Shrink USERS tablespaces
     ----------------------------

     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/users01.dbf' RESIZE ${USERS_SIZE}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/users01.dbf'
     AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     ALTER SESSION SET CONTAINER=FREEPDB1;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/users01.dbf' RESIZE ${USERS_SIZE}M;
     ALTER DATABASE DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/users01.dbf'
     AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     ALTER SESSION SET CONTAINER=CDB\$ROOT;

     ----------------------------
     -- Shrink UNDO tablespaces
     ----------------------------

     -- Create new temporary UNDO tablespace
     CREATE UNDO TABLESPACE UNDO_TMP DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/undotbs_tmp.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use new temporary UNDO tablespace (so that old one can be deleted)
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDO_TMP';

     -- Delete old UNDO tablespace
     DROP TABLESPACE UNDOTBS1 INCLUDING CONTENTS AND DATAFILES;

     -- Recreate old UNDO tablespace with 1M size and AUTOEXTEND
     CREATE UNDO TABLESPACE UNDOTBS1 DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/undotbs01.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use newly created UNDO tablespace
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDOTBS1';

     -- Drop temporary UNDO tablespace
     DROP TABLESPACE UNDO_TMP INCLUDING CONTENTS AND DATAFILES;

     --------------------------------------
     ALTER SESSION SET CONTAINER=PDB\$SEED;
     --------------------------------------

     -- Create new temporary UNDO tablespace
     CREATE UNDO TABLESPACE UNDO_TMP DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/undotbs_tmp.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use new temporary UNDO tablespace (so that old one can be deleted)
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDO_TMP';

     -- Delete old UNDO tablespace
     DROP TABLESPACE UNDOTBS1 INCLUDING CONTENTS AND DATAFILES;

     -- Recreate old UNDO tablespace with 1M size and AUTOEXTEND
     CREATE UNDO TABLESPACE UNDOTBS1 DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/pdbseed/undotbs01.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use newly created UNDO tablespace
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDOTBS1';

     -- Drop temporary UNDO tablespace
     DROP TABLESPACE UNDO_TMP INCLUDING CONTENTS AND DATAFILES;

     -----------------------------------
     ALTER SESSION SET CONTAINER=FREEPDB1;
     -----------------------------------

     -- Create new temporary UNDO tablespace
     CREATE UNDO TABLESPACE UNDO_TMP DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/undotbs_tmp.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use new temporary UNDO tablespace (so that old one can be deleted)
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDO_TMP';
     ALTER SYSTEM CHECKPOINT;

     -- Delete old UNDO tablespace
     DROP TABLESPACE UNDOTBS1 INCLUDING CONTENTS AND DATAFILES;

     -- Recreate old UNDO tablespace with 1M size and AUTOEXTEND
     CREATE UNDO TABLESPACE UNDOTBS1 DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/FREEPDB1/undotbs01.dbf'
        SIZE 1M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

     -- Use newly created UNDO tablespace
     ALTER SYSTEM SET UNDO_TABLESPACE='UNDOTBS1';
     ALTER SYSTEM CHECKPOINT;

     -- Drop temporary UNDO tablespace
     DROP TABLESPACE UNDO_TMP INCLUDING CONTENTS AND DATAFILES;

     ---------------------------------
     -- Shrink REDO log files
     ---------------------------------

     ALTER SESSION SET CONTAINER=CDB\$ROOT;

     -- Remove original redo logs and create new ones
     ALTER DATABASE ADD LOGFILE GROUP 4 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo04.log') SIZE ${REDO_SIZE}M;
     ALTER DATABASE ADD LOGFILE GROUP 5 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo05.log') SIZE ${REDO_SIZE}M;
     ALTER DATABASE ADD LOGFILE GROUP 6 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo06.log') SIZE ${REDO_SIZE}M;
     ALTER SYSTEM SWITCH LOGFILE;
     ALTER SYSTEM SWITCH LOGFILE;
     ALTER SYSTEM SWITCH LOGFILE;
     ALTER SYSTEM CHECKPOINT;
     ALTER DATABASE DROP LOGFILE GROUP 1;
     ALTER DATABASE DROP LOGFILE GROUP 2;
     ALTER DATABASE DROP LOGFILE GROUP 3;
     HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo03.log
     ALTER DATABASE ADD LOGFILE GROUP 1 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo01.log') SIZE ${REDO_SIZE}M REUSE;
     ALTER DATABASE ADD LOGFILE GROUP 2 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo02.log') SIZE ${REDO_SIZE}M REUSE;
     ALTER SYSTEM SWITCH LOGFILE;
     ALTER SYSTEM SWITCH LOGFILE;
     ALTER SYSTEM CHECKPOINT;
     ALTER DATABASE DROP LOGFILE GROUP 4;
     HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo04.log
     ALTER DATABASE DROP LOGFILE GROUP 5;
     HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo05.log
     ALTER DATABASE DROP LOGFILE GROUP 6;
     HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo06.log

     exit;
EOF

  # Close PDB\$SEED to READ ONLY again
  echo "BUILDER: Opening PDB\$SEED in READ ONLY (default) mode"
  sqlplus -s / as sysdba << EOF

     -- Exit on any errors
     WHENEVER SQLERROR EXIT SQL.SQLCODE

     -- Open PDB\$SEED to READ WRITE mode
     ALTER PLUGGABLE DATABASE PDB\$SEED CLOSE;
     ALTER PLUGGABLE DATABASE PDB\$SEED OPEN READ ONLY;

     exit;
EOF

fi;

###################################
########### DB SHUTDOWN ###########
###################################

echo "BUILDER: graceful database shutdown"

# Shutdown database gracefully
sqlplus -s / as sysdba << EOF

   -- Exit on any errors
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   -- Shutdown database gracefully
   SHUTDOWN IMMEDIATE;

   exit;
EOF

# Stop listener
lsnrctl stop

###############################
### Compress Database files ###
###############################

echo "BUILDER: compressing database data files"
rm -f "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/pdbseed/temp01*.dbf
du -ah "${ORACLE_BASE}"/oradata/

cd "${ORACLE_BASE}"/oradata
7zzs a "${ORACLE_SID}".7z "${ORACLE_SID}"
chown oracle:dba "${ORACLE_SID}".7z
mv "${ORACLE_SID}".7z "${ORACLE_BASE}"/
# Delete database files but not directory structure,
# that way external mount can mount just a sub directory
find "${ORACLE_SID}" -type f -exec rm "{}" \;
cd - 1> /dev/null

########################
### Install run file ###
########################

echo "BUILDER: install operational files"

# Move operational files to ${ORACLE_BASE}
mv $INSTALL_DIR/container-entrypoint.sh "${ORACLE_BASE}"/
mv $INSTALL_DIR/healthcheck.sh "${ORACLE_BASE}"/
mv $INSTALL_DIR/resetPassword "${ORACLE_BASE}"/
mv $INSTALL_DIR/createAppUser "${ORACLE_BASE}"/

chown oracle:dba "${ORACLE_BASE}"/*.sh \
                 "${ORACLE_BASE}"/resetPassword \
                 "${ORACLE_BASE}"/createAppUser

chmod u+x "${ORACLE_BASE}"/*.sh \
          "${ORACLE_BASE}"/resetPassword \
          "${ORACLE_BASE}"/createAppUser

#########################
####### Cleanup #########
#########################

echo "BUILDER: cleanup"

# Remove SYS audit directories and files created during install
rm -rf "${ORACLE_BASE}"/audit/"${ORACLE_SID}"/*

# Remove Data Pump files
rm -r "${ORACLE_BASE}"/admin/"${ORACLE_SID}"/dpdump/*

# Remove Oracle DB install logs
rm -rf "${ORACLE_BASE}"/admin/"${ORACLE_SID}"/adump/*
rm -rf "${ORACLE_BASE}"/cfgtoollogs/dbca/"${ORACLE_SID}"/*
rm -rf "${ORACLE_BASE}"/cfgtoollogs/*
rm -rf "${ORACLE_HOME}"/cfgtoollogs/*
rm -rf "${ORACLE_BASE}"/oraInventory/logs/*
rm -rf "${ORACLE_HOME}"/log/*
rm -rf "${ORACLE_HOME}"/rdbms/log/*

# Remove diag files
rm -rf "${ORACLE_BASE}"/diag/clients/*
rm -rf "${ORACLE_BASE}"/diag/rdbms/*
rm -rf "${ORACLE_BASE}"/diag/tnslsnr/*

# Remove log4j-containing ndmserver.ear
#rm "${ORACLE_HOME}"/md/jlib/ndmserver.ear*

# Remove additional files for NOMRAL and SLIM builds
if [ "${BUILD_MODE}" == "REGULAR" ] || [ "${BUILD_MODE}" == "SLIM" ]; then

  echo "BUILDER: further cleanup for REGULAR and SLIM image"

  # Remove OPatch and QOpatch
  rm -r "${ORACLE_HOME}"/OPatch
  rm -r "${ORACLE_HOME}"/QOpatch

  # Remove assistants
  rm -r "${ORACLE_HOME}"/assistants

  # Remove inventory directory
  rm -r "${ORACLE_HOME}"/inventory

  # Remove JDBC drivers
  rm -r "${ORACLE_HOME}"/jdbc
  rm -r "${ORACLE_HOME}"/jlib

  # Remove lib/*.jar files
  rm "${ORACLE_HOME}"/lib/*.jar

  # Remove unnecessary timezone information
  rm    "${ORACLE_HOME}"/oracore/zoneinfo/readme.txt
  rm    "${ORACLE_HOME}"/oracore/zoneinfo/timezdif.csv
  rm -r "${ORACLE_HOME}"/oracore/zoneinfo/big
  rm -r "${ORACLE_HOME}"/oracore/zoneinfo/little
  rm    "${ORACLE_HOME}"/oracore/zoneinfo/timezone*
  mv    "${ORACLE_HOME}"/oracore/zoneinfo/timezlrg_32.dat "${ORACLE_HOME}"/oracore/zoneinfo/current.dat
  rm    "${ORACLE_HOME}"/oracore/zoneinfo/timezlrg*
  mv    "${ORACLE_HOME}"/oracore/zoneinfo/current.dat "${ORACLE_HOME}"/oracore/zoneinfo/timezlrg_32.dat

  # Remove Multimedia
  rm -r "${ORACLE_HOME}"/ord/im

  # Remove Oracle XDK
  rm -r "${ORACLE_HOME}"/xdk

  # Remove JServer JAVA Virtual Machine
  rm -r  "${ORACLE_HOME}"/javavm

  # Remove Java JDK
  rm -r "${ORACLE_HOME}"/jdk

  # Remove rdbms/jlib
  rm -r "${ORACLE_HOME}"/rdbms/jlib

  # Remove OLAP
  rm -r "${ORACLE_HOME}"/olap
  rm "${ORACLE_HOME}"/lib/libolapapi19.so

  # Remove Cluster Ready Services
  rm -r "${ORACLE_HOME}"/crs

  # Remove Cluster Verification Utility (CVU)
  rm -r "${ORACLE_HOME}"/cv

  # Remove everything in install directory except orabasetab (needed for read-only homes)
  mv "${ORACLE_HOME}"/install/orabasetab "${ORACLE_HOME}"/
  rm -r "${ORACLE_HOME}"/install/*
  mv "${ORACLE_HOME}"/orabasetab "${ORACLE_HOME}"/install/

  # Remove network/jlib directory
  rm -r "${ORACLE_HOME}"/network/jlib

  # Remove network/tools directory
  rm -r "${ORACLE_HOME}"/network/tools

  # Remove opmn directory
  rm -r "${ORACLE_HOME}"/opmn

  # Remove unnecessary binaries (see http://yong321.freeshell.org/computer/oraclebin.html)
  rm "${ORACLE_HOME}"/bin/acfs*       # ACFS File system components
  rm "${ORACLE_HOME}"/bin/adrci       # Automatic Diagnostic Repository Command Interpreter
  rm "${ORACLE_HOME}"/bin/agtctl      # Multi-Threaded extproc agent control utility
  rm "${ORACLE_HOME}"/bin/afd*        # ASM Filter Drive components
  rm "${ORACLE_HOME}"/bin/amdu        # ASM Disk Utility
  rm "${ORACLE_HOME}"/bin/dg4*        # Database Gateway
  rm "${ORACLE_HOME}"/bin/dgmgrl      # Data Guard Manager CLI
  rm "${ORACLE_HOME}"/bin/orion       # ORacle IO Numbers benchmark tool
  rm "${ORACLE_HOME}"/bin/proc        # Pro*C/C++ Precompiler
  rm "${ORACLE_HOME}"/bin/procob      # Pro COBOL Precompiler
  rm "${ORACLE_HOME}"/bin/renamedg    # Rename Disk Group binary

  # Replace `orabase` with static path shell script
  echo 'echo ${ORACLE_BASE}' > ${ORACLE_HOME}/bin/orabase

  # Replace `orabasehome` with static path shell script
  echo 'echo ${ORACLE_BASE_HOME}' > ${ORACLE_HOME}/bin/orabasehome

  # Replace `orabaseconfig` with static path shell script
  echo 'echo ${ORACLE_BASE_CONFIG}' > ${ORACLE_HOME}/bin/orabaseconfig

  # Remove unnecessary libraries
  rm "${ORACLE_HOME}"/lib/libopc.so   # Oracle Public Cloud
  rm "${ORACLE_HOME}"/lib/libosbws.so # Oracle Secure Backup Cloud Module
  rm "${ORACLE_HOME}"/lib/libra.so    # Recovery Appliance

  # Remove components from ORACLE_HOME
  if [ "${BUILD_MODE}" == "SLIM" ]; then

    echo "BUILDER: further cleanup for SLIM image"

    # Remove Oracle Text directory
    rm -r "${ORACLE_HOME}"/ctx
    rm "${ORACLE_HOME}"/bin/ctx*        # Oracle Text binaries

    # Remove demo directory
    rm -r "${ORACLE_HOME}"/demo

    # Remove ODBC samples
    rm -r "${ORACLE_HOME}"/odbc

    # Remove TNS samples
    rm -r "${ORACLE_HOME}"/network/admin/samples

    # Remove NLS LBuilder
    rm -r "${ORACLE_HOME}"/nls/lbuilder

    # Remove hs directory
    rm -r "${ORACLE_HOME}"/hs

    # DO NOT remove ldap directory.
    # Some message files (mesg/*.msb) are needed for ALTER USER ... IDENTIFIED BY
    # TODO: Clean up not needed ldap files
    #rm -r "${ORACLE_HOME}"/ldap

    # Remove precomp directory
    rm -r "${ORACLE_HOME}"/precomp

    # Remove rdbms/public directory
    rm -r "${ORACLE_HOME}"/rdbms/public

    # Remove rdbms/jlib directory
    rm -r "${ORACLE_HOME}"/rdbms/xml

    # Remove Spatial
    rm -r "${ORACLE_HOME}"/md

    # Remove ord directory
    rm -r "${ORACLE_HOME}"/ord

    # Remove Oracle R
    rm -r "${ORACLE_HOME}"/R

    # Remove deinstall directory
    rm -r "${ORACLE_HOME}"/deinstall

    # Remove Oracle Universal Installer
    rm -r "${ORACLE_HOME}"/oui

    # Remove Perl
    rm -r "${ORACLE_HOME}"/perl

    # Remove unnecessary binaries
    rm "${ORACLE_HOME}"/bin/cursize    # Cursor Size binary
    rm "${ORACLE_HOME}"/bin/dbfs*      # DataBase File System
    rm "${ORACLE_HOME}"/bin/ORE        # Oracle R Enterprise
    rm "${ORACLE_HOME}"/bin/rman       # Oracle Recovery Manager
    rm "${ORACLE_HOME}"/bin/wrap       # PL/SQL Wrapper

    # Remove unnecessary libraries
    rm "${ORACLE_HOME}"/lib/asm*       # Oracle Automatic Storage Management
    rm "${ORACLE_HOME}"/lib/ore.so     # Oracle R Enterprise

  fi;

fi;
